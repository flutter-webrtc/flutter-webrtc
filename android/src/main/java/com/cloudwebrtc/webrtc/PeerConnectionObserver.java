package com.cloudwebrtc.webrtc;

import android.util.Log;
import android.util.SparseArray;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EnumStringifier;
import com.cloudwebrtc.webrtc.utils.ObjectExporter;

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
import org.webrtc.StatsReport;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;

class PeerConnectionObserver implements PeerConnection.Observer, EventChannel.StreamHandler {
  private static final String TAG = FlutterWebRTCPlugin.TAG;
  private final SparseArray<DataChannel> dataChannels = new SparseArray<>();
  private final String id;
  private PeerConnection peerConnection;
  private final PeerConnection.RTCConfiguration configuration;
  private final StateProvider stateProvider;
  @NonNull
  private final EventChannel eventChannel;
  @Nullable
  private EventChannel.EventSink eventSink;

  PeerConnectionObserver(PeerConnection.RTCConfiguration configuration, StateProvider stateProvider, BinaryMessenger messenger, String id) {
    this.configuration = configuration;
    this.stateProvider = stateProvider;
    this.id = id;

    eventChannel = new EventChannel(messenger, "FlutterWebRTC/peerConnectionEvent" + id);
    eventChannel.setStreamHandler(this);
  }

  private static void resultError(String method, String error, @NonNull Result result) {
      String errorMsg = method + "(): " + error;
      result.error(method, errorMsg, null);
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
    dataChannels.clear();
  }

  void dispose() {
    close();
    peerConnection.dispose();
    eventChannel.setStreamHandler(null);
  }

    @Nullable
    private RtpTransceiver getRtpTransceiverById(int id) {
        List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
        int transceiverId = 0;
        for (RtpTransceiver transceiver : transceivers) {
            if (transceiverId == id) {
              return transceiver;
            }
            transceiverId++;
       }
       return null;
    }

    @Nullable
    RtpSender getRtpSenderById(String id) {
        List<RtpSender> senders = peerConnection.getSenders();
        for(RtpSender sender : senders) {
            if (id.equals(sender.id())){
                return sender;
            }
        }
        return null;
    }

  void getStats(@Nullable String trackId, @NonNull final Result result) {
    MediaStreamTrack track = null;
    if (trackId == null
        || trackId.isEmpty()
        || (track = stateProvider.getLocalTrack(trackId)) != null
        || (track = getTransceiversTrack(trackId)) != null) {
      peerConnection.getStats(
           reports -> {
              ConstraintsMap params = new ConstraintsMap();
              ConstraintsArray stats = new ConstraintsArray();

              for (StatsReport report : reports) {
                ConstraintsMap report_map = new ConstraintsMap();

                report_map.putString("id", report.id);
                report_map.putString("type", report.type);
                report_map.putDouble("timestamp", report.timestamp);

                StatsReport.Value[] values = report.values;
                ConstraintsMap v_map = new ConstraintsMap();
                for (StatsReport.Value v : values) {
                  v_map.putString(v.name, v.value);
                }

                report_map.putMap("values", v_map.toMap());
                stats.pushMap(report_map);
              }

              params.putArray("stats", stats.toArrayList());
              result.success(params.toMap());
            },
          track);
    } else {
        resultError("peerConnectionGetStats", "MediaStreamTrack not found for id: " + trackId, result);
    }
  }

