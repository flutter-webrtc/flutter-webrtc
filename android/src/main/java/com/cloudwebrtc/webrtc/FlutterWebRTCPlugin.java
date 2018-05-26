package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Context;
import android.hardware.Camera;
import android.util.Log;
import android.util.SparseArray;
import java.util.*;

import org.webrtc.AudioTrack;
import org.webrtc.EglBase;
import org.webrtc.IceCandidate;
import org.webrtc.Logging;
import org.webrtc.MediaConstraints;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.SdpObserver;
import org.webrtc.SessionDescription;
import org.webrtc.VideoRenderer;
import org.webrtc.VideoTrack;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * WebrtcPlugin
 */
public class FlutterWebRTCPlugin implements MethodCallHandler {

  static public final String TAG = "FlutterWebRTCPlugin";

  private final Registrar registrar;
  private final MethodChannel channel;

  private Map<String, PeerConnection> peerConnectionMap;
  public  Map<String, MediaStream> localStreams;
  public Map<String, MediaStreamTrack> localTracks;
  private Map<String, VideoRenderer> renders;

  private final SparseArray<PeerConnectionObserver> mPeerConnectionObservers;

  /**
   * The implementation of {@code getUserMedia} extracted into a separate file
   * in order to reduce complexity and to (somewhat) separate concerns.
   */
  private GetUserMediaImpl getUserMediaImpl;

  EventChannel.EventSink nativeToDartEventSink;
  final PeerConnectionFactory mFactory;


  public Activity getActivity() {
    return registrar.activity();
  }

