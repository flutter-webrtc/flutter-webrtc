package com.cloudwebrtc.webrtc;

import android.util.Log;
import androidx.annotation.Nullable;

import com.cloudwebrtc.webrtc.audio.AudioSwitchManager;
import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import java.lang.reflect.Field;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.List;
import java.util.UUID;
import org.webrtc.AudioTrack;
import org.webrtc.CandidatePairChangeEvent;
import org.webrtc.DataChannel;
import org.webrtc.DtmfSender;
import org.webrtc.IceCandidate;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.RTCStats;
import org.webrtc.RTCStatsCollectorCallback;
import org.webrtc.RTCStatsReport;
import org.webrtc.RtpCapabilities;
import org.webrtc.RtpParameters;
import org.webrtc.RtpReceiver;
import org.webrtc.RtpSender;
import org.webrtc.RtpTransceiver;
import org.webrtc.StatsObserver;
import org.webrtc.StatsReport;
import org.webrtc.VideoTrack;

class PeerConnectionObserver implements PeerConnection.Observer, EventChannel.StreamHandler {
  private final static String TAG = FlutterWebRTCPlugin.TAG;
  private final Map<String, DataChannel> dataChannels = new HashMap<>();
  private BinaryMessenger messenger;
  private final String id;
  private PeerConnection peerConnection;
  private PeerConnection.RTCConfiguration configuration;
  final Map<String, MediaStream> remoteStreams = new HashMap<>();
  final Map<String, MediaStreamTrack> remoteTracks = new HashMap<>();
  final Map<String, RtpTransceiver> transceivers = new HashMap<>();
  private final StateProvider stateProvider;
  private final EventChannel eventChannel;
  private EventChannel.EventSink eventSink;

  PeerConnectionObserver(PeerConnection.RTCConfiguration configuration, StateProvider stateProvider, BinaryMessenger messenger, String id) {
    this.configuration = configuration;
    this.stateProvider = stateProvider;
    this.messenger = messenger;
    this.id = id;

    eventChannel = new EventChannel(messenger, "FlutterWebRTC/peerConnectionEvent" + id);
    eventChannel.setStreamHandler(this);
  }

  static private void resultError(String method, String error, Result result) {
      String errorMsg = method + "(): " + error;
      result.error(method, errorMsg,null);
      Log.d(TAG, errorMsg);
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink sink) {
    eventSink = new AnyThreadSink(sink);
  }

  @Override
  public void onCancel(Object o) {
    eventSink = null;
  }

  PeerConnection getPeerConnection() {
    return peerConnection;
  }

  void setPeerConnection(PeerConnection peerConnection) {
    this.peerConnection = peerConnection;
  }

  void restartIce() {
    peerConnection.restartIce();
  }

  void close() {
    peerConnection.close();
    remoteStreams.clear();
    remoteTracks.clear();
    dataChannels.clear();
  }

  void dispose() {
    this.close();
    peerConnection.dispose();
    eventChannel.setStreamHandler(null);
  }

  void createDataChannel(String label, ConstraintsMap config, Result result) {
    DataChannel.Init init = new DataChannel.Init();
    if (config != null) {
      if (config.hasKey("id")) {
        init.id = config.getInt("id");
      }
      if (config.hasKey("ordered")) {
        init.ordered = config.getBoolean("ordered");
      }
      if (config.hasKey("maxRetransmits")) {
        init.maxRetransmits = config.getInt("maxRetransmits");
      }
      if (config.hasKey("protocol")) {
        init.protocol = config.getString("protocol");
      }
      if (config.hasKey("negotiated")) {
        init.negotiated = config.getBoolean("negotiated");
      }
    }
    DataChannel dataChannel = peerConnection.createDataChannel(label, init);
    // XXX RTP data channels are not defined by the WebRTC standard, have
    // been deprecated in Chromium, and Google have decided (in 2015) to no
    // longer support them (in the face of multiple reported issues of
    // breakages).
    String flutterId = getNextDataChannelUUID();
    if (dataChannel != null) {
        dataChannels.put(flutterId, dataChannel);
        registerDataChannelObserver(flutterId, dataChannel);

        ConstraintsMap params = new ConstraintsMap();
        params.putInt("id", dataChannel.id());
        params.putString("label", dataChannel.label());
        params.putString("flutterId", flutterId);
        result.success(params.toMap());
    } else {
        resultError("createDataChannel", "Can't create data-channel for id: " + init.id, result);
    }
  }

    void dataChannelClose(String dataChannelId) {
        DataChannel dataChannel = dataChannels.get(dataChannelId);
        if (dataChannel != null) {
            dataChannel.close();
            dataChannels.remove(dataChannelId);
        } else {
            Log.d(TAG, "dataChannelClose() dataChannel is null");
        }
    }

    void dataChannelSend(String dataChannelId, ByteBuffer byteBuffer, Boolean isBinary) {
        DataChannel dataChannel = dataChannels.get(dataChannelId);
        if (dataChannel != null) {
            DataChannel.Buffer buffer = new DataChannel.Buffer(byteBuffer, isBinary);
            dataChannel.send(buffer);
        } else {
            Log.d(TAG, "dataChannelSend() dataChannel is null");
        }
    }