  @Override
  public void onIceCandidate(@NonNull final IceCandidate candidate) {
    Log.d(TAG, "onIceCandidate");
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "onCandidate");
    params.putMap("candidate", ObjectExporter.exportIceCandidate(candidate));
    sendEvent(params);
  }

  @Override
  public void onSelectedCandidatePairChanged(@NonNull CandidatePairChangeEvent event) {
      Log.d(TAG, "onSelectedCandidatePairChanged");
      ConstraintsMap params = new ConstraintsMap();
      params.putString("event", "onSelectedCandidatePairChanged");
      ConstraintsMap candidateParams = new ConstraintsMap();
      candidateParams.putInt("lastDataReceivedMs", event.lastDataReceivedMs);
      candidateParams.putMap("local", ObjectExporter.exportIceCandidate(event.local));
      candidateParams.putMap("remote", ObjectExporter.exportIceCandidate(event.remote));
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
  public void onIceConnectionChange(@NonNull PeerConnection.IceConnectionState iceConnectionState) {
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "iceConnectionState");
    params.putString("state", EnumStringifier.iceConnectionStateString(iceConnectionState));
    sendEvent(params);
  }

    @Override
    public void onStandardizedIceConnectionChange(PeerConnection.IceConnectionState newState) {
    }

  @Override
  public void onIceConnectionReceivingChange(boolean var1) {
  }

  @Override
  public void onIceGatheringChange(@NonNull PeerConnection.IceGatheringState iceGatheringState) {
    Log.d(TAG, "onIceGatheringChange" + iceGatheringState.name());
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "iceGatheringState");
    params.putString("state", EnumStringifier.iceGatheringStateString(iceGatheringState));
    sendEvent(params);
  }

  private void sendEvent(@NonNull ConstraintsMap event) {
    if (eventSink != null) {
      eventSink.success(event.toMap());
    }
  }

  @Override
  public void onTrack(RtpTransceiver transceiver) {
  }

  @Override
  public void onAddTrack(@NonNull RtpReceiver receiver, @NonNull MediaStream[] mediaStreams) {
      Log.d(TAG, "onAddTrack");

      ConstraintsMap params = new ConstraintsMap();
      ConstraintsArray streams = new ConstraintsArray();
      for(MediaStream stream : mediaStreams){
          streams.pushMap(new ConstraintsMap(ObjectExporter.exportMediaStream(id, stream)));
      }

      params.putString("event", "onTrack");
      params.putArray("streams", streams.toArrayList());
      params.putMap("track", ObjectExporter.exportMediaStreamTrack(receiver.track()));
      params.putMap("receiver", ObjectExporter.exportRtpReceiver(receiver));

      if(configuration.sdpSemantics == PeerConnection.SdpSemantics.UNIFIED_PLAN) {
            List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
            int id = 0;
            for (RtpTransceiver transceiver : transceivers) {
                if (transceiver.getReceiver() != null && receiver.id().equals(transceiver.getReceiver().id())) {
                    params.putMap("transceiver", ObjectExporter.exportTransceiver(id, transceiver));
                    id++;
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
  public void onSignalingChange(@NonNull PeerConnection.SignalingState signalingState) {
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "signalingState");
    params.putString("state", EnumStringifier.signalingStateString(signalingState));
    sendEvent(params);
  }

  @Override
  public void onConnectionChange(@NonNull PeerConnection.PeerConnectionState connectionState) {
    Log.d(TAG, "onConnectionChange" + connectionState.name());
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "peerConnectionState");
    params.putString("state", EnumStringifier.connectionStateString(connectionState));
    sendEvent(params);
  }

  @NonNull
  private MediaStreamTrack.MediaType stringToMediaType(@NonNull String mediaType) {
    MediaStreamTrack.MediaType type = MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO;
    if(mediaType.equals("audio")){
      type = MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO;
    } else if(mediaType.equals("video")){
      type = MediaStreamTrack.MediaType.MEDIA_TYPE_VIDEO;
    }
    return type;
  }

  @NonNull
  private RtpParameters.Encoding mapToEncoding(@NonNull Map<String, Object> parameters) {
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

  @NonNull
  private RtpTransceiver.RtpTransceiverInit mapToRtpTransceiverInit(@NonNull Map<String, Object> parameters) {
      List<String> streamIds =
              Optional.ofNullable((List<String>) parameters.get("streamIds"))
                      .orElse(new ArrayList<>());
      String direction =
              Optional.ofNullable((String) parameters.get("direction")).orElse("sendrecv");
      List<Map<String, Object>> encodingsParams =
              (List<Map<String, Object>>) parameters.get("sendEncodings");

      if (encodingsParams != null) {
          List<RtpParameters.Encoding> sendEncodings = new ArrayList<>();
          for (int i = 0; i < encodingsParams.size(); i++) {
              Map<String, Object> params = encodingsParams.get(i);
              sendEncodings.add(0, mapToEncoding(params));
          }
          return new RtpTransceiver.RtpTransceiverInit(
                  EnumStringifier.stringToTransceiverDirection(direction), streamIds, sendEncodings);
      } else {
          return new RtpTransceiver.RtpTransceiverInit(
                  EnumStringifier.stringToTransceiverDirection(direction), streamIds);
      }
  }

  @NonNull
  private RtpParameters updateRtpParameters(@NonNull Map<String, Object> newParameters, @NonNull RtpParameters parameters) {
    List<Map<String, Object>> encodings = (List<Map<String, Object>>) newParameters.get("encodings");
    final Iterator<?> encodingsIterator = encodings.iterator();
    final Iterator<?> nativeEncodingsIterator = parameters.encodings.iterator();
    while (encodingsIterator.hasNext() && nativeEncodingsIterator.hasNext()) {
      final RtpParameters.Encoding nativeEncoding = (RtpParameters.Encoding) nativeEncodingsIterator.next();
      final Map<String, Object> encoding = (Map<String, Object>) encodingsIterator.next();
      if (encoding.containsKey("active")) {
        nativeEncoding.active = (Boolean) encoding.get("active");
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
      if (encoding.containsKey("scaleResolutionDownBy")) {
        nativeEncoding.scaleResolutionDownBy = (Double) encoding.get("scaleResolutionDownBy");
      }
    }
    return parameters;
  }

  public void addTrack(MediaStreamTrack track, List<String> streamIds, @NonNull Result result) {
      RtpSender sender = peerConnection.addTrack(track, streamIds);
      result.success(ObjectExporter.exportRtpSender(sender));
  }

  public void removeTrack(@NonNull String senderId, @NonNull Result result) {
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

  public void addTransceiver(MediaStreamTrack track, @Nullable Map<String, Object> transceiverInit, @NonNull Result result) {
      RtpTransceiver  transceiver;
      if(transceiverInit != null){
          transceiver = peerConnection.addTransceiver(track, mapToRtpTransceiverInit(transceiverInit));
      } else {
          transceiver = peerConnection.addTransceiver(track);
      }
      int id = peerConnection.getTransceivers().size() - 1;
      result.success(ObjectExporter.exportTransceiver(id, transceiver));
  }

  public void addTransceiverOfType(@NonNull String mediaType, @Nullable Map<String, Object> transceiverInit, @NonNull Result result) {
      if(transceiverInit != null){
          peerConnection.addTransceiver(stringToMediaType(mediaType), mapToRtpTransceiverInit(transceiverInit));
      } else {
          peerConnection.addTransceiver(stringToMediaType(mediaType));
      }
      List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
      int id = transceivers.size() - 1;
      result.success(ObjectExporter.exportTransceiver(id, transceivers.get(id)));
  }

  public void rtpTransceiverSetDirection(@NonNull String direction, int transceiverId, @NonNull Result result) {
      RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
      if (transceiver == null) {
          resultError("rtpTransceiverSetDirection", "transceiver is null", result);
          return;
      }
      transceiver.setDirection(EnumStringifier.stringToTransceiverDirection(direction));
      result.success(null);
  }

  public void rtpTransceiverGetMid(int transceiverId, @NonNull Result result) {
      RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
      if (transceiver == null) {
          resultError("rtpTransceiverGetMid", "transceiver is null", result);
          return;
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putString("result", transceiver.getMid());
      result.success(params.toMap());
  }

  public void rtpTransceiverGetDirection(int transceiverId, @NonNull Result result) {
      RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
      if (transceiver == null) {
          resultError("rtpTransceiverGetDirection", "transceiver is null", result);
          return;
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putString("result", EnumStringifier.transceiverDirectionString(transceiver.getDirection()));
      result.success(params.toMap());
  }

  public void rtpTransceiverGetCurrentDirection(int transceiverId, @NonNull Result result) {
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
          params.putString("result", EnumStringifier.transceiverDirectionString(direction));
          result.success(params.toMap());
      }
  }

    public void rtpTransceiverStop(int transceiverId, @NonNull Result result) {
        RtpTransceiver transceiver = getRtpTransceiverById(transceiverId);
        if (transceiver == null) {
            resultError("rtpTransceiverStop", "transceiver is null", result);
            return;
        }
        transceiver.stop();
        result.success(null);
    }

    public void rtpSenderSetParameters(@NonNull String rtpSenderId, @NonNull Map<String, Object> parameters, @NonNull Result result) {
        RtpSender sender = getRtpSenderById(rtpSenderId);
        if (sender == null) {
            resultError("rtpSenderSetParameters", "sender is null", result);
            return;
        }
        final RtpParameters updatedParameters = updateRtpParameters(parameters, sender.getParameters());
        final boolean success = sender.setParameters(updatedParameters);
        ConstraintsMap params = new ConstraintsMap();
        params.putBoolean("result", success);
        result.success(params.toMap());
    }

    public void rtpSenderSetTrack(@NonNull String rtpSenderId, MediaStreamTrack track, @NonNull Result result, boolean replace) {
        RtpSender sender = getRtpSenderById(rtpSenderId);
        if (sender == null) {
            resultError("rtpSenderSetTrack", "sender is null", result);
            return;
        }
        sender.setTrack(track, replace);
        result.success(null);
    }

    public void rtpSenderDispose(@NonNull String rtpSenderId, @NonNull Result result) {
        RtpSender sender = getRtpSenderById(rtpSenderId);
        if (sender == null) {
            resultError("rtpSenderDispose", "sender is null", result);
            return;
        }
        sender.dispose();
        result.success(null);
    }

    public void getSenders(@NonNull Result result) {
      List<RtpSender> senders = peerConnection.getSenders();
      ConstraintsArray sendersParams = new ConstraintsArray();
      for (RtpSender sender : senders) {
        sendersParams.pushMap(new ConstraintsMap(ObjectExporter.exportRtpSender(sender)));
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putArray("senders", sendersParams.toArrayList());
      result.success(params.toMap());
    }

    public void getReceivers(@NonNull Result result) {
      List<RtpReceiver> receivers = peerConnection.getReceivers();
      ConstraintsArray receiversParams = new ConstraintsArray();
      for (RtpReceiver receiver : receivers) {
        receiversParams.pushMap(new ConstraintsMap(ObjectExporter.exportRtpReceiver(receiver)));
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putArray("receivers", receiversParams.toArrayList());
      result.success(params.toMap());
    }

    public void getTransceivers(@NonNull Result result) {
      List<RtpTransceiver> transceivers = peerConnection.getTransceivers();
      ConstraintsArray transceiversParams = new ConstraintsArray();
      int id = 0;
      for(RtpTransceiver receiver : transceivers){
        transceiversParams.pushMap(new ConstraintsMap(ObjectExporter.exportTransceiver(id, receiver)));
        id++;
      }
      ConstraintsMap params = new ConstraintsMap();
      params.putArray("transceivers", transceiversParams.toArrayList());
      result.success(params.toMap());
    }

  @Nullable
    MediaStreamTrack getTransceiversTrack(String trackId) {
        if(configuration.sdpSemantics != PeerConnection.SdpSemantics.UNIFIED_PLAN) {
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