  public Context getContext() {
    return registrar.context();
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "cloudwebrtc.com/WebRTC.Method");
    channel.setMethodCallHandler(new FlutterWebRTCPlugin(registrar,channel));
  }

  private FlutterWebRTCPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;

    mPeerConnectionObservers = new SparseArray<PeerConnectionObserver>();
    localStreams = new HashMap<String, MediaStream>();
    localTracks = new HashMap<String, MediaStreamTrack>();

    //PeerConnectionFactory.initializeAndroidGlobals(reactContext, true, true, true);

    PeerConnectionFactory.initialize(
            PeerConnectionFactory.InitializationOptions.builder(registrar.context())
                    .setEnableInternalTracer(false)
                    .setEnableVideoHwAcceleration(true)
                    .createInitializationOptions());

    mFactory = new PeerConnectionFactory(null);
    // Initialize EGL contexts required for HW acceleration.
    EglBase.Context eglContext = EglUtils.getRootEglBaseContext();
    if (eglContext != null) {
      mFactory.setVideoHwAccelerationOptions(eglContext, eglContext);
    }

    getUserMediaImpl = new GetUserMediaImpl(this, registrar.context());
    /*
    String peerConnectionId = "xxxxx";
    EventChannel eventChannel =
            new EventChannel(
                    registrar.messenger(), "cloudwebrtc.com/WebRTC/peerConnectoinEvent" + peerConnectionId);

    eventChannel.setStreamHandler(
            new EventChannel.StreamHandler() {
              @Override
              public void onListen(Object o, EventChannel.EventSink sink) {
                nativeToDartEventSink = sink;
              }

              @Override
              public void onCancel(Object o) {
                nativeToDartEventSink = null;
              }
            });

    Map<String, Object> event = new HashMap<>();
    event.put("event", "onInit");
    event.put("duration", 111);
    event.put("width", 222);
    event.put("height", 333);
    nativeToDartEventSink.success(event);
    */
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getUserMedia")) {
      Map<String, Object> constraints = call.argument("constraints");
      MediaStream mediaStream = null;
        ConstraintsMap constraintsMap = new ConstraintsMap(constraints);
      getUserMediaImpl.getUserMedia(constraintsMap, result, mediaStream);
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } if (call.method.equals("createOffer")) {

      Map<String, Object> constraints = call.argument("constraints");

      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }else {
      result.notImplemented();
    }
  }

  private PeerConnection getPeerConnection(int id) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
    return (pco == null) ? null : pco.getPeerConnection();
  }

  void sendEvent(String eventName,  ConstraintsMap params) {
    Map<String, Object> event = new HashMap<>();
    event.put("event", eventName);
    event.put("body", params.toMap());
    nativeToDartEventSink.success(event);
  }

  private List<PeerConnection.IceServer> createIceServers(ConstraintsArray iceServersArray) {
    final int size = (iceServersArray == null) ? 0 : iceServersArray.size();
    List<PeerConnection.IceServer> iceServers = new ArrayList<>(size);
    for (int i = 0; i < size; i++) {
       ConstraintsMap iceServerMap = iceServersArray.getMap(i);
      boolean hasUsernameAndCredential = iceServerMap.hasKey("username") && iceServerMap.hasKey("credential");
      if (iceServerMap.hasKey("url")) {
        if (hasUsernameAndCredential) {
          iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("url"), iceServerMap.getString("username"), iceServerMap.getString("credential")));
        } else {
          iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("url")));
        }
      } else if (iceServerMap.hasKey("urls")) {
        switch (iceServerMap.getType("urls")) {
          case String:
            if (hasUsernameAndCredential) {
              iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("urls"), iceServerMap.getString("username"), iceServerMap.getString("credential")));
            } else {
              iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("urls")));
            }
            break;
          case Array:
            ConstraintsArray urls = iceServerMap.getArray("urls");
            for (int j = 0; j < urls.size(); j++) {
              String url = urls.getString(j);
              if (hasUsernameAndCredential) {
                iceServers.add(new PeerConnection.IceServer(url,iceServerMap.getString("username"), iceServerMap.getString("credential")));
              } else {
                iceServers.add(new PeerConnection.IceServer(url));
              }
            }
            break;
        }
      }
    }
    return iceServers;
  }

  private PeerConnection.RTCConfiguration parseRTCConfiguration(ConstraintsMap map) {
    ConstraintsArray iceServersArray = null;
    if (map != null) {
      iceServersArray = map.getArray("iceServers");
    }
    List<PeerConnection.IceServer> iceServers = createIceServers(iceServersArray);
    PeerConnection.RTCConfiguration conf = new PeerConnection.RTCConfiguration(iceServers);
    if (map == null) {
      return conf;
    }

    // iceTransportPolicy (public api)
    if (map.hasKey("iceTransportPolicy")
            && map.getType("iceTransportPolicy") == ObjectType.String) {
      final String v = map.getString("iceTransportPolicy");
      if (v != null) {
        switch (v) {
          case "all": // public
            conf.iceTransportsType = PeerConnection.IceTransportsType.ALL;
            break;
          case "relay": // public
            conf.iceTransportsType = PeerConnection.IceTransportsType.RELAY;
            break;
          case "nohost":
            conf.iceTransportsType = PeerConnection.IceTransportsType.NOHOST;
            break;
          case "none":
            conf.iceTransportsType = PeerConnection.IceTransportsType.NONE;
            break;
        }
      }
    }

    // bundlePolicy (public api)
    if (map.hasKey("bundlePolicy")
            && map.getType("bundlePolicy") == ObjectType.String) {
      final String v = map.getString("bundlePolicy");
      if (v != null) {
        switch (v) {
          case "balanced": // public
            conf.bundlePolicy = PeerConnection.BundlePolicy.BALANCED;
            break;
          case "max-compat": // public
            conf.bundlePolicy = PeerConnection.BundlePolicy.MAXCOMPAT;
            break;
          case "max-bundle": // public
            conf.bundlePolicy = PeerConnection.BundlePolicy.MAXBUNDLE;
            break;
        }
      }
    }

    // rtcpMuxPolicy (public api)
    if (map.hasKey("rtcpMuxPolicy")
            && map.getType("rtcpMuxPolicy") == ObjectType.String) {
      final String v = map.getString("rtcpMuxPolicy");
      if (v != null) {
        switch (v) {
          case "negotiate": // public
            conf.rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.NEGOTIATE;
            break;
          case "require": // public
            conf.rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.REQUIRE;
            break;
        }
      }
    }

    // FIXME: peerIdentity of type DOMString (public api)
    // FIXME: certificates of type sequence<RTCCertificate> (public api)

    // iceCandidatePoolSize of type unsigned short, defaulting to 0
    if (map.hasKey("iceCandidatePoolSize")
            && map.getType("iceCandidatePoolSize") == ObjectType.Number) {
      final int v = map.getInt("iceCandidatePoolSize");
      if (v > 0) {
        conf.iceCandidatePoolSize = v;
      }
    }

    // === below is private api in webrtc ===

    // tcpCandidatePolicy (private api)
    if (map.hasKey("tcpCandidatePolicy")
            && map.getType("tcpCandidatePolicy") == ObjectType.String) {
      final String v = map.getString("tcpCandidatePolicy");
      if (v != null) {
        switch (v) {
          case "enabled":
            conf.tcpCandidatePolicy = PeerConnection.TcpCandidatePolicy.ENABLED;
            break;
          case "disabled":
            conf.tcpCandidatePolicy = PeerConnection.TcpCandidatePolicy.DISABLED;
            break;
        }
      }
    }

    // candidateNetworkPolicy (private api)
    if (map.hasKey("candidateNetworkPolicy")
            && map.getType("candidateNetworkPolicy") == ObjectType.String) {
      final String v = map.getString("candidateNetworkPolicy");
      if (v != null) {
        switch (v) {
          case "all":
            conf.candidateNetworkPolicy = PeerConnection.CandidateNetworkPolicy.ALL;
            break;
          case "low_cost":
            conf.candidateNetworkPolicy = PeerConnection.CandidateNetworkPolicy.LOW_COST;
            break;
        }
      }
    }

    // KeyType (private api)
    if (map.hasKey("keyType")
            && map.getType("keyType") == ObjectType.String) {
      final String v = map.getString("keyType");
      if (v != null) {
        switch (v) {
          case "RSA":
            conf.keyType = PeerConnection.KeyType.RSA;
            break;
          case "ECDSA":
            conf.keyType = PeerConnection.KeyType.ECDSA;
            break;
        }
      }
    }

    // continualGatheringPolicy (private api)
    if (map.hasKey("continualGatheringPolicy")
            && map.getType("continualGatheringPolicy") == ObjectType.String) {
      final String v = map.getString("continualGatheringPolicy");
      if (v != null) {
        switch (v) {
          case "gather_once":
            conf.continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_ONCE;
            break;
          case "gather_continually":
            conf.continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY;
            break;
        }
      }
    }

    // audioJitterBufferMaxPackets (private api)
    if (map.hasKey("audioJitterBufferMaxPackets")
            && map.getType("audioJitterBufferMaxPackets") == ObjectType.Number) {
      final int v = map.getInt("audioJitterBufferMaxPackets");
      if (v > 0) {
        conf.audioJitterBufferMaxPackets = v;
      }
    }

    // iceConnectionReceivingTimeout (private api)
    if (map.hasKey("iceConnectionReceivingTimeout")
            && map.getType("iceConnectionReceivingTimeout") == ObjectType.Number) {
      final int v = map.getInt("iceConnectionReceivingTimeout");
      conf.iceConnectionReceivingTimeout = v;
    }

    // iceBackupCandidatePairPingInterval (private api)
    if (map.hasKey("iceBackupCandidatePairPingInterval")
            && map.getType("iceBackupCandidatePairPingInterval") == ObjectType.Number) {
      final int v = map.getInt("iceBackupCandidatePairPingInterval");
      conf.iceBackupCandidatePairPingInterval = v;
    }

    // audioJitterBufferFastAccelerate (private api)
    if (map.hasKey("audioJitterBufferFastAccelerate")
            && map.getType("audioJitterBufferFastAccelerate") == ObjectType.Boolean) {
      final boolean v = map.getBoolean("audioJitterBufferFastAccelerate");
      conf.audioJitterBufferFastAccelerate = v;
    }

    // pruneTurnPorts (private api)
    if (map.hasKey("pruneTurnPorts")
            && map.getType("pruneTurnPorts") == ObjectType.Boolean) {
      final boolean v = map.getBoolean("pruneTurnPorts");
      conf.pruneTurnPorts = v;
    }

    // presumeWritableWhenFullyRelayed (private api)
    if (map.hasKey("presumeWritableWhenFullyRelayed")
            && map.getType("presumeWritableWhenFullyRelayed") == ObjectType.Boolean) {
      final boolean v = map.getBoolean("presumeWritableWhenFullyRelayed");
      conf.presumeWritableWhenFullyRelayed = v;
    }

    return conf;
  }

  public void peerConnectionInit(
          ConstraintsMap configuration,
          ConstraintsMap constraints,
          int id) {
    PeerConnectionObserver observer = new PeerConnectionObserver(this, id);
    PeerConnection peerConnection
            = mFactory.createPeerConnection(
            parseRTCConfiguration(configuration),
            parseMediaConstraints(constraints),
            observer);

    observer.setPeerConnection(peerConnection);
    mPeerConnectionObservers.put(id, observer);
  }

  String getNextStreamUUID() {
    String uuid;

    do {
      uuid = UUID.randomUUID().toString();
    } while (getStreamForReactTag(uuid) != null);

    return uuid;
  }

  String getNextTrackUUID() {
    String uuid;

    do {
      uuid = UUID.randomUUID().toString();
    } while (getTrackForId(uuid) != null);

    return uuid;
  }

  MediaStream getStreamForReactTag(String streamReactTag) {
    MediaStream stream = localStreams.get(streamReactTag);

    if (stream == null) {
      for (int i = 0, size = mPeerConnectionObservers.size();
           i < size;
           i++) {
        PeerConnectionObserver pco
                = mPeerConnectionObservers.valueAt(i);
        stream = pco.remoteStreams.get(streamReactTag);
        if (stream != null) {
          break;
        }
      }
    }

    return stream;
  }

  private MediaStreamTrack getTrackForId(String trackId) {
    MediaStreamTrack track = localTracks.get(trackId);

    if (track == null) {
      for (int i = 0, size = mPeerConnectionObservers.size();
           i < size;
           i++) {
        PeerConnectionObserver pco
                = mPeerConnectionObservers.valueAt(i);
        track = pco.remoteTracks.get(trackId);
        if (track != null) {
          break;
        }
      }
    }

    return track;
  }

  /**
   * Parses a constraint set specified in the form of a JavaScript object into
   * a specific <tt>List</tt> of <tt>MediaConstraints.KeyValuePair</tt>s.
   *
   * @param src The constraint set in the form of a JavaScript object to
   * parse.
   * @param dst The <tt>List</tt> of <tt>MediaConstraints.KeyValuePair</tt>s
   * into which the specified <tt>src</tt> is to be parsed.
   */
  private void parseConstraints(
          ConstraintsMap src,
          List<MediaConstraints.KeyValuePair> dst) {

      for (Map.Entry<String, Object> entry : src.toMap().entrySet()) {
          dst.add(new MediaConstraints.KeyValuePair(entry.getKey(), (String)entry.getValue()));
          System.out.println("Key = " + entry.getKey() + ", Value = " + entry.getValue());
      }
  }

  /**
   * Parses mandatory and optional "GUM" constraints described by a specific
   * <tt>ConstraintsMap</tt>.
   *
   * @param constraints A <tt>ConstraintsMap</tt> which represents a JavaScript
   * object specifying the constraints to be parsed into a
   * <tt>MediaConstraints</tt> instance.
   * @return A new <tt>MediaConstraints</tt> instance initialized with the
   * mandatory and optional constraint keys and values specified by
   * <tt>constraints</tt>.
   */
  MediaConstraints parseMediaConstraints(ConstraintsMap constraints) {
    MediaConstraints mediaConstraints = new MediaConstraints();

    if (constraints.hasKey("mandatory")
            && constraints.getType("mandatory") == ObjectType.Map) {
      parseConstraints(constraints.getMap("mandatory"),
              mediaConstraints.mandatory);
    } else {
      Log.d(TAG, "mandatory constraints are not a map");
    }

    if (constraints.hasKey("optional")
            && constraints.getType("optional") ==  ObjectType.Array) {
       ConstraintsArray optional = constraints.getArray("optional");

      for (int i = 0, size = optional.size(); i < size; i++) {
        if (optional.getType(i) == ObjectType.Map) {
          parseConstraints(
                  optional.getMap(i),
                  mediaConstraints.optional);
        }
      }
    } else {
      Log.d(TAG, "optional constraints are not an array");
    }

    return mediaConstraints;
  }

  public void getUserMedia(ConstraintsMap constraints, Result result) {
    String streamId = getNextStreamUUID();
    MediaStream mediaStream = mFactory.createLocalMediaStream(streamId);

    if (mediaStream == null) {
      // XXX The following does not follow the getUserMedia() algorithm
      // specified by
      // https://www.w3.org/TR/mediacapture-streams/#dom-mediadevices-getusermedia
      // with respect to distinguishing the various causes of failure.
      result.error(
              /* type */ "getUserMediaFailed",
              "Failed to create new media stream", null);
      return;
    }

    getUserMediaImpl.getUserMedia(constraints, result, mediaStream);
  }

  public void getImageMedia(ConstraintsMap constraints, Result result) {
    String streamId = getNextStreamUUID();
    MediaStream mediaStream = mFactory.createLocalMediaStream(streamId);

    if (mediaStream == null) {
      // XXX The following does not follow the getUserMedia() algorithm
      // specified by
      // https://www.w3.org/TR/mediacapture-streams/#dom-mediadevices-getusermedia
      // with respect to distinguishing the various causes of failure.

      result.error(
              /* type */ "getImageMedia",
              "Failed to create new media stream", null);
      return;
    }

    getUserMediaImpl.getImageMedia(constraints, result, mediaStream);
  }

  public void mediaStreamTrackGetSources(Result promise){
    ConstraintsArray array = new ConstraintsArray();
    String[] names = new String[Camera.getNumberOfCameras()];

    for(int i = 0; i < Camera.getNumberOfCameras(); ++i) {
      ConstraintsMap info = getCameraInfo(i);
      if (info != null) {
        array.pushMap(info);
      }
    }

    ConstraintsMap audio = new ConstraintsMap();
    audio.putString("label", "Audio");
    audio.putString("deviceId", "audio-1");
    audio.putString("facing", "");
    audio.putString("kind", "audioinput");

    array.pushMap(audio);
    promise.success(array);
  }

  public void mediaStreamTrackStop(final String id) {
    // Is this functionality equivalent to `mediaStreamTrackRelease()` ?
    // if so, we should merge this two and remove track from stream as well.
    MediaStreamTrack track = localTracks.get(id);
    if (track == null) {
      Log.d(TAG, "mediaStreamTrackStop() track is null");
      return;
    }
    track.setEnabled(false);
    if (track.kind().equals("video")) {
      getUserMediaImpl.removeVideoCapturer(id);
    }
    localTracks.remove(id);
    // What exactly does `detached` mean in doc?
    // see: https://www.w3.org/TR/mediacapture-streams/#track-detached
  }

  public void mediaStreamTrackSetEnabled(final String id, final boolean enabled) {
    MediaStreamTrack track = localTracks.get(id);
    if (track == null) {
      Log.d(TAG, "mediaStreamTrackSetEnabled() track is null");
      return;
    } else if (track.enabled() == enabled) {
      return;
    }
    track.setEnabled(enabled);
  }

  public void mediaStreamTrackSwitchCamera(final String id) {
    MediaStreamTrack track = localTracks.get(id);
    if (track != null) {
      getUserMediaImpl.switchCamera(id);
    }
  }

  public void mediaStreamTrackPutImage(final String id, final String base64_image) {
    MediaStreamTrack track = localTracks.get(id);
    if (track != null) {
      getUserMediaImpl.putImage(id, base64_image);
    }
  }

  public void mediaStreamTrackRelease(final String streamId, final String _trackId) {
    MediaStream stream = localStreams.get(streamId);
    if (stream == null) {
      Log.d(TAG, "mediaStreamTrackRelease() stream is null");
      return;
    }
    MediaStreamTrack track = localTracks.get(_trackId);
    if (track == null) {
      Log.d(TAG, "mediaStreamTrackRelease() track is null");
      return;
    }
    track.setEnabled(false); // should we do this?
    localTracks.remove(_trackId);
    if (track.kind().equals("audio")) {
      stream.removeTrack((AudioTrack)track);
    } else if (track.kind().equals("video")) {
      stream.removeTrack((VideoTrack)track);
      getUserMediaImpl.removeVideoCapturer(_trackId);
    }
  }

  public ConstraintsMap getCameraInfo(int index) {
    Camera.CameraInfo info = new Camera.CameraInfo();

    try {
      Camera.getCameraInfo(index, info);
    } catch (Exception e) {
      Logging.e("CameraEnumerationAndroid", "getCameraInfo failed on index " + index, e);
      return null;
    }
    ConstraintsMap params = new ConstraintsMap();
    String facing = info.facing == 1 ? "front" : "back";
    params.putString("label", "Camera " + index + ", Facing " + facing + ", Orientation " + info.orientation);
    params.putString("deviceId", "" + index);
    params.putString("facing", facing);
    params.putString("kind", "videoinput");

    return params;
  }

  private MediaConstraints defaultConstraints() {
    MediaConstraints constraints = new MediaConstraints();
    // TODO video media
    constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
    constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"));
    constraints.optional.add(new MediaConstraints.KeyValuePair("DtlsSrtpKeyAgreement", "true"));
    return constraints;
  }

  public void peerConnectionSetConfiguration(ConstraintsMap configuration, final int id) {
    PeerConnection peerConnection = getPeerConnection(id);
    if (peerConnection == null) {
      Log.d(TAG, "peerConnectionSetConfiguration() peerConnection is null");
      return;
    }
    peerConnection.setConfiguration(parseRTCConfiguration(configuration));
  }

  public void peerConnectionAddStream(final String streamId, final int id){
    MediaStream mediaStream = localStreams.get(streamId);
    if (mediaStream == null) {
      Log.d(TAG, "peerConnectionAddStream() mediaStream is null");
      return;
    }
    PeerConnection peerConnection = getPeerConnection(id);
    if (peerConnection != null) {
      boolean result = peerConnection.addStream(mediaStream);
      Log.d(TAG, "addStream" + result);
    } else {
      Log.d(TAG, "peerConnectionAddStream() peerConnection is null");
    }
  }

  public void peerConnectionRemoveStream(final String streamId, final int id){
    MediaStream mediaStream = localStreams.get(streamId);
    if (mediaStream == null) {
      Log.d(TAG, "peerConnectionRemoveStream() mediaStream is null");
      return;
    }
    PeerConnection peerConnection = getPeerConnection(id);
    if (peerConnection != null) {
      peerConnection.removeStream(mediaStream);
    } else {
      Log.d(TAG, "peerConnectionRemoveStream() peerConnection is null");
    }
  }

  public void peerConnectionCreateOffer(
          int id,
          ConstraintsMap constraints,
          final Result promise) {
    PeerConnection peerConnection = getPeerConnection(id);

    if (peerConnection != null) {
      peerConnection.createOffer(new SdpObserver() {
        @Override
        public void onCreateFailure(String s) {
          promise.error("WEBRTC_CREATE_OFFER_ERROR", s, null);
        }

        @Override
        public void onCreateSuccess(final SessionDescription sdp) {
          ConstraintsMap params =  new ConstraintsMap();
          params.putString("sdp", sdp.description);
          params.putString("type", sdp.type.canonicalForm());
          promise.success(params);
        }

        @Override
        public void onSetFailure(String s) {}

        @Override
        public void onSetSuccess() {}
      }, parseMediaConstraints(constraints));
    } else {
      Log.d(TAG, "peerConnectionCreateOffer() peerConnection is null");
      promise.error("WEBRTC_CREATE_OFFER_ERROR", "peerConnection is null", null);
    }
  }

  public void peerConnectionCreateAnswer(
          int id,
          ConstraintsMap constraints,
          final Result promise) {
    PeerConnection peerConnection = getPeerConnection(id);

    if (peerConnection != null) {
      peerConnection.createAnswer(new SdpObserver() {
        @Override
        public void onCreateFailure(String s) {
          promise.error("WEBRTC_CREATE_ANSWER_ERROR", s, null);
        }

        @Override
        public void onCreateSuccess(final SessionDescription sdp) {
          ConstraintsMap params = new ConstraintsMap();
          params.putString("sdp", sdp.description);
          params.putString("type", sdp.type.canonicalForm());
          promise.success(params);
        }

        @Override
        public void onSetFailure(String s) {}

        @Override
        public void onSetSuccess() {}
      }, parseMediaConstraints(constraints));
    } else {
      Log.d(TAG, "peerConnectionCreateAnswer() peerConnection is null");
      promise.error("WEBRTC_CREATE_ANSWER_ERROR", "peerConnection is null", null);
    }
  }

  public void peerConnectionSetLocalDescription(ConstraintsMap sdpMap, final int id, final Result promise) {
    PeerConnection peerConnection = getPeerConnection(id);

    Log.d(TAG, "peerConnectionSetLocalDescription() start");
    if (peerConnection != null) {
      SessionDescription sdp = new SessionDescription(
              SessionDescription.Type.fromCanonicalForm(sdpMap.getString("type")),
              sdpMap.getString("sdp")
      );

      peerConnection.setLocalDescription(new SdpObserver() {
        @Override
        public void onCreateSuccess(final SessionDescription sdp) {
        }

        @Override
        public void onSetSuccess() {
          promise.success(null);
        }

        @Override
        public void onCreateFailure(String s) {
        }

        @Override
        public void onSetFailure(String s) {
          promise.error("WEBRTC_SET_LOCAL_DESCRIPTION_ERROR", s, null);
        }
      }, sdp);
    } else {
      Log.d(TAG, "peerConnectionSetLocalDescription() peerConnection is null");
      promise.error("WEBRTC_SET_LOCAL_DESCRIPTION_ERROR", "peerConnection is null", null);
    }
    Log.d(TAG, "peerConnectionSetLocalDescription() end");
  }

  public void peerConnectionSetRemoteDescription(final ConstraintsMap sdpMap, final int id, final Result promise) {
    PeerConnection peerConnection = getPeerConnection(id);
    // final String d = sdpMap.getString("type");

    Log.d(TAG, "peerConnectionSetRemoteDescription() start");
    if (peerConnection != null) {
      SessionDescription sdp = new SessionDescription(
              SessionDescription.Type.fromCanonicalForm(sdpMap.getString("type")),
              sdpMap.getString("sdp")
      );

      peerConnection.setRemoteDescription(new SdpObserver() {
        @Override
        public void onCreateSuccess(final SessionDescription sdp) {
        }

        @Override
        public void onSetSuccess() {
          promise.success(null);
        }

        @Override
        public void onCreateFailure(String s) {
        }

        @Override
        public void onSetFailure(String s) {
          promise.error("WEBRTC_SET_REMOTE_DESCRIPTION_ERROR", s, null);
        }
      }, sdp);
    } else {
      Log.d(TAG, "peerConnectionSetRemoteDescription() peerConnection is null");
      promise.error("WEBRTC_SET_REMOTE_DESCRIPTION_ERROR", "peerConnection is null", null);
    }
    Log.d(TAG, "peerConnectionSetRemoteDescription() end");
  }

  public void peerConnectionAddICECandidate(ConstraintsMap candidateMap, final int id, final Result promise) {
    boolean result = false;
    PeerConnection peerConnection = getPeerConnection(id);
    Log.d(TAG, "peerConnectionAddICECandidate() start");
    if (peerConnection != null) {
      IceCandidate candidate = new IceCandidate(
              candidateMap.getString("sdpMid"),
              candidateMap.getInt("sdpMLineIndex"),
              candidateMap.getString("candidate")
      );
      result = peerConnection.addIceCandidate(candidate);
    } else {
      Log.d(TAG, "peerConnectionAddICECandidate() peerConnection is null");
    }
    promise.success(result);
    Log.d(TAG, "peerConnectionAddICECandidate() end");
  }

  public void peerConnectionGetStats(String trackId, int id, final Result promise) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
    if (pco == null || pco.getPeerConnection() == null) {
      Log.d(TAG, "peerConnectionGetStats() peerConnection is null");
    } else {
      pco.getStats(trackId, promise);
    }
  }

  public void peerConnectionClose(final int id) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
    if (pco == null || pco.getPeerConnection() == null) {
      Log.d(TAG, "peerConnectionClose() peerConnection is null");
    } else {
      pco.close();
      mPeerConnectionObservers.remove(id);
    }
  }

  public void mediaStreamRelease(final String id) {
    MediaStream mediaStream = localStreams.get(id);
    if (mediaStream != null) {
      for (VideoTrack track : mediaStream.videoTracks) {
        localTracks.remove(track.id());
        getUserMediaImpl.removeVideoCapturer(track.id());
      }
      for (AudioTrack track : mediaStream.audioTracks) {
        localTracks.remove(track.id());
      }
      localStreams.remove(id);
    } else {
      Log.d(TAG, "mediaStreamRelease() mediaStream is null");
    }
  }

  public void createDataChannel(final int peerConnectionId, String label, ConstraintsMap config) {
    // Forward to PeerConnectionObserver which deals with DataChannels
    // because DataChannel is owned by PeerConnection.
    PeerConnectionObserver pco
            = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      Log.d(TAG, "createDataChannel() peerConnection is null");
    } else {
      pco.createDataChannel(label, config);
    }
  }

  public void dataChannelSend(int peerConnectionId, int dataChannelId, String data, String type) {
    // Forward to PeerConnectionObserver which deals with DataChannels
    // because DataChannel is owned by PeerConnection.
    PeerConnectionObserver pco
            = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      Log.d(TAG, "dataChannelSend() peerConnection is null");
    } else {
      pco.dataChannelSend(dataChannelId, data, type);
    }
  }

  public void dataChannelClose(int peerConnectionId, int dataChannelId) {
    // Forward to PeerConnectionObserver which deals with DataChannels
    // because DataChannel is owned by PeerConnection.
    PeerConnectionObserver pco
            = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      Log.d(TAG, "dataChannelClose() peerConnection is null");
    } else {
      pco.dataChannelClose(dataChannelId);
    }
  }
}
