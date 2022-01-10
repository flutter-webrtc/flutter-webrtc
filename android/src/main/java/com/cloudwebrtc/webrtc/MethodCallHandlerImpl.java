package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.util.Log;
import android.util.LongSparseArray;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.cloudwebrtc.webrtc.utils.AnyThreadResult;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;
import com.cloudwebrtc.webrtc.utils.MediaConstraintsUtils;
import com.cloudwebrtc.webrtc.utils.ObjectType;
import com.cloudwebrtc.webrtc.utils.RTCUtils;

import org.webrtc.AudioTrack;
import org.webrtc.CryptoOptions;
import org.webrtc.DefaultVideoDecoderFactory;
import org.webrtc.EglBase;
import org.webrtc.IceCandidate;
import org.webrtc.Logging;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnection.BundlePolicy;
import org.webrtc.PeerConnection.CandidateNetworkPolicy;
import org.webrtc.PeerConnection.ContinualGatheringPolicy;
import org.webrtc.PeerConnection.IceServer;
import org.webrtc.PeerConnection.IceServer.Builder;
import org.webrtc.PeerConnection.IceTransportsType;
import org.webrtc.PeerConnection.KeyType;
import org.webrtc.PeerConnection.RTCConfiguration;
import org.webrtc.PeerConnection.RtcpMuxPolicy;
import org.webrtc.PeerConnection.SdpSemantics;
import org.webrtc.PeerConnection.TcpCandidatePolicy;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.PeerConnectionFactory.InitializationOptions;
import org.webrtc.PeerConnectionFactory.Options;
import org.webrtc.SdpObserver;
import org.webrtc.SessionDescription;
import org.webrtc.SessionDescription.Type;
import org.webrtc.VideoTrack;
import org.webrtc.audio.JavaAudioDeviceModule;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.UUID;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.TextureRegistry;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;

public class MethodCallHandlerImpl implements MethodCallHandler, StateProvider {
  interface AudioManager {

    void onAudioManagerRequested(boolean requested);

    void setMicrophoneMute(boolean mute);

    void setSpeakerphoneOn(boolean on);
  }

  private static final String TAG = "FlutterWebRTCPlugin";

  private final Map<String, PeerConnectionObserver> mPeerConnectionObservers = new HashMap<>();
  private final BinaryMessenger messenger;
  private final Context context;
  private final TextureRegistry textures;

  private PeerConnectionFactory mFactory;

  private final Map<String, MediaStream> localStreams = new HashMap<>();

  private final LongSparseArray<FlutterRTCVideoRenderer> renderers = new LongSparseArray<>();

  /**
   * The implementation of {@code getUserMedia} extracted into a separate file in order to reduce
   * complexity and to (somewhat) separate concerns.
   */
  private GetUserMediaImpl getUserMediaImpl;

  @NonNull
  private final AudioManager audioManager;

  private Activity activity;

  MethodCallHandlerImpl(Context context, BinaryMessenger messenger, TextureRegistry textureRegistry,
                        @NonNull AudioManager audioManager) {
    this.context = context;
    this.textures = textureRegistry;
    this.messenger = messenger;
    this.audioManager = audioManager;
  }

  private static void resultError(String method, String error, @NonNull Result result) {
    String errorMsg = method + "(): " + error;
    result.error(method, errorMsg, null);
    Log.d(TAG, errorMsg);
  }

  void dispose() {
    mPeerConnectionObservers.clear();
  }