    RtpTransceiver getRtpTransceiverById(String id) {
       RtpTransceiver transceiver = transceivers.get(id);
       if(null == transceiver) {
           List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
           for(RtpTransceiver t : transceivers) {
               if (id.equals(t.getMid())){
                   transceiver = t;
               }
           }
       }
       return transceiver;
    }

    RtpSender getRtpSenderById(String id) {
        List<RtpSender> senders = peerConnection.getSenders();
        for(RtpSender sender : senders) {
            if (id.equals(sender.id())){
                return sender;
            }
        }
        return null;
    }

    RtpReceiver getRtpReceiverById(String id) {
        List<RtpReceiver> receivers = peerConnection.getReceivers();
        for(RtpReceiver receiver : receivers) {
            if (id.equals(receiver.id())){
                return receiver;
            }
        }
        return null;
    }
  void handleStatsReport(RTCStatsReport rtcStatsReport, Result result) {
      Map<String, RTCStats>    reports = rtcStatsReport.getStatsMap();
      ConstraintsMap params = new ConstraintsMap();
      ConstraintsArray stats = new ConstraintsArray();

      for (RTCStats report : reports.values()) {
          ConstraintsMap report_map = new ConstraintsMap();

          report_map.putString("id", report.getId());
          report_map.putString("type", report.getType());
          report_map.putDouble("timestamp", report.getTimestampUs());

          Map<String, Object> values = report.getMembers();
          ConstraintsMap v_map = new ConstraintsMap();
          for (String key : values.keySet()) {
              Object v = values.get(key);
              if(v instanceof String) {
                  v_map.putString(key, (String)v);
              } else if(v instanceof String[]) {
                  ConstraintsArray arr = new ConstraintsArray();
                  for(String s : (String[])v) {
                      arr.pushString(s);
                  }
                  v_map.putArray(key, arr.toArrayList());
              } else if(v instanceof Integer) {
                  v_map.putInt(key, (Integer)v);
              } else if(v instanceof Long) {
                  v_map.putLong(key, (Long)v);
              } else if(v instanceof Double) {
                  v_map.putDouble(key, (Double)v);
              } else if(v instanceof Boolean) {
                  v_map.putBoolean(key, (Boolean)v);
              } else if(v instanceof BigInteger){
                  v_map.putLong(key, ((BigInteger)v).longValue());
              } else {
                  Log.d(TAG, "getStats() unknown type: " + v.getClass().getName() + " for [" + key + "] value: " + v.toString());
              }
          }
          report_map.putMap("values", v_map.toMap());
          stats.pushMap(report_map);
      }

      params.putArray("stats", stats.toArrayList());
      result.success(params.toMap());
  }

  void getStatsForTrack(String trackId, Result result) {
      if (trackId == null || trackId.isEmpty()) {
          resultError("peerConnectionGetStats","MediaStreamTrack not found for id: " + trackId, result);
          return;
      }

      RtpSender sender = null;
      RtpReceiver receiver = null;
      for (RtpSender s : peerConnection.getSenders()) {
          if (s.track() != null && trackId.equals(s.track().id())) {
              sender = s;
              break;
          }
      }
      for (RtpReceiver r : peerConnection.getReceivers()) {
          if (r.track() != null && trackId.equals(r.track().id())) {
              receiver = r;
              break;
          }
      }
      if (sender != null) {
          peerConnection.getStats(rtcStatsReport -> handleStatsReport(rtcStatsReport, result), sender);
      } else if(receiver != null) {
          peerConnection.getStats(rtcStatsReport -> handleStatsReport(rtcStatsReport, result), receiver);
      } else {
          resultError("peerConnectionGetStats","MediaStreamTrack not found for id: " + trackId, result);
      }
  }

  void getStats(final Result result) {
      peerConnection.getStats(
              rtcStatsReport -> handleStatsReport(rtcStatsReport, result));
  }

