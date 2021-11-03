package com.cloudwebrtc.webrtc;

import android.util.Log;
import android.util.SparseArray;
import androidx.annotation.Nullable;
import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import java.lang.reflect.Field;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.List;
import org.webrtc.CandidatePairChangeEvent;
import org.webrtc.DataChannel;
import org.webrtc.IceCandidate;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.RtpParameters;
import org.webrtc.RtpReceiver;
import org.webrtc.RtpSender;
import org.webrtc.RtpTransceiver;
import org.webrtc.StatsObserver;
import org.webrtc.StatsReport;
import org.webrtc.VideoTrack;

class PeerConnectionObserver implements PeerConnection.Observer, EventChannel.StreamHandler {
  private final static String TAG = FlutterWebRTCPlugin.TAG;
  private final SparseArray<DataChannel> dataChannels = new SparseArray<>();
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
    this.id = id;

    eventChannel = new EventChannel(messenger, "FlutterWebRTC/peerConnectoinEvent" + id);
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

  void getStats(String trackId, final Result result) {
    MediaStreamTrack track = null;
    if (trackId == null
        || trackId.isEmpty()
        || (track = stateProvider.getLocalTracks().get(trackId)) != null
        || (track = remoteTracks.get(trackId)) != null) {
      peerConnection.getStats(
          new StatsObserver() {
            @Override
            public void onComplete(StatsReport[] reports) {

              final int reportCount = reports.length;
              ConstraintsMap params = new ConstraintsMap();
              ConstraintsArray stats = new ConstraintsArray();

              for (int i = 0; i < reportCount; ++i) {
                StatsReport report = reports[i];
                ConstraintsMap report_map = new ConstraintsMap();

                report_map.putString("id", report.id);
                report_map.putString("type", report.type);
                report_map.putDouble("timestamp", report.timestamp);

                StatsReport.Value[] values = report.values;
                ConstraintsMap v_map = new ConstraintsMap();
                final int valueCount = values.length;
                for (int j = 0; j < valueCount; ++j) {
                  StatsReport.Value v = values[j];
                  v_map.putString(v.name, v.value);
                }

                report_map.putMap("values", v_map.toMap());
                stats.pushMap(report_map);
              }

              params.putArray("stats", stats.toArrayList());
              result.success(params.toMap());
            }
          },
          track);
    } else {
        resultError("peerConnectionGetStats","MediaStreamTrack not found for id: " + trackId, result);
    }
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
    public void onAddStream(MediaStream mediaStream) {

    }

    @Override
    public void onRemoveStream(MediaStream mediaStream) {

    }

    @Override
    public void onDataChannel(DataChannel dataChannel) {

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

  void sendEvent(ConstraintsMap event) {
    if (eventSink != null) {
      eventSink.success(event.toMap());
    }
  }

  @Override
  public void onTrack(RtpTransceiver transceiver) {
      /*
      ConstraintsMap params = new ConstraintsMap();
      params.putString("event", "onTrack");
      params.putMap("transceiver", transceiverToMap(transceiver));
      params.putMap("receiver", rtpReceiverToMap(transceiver.getReceiver()));
      params.putMap("track", mediaTrackToMap(transceiver.getReceiver().track()));
      params.putArray("streams", new ConstraintsArray().toArrayList());
      sendEvent(params);
      */
  }

  @Override
  public void onAddTrack(RtpReceiver receiver, MediaStream[] mediaStreams) {
      Log.d(TAG, "onAddTrack");

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

  private RtpParameters updateRtpParameters(Map<String, Object> newParameters, RtpParameters parameters){
    List<Map<String, Object>> encodings = (List<Map<String, Object>>) newParameters.get("encodings");
    final Iterator encodingsIterator = encodings.iterator();
    final Iterator nativeEncodingsIterator = parameters.encodings.iterator();
    while(encodingsIterator.hasNext() && nativeEncodingsIterator.hasNext()){
      final RtpParameters.Encoding nativeEncoding = (RtpParameters.Encoding) nativeEncodingsIterator.next();
      final Map<String, Object> encoding = (Map<String, Object>) encodingsIterator.next();
      if(encoding.containsKey("active")){
        nativeEncoding.active =  (Boolean) encoding.get("active");
      }
      if (encoding.containsKey("maxBitrate")) {
        nativeEncoding.maxBitrateBps = (Integer) encoding.get("maxBitrate");
      }
      if (encoding.containsKey("minBitrate")) {
        nativeEncoding.minBitrateBps = (Integer) encoding.get("minBitrate");
      }
      if (encoding.containsKey("maxFramerate")) {
        nativeEncoding.maxFramerate = (Integer) encoding.get("maxFramerate");
      }
      if (encoding.containsKey("numTemporalLayers")) {
        nativeEncoding.numTemporalLayers = (Integer) encoding.get("numTemporalLayers");
      }
      if (encoding.containsKey("scaleResolutionDownBy") ) {
        nativeEncoding.scaleResolutionDownBy = (Double) encoding.get("scaleResolutionDownBy");
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

  private Map<String, Object> rtpSenderToMap(RtpSender sender){
      ConstraintsMap info = new ConstraintsMap();
      info.putString("senderId", sender.id());
      info.putBoolean("ownsTrack", true);
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
        final RtpParameters updatedParameters = updateRtpParameters(parameters, sender.getParameters());
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
        sender.setTrack(track, replace );
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

}