  private void ensureInitialized() {
    if (mFactory != null) {
      return;
    }

    PeerConnectionFactory.initialize(
            InitializationOptions.builder(context)
                    .setEnableInternalTracer(true)
                    .createInitializationOptions());

    // Initialize EGL contexts required for HW acceleration.
    EglBase.Context eglContext = EglUtils.getRootEglBaseContext();

    getUserMediaImpl = new GetUserMediaImpl(this, context);

    JavaAudioDeviceModule audioDeviceModule = JavaAudioDeviceModule.builder(context)
            .setUseHardwareAcousticEchoCanceler(true)
            .setUseHardwareNoiseSuppressor(true)
            .createAudioDeviceModule();

    mFactory = PeerConnectionFactory.builder()
            .setOptions(new Options())
            .setVideoEncoderFactory(new SimulcastVideoEncoderFactoryWrapper(eglContext, true, false))
            .setVideoDecoderFactory(new DefaultVideoDecoderFactory(eglContext))
            .setAudioDeviceModule(audioDeviceModule)
            .createPeerConnectionFactory();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result notSafeResult) {
    ensureInitialized();

    final AnyThreadResult result = new AnyThreadResult(notSafeResult);
    switch (call.method) {
      case "createPeerConnection": {
        Map<String, Object> constraints = call.argument("constraints");
        Map<String, Object> configuration = call.argument("configuration");
        String peerConnectionId = peerConnectionInit(new ConstraintsMap(configuration),
                new ConstraintsMap(constraints));
        ConstraintsMap res = new ConstraintsMap();
        res.putString("peerConnectionId", peerConnectionId);
        result.success(res.toMap());
        break;
      }
      case "getUserMedia": {
        Map<String, Object> constraints = call.argument("constraints");
        ConstraintsMap constraintsMap = new ConstraintsMap(constraints);
        getUserMedia(constraintsMap, result);
        break;
      }
      case "createLocalMediaStream":
        createLocalMediaStream(result);
        break;
      case "getSources":
        getSources(result);
        break;
      case "createOffer": {
        String peerConnectionId = call.argument("peerConnectionId");
        Map<String, Object> constraints = call.argument("constraints");
        peerConnectionCreateOffer(peerConnectionId, new ConstraintsMap(constraints), result);
        break;
      }
      case "createAnswer": {
        String peerConnectionId = call.argument("peerConnectionId");
        Map<String, Object> constraints = call.argument("constraints");
        peerConnectionCreateAnswer(peerConnectionId, new ConstraintsMap(constraints), result);
        break;
      }
      case "mediaStreamGetTracks": {
        String streamId = call.argument("streamId");
        MediaStream stream = localStreams.get(streamId);
        Map<String, Object> resultMap = new HashMap<>();
        List<Object> audioTracks = new ArrayList<>();
        List<Object> videoTracks = new ArrayList<>();
        for (AudioTrack track : stream.audioTracks) {
          Map<String, Object> trackMap = new HashMap<>();
          trackMap.put("enabled", track.enabled());
          trackMap.put("id", track.id());
          trackMap.put("kind", track.kind());
          trackMap.put("label", track.id());
          trackMap.put("remote", false);
          audioTracks.add(trackMap);
        }
        for (VideoTrack track : stream.videoTracks) {
          Map<String, Object> trackMap = new HashMap<>();
          trackMap.put("enabled", track.enabled());
          trackMap.put("id", track.id());
          trackMap.put("kind", track.kind());
          trackMap.put("label", track.id());
          trackMap.put("remote", false);
          videoTracks.add(trackMap);
        }
        resultMap.put("audioTracks", audioTracks);
        resultMap.put("videoTracks", videoTracks);
        result.success(resultMap);
        break;
      }
      case "setLocalDescription": {
        String peerConnectionId = call.argument("peerConnectionId");
        Map<String, Object> description = call.argument("description");
        peerConnectionSetLocalDescription(new ConstraintsMap(description), peerConnectionId,
                result);
        break;
      }
      case "setRemoteDescription": {
        String peerConnectionId = call.argument("peerConnectionId");
        Map<String, Object> description = call.argument("description");
        peerConnectionSetRemoteDescription(new ConstraintsMap(description), peerConnectionId,
                result);
        break;
      }
      case "addCandidate": {
        String peerConnectionId = call.argument("peerConnectionId");
        Map<String, Object> candidate = call.argument("candidate");
        peerConnectionAddICECandidate(new ConstraintsMap(candidate), peerConnectionId, result);
        break;
      }
      case "getStats": {
        String peerConnectionId = call.argument("peerConnectionId");
        String trackId = call.argument("trackId");
        peerConnectionGetStats(trackId, peerConnectionId, result);
        break;
      }
      case "streamDispose": {
        String streamId = call.argument("streamId");
        mediaStreamRelease(streamId);
        result.success(null);
        break;
      }
      case "mediaStreamTrackSetEnable": {
        String trackId = call.argument("trackId");
        Boolean enabled = call.argument("enabled");
        mediaStreamTrackSetEnabled(trackId, enabled);
        result.success(null);
        break;
      }
      case "mediaStreamAddTrack": {
        String streamId = call.argument("streamId");
        String trackId = call.argument("trackId");
        mediaStreamAddTrack(streamId, trackId, result);
        for (int i = 0; i < renderers.size(); i++) {
          FlutterRTCVideoRenderer renderer = renderers.get(i);
          if (renderer.checkMediaStream(streamId)) {
            renderer.setVideoTrack((VideoTrack) getLocalTrack(trackId));
          }
        }
        break;
      }
      case "mediaStreamRemoveTrack": {
        String streamId = call.argument("streamId");
        String trackId = call.argument("trackId");
        mediaStreamRemoveTrack(streamId, trackId, result);
        for (int i = 0; i < renderers.size(); i++) {
          FlutterRTCVideoRenderer renderer = renderers.get(i);
          if (renderer.checkVideoTrack(trackId)) {
            renderer.setVideoTrack(null);
          }
        }
        break;
      }
      case "trackDispose": {
        // TODO (evdokimovs): Implement MediaStreamTracks disposing in
        //                    the "Implement missing flutter_webrtc APIs" PR
        // String trackId = call.argument("trackId");

        result.success(null);
        break;
      }
      case "peerConnectionClose": {
        String peerConnectionId = call.argument("peerConnectionId");
        peerConnectionClose(peerConnectionId);
        result.success(null);
        break;
      }
      case "peerConnectionDispose": {
        String peerConnectionId = call.argument("peerConnectionId");
        peerConnectionDispose(peerConnectionId);
        result.success(null);
        break;
      }
      case "createVideoRenderer": {
        SurfaceTextureEntry entry = textures.createSurfaceTexture();
        SurfaceTexture surfaceTexture = entry.surfaceTexture();
        FlutterRTCVideoRenderer render = new FlutterRTCVideoRenderer(surfaceTexture, entry);
        renderers.put(entry.id(), render);

        EventChannel eventChannel =
                new EventChannel(
                        messenger,
                        "FlutterWebRTC/Texture" + entry.id());

        eventChannel.setStreamHandler(render);
        render.setEventChannel(eventChannel);
        render.setId((int) entry.id());

        ConstraintsMap params = new ConstraintsMap();
        params.putInt("textureId", (int) entry.id());
        result.success(params.toMap());
        break;
      }
      case "videoRendererDispose": {
        int textureId = call.argument("textureId");
        FlutterRTCVideoRenderer render = renderers.get(textureId);
        if (render == null) {
          resultError("videoRendererDispose", "render [" + textureId + "] not found !", result);
          return;
        }
        render.Dispose();
        renderers.delete(textureId);
        result.success(null);
        break;
      }
      case "videoRendererSetSrcObject": {
        int textureId = call.argument("textureId");
        String streamId = call.argument("streamId");
        FlutterRTCVideoRenderer render = renderers.get(textureId);
        if (render == null) {
          resultError("videoRendererSetSrcObject", "render [" + textureId + "] not found !", result);
          return;
        }

        render.setStream(localStreams.get(streamId));

        result.success(null);
        break;
      }
      case "mediaStreamTrackHasTorch": {
        String trackId = call.argument("trackId");
        getUserMediaImpl.hasTorch(trackId, result);
        break;
      }
      case "mediaStreamTrackSetTorch": {
        String trackId = call.argument("trackId");
        boolean torch = call.argument("torch");
        getUserMediaImpl.setTorch(trackId, torch, result);
        break;
      }
      case "mediaStreamTrackSwitchCamera": {
        String trackId = call.argument("trackId");
        getUserMediaImpl.switchCamera(trackId, result);
        break;
      }
      case "setVolume": {
        String trackId = call.argument("trackId");
        double volume = call.argument("volume");
        mediaStreamTrackSetVolume(trackId, volume);
        result.success(null);
        break;
      }
      case "setMicrophoneMute":
        boolean mute = call.argument("mute");
        audioManager.setMicrophoneMute(mute);
        result.success(null);
        break;
      case "enableSpeakerphone":
        boolean enable = call.argument("enable");
        audioManager.setSpeakerphoneOn(enable);
        result.success(null);
        break;
      case "getLocalDescription": {
        String peerConnectionId = call.argument("peerConnectionId");
        PeerConnection peerConnection = getPeerConnection(peerConnectionId);
        if (peerConnection != null) {
          SessionDescription sdp = peerConnection.getLocalDescription();
          ConstraintsMap params = new ConstraintsMap();
          params.putString("sdp", sdp.description);
          params.putString("type", sdp.type.canonicalForm());
          result.success(params.toMap());
        } else {
          resultError("getLocalDescription", "peerConnection is nulll", result);
        }
        break;
      }
      case "getRemoteDescription": {
        String peerConnectionId = call.argument("peerConnectionId");
        PeerConnection peerConnection = getPeerConnection(peerConnectionId);
        if (peerConnection != null) {
          SessionDescription sdp = peerConnection.getRemoteDescription();
          if (null == sdp) {
            result.success(null);
          } else {
            ConstraintsMap params = new ConstraintsMap();
            params.putString("sdp", sdp.description);
            params.putString("type", sdp.type.canonicalForm());
            result.success(params.toMap());
          }
        } else {
          resultError("getRemoteDescription", "peerConnection is null", result);
        }
        break;
      }
      case "setConfiguration": {
        String peerConnectionId = call.argument("peerConnectionId");
        Map<String, Object> configuration = call.argument("configuration");
        PeerConnection peerConnection = getPeerConnection(peerConnectionId);
        if (peerConnection != null) {
          peerConnectionSetConfiguration(new ConstraintsMap(configuration), peerConnection);
          result.success(null);
        } else {
          resultError("setConfiguration", "peerConnection is null", result);
        }
        break;
      }
      case "addTrack": {
        String peerConnectionId = call.argument("peerConnectionId");
        String trackId = call.argument("trackId");
        List<String> streamIds = call.argument("streamIds");
        addTrack(peerConnectionId, trackId, streamIds, result);
        break;
      }
      case "removeTrack": {
        String peerConnectionId = call.argument("peerConnectionId");
        String senderId = call.argument("senderId");
        removeTrack(peerConnectionId, senderId, result);
        break;
      }
      case "addTransceiver": {
        String peerConnectionId = call.argument("peerConnectionId");
        Map<String, Object> transceiverInit = call.argument("transceiverInit");
        if (call.hasArgument("trackId")) {
          String trackId = call.argument("trackId");
          addTransceiver(peerConnectionId, trackId, transceiverInit, result);
        } else if (call.hasArgument("mediaType")) {
          String mediaType = call.argument("mediaType");
          addTransceiverOfType(peerConnectionId, mediaType, transceiverInit, result);
        } else {
          resultError("addTransceiver", "Incomplete parameters", result);
        }
        break;
      }
      case "rtpTransceiverSetDirection": {
        String peerConnectionId = call.argument("peerConnectionId");
        String direction = call.argument("direction");
        int transceiverId = call.argument("transceiverId");
        rtpTransceiverSetDirection(peerConnectionId, direction, transceiverId, result);
        break;
      }
      case "rtpTransceiverGetMid": {
        String peerConnectionId = call.argument("peerConnectionId");
        int transceiverId = call.argument("transceiverId");
        rtpTransceiverGetMid(peerConnectionId, transceiverId, result);
        break;
      }
      case "rtpTransceiverGetDirection": {
        String peerConnectionId = call.argument("peerConnectionId");
        int transceiverId = call.argument("transceiverId");
        rtpTransceiverGetDirection(peerConnectionId, transceiverId, result);
        break;
      }
      case "rtpTransceiverGetCurrentDirection": {
        String peerConnectionId = call.argument("peerConnectionId");
        int transceiverId = call.argument("transceiverId");
        rtpTransceiverGetCurrentDirection(peerConnectionId, transceiverId, result);
        break;
      }
      case "rtpTransceiverStop": {
        String peerConnectionId = call.argument("peerConnectionId");
        int transceiverId = call.argument("transceiverId");
        rtpTransceiverStop(peerConnectionId, transceiverId, result);
        break;
      }
      case "rtpSenderSetParameters": {
        String peerConnectionId = call.argument("peerConnectionId");
        String rtpSenderId = call.argument("rtpSenderId");
        Map<String, Object> parameters = call.argument("parameters");
        rtpSenderSetParameters(peerConnectionId, rtpSenderId, parameters, result);
        break;
      }
      case "rtpSenderReplaceTrack": {
        String peerConnectionId = call.argument("peerConnectionId");
        String rtpSenderId = call.argument("rtpSenderId");
        String trackId = call.argument("trackId");
        rtpSenderSetTrack(peerConnectionId, rtpSenderId, trackId, true, result);
        break;
      }
      case "rtpSenderSetTrack": {
        String peerConnectionId = call.argument("peerConnectionId");
        String rtpSenderId = call.argument("rtpSenderId");
        String trackId = call.argument("trackId");
        rtpSenderSetTrack(peerConnectionId, rtpSenderId, trackId, false, result);
        break;
      }
      case "rtpSenderDispose": {
        String peerConnectionId = call.argument("peerConnectionId");
        String rtpSenderId = call.argument("rtpSenderId");
        rtpSenderDispose(peerConnectionId, rtpSenderId, result);
        break;
      }
      case "getSenders": {
        String peerConnectionId = call.argument("peerConnectionId");
        getSenders(peerConnectionId, result);
        break;
      }
      case "getReceivers": {
        String peerConnectionId = call.argument("peerConnectionId");
        getReceivers(peerConnectionId, result);
        break;
      }
      case "getTransceivers": {
        String peerConnectionId = call.argument("peerConnectionId");
        getTransceivers(peerConnectionId, result);
        break;
      }
      default:
        result.notImplemented();
        break;
    }
  }