  @Override
  public void onIceCandidate(final IceCandidate candidate) {
    Log.d(TAG, "onIceCandidate");
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "onCandidate");
    params.putMap("candidate", candidateToMap(candidate));
    sendEvent(params);
  }

  @Override
  public void onSelectedCandidatePairChanged(CandidatePairChangeEvent event) {
      Log.d(TAG, "onSelectedCandidatePairChanged");
      ConstraintsMap params = new ConstraintsMap();
      params.putString("event", "onSelectedCandidatePairChanged");
      ConstraintsMap candidateParams = new ConstraintsMap();
      candidateParams.putInt("lastDataReceivedMs", event.lastDataReceivedMs);
      candidateParams.putMap("local", candidateToMap(event.local));
      candidateParams.putMap("remote", candidateToMap(event.remote));
      candidateParams.putString("reason", event.reason);
      params.putMap("candidate", candidateParams.toMap());
      sendEvent(params);
  }

  @Override
  public void onIceCandidatesRemoved(final IceCandidate[] candidates) {
    Log.d(TAG, "onIceCandidatesRemoved");
  }

  @Override
  public void onIceConnectionChange(PeerConnection.IceConnectionState iceConnectionState) {
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "iceConnectionState");
    params.putString("state", iceConnectionStateString(iceConnectionState));
    sendEvent(params);
  }

    @Override
    public void onStandardizedIceConnectionChange(PeerConnection.IceConnectionState newState) {

    }

    @Override
  public void onIceConnectionReceivingChange(boolean var1) {
  }

  @Override
  public void onIceGatheringChange(PeerConnection.IceGatheringState iceGatheringState) {
    Log.d(TAG, "onIceGatheringChange" + iceGatheringState.name());
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "iceGatheringState");
    params.putString("state", iceGatheringStateString(iceGatheringState));
    sendEvent(params);
  }

  private String getUIDForStream(MediaStream mediaStream) {
    for (Iterator<Map.Entry<String, MediaStream>> i
        = remoteStreams.entrySet().iterator();
        i.hasNext(); ) {
      Map.Entry<String, MediaStream> e = i.next();
      if (e.getValue().equals(mediaStream)) {
        return e.getKey();
      }
    }
    return null;
  }

  @Override
  public void onAddStream(MediaStream mediaStream) {
    String streamUID = null;
    String streamId = mediaStream.getId();
    // The native WebRTC implementation has a special concept of a default
    // MediaStream instance with the label default that the implementation
    // reuses.
    if ("default".equals(streamId)) {
      for (Map.Entry<String, MediaStream> e
          : remoteStreams.entrySet()) {
        if (e.getValue().equals(mediaStream)) {
          streamUID = e.getKey();
          break;
        }
      }
    }

    if (streamUID == null) {
      streamUID = stateProvider.getNextStreamUUID();
      remoteStreams.put(streamId, mediaStream);
    }

    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "onAddStream");
    params.putString("streamId", streamId);
    params.putString("ownerTag", id);

    ConstraintsArray audioTracks = new ConstraintsArray();
    ConstraintsArray videoTracks = new ConstraintsArray();

    for (int i = 0; i < mediaStream.videoTracks.size(); i++) {
      VideoTrack track = mediaStream.videoTracks.get(i);
      String trackId = track.id();

      remoteTracks.put(trackId, track);

      ConstraintsMap trackInfo = new ConstraintsMap();
      trackInfo.putString("id", trackId);
      trackInfo.putString("label", "Video");
      trackInfo.putString("kind", track.kind());
      trackInfo.putBoolean("enabled", track.enabled());
      trackInfo.putString("readyState", track.state().toString());
      trackInfo.putBoolean("remote", true);
      videoTracks.pushMap(trackInfo);
    }
    for (int i = 0; i < mediaStream.audioTracks.size(); i++) {
      AudioTrack track = mediaStream.audioTracks.get(i);
      String trackId = track.id();

      remoteTracks.put(trackId, track);

      ConstraintsMap trackInfo = new ConstraintsMap();
      trackInfo.putString("id", trackId);
      trackInfo.putString("label", "Audio");
      trackInfo.putString("kind", track.kind());
      trackInfo.putBoolean("enabled", track.enabled());
      trackInfo.putString("readyState", track.state().toString());
      trackInfo.putBoolean("remote", true);
      audioTracks.pushMap(trackInfo);
    }
    params.putArray("audioTracks", audioTracks.toArrayList());
    params.putArray("videoTracks", videoTracks.toArrayList());

    sendEvent(params);
  }

  void sendEvent(ConstraintsMap event) {
    if (eventSink != null) {
      eventSink.success(event.toMap());
    }
  }

  @Override
  public void onRemoveStream(MediaStream mediaStream) {

    String streamId = mediaStream.getId();

    for (VideoTrack track : mediaStream.videoTracks) {
      this.remoteTracks.remove(track.id());
    }
    for (AudioTrack track : mediaStream.audioTracks) {
      this.remoteTracks.remove(track.id());
    }

    this.remoteStreams.remove(streamId);
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "onRemoveStream");
    params.putString("streamId", streamId);
    sendEvent(params);
  }

  @Override
  public void onTrack(RtpTransceiver transceiver) {}

  @Override
  public void onAddTrack(RtpReceiver receiver, MediaStream[] mediaStreams) {
      Log.d(TAG, "onAddTrack");
      // for plan-b
      for (MediaStream stream : mediaStreams) {
          String streamId = stream.getId();
          MediaStreamTrack track = receiver.track();
          ConstraintsMap params = new ConstraintsMap();
          params.putString("event", "onAddTrack");
          params.putString("streamId", streamId);
          params.putString("ownerTag", id);
          params.putString("trackId", track.id());

          String trackId = track.id();
          ConstraintsMap trackInfo = new ConstraintsMap();
          trackInfo.putString("id", trackId);
          trackInfo.putString("label", track.kind());
          trackInfo.putString("kind", track.kind());
          trackInfo.putBoolean("enabled", track.enabled());
          trackInfo.putString("readyState", track.state().toString());
          trackInfo.putBoolean("remote", true);
          params.putMap("track", trackInfo.toMap());
          sendEvent(params);

          if ("audio".equals(track.kind())) {
              AudioSwitchManager.instance.start();
          }
      }

      // For unified-plan
      ConstraintsMap params = new ConstraintsMap();
      ConstraintsArray streams = new ConstraintsArray();
      for(int i = 0; i< mediaStreams.length; i++){
          MediaStream stream = mediaStreams[i];
          streams.pushMap(new ConstraintsMap(mediaStreamToMap(stream)));
      }

      params.putString("event", "onTrack");
      params.putArray("streams", streams.toArrayList());
      params.putMap("track", mediaTrackToMap(receiver.track()));
      params.putMap("receiver", rtpReceiverToMap(receiver));

      if(this.configuration.sdpSemantics == PeerConnection.SdpSemantics.UNIFIED_PLAN) {
          List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
          for( RtpTransceiver transceiver : transceivers ) {
              if(transceiver.getReceiver() != null && receiver.id().equals(transceiver.getReceiver().id())) {
                  String transceiverId = transceiver.getMid();
                  if(null == transceiverId) {
                      transceiverId = stateProvider.getNextStreamUUID();
                  }
                  params.putMap("transceiver", transceiverToMap(transceiverId, transceiver));
              }
          }
      }
      sendEvent(params);
  }

    @Override
    public void onRemoveTrack(RtpReceiver rtpReceiver) {
        Log.d(TAG, "onRemoveTrack");

        MediaStreamTrack track = rtpReceiver.track();
        String trackId = track.id();
        ConstraintsMap trackInfo = new ConstraintsMap();
        trackInfo.putString("id", trackId);
        trackInfo.putString("label", track.kind());
        trackInfo.putString("kind", track.kind());
        trackInfo.putBoolean("enabled", track.enabled());
        trackInfo.putString("readyState", track.state().toString());
        trackInfo.putBoolean("remote", true);
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "onRemoveTrack");
        params.putString("trackId", track.id());
        params.putMap("track", trackInfo.toMap());
        sendEvent(params);
    }

    @Override
  public void onDataChannel(DataChannel dataChannel) {
    String flutterId = getNextDataChannelUUID();
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "didOpenDataChannel");
    params.putInt("id", dataChannel.id());
    params.putString("label", dataChannel.label());
    params.putString("flutterId", flutterId);

    dataChannels.put(flutterId, dataChannel);
    registerDataChannelObserver(flutterId, dataChannel);

    sendEvent(params);
  }

  private void registerDataChannelObserver(String dcId, DataChannel dataChannel) {
    // DataChannel.registerObserver implementation does not allow to
    // unregister, so the observer is registered here and is never
    // unregistered
    dataChannel.registerObserver(
        new DataChannelObserver(messenger, id, dcId, dataChannel));
  }

  @Override
  public void onRenegotiationNeeded() {
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "onRenegotiationNeeded");
    sendEvent(params);
  }

  @Override
  public void onSignalingChange(PeerConnection.SignalingState signalingState) {
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "signalingState");
    params.putString("state", signalingStateString(signalingState));
    sendEvent(params);
  }

  @Override
  public void onConnectionChange(PeerConnection.PeerConnectionState connectionState) {
    Log.d(TAG, "onConnectionChange" + connectionState.name());
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "peerConnectionState");
    params.putString("state", connectionStateString(connectionState));
    sendEvent(params);
  }

  @Nullable
  private String iceConnectionStateString(PeerConnection.IceConnectionState iceConnectionState) {
    switch (iceConnectionState) {
      case NEW:
        return "new";
      case CHECKING:
        return "checking";
      case CONNECTED:
        return "connected";
      case COMPLETED:
        return "completed";
      case FAILED:
        return "failed";
      case DISCONNECTED:
        return "disconnected";
      case CLOSED:
        return "closed";
    }
    return null;
  }

  @Nullable
  private String iceGatheringStateString(PeerConnection.IceGatheringState iceGatheringState) {
    switch (iceGatheringState) {
      case NEW:
        return "new";
      case GATHERING:
        return "gathering";
      case COMPLETE:
        return "complete";
    }
    return null;
  }

  @Nullable
  private String signalingStateString(PeerConnection.SignalingState signalingState) {
    switch (signalingState) {
      case STABLE:
        return "stable";
      case HAVE_LOCAL_OFFER:
        return "have-local-offer";
      case HAVE_LOCAL_PRANSWER:
        return "have-local-pranswer";
      case HAVE_REMOTE_OFFER:
        return "have-remote-offer";
      case HAVE_REMOTE_PRANSWER:
        return "have-remote-pranswer";
      case CLOSED:
        return "closed";
    }
    return null;
  }

    @Nullable
    private String connectionStateString(PeerConnection.PeerConnectionState connectionState) {
        switch (connectionState) {
            case NEW:
                return "new";
            case CONNECTING:
                return "connecting";
            case CONNECTED:
                return "connected";
            case DISCONNECTED:
                return "disconnected";
            case FAILED:
                return "failed";
            case CLOSED:
                return "closed";
        }
        return null;
    }

  @Nullable
  private String transceiverDirectionString(RtpTransceiver.RtpTransceiverDirection direction) {
      switch (direction) {
          case SEND_RECV:
              return "sendrecv";
          case SEND_ONLY:
              return "sendonly";
          case RECV_ONLY:
              return "recvonly";
          case INACTIVE:
              return "inactive";
          case STOPPED:
              return "stopped";
      }
      return null;
  }

  private RtpTransceiver.RtpTransceiverDirection stringToTransceiverDirection(String direction) {
      switch (direction) {
          case "sendrecv":
              return RtpTransceiver.RtpTransceiverDirection.SEND_RECV;
          case "sendonly":
              return RtpTransceiver.RtpTransceiverDirection.SEND_ONLY;
          case "recvonly":
              return RtpTransceiver.RtpTransceiverDirection.RECV_ONLY;
          case "inactive":
              return RtpTransceiver.RtpTransceiverDirection.INACTIVE;
          case "stopped":
              return RtpTransceiver.RtpTransceiverDirection.STOPPED;
      }
      return RtpTransceiver.RtpTransceiverDirection.INACTIVE;
  }

  private MediaStreamTrack.MediaType stringToMediaType(String mediaType) {
      MediaStreamTrack.MediaType type = MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO;
      if(mediaType.equals("audio"))
          type = MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO;
      else if(mediaType.equals("video"))
          type = MediaStreamTrack.MediaType.MEDIA_TYPE_VIDEO;
      return type;
  }

  private RtpParameters.Encoding mapToEncoding(Map<String, Object> parameters) {
      RtpParameters.Encoding encoding = new RtpParameters.Encoding((String)parameters.get("rid"), true, 1.0);

      if( parameters.get("active") != null) {
          encoding.active = (Boolean) parameters.get("active");
      }

      if( parameters.get("ssrc") != null) {
          encoding.ssrc = ((Integer) parameters.get("ssrc")).longValue();
      }

      if( parameters.get("minBitrate") != null) {
          encoding.minBitrateBps = (Integer) parameters.get("minBitrate");
      }

      if( parameters.get("maxBitrate") != null) {
          encoding.maxBitrateBps = (Integer) parameters.get("maxBitrate");
      }

      if( parameters.get("maxFramerate") != null) {
          encoding.maxFramerate = (Integer) parameters.get("maxFramerate");
      }

      if( parameters.get("numTemporalLayers") != null) {
          encoding.numTemporalLayers = (Integer) parameters.get("numTemporalLayers");
      }

      if( parameters.get("scaleResolutionDownBy") != null) {
          encoding.scaleResolutionDownBy = (Double) parameters.get("scaleResolutionDownBy");
      }

      return  encoding;
  }

  private RtpTransceiver.RtpTransceiverInit mapToRtpTransceiverInit(Map<String, Object> parameters) {
      List<String> streamIds =  (List)parameters.get("streamIds");
      List<Map<String, Object>> encodingsParams = (List<Map<String, Object>>)parameters.get("sendEncodings");
      String direction = (String)parameters.get("direction");
      List<RtpParameters.Encoding> sendEncodings = new ArrayList<>();
      RtpTransceiver.RtpTransceiverInit init = null;

      if(streamIds == null) {
          streamIds = new ArrayList<String>();
      }

      if(direction == null) {
          direction = "sendrecv";
      }

      if(encodingsParams != null) {
          for (int i=0;i< encodingsParams.size();i++){
              Map<String, Object> params = encodingsParams.get(i);
              sendEncodings.add(0, mapToEncoding(params));
          }
          init = new RtpTransceiver.RtpTransceiverInit(stringToTransceiverDirection(direction) ,streamIds, sendEncodings);
      } else {
          init = new RtpTransceiver.RtpTransceiverInit(stringToTransceiverDirection(direction) ,streamIds);
      }
      return  init;
  }