  @Nullable
  private PeerConnection getPeerConnection(String id) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
    return (pco == null) ? null : pco.getPeerConnection();
  }

  @NonNull
  private List<IceServer> createIceServers(@Nullable ConstraintsArray iceServersArray) {
    final int size = (iceServersArray == null) ? 0 : iceServersArray.size();
    List<IceServer> iceServers = new ArrayList<>(size);
    for (int i = 0; i < size; i++) {
      ConstraintsMap iceServerMap = iceServersArray.getMap(i);
      boolean hasUsernameAndCredential =
              iceServerMap.hasKey("username") && iceServerMap.hasKey("credential");
      if (iceServerMap.hasKey("url")) {
        if (hasUsernameAndCredential) {
          iceServers.add(IceServer.builder(iceServerMap.getString("url"))
                  .setUsername(iceServerMap.getString("username"))
                  .setPassword(iceServerMap.getString("credential")).createIceServer());
        } else {
          iceServers.add(
                  IceServer.builder(iceServerMap.getString("url")).createIceServer());
        }
      } else if (iceServerMap.hasKey("urls")) {
        switch (iceServerMap.getType("urls")) {
          case String:
            if (hasUsernameAndCredential) {
              iceServers.add(IceServer.builder(iceServerMap.getString("urls"))
                      .setUsername(iceServerMap.getString("username"))
                      .setPassword(iceServerMap.getString("credential")).createIceServer());
            } else {
              iceServers.add(IceServer.builder(iceServerMap.getString("urls"))
                      .createIceServer());
            }
            break;
          case Array:
            ConstraintsArray urls = iceServerMap.getArray("urls");
            List<String> urlsList = new ArrayList<>();

            for (int j = 0; j < urls.size(); j++) {
              urlsList.add(urls.getString(j));
            }

            Builder builder = IceServer.builder(urlsList);

            if (hasUsernameAndCredential) {
              builder
                      .setUsername(iceServerMap.getString("username"))
                      .setPassword(iceServerMap.getString("credential"));
            }

            iceServers.add(builder.createIceServer());

            break;
        }
      }
    }
    return iceServers;
  }

  @NonNull
  private RTCConfiguration parseRTCConfiguration(@Nullable ConstraintsMap map) {
    ConstraintsArray iceServersArray = null;
    if (map != null) {
      iceServersArray = map.getArray("iceServers");
    }
    List<IceServer> iceServers = createIceServers(iceServersArray);
    RTCConfiguration conf = new RTCConfiguration(iceServers);
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
            conf.iceTransportsType = IceTransportsType.ALL;
            break;
          case "relay": // public
            conf.iceTransportsType = IceTransportsType.RELAY;
            break;
          case "nohost":
            conf.iceTransportsType = IceTransportsType.NOHOST;
            break;
          case "none":
            conf.iceTransportsType = IceTransportsType.NONE;
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
            conf.bundlePolicy = BundlePolicy.BALANCED;
            break;
          case "max-compat": // public
            conf.bundlePolicy = BundlePolicy.MAXCOMPAT;
            break;
          case "max-bundle": // public
            conf.bundlePolicy = BundlePolicy.MAXBUNDLE;
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
            conf.rtcpMuxPolicy = RtcpMuxPolicy.NEGOTIATE;
            break;
          case "require": // public
            conf.rtcpMuxPolicy = RtcpMuxPolicy.REQUIRE;
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

    // sdpSemantics
    if (map.hasKey("sdpSemantics")
            && map.getType("sdpSemantics") == ObjectType.String) {
      final String v = map.getString("sdpSemantics");
      if (v != null) {
        switch (v) {
          case "plan-b":
            conf.sdpSemantics = SdpSemantics.PLAN_B;
            break;
          case "unified-plan":
            conf.sdpSemantics = SdpSemantics.UNIFIED_PLAN;
            break;
        }
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
            conf.tcpCandidatePolicy = TcpCandidatePolicy.ENABLED;
            break;
          case "disabled":
            conf.tcpCandidatePolicy = TcpCandidatePolicy.DISABLED;
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
            conf.candidateNetworkPolicy = CandidateNetworkPolicy.ALL;
            break;
          case "low_cost":
            conf.candidateNetworkPolicy = CandidateNetworkPolicy.LOW_COST;
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
            conf.keyType = KeyType.RSA;
            break;
          case "ECDSA":
            conf.keyType = KeyType.ECDSA;
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
            conf.continualGatheringPolicy = ContinualGatheringPolicy.GATHER_ONCE;
            break;
          case "gather_continually":
            conf.continualGatheringPolicy = ContinualGatheringPolicy.GATHER_CONTINUALLY;
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
      conf.iceConnectionReceivingTimeout = map.getInt("iceConnectionReceivingTimeout");
    }

    // iceBackupCandidatePairPingInterval (private api)
    if (map.hasKey("iceBackupCandidatePairPingInterval")
            && map.getType("iceBackupCandidatePairPingInterval") == ObjectType.Number) {
      conf.iceBackupCandidatePairPingInterval = map.getInt("iceBackupCandidatePairPingInterval");
    }

    // audioJitterBufferFastAccelerate (private api)
    if (map.hasKey("audioJitterBufferFastAccelerate")
            && map.getType("audioJitterBufferFastAccelerate") == ObjectType.Boolean) {
      conf.audioJitterBufferFastAccelerate = map.getBoolean("audioJitterBufferFastAccelerate");
    }

    // pruneTurnPorts (private api)
    if (map.hasKey("pruneTurnPorts")
            && map.getType("pruneTurnPorts") == ObjectType.Boolean) {
      conf.pruneTurnPorts = map.getBoolean("pruneTurnPorts");
    }

    // presumeWritableWhenFullyRelayed (private api)
    if (map.hasKey("presumeWritableWhenFullyRelayed")
            && map.getType("presumeWritableWhenFullyRelayed") == ObjectType.Boolean) {
      conf.presumeWritableWhenFullyRelayed = map.getBoolean("presumeWritableWhenFullyRelayed");
    }
    // cryptoOptions
    if (map.hasKey("cryptoOptions")
            && map.getType("cryptoOptions") == ObjectType.Map) {
      final ConstraintsMap cryptoOptions = map.getMap("cryptoOptions");
      conf.cryptoOptions = CryptoOptions.builder()
              .setEnableGcmCryptoSuites(cryptoOptions.hasKey("enableGcmCryptoSuites") && cryptoOptions.getBoolean("enableGcmCryptoSuites"))
              .setRequireFrameEncryption(cryptoOptions.hasKey("requireFrameEncryption") && cryptoOptions.getBoolean("requireFrameEncryption"))
              .setEnableEncryptedRtpHeaderExtensions(cryptoOptions.hasKey("enableEncryptedRtpHeaderExtensions") && cryptoOptions.getBoolean("enableEncryptedRtpHeaderExtensions"))
              .setEnableAes128Sha1_32CryptoCipher(cryptoOptions.hasKey("enableAes128Sha1_32CryptoCipher") && cryptoOptions.getBoolean("enableAes128Sha1_32CryptoCipher"))
              .createCryptoOptions();
    }
    return conf;
  }

  private String peerConnectionInit(ConstraintsMap configuration, @NonNull ConstraintsMap constraints) {
    String peerConnectionId = getNextStreamUUID();
    RTCConfiguration conf = parseRTCConfiguration(configuration);
    PeerConnectionObserver observer = new PeerConnectionObserver(conf, this, messenger, peerConnectionId);
    PeerConnection peerConnection
            = mFactory.createPeerConnection(
            conf,
            MediaConstraintsUtils.parseMediaConstraints(constraints),
            observer);
    observer.setPeerConnection(peerConnection);
    if (mPeerConnectionObservers.isEmpty()) {
      audioManager.onAudioManagerRequested(true);
    }
    mPeerConnectionObservers.put(peerConnectionId, observer);
    return peerConnectionId;
  }

  @NonNull
  @Override
  public Map<String, MediaStream> getLocalStreams() {
    return localStreams;
  }

  @Override
  public String getNextStreamUUID() {
    String uuid;

    do {
      uuid = UUID.randomUUID().toString();
    } while (localStreams.containsKey(uuid));

    return uuid;
  }

  @Override
  public String getNextTrackUUID() {
    String uuid;

    do {
      uuid = UUID.randomUUID().toString();
    } while (getTrackForId(uuid) != null);

    return uuid;
  }

  @Override
  public PeerConnectionFactory getPeerConnectionFactory() {
    return mFactory;
  }

  @Nullable
  @Override
  public Activity getActivity() {
    return activity;
  }

  @Nullable
  @Override
  public Context getApplicationContext() {
    return context;
  }

  @Nullable
  private MediaStreamTrack getTrackForId(@NonNull String trackId) {
    MediaStreamTrack track = getLocalTrack(trackId);

    if (track == null) {
      for (Entry<String, PeerConnectionObserver> entry : mPeerConnectionObservers.entrySet()) {
        PeerConnectionObserver pco = entry.getValue();

        if (track == null) {
          track = pco.getTransceiversTrack(trackId);
        }

        if (track != null) {
          break;
        }
      }
    }

    return track;
  }


  private void getUserMedia(@NonNull ConstraintsMap constraints, @NonNull Result result) {
    String streamId = getNextStreamUUID();
    MediaStream mediaStream = mFactory.createLocalMediaStream(streamId);

    if (mediaStream == null) {
      // XXX The following does not follow the getUserMedia() algorithm
      // specified by
      // https://www.w3.org/TR/mediacapture-streams/#dom-mediadevices-getusermedia
      // with respect to distinguishing the various causes of failure.
      resultError("getUserMediaFailed", "Failed to create new media stream", result);
      return;
    }

    getUserMediaImpl.getUserMedia(constraints, result, mediaStream);
  }

  private void getSources(@NonNull Result result) {
    ConstraintsArray array = new ConstraintsArray();

    for (int i = 0; i < Camera.getNumberOfCameras(); ++i) {
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

    ConstraintsMap map = new ConstraintsMap();
    map.putArray("sources", array.toArrayList());

    result.success(map.toMap());
  }

  private void createLocalMediaStream(@NonNull Result result) {
    String streamId = getNextStreamUUID();
    MediaStream mediaStream = mFactory.createLocalMediaStream(streamId);
    localStreams.put(streamId, mediaStream);

    if (mediaStream == null) {
      resultError("createLocalMediaStream", "Failed to create new media stream", result);
      return;
    }
    Map<String, Object> resultMap = new HashMap<>();
    resultMap.put("streamId", mediaStream.getId());
    result.success(resultMap);
  }

  private void mediaStreamTrackSetEnabled(@NonNull final String id, final boolean enabled) {
    MediaStreamTrack track = getTrackForId(id);

    if (track == null) {
      Log.d(TAG, "mediaStreamTrackSetEnabled() track is null");
      return;
    } else if (track.enabled() == enabled) {
      return;
    }
    track.setEnabled(enabled);
  }

  @Nullable
  @Override
  public MediaStreamTrack getLocalTrack(@NonNull final String id) {
    for (MediaStream s : localStreams.values()) {
      for (MediaStreamTrack t : s.audioTracks) {
        if (t.id().equals(id)) {
          return t;
        }
      }
      for (MediaStreamTrack t : s.videoTracks) {
        if (t.id().equals(id)) {
          return t;
        }
      }
    }

    return null;
  }

  private void mediaStreamTrackSetVolume(@NonNull final String id, final double volume) {
    MediaStreamTrack track = getLocalTrack(id);
    if (track instanceof AudioTrack) {
      Log.d(TAG, "setVolume(): " + id + "," + volume);
      try {
        ((AudioTrack) track).setVolume(volume);
      } catch (Exception e) {
        Log.e(TAG, "setVolume(): error", e);
      }
    } else {
      Log.w(TAG, "setVolume(): track not found: " + id);
    }
  }

  private void mediaStreamAddTrack(final String streamId, @NonNull final String trackId, @NonNull Result result) {
    MediaStream mediaStream = localStreams.get(streamId);
    if (mediaStream != null) {
      MediaStreamTrack track = getTrackForId(trackId);
      if (track != null) {
        MediaStreamTrack clonedTrack = RTCUtils.cloneMediaStreamTrack(track);
        if (clonedTrack instanceof AudioTrack) {
          mediaStream.addTrack((AudioTrack) clonedTrack);
        } else if (clonedTrack instanceof VideoTrack) {
          mediaStream.addTrack((VideoTrack) clonedTrack);
        } else {
          resultError("mediaStreamAddTrack", "mediaStreamAddTrack() track [" + trackId + "] is not AudioTrack or VideoTrack", result);
        }
      } else {
        resultError("mediaStreamAddTrack", "mediaStreamAddTrack() track [" + trackId + "] is null", result);
      }
    } else {
      resultError("mediaStreamAddTrack", "mediaStreamAddTrack() stream [" + streamId + "] is null", result);
    }
    result.success(null);
  }

  private void mediaStreamRemoveTrack(final String streamId, @NonNull final String trackId, @NonNull Result result) {
    MediaStream mediaStream = localStreams.get(streamId);
    if (mediaStream != null) {
      MediaStreamTrack track = getLocalTrack(trackId);
      if (track != null) {
        if ("audio".equals(track.kind())) {
          mediaStream.removeTrack((AudioTrack) track);
        } else if ("video".equals(track.kind())) {
          mediaStream.removeTrack((VideoTrack) track);
        }
      } else {
        resultError("mediaStreamRemoveTrack", "mediaStreamAddTrack() track [" + trackId + "] is null", result);
      }
    } else {
      resultError("mediaStreamRemoveTrack", "mediaStreamAddTrack() stream [" + streamId + "] is null", result);
    }
    result.success(null);
  }

  @Nullable
  private ConstraintsMap getCameraInfo(int index) {
    CameraInfo info = new CameraInfo();

    try {
      Camera.getCameraInfo(index, info);
    } catch (Exception e) {
      Logging.e("CameraEnumerationAndroid", "getCameraInfo failed on index " + index, e);
      return null;
    }
    ConstraintsMap params = new ConstraintsMap();
    String facing = info.facing == 1 ? "front" : "back";
    params.putString("label",
            "Camera " + index + ", Facing " + facing + ", Orientation " + info.orientation);
    params.putString("deviceId", "" + index);
    params.putString("facing", facing);
    params.putString("kind", "videoinput");
    return params;
  }

  private void peerConnectionSetConfiguration(@NonNull ConstraintsMap configuration,
                                              @Nullable PeerConnection peerConnection) {
    if (peerConnection == null) {
      Log.d(TAG, "peerConnectionSetConfiguration() peerConnection is null");
      return;
    }
    peerConnection.setConfiguration(parseRTCConfiguration(configuration));
  }

  private void peerConnectionCreateOffer(
          @NonNull String id,
          @NonNull ConstraintsMap constraints,
          @NonNull final Result result) {
    PeerConnection peerConnection = getPeerConnection(id);

    if (peerConnection != null) {
      peerConnection.createOffer(new SdpObserver() {
        @Override
        public void onCreateFailure(String s) {
          resultError("peerConnectionCreateOffer", "WEBRTC_CREATE_OFFER_ERROR: " + s, result);
        }

        @Override
        public void onCreateSuccess(@NonNull final SessionDescription sdp) {
          ConstraintsMap params = new ConstraintsMap();
          params.putString("sdp", sdp.description);
          params.putString("type", sdp.type.canonicalForm());
          result.success(params.toMap());
        }

        @Override
        public void onSetFailure(String s) {
        }

        @Override
        public void onSetSuccess() {
        }
      }, MediaConstraintsUtils.parseMediaConstraints(constraints));
    } else {
      resultError("peerConnectionCreateOffer", "WEBRTC_CREATE_OFFER_ERROR", result);
    }
  }

  private void peerConnectionCreateAnswer(
          @NonNull String id,
          @NonNull ConstraintsMap constraints,
          @NonNull final Result result) {
    PeerConnection peerConnection = getPeerConnection(id);

    if (peerConnection != null) {
      peerConnection.createAnswer(new SdpObserver() {
        @Override
        public void onCreateFailure(String s) {
          resultError("peerConnectionCreateAnswer", "WEBRTC_CREATE_ANSWER_ERROR: " + s, result);
        }

        @Override
        public void onCreateSuccess(@NonNull final SessionDescription sdp) {
          ConstraintsMap params = new ConstraintsMap();
          params.putString("sdp", sdp.description);
          params.putString("type", sdp.type.canonicalForm());
          result.success(params.toMap());
        }

        @Override
        public void onSetFailure(String s) {
        }

        @Override
        public void onSetSuccess() {
        }
      }, MediaConstraintsUtils.parseMediaConstraints(constraints));
    } else {
      resultError("peerConnectionCreateAnswer", "peerConnection is null", result);
    }
  }

  private void peerConnectionSetLocalDescription(@NonNull ConstraintsMap sdpMap, @NonNull final String id,
                                                 @NonNull final Result result) {
    PeerConnection peerConnection = getPeerConnection(id);
    if (peerConnection != null) {
      SessionDescription sdp = new SessionDescription(
              Type.fromCanonicalForm(sdpMap.getString("type")),
              sdpMap.getString("sdp")
      );

      peerConnection.setLocalDescription(new SdpObserver() {
        @Override
        public void onCreateSuccess(final SessionDescription sdp) {
        }

        @Override
        public void onSetSuccess() {
          result.success(null);
        }

        @Override
        public void onCreateFailure(String s) {
        }

        @Override
        public void onSetFailure(String s) {
          resultError("peerConnectionSetLocalDescription", "WEBRTC_SET_LOCAL_DESCRIPTION_ERROR: " + s, result);
        }
      }, sdp);
    } else {
      resultError("peerConnectionSetLocalDescription", "WEBRTC_SET_LOCAL_DESCRIPTION_ERROR: peerConnection is null", result);
    }
  }

  private void peerConnectionSetRemoteDescription(@NonNull final ConstraintsMap sdpMap, @NonNull final String id,
                                                  @NonNull final Result result) {
    PeerConnection peerConnection = getPeerConnection(id);
    if (peerConnection != null) {
      SessionDescription sdp = new SessionDescription(
              Type.fromCanonicalForm(sdpMap.getString("type")),
              sdpMap.getString("sdp")
      );

      peerConnection.setRemoteDescription(new SdpObserver() {
        @Override
        public void onCreateSuccess(final SessionDescription sdp) {
        }

        @Override
        public void onSetSuccess() {
          result.success(null);
        }

        @Override
        public void onCreateFailure(String s) {
        }

        @Override
        public void onSetFailure(String s) {
          resultError("peerConnectionSetRemoteDescription", "WEBRTC_SET_REMOTE_DESCRIPTION_ERROR: " + s, result);
        }
      }, sdp);
    } else {
      resultError("peerConnectionSetRemoteDescription", "WEBRTC_SET_REMOTE_DESCRIPTION_ERROR: peerConnection is null", result);
    }
  }

  private void peerConnectionAddICECandidate(@NonNull ConstraintsMap candidateMap, @NonNull final String id,
                                             @NonNull final Result result) {
    boolean res = false;
    PeerConnection peerConnection = getPeerConnection(id);
    if (peerConnection != null) {
      IceCandidate candidate = new IceCandidate(
              candidateMap.getString("sdpMid"),
              candidateMap.getInt("sdpMLineIndex"),
              candidateMap.getString("candidate")
      );
      res = peerConnection.addIceCandidate(candidate);
    } else {
      resultError("peerConnectionAddICECandidate", "peerConnection is null", result);
    }
    result.success(res);
  }

  private void peerConnectionGetStats(@NonNull String trackId, @NonNull String id, @NonNull final Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("peerConnectionGetStats", "peerConnection is null", result);
    } else {
      pco.getStats(trackId, result);
    }
  }

  private void peerConnectionClose(@NonNull final String id) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
    if (pco == null || pco.getPeerConnection() == null) {
      Log.d(TAG, "peerConnectionClose() peerConnection is null");
    } else {
      pco.close();
    }
  }

  private void peerConnectionDispose(@NonNull final String id) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
    if (pco == null || pco.getPeerConnection() == null) {
      Log.d(TAG, "peerConnectionDispose() peerConnection is null");
    } else {
      pco.dispose();
      mPeerConnectionObservers.remove(id);
    }
    if (mPeerConnectionObservers.isEmpty()) {
      audioManager.onAudioManagerRequested(false);
    }
  }

  private void mediaStreamRelease(@NonNull final String id) {
    MediaStream mediaStream = localStreams.get(id);
    if (mediaStream != null) {
      for (VideoTrack track : mediaStream.videoTracks) {
        getUserMediaImpl.removeVideoCapturer(track.id());
      }
      localStreams.remove(id);
    } else {
      Log.d(TAG, "mediaStreamRelease() mediaStream is null");
    }
  }

  public void setActivity(@NonNull Activity activity) {
    this.activity = activity;
  }

  private void addTrack(@NonNull String peerConnectionId, @NonNull String trackId, @NonNull List<String> streamIds, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    MediaStreamTrack track = getLocalTrack(trackId);
    if (track == null) {
      resultError("addTrack", "track is null", result);
      return;
    }
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("addTrack", "peerConnection is null", result);
    } else {
      pco.addTrack(track, streamIds, result);
    }
  }

  private void removeTrack(@NonNull String peerConnectionId, @NonNull String senderId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("removeTrack", "peerConnection is null", result);
    } else {
      pco.removeTrack(senderId, result);
    }
  }

  private void addTransceiver(@NonNull String peerConnectionId, @NonNull String trackId, @NonNull Map<String, Object> transceiverInit,
                              @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    MediaStreamTrack track = getLocalTrack(trackId);
    if (track == null) {
      resultError("addTransceiver", "track is null", result);
      return;
    }
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("addTransceiver", "peerConnection is null", result);
    } else {
      pco.addTransceiver(track, transceiverInit, result);
    }
  }

  private void addTransceiverOfType(@NonNull String peerConnectionId, @NonNull String mediaType, @NonNull Map<String, Object> transceiverInit,
                                    @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("addTransceiverOfType", "peerConnection is null", result);
    } else {
      pco.addTransceiverOfType(mediaType, transceiverInit, result);
    }
  }

  private void rtpTransceiverSetDirection(@NonNull String peerConnectionId, @NonNull String direction, int transceiverId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpTransceiverSetDirection", "peerConnection is null", result);
    } else {
      pco.rtpTransceiverSetDirection(direction, transceiverId, result);
    }
  }

  private void rtpTransceiverGetMid(@NonNull String peerConnectionId, int transceiverId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpTransceiverGetMid", "peerConnection is null", result);
    } else {
      pco.rtpTransceiverGetMid(transceiverId, result);
    }
  }

  private void rtpTransceiverGetDirection(@NonNull String peerConnectionId, int transceiverId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpTransceiverSetDirection", "peerConnection is null", result);
    } else {
      pco.rtpTransceiverGetDirection(transceiverId, result);
    }
  }

  private void rtpTransceiverGetCurrentDirection(@NonNull String peerConnectionId, int transceiverId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpTransceiverSetDirection", "peerConnection is null", result);
    } else {
      pco.rtpTransceiverGetCurrentDirection(transceiverId, result);
    }
  }

  private void rtpTransceiverStop(@NonNull String peerConnectionId, int transceiverId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpTransceiverStop", "peerConnection is null", result);
    } else {
      pco.rtpTransceiverStop(transceiverId, result);
    }
  }

  private void rtpSenderSetParameters(@NonNull String peerConnectionId, @NonNull String rtpSenderId, @NonNull Map<String, Object> parameters, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpSenderSetParameters", "peerConnection is null", result);
    } else {
      pco.rtpSenderSetParameters(rtpSenderId, parameters, result);
    }
  }

  private void rtpSenderDispose(@NonNull String peerConnectionId, @NonNull String rtpSenderId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpSenderDispose", "peerConnection is null", result);
    } else {
      pco.rtpSenderDispose(rtpSenderId, result);
    }
  }

  private void getSenders(@NonNull String peerConnectionId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("getSenders", "peerConnection is null", result);
    } else {
      pco.getSenders(result);
    }
  }

  private void getReceivers(@NonNull String peerConnectionId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("getReceivers", "peerConnection is null", result);
    } else {
      pco.getReceivers(result);
    }
  }

  private void getTransceivers(@NonNull String peerConnectionId, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("getTransceivers", "peerConnection is null", result);
    } else {
      pco.getTransceivers(result);
    }
  }

  private void rtpSenderSetTrack(@NonNull String peerConnectionId, @NonNull String rtpSenderId, @NonNull String trackId, boolean replace, @NonNull Result result) {
    PeerConnectionObserver pco = mPeerConnectionObservers.get(peerConnectionId);
    if (pco == null || pco.getPeerConnection() == null) {
      resultError("rtpSenderSetTrack", "peerConnection is null", result);
    } else {
      MediaStreamTrack track = getLocalTrack(trackId);
      if (track == null) {
        resultError("rtpSenderSetTrack", "track is null", result);
        return;
      }
      pco.rtpSenderSetTrack(rtpSenderId, track, result, replace);
    }
  }


  public void reStartCamera() {
    if (null == getUserMediaImpl) {
      return;
    }
    getUserMediaImpl.reStartCamera(id -> {
      final MediaStreamTrack track = getLocalTrack(id);
      if (track == null) {
        return false;
      } else {
        return track.enabled();
      }
    });
  }
}