private RtpParameters updateRtpParameters(RtpParameters parameters, Map<String, Object> newParameters) {
    // new
    final List<Map<String, Object>> encodings = (List<Map<String, Object>>)newParameters.get("encodings");
    // current
    final List<RtpParameters.Encoding> nativeEncodings = parameters.encodings;

    for (Map<String, Object> encoding: encodings) {
        RtpParameters.Encoding currentParams = null;
        String rid = (String)encoding.get("rid");

        // find by rid
        if (rid != null) {
            for (RtpParameters.Encoding x : nativeEncodings) {
                if (rid.equals(x.rid)) {
                    currentParams = x;
                    break;
                }
            }
        }

        // fall back to index
        if (currentParams == null) {
            int idx = encodings.indexOf(encoding);
            if (idx < nativeEncodings.size()) {
                currentParams = nativeEncodings.get(idx);
            }
        }

        if (currentParams != null) {
          Boolean active = (Boolean)encoding.get("active");
          if (active != null) currentParams.active = active;
          Integer maxBitrate = (Integer)encoding.get("maxBitrate");
          if (maxBitrate != null) currentParams.maxBitrateBps = maxBitrate;
          Integer minBitrate = (Integer)encoding.get("minBitrate");
          if (minBitrate != null) currentParams.minBitrateBps = minBitrate;
          Integer maxFramerate = (Integer)encoding.get("maxFramerate");
          if (maxFramerate != null) currentParams.maxFramerate = maxFramerate; 
          Integer numTemporalLayers = (Integer)encoding.get("numTemporalLayers");
          if (numTemporalLayers != null) currentParams.numTemporalLayers = numTemporalLayers;
          Double scaleResolutionDownBy = (Double)encoding.get("scaleResolutionDownBy");
          if (scaleResolutionDownBy != null) currentParams.scaleResolutionDownBy = scaleResolutionDownBy;  
        }
    }

    return parameters;
}

  private Map<String, Object> rtpParametersToMap(RtpParameters rtpParameters){
      ConstraintsMap info = new ConstraintsMap();
      info.putString("transactionId", rtpParameters.transactionId);

      ConstraintsMap rtcp = new ConstraintsMap();
      rtcp.putString("cname", rtpParameters.getRtcp().getCname());
      rtcp.putBoolean("reducedSize",  rtpParameters.getRtcp().getReducedSize());
      info.putMap("rtcp", rtcp.toMap());

      ConstraintsArray headerExtensions = new ConstraintsArray();
      for(RtpParameters.HeaderExtension extension : rtpParameters.getHeaderExtensions()){
          ConstraintsMap map = new ConstraintsMap();
          map.putString("uri",extension.getUri());
          map.putInt("id", extension.getId());
          map.putBoolean("encrypted", extension.getEncrypted());
          headerExtensions.pushMap(map);
      }
      info.putArray("headerExtensions", headerExtensions.toArrayList());

      ConstraintsArray encodings = new ConstraintsArray();
      for(RtpParameters.Encoding encoding : rtpParameters.encodings){
          ConstraintsMap map = new ConstraintsMap();
          map.putBoolean("active",encoding.active);
          if (encoding.rid != null) {
              map.putString("rid", encoding.rid);
          }
          if (encoding.maxBitrateBps != null) {
              map.putInt("maxBitrate", encoding.maxBitrateBps);
          }
          if (encoding.minBitrateBps != null) {
              map.putInt("minBitrate", encoding.minBitrateBps);
          }
          if (encoding.maxFramerate != null) {
              map.putInt("maxFramerate", encoding.maxFramerate);
          }
          if (encoding.numTemporalLayers != null) {
              map.putInt("numTemporalLayers", encoding.numTemporalLayers);
          }
          if (encoding.scaleResolutionDownBy != null) {
              map.putDouble("scaleResolutionDownBy", encoding.scaleResolutionDownBy);
          }
          if (encoding.ssrc != null) {
              map.putLong("ssrc", encoding.ssrc);
          }
          encodings.pushMap(map);
      }
      info.putArray("encodings", encodings.toArrayList());

      ConstraintsArray codecs = new ConstraintsArray();
      for(RtpParameters.Codec codec : rtpParameters.codecs){
          ConstraintsMap map = new ConstraintsMap();
          map.putString("name",codec.name);
          map.putInt("payloadType", codec.payloadType);
          map.putInt("clockRate", codec.clockRate);
          if (codec.numChannels != null) {
              map.putInt("numChannels", codec.numChannels);
          }
          map.putMap("parameters", new HashMap<String, Object>(codec.parameters));
          try {
              Field field = codec.getClass().getDeclaredField("kind");
              field.setAccessible(true);
              if (field.get(codec).equals(MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO)) {
                  map.putString("kind", "audio");
              } else if(field.get(codec).equals(MediaStreamTrack.MediaType.MEDIA_TYPE_VIDEO)) {
                  map.putString("kind", "video");
              }
          } catch (NoSuchFieldException e1) {
              e1.printStackTrace();
          } catch (IllegalArgumentException e1) {
              e1.printStackTrace();
          } catch (IllegalAccessException e1) {
              e1.printStackTrace();
          }
          codecs.pushMap(map);
      }

      info.putArray("codecs", codecs.toArrayList());
      return info.toMap();
  }

    @Nullable
    private Map<String, Object> mediaStreamToMap(MediaStream stream){
        ConstraintsMap params = new ConstraintsMap();
        params.putString("streamId", stream.getId());
        params.putString("ownerTag", id);
        ConstraintsArray audioTracks = new ConstraintsArray();
        ConstraintsArray videoTracks = new ConstraintsArray();

        for (MediaStreamTrack track : stream.audioTracks) {
            audioTracks.pushMap(new ConstraintsMap(mediaTrackToMap(track)));
        }

        for (MediaStreamTrack track : stream.videoTracks) {
            videoTracks.pushMap(new ConstraintsMap(mediaTrackToMap(track)));
        }

        params.putArray("audioTracks", audioTracks.toArrayList());
        params.putArray("videoTracks", videoTracks.toArrayList());
        return params.toMap();
    }

  @Nullable
  private Map<String, Object> mediaTrackToMap(MediaStreamTrack track){
      ConstraintsMap info = new ConstraintsMap();
      if(track != null){
          info.putString("id", track.id());
          info.putString("label",track.getClass() == VideoTrack.class? "video": "audio");
          info.putString("kind",track.kind());
          info.putBoolean("enabled", track.enabled());
          info.putString("readyState", track.state().toString());
      }
      return info.toMap();
  }

  private Map<String, Object> dtmfSenderToMap(DtmfSender dtmfSender, String id){
      ConstraintsMap info = new ConstraintsMap();
      info.putString("dtmfSenderId",id);
      if (dtmfSender != null) {
          info.putInt("interToneGap", dtmfSender.interToneGap());
          info.putInt("duration", dtmfSender.duration());
      }
      return info.toMap();
  }

  private Map<String, Object> rtpSenderToMap(RtpSender sender){
      ConstraintsMap info = new ConstraintsMap();
      info.putString("senderId", sender.id());
      info.putBoolean("ownsTrack", true);
      info.putMap("dtmfSender", dtmfSenderToMap(sender.dtmf(), sender.id()));
      info.putMap("rtpParameters", rtpParametersToMap(sender.getParameters()));
      info.putMap("track", mediaTrackToMap(sender.track()));
      return info.toMap();
  }

  private Map<String, Object> rtpReceiverToMap(RtpReceiver receiver){
      ConstraintsMap info = new ConstraintsMap();
      info.putString("receiverId", receiver.id());
      info.putMap("rtpParameters", rtpParametersToMap(receiver.getParameters()));
      info.putMap("track", mediaTrackToMap(receiver.track()));
      return info.toMap();
  }

  Map<String, Object> transceiverToMap(String transceiverId, RtpTransceiver transceiver){
      ConstraintsMap info = new ConstraintsMap();
      info.putString("transceiverId", transceiverId);
      if(transceiver.getMid() == null) {
          info.putString("mid", "");
      } else {
          info.putString("mid", transceiver.getMid());
      }
      info.putString("direction", transceiverDirectionString(transceiver.getDirection()));
      info.putMap("sender", rtpSenderToMap(transceiver.getSender()));
      info.putMap("receiver", rtpReceiverToMap(transceiver.getReceiver()));
      return info.toMap();
  }

  Map<String, Object> candidateToMap(IceCandidate candidate) {
      ConstraintsMap candidateParams = new ConstraintsMap();
      candidateParams.putInt("sdpMLineIndex", candidate.sdpMLineIndex);
      candidateParams.putString("sdpMid", candidate.sdpMid);
      candidateParams.putString("candidate", candidate.sdp);
      return candidateParams.toMap();
  }

  public void addTrack(MediaStreamTrack track, List<String> streamIds, Result result){
      RtpSender sender = peerConnection.addTrack(track, streamIds);
      result.success(rtpSenderToMap(sender));
  }

  public void removeTrack(String senderId, Result result){
      RtpSender sender = getRtpSenderById(senderId);
      if(sender == null){
          resultError("removeTrack", "sender is null", result);
          return;
      }
      boolean res = peerConnection.removeTrack(sender);
      Map<String, Object> params = new HashMap<>();
      params.put("result", res);
      result.success(params);
  }

  public void addTransceiver(MediaStreamTrack track, Map<String, Object> transceiverInit,  Result result) {
      RtpTransceiver  transceiver;
      if(transceiverInit != null){
          transceiver = peerConnection.addTransceiver(track, mapToRtpTransceiverInit(transceiverInit));
      } else {
          transceiver = peerConnection.addTransceiver(track);
      }
      String transceiverId = transceiver.getMid();
      if(null == transceiverId) {
          transceiverId = stateProvider.getNextStreamUUID();
      }
      transceivers.put(transceiverId, transceiver);
      result.success(transceiverToMap(transceiverId, transceiver));
  }

  public void addTransceiverOfType(String mediaType, Map<String, Object> transceiverInit,  Result result) {
      RtpTransceiver  transceiver;
      if(transceiverInit != null){
          transceiver = peerConnection.addTransceiver(stringToMediaType(mediaType), mapToRtpTransceiverInit(transceiverInit));
      } else {
          transceiver = peerConnection.addTransceiver(stringToMediaType(mediaType));
      }
      String transceiverId = transceiver.getMid();
      if(null == transceiverId) {
          transceiverId = stateProvider.getNextStreamUUID();
      }
      transceivers.put(transceiverId, transceiver);
      result.success(transceiverToMap(transceiverId, transceiver));
  }

  public void rtpTransceiverSetDirection(String direction, String transceiverId, Result result) {
      RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
      if (transceiver == null) {
          resultError("rtpTransceiverSetDirection", "transceiver is null", result);
          return;
      }
      transceiver.setDirection(stringToTransceiverDirection(direction));
      result.success(null);
  }

  public void rtpTransceiverSetCodecPreferences(String transceiverId, List<Map<String, Object>> codecs, Result result) {
      RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
      if (transceiver == null) {
          resultError("rtpTransceiverSetCodecPreferences", "transceiver is null", result);
          return;
      }
      List<RtpCapabilities.CodecCapability> preferedCodecs = new ArrayList<>();
      for(Map<String, Object> codec : codecs) {
            RtpCapabilities.CodecCapability codecCapability = new RtpCapabilities.CodecCapability();
            String mimeType = (String) codec.get("mimeType");
            List<String> mimeTypeParts = Arrays.asList(mimeType.split("/"));
            codecCapability.name = mimeTypeParts.get(1);
            codecCapability.kind = stringToMediaType(mimeTypeParts.get(0));
            codecCapability.mimeType = mimeType;
            codecCapability.clockRate = (int) codec.get("clockRate");
            if(codec.get("numChannels") != null)
                codecCapability.numChannels = (int) codec.get("numChannels");
            if(codec.get("sdpFmtpLine") != null) {
                String sdpFmtpLine = (String) codec.get("sdpFmtpLine");
                codecCapability.parameters = new HashMap<>();
                List<String> parameters = Arrays.asList(sdpFmtpLine.split(";"));
                for(String parameter : parameters) {
                    if(parameter.contains("=")) {
                        List<String> parameterParts = Arrays.asList(parameter.split("="));
                        codecCapability.parameters.put(parameterParts.get(0), parameterParts.get(1));
                    } else {
                        codecCapability.parameters.put("", parameter);
                    }
                }
            } else {
                codecCapability.parameters = new HashMap<>();
            }
            preferedCodecs.add(codecCapability);
      }
      transceiver.setCodecPreferences(preferedCodecs);
      result.success(null);
  }

  public void rtpTransceiverGetDirection(String transceiverId, Result result) {
      RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
      if (transceiver == null) {
          resultError("rtpTransceiverGetDirection", "transceiver is null", result);
          return;
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putString("result", transceiverDirectionString(transceiver.getDirection()));
      result.success(params.toMap());
  }

  public void rtpTransceiverGetCurrentDirection(String transceiverId, Result result) {
      RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
      if (transceiver == null) {
          resultError("rtpTransceiverGetCurrentDirection", "transceiver is null", result);
          return;
      }
      RtpTransceiver.RtpTransceiverDirection direction = transceiver.getCurrentDirection();
      if(direction == null) {
          result.success(null);
      } else {
          ConstraintsMap params = new ConstraintsMap();
          params.putString("result", transceiverDirectionString(direction));
          result.success(params.toMap());
      }
  }

    public void rtpTransceiverStop(String transceiverId, Result result) {
        RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
        if (transceiver == null) {
            resultError("rtpTransceiverStop", "transceiver is null", result);
            return;
        }
        transceiver.stop();
        result.success(null);
    }

    public void rtpSenderSetParameters(String rtpSenderId, Map<String, Object> parameters, Result result) {
        RtpSender sender = getRtpSenderById(rtpSenderId);
        if (sender == null) {
            resultError("rtpSenderSetParameters", "sender is null", result);
            return;
        }
        final RtpParameters updatedParameters = updateRtpParameters(sender.getParameters(), parameters);
        final Boolean success = sender.setParameters(updatedParameters);
        ConstraintsMap params = new ConstraintsMap();
        params.putBoolean("result", success);
        result.success(params.toMap());
    }

    public void rtpSenderSetTrack(String rtpSenderId, MediaStreamTrack track, Result result, boolean replace) {
        RtpSender sender = getRtpSenderById(rtpSenderId);
        if (sender == null) {
            resultError("rtpSenderSetTrack", "sender is null", result);
            return;
        }
        sender.setTrack(track, false);
        result.success(null);
    }

    public void rtpSenderDispose(String rtpSenderId, Result result) {
        RtpSender sender = getRtpSenderById(rtpSenderId);
        if (sender == null) {
            resultError("rtpSenderDispose", "sender is null", result);
            return;
        }
        sender.dispose();
        result.success(null);
    }

    public void getSenders(Result result) {
      List<RtpSender> senders = peerConnection.getSenders();
      ConstraintsArray sendersParams = new ConstraintsArray();
      for(RtpSender sender : senders){
        sendersParams.pushMap(new ConstraintsMap(rtpSenderToMap(sender)));
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putArray("senders", sendersParams.toArrayList());
      result.success(params.toMap());
    }
  
    public void getReceivers(Result result) {
      List<RtpReceiver> receivers = peerConnection.getReceivers();
      ConstraintsArray receiversParams = new ConstraintsArray();
      for(RtpReceiver receiver : receivers){
        receiversParams.pushMap(new ConstraintsMap(rtpReceiverToMap(receiver)));
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putArray("receivers", receiversParams.toArrayList());
      result.success(params.toMap());
    }
  
    public void getTransceivers(Result result) {
      List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
      ConstraintsArray transceiversParams = new ConstraintsArray();
      for(RtpTransceiver transceiver : transceivers){
          String transceiverId = transceiver.getMid();
          if(null == transceiverId) {
              transceiverId = stateProvider.getNextStreamUUID();
          }
        transceiversParams.pushMap(new ConstraintsMap(transceiverToMap(transceiverId, transceiver)));
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putArray("transceivers", transceiversParams.toArrayList());
      result.success(params.toMap());
    }

    protected MediaStreamTrack getTransceiversTrack(String trackId) {
        if(this.configuration.sdpSemantics != PeerConnection.SdpSemantics.UNIFIED_PLAN) {
            return null;
        }
        MediaStreamTrack track = null;
        List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
        for (RtpTransceiver transceiver : transceivers) {
            RtpReceiver receiver = transceiver.getReceiver();
            if (receiver != null) {
                if (receiver.track() != null && receiver.track().id().equals(trackId)) {
                    track = receiver.track();
                    break;
                }
            }
        }
        return track;
    }

    public String getNextDataChannelUUID() {
      String uuid;
  
      do {
        uuid = UUID.randomUUID().toString();
      } while (dataChannels.get(uuid) != null);
  
      return uuid;
    }
  
}
