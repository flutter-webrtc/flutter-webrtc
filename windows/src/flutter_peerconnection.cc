#include "flutter_peerconnection.h"
#include "base/scoped_ref_ptr.h"
#include "flutter_data_channel.h"
#include "rtc_rtp_parameters.h"

namespace flutter_webrtc_plugin {

void FlutterPeerConnection::CreateRTCPeerConnection(
    const EncodableMap& configurationMap,
    const EncodableMap& constraintsMap,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  // std::cout << " configuration = " << configurationMap.StringValue() <<
  // std::endl;
  base_->ParseRTCConfiguration(configurationMap, base_->configuration_);
  // std::cout << " constraints = " << constraintsMap.StringValue() <<
  // std::endl;
  scoped_refptr<RTCMediaConstraints> constraints =
      base_->ParseMediaConstraints(constraintsMap);

  std::string uuid = base_->GenerateUUID();
  scoped_refptr<RTCPeerConnection> pc =
      base_->factory_->Create(base_->configuration_, constraints);
  base_->peerconnections_[uuid] = pc;

  std::string event_channel = "FlutterWebRTC/peerConnectoinEvent" + uuid;

  std::unique_ptr<FlutterPeerConnectionObserver> observer(
      new FlutterPeerConnectionObserver(base_, pc, base_->messenger_,
                                        event_channel));

  base_->peerconnection_observers_[uuid] = std::move(observer);

  EncodableMap params;
  params[EncodableValue("peerConnectionId")] = uuid;
  result->Success(EncodableValue(params));
}

void FlutterPeerConnection::RTCPeerConnectionClose(
    RTCPeerConnection* pc,
    const std::string& uuid,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  pc->Close();
  auto it = base_->peerconnection_observers_.find(uuid);
  if (it != base_->peerconnection_observers_.end())
    base_->peerconnection_observers_.erase(it);

  result->Success(nullptr);
}

void FlutterPeerConnection::CreateOffer(
    const EncodableMap& constraintsMap,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  scoped_refptr<RTCMediaConstraints> constraints =
      base_->ParseMediaConstraints(constraintsMap);
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(result.release());
  pc->CreateOffer(
      [result_ptr](const char* sdp, const char* type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = sdp;
        params[EncodableValue("type")] = type;
        result_ptr->Success(EncodableValue(params));
      },
      [result_ptr](const char* error) {
        result_ptr->Error("createOfferFailed", error);
      },
      constraints);
}

void FlutterPeerConnection::CreateAnswer(
    const EncodableMap& constraintsMap,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  scoped_refptr<RTCMediaConstraints> constraints =
      base_->ParseMediaConstraints(constraintsMap);
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(result.release());
  pc->CreateAnswer(
      [result_ptr](const char* sdp, const char* type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = sdp;
        params[EncodableValue("type")] = type;
        result_ptr->Success(EncodableValue(params));
      },
      [result_ptr](const std::string& error) {
        result_ptr->Error("createAnswerFailed", error);
      },
      constraints);
}

void FlutterPeerConnection::SetLocalDescription(
    RTCSessionDescription* sdp,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(result.release());
  pc->SetLocalDescription(
      sdp->sdp(), sdp->type(), [result_ptr]() { result_ptr->Success(nullptr); },
      [result_ptr](const char* error) {
        result_ptr->Error("setLocalDescriptionFailed", error);
      });
}

void FlutterPeerConnection::SetRemoteDescription(
    RTCSessionDescription* sdp,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(result.release());
  pc->SetRemoteDescription(
      sdp->sdp(), sdp->type(), [result_ptr]() { result_ptr->Success(nullptr); },
      [result_ptr](const char* error) {
        result_ptr->Error("setRemoteDescriptionFailed", error);
      });
}

void FlutterPeerConnection::GetLocalDescription(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  pc->GetLocalDescription(
      [result_ptr](const char* sdp, const char* type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = sdp;
        params[EncodableValue("type")] = type;
        result_ptr->Success(EncodableValue(params));
      },
      [result_ptr](const std::string& error) {
        result_ptr->Error("GetLocalDescription", error);
      });
}

void FlutterPeerConnection::GetRemoteDescription(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  pc->GetRemoteDescription(
      [result_ptr](const char* sdp, const char* type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = sdp;
        params[EncodableValue("type")] = type;
        result_ptr->Success(EncodableValue(params));
      },
      [result_ptr](const std::string& error) {
        result_ptr->Error("GetRemoteDescription", error);
      });
}

scoped_refptr<RTCRtpTransceiverInit>
FlutterPeerConnection::mapToRtpTransceiverInit(const EncodableMap& params) {
  scoped_refptr<RTCRtpTransceiverInit> init = RTCRtpTransceiverInit::Create();

  EncodableList streamIds = findList(params, "streamIds");
  if (0 < streamIds.size()) {
    Vector<String> list;
    for (EncodableValue value : streamIds) {
      list.push_back(mapToEncoding(params));
    }
    init->SetStreamIds(list);
  }

  EncodableValue direction = findEncodableValue(params, "direction");
  if (direction.IsNull()) {
    direction = "sendrecv";
    init->SetSendEncodings(
        stringToTransceiverDirection(GetValue<std::string>(direction)));
  }

  EncodableList sendEncodings = findList(params, "sendEncodings");
  if (0 < sendEncodings.size()) {
    Vector<libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters>> list;
    for (EncodableValue value : sendEncodings) {
      list.push_back(mapToEncoding(GetValue<EncodableMap>(value)));
    }
    init->SetSendEncodings(list);
  }

  return init;
}

RTCRtpTransceiverDirection FlutterPeerConnection::stringToTransceiverDirection(
    String direction) {
  if (0 == direction.compare("sendrecv")) {
    return RTCRtpTransceiverDirection::kSendRecv;
  } else if (0 == direction.compare("sendonly")) {
    return RTCRtpTransceiverDirection::kSendOnly;
  } else if (0 == direction.compare("recvonly")) {
    return RTCRtpTransceiverDirection::kRecvOnly;
  } else if (0 == direction.compare("inactive")) {
    return RTCRtpTransceiverDirection::kInactive;
  }
  return RTCRtpTransceiverDirection::kInactive;
}

libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters>
FlutterPeerConnection::mapToEncoding(const EncodableMap& params) {
  libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters> encoding;
  const std::string rid = findString(params, "rid");
  encoding->SetRid(rid);
  encoding->SetActive(true);
  encoding->SetScaleResolutionDownBy(1.0);

  EncodableValue value = findEncodableValue(params, "active");
  if (!value.IsNull()) {
    encoding->SetActive(GetValue<bool>(value));
  }

  EncodableValue value = findEncodableValue(params, "ssrc");
  if (!value.IsNull()) {
    encoding->SetSsrc(GetValue<uint32_t>(value));
  }
  
  EncodableValue value = findEncodableValue(params, "minBitrate");
  if (!value.IsNull()) {
    encoding->SetMinBitrateBps(GetValue<int>(value));
  }

  EncodableValue value = findEncodableValue(params, "maxBitrate");
  if (!value.IsNull()) {
    encoding->SetMaxBitrateBps(GetValue<int>(value));
  }

  EncodableValue value = findEncodableValue(params, "maxFramerate");
  if (!value.IsNull()) {
    encoding->SetMaxFramerate(GetValue<double>(value));
  }

  EncodableValue value = findEncodableValue(params, "numTemporalLayers");
  if (!value.IsNull()) {
    encoding->SetNumTemporalLayers(GetValue<int>(value));
  }

    EncodableValue value = findEncodableValue(params, "scaleResolutionDownBy");
  if (!value.IsNull()) {
      encoding->SetScaleResolutionDownBy(GetValue<double>(value));
  }

  return encoding;
}

  EncodableMap FlutterPeerConnection::transceiverToMap(
    scoped_refptr<RTCRtpTransceiver> transceiver) {
  EncodableMap info;
    info[EncodableValue("transceiverId")] =
        EncodableValue(transceiver->GetMid()); 

    info[EncodableValue("mid")] =
        EncodableValue(transceiver->GetMid()); 
    
    info[EncodableValue("direction")] =
        transceiverDirectionString(transceiver->Direction());
        
    info[EncodableValue("sender")] = rtpSenderToMap(transceiver->Sender());

    info[EncodableValue("receiver")] =
        rtpReceiverToMap(transceiver->Receiver());
  return info;
}

void FlutterPeerConnection::AddTransceiver(
    RTCPeerConnection* pc,
    RTCMediaTrack* track,
    const EncodableMap& transceiverInit,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

  if (0 < transceiverInit.size()) {
    pc->AddTransceiver(
        track, mapToRtpTransceiverInit(transceiverInit),
        [=](scoped_refptr<RTCRtpTransceiver> transceiver, const char* message) {
          result_ptr.Success(transceiverToMap(transceiver));
        });
  } else {
    pc->AddTransceiver(track, [=](scoped_refptr<RTCRtpTransceiver> transceiver,
                                  const char* message) {
      result_ptr.Success(transceiverToMap(transceiver));
    });
  }
}

void FlutterPeerConnection::GetTransceivers(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::GetReceivers(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::RtpSenderDispose(
    RTCPeerConnection* pc,
    std::string rtpSenderId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::RtpSenderSetTrack(
    RTCPeerConnection* pc,
    RTCMediaTrack* track,
    std::string rtpSenderId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::RtpSenderReplaceTrack(
    RTCPeerConnection* pc,
    RTCMediaTrack* track,
    std::string rtpSenderId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::RtpSenderSetParameters(
    RTCPeerConnection* pc,
    std::string rtpSenderId,
    const EncodableMap& parameters,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::RtpTransceiverStop(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::RtpTransceiverGetCurrentDirection(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::SetConfiguration(
    RTCPeerConnection* pc,
    const EncodableMap& configuration,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::CaptureFrame(
    RTCVideoTrack* track,
    std::string path,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::RtpTransceiverSetDirection(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::string direction,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
}

void FlutterPeerConnection::GetSenders(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  pc->GetSenders();
}

void FlutterPeerConnection::AddIceCandidate(
    RTCIceCandidate* candidate,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  pc->AddCandidate(candidate->sdp_mid(), candidate->sdp_mline_index(),
                   candidate->candidate());
  result->Success(nullptr);
}

void FlutterPeerConnection::GetStats(
    const std::string& track_id,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> result) {}

void FlutterPeerConnection::MediaStreamAddTrack(
    scoped_refptr<RTCMediaStream> stream,
    scoped_refptr<RTCMediaTrack> track,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  std::string kind = track->kind();
  if (0 == kind.compare("audio")) {
    stream->AddTrack(static_cast<RTCAudioTrack*>(track.get()));
  } else if (0 == kind.compare("video")) {
    stream->AddTrack(static_cast<RTCVideoTrack*>(track.get()));
  }

  result_ptr->Success(nullptr);
}

void FlutterPeerConnection::MediaStreamRemoveTrack(
    scoped_refptr<RTCMediaStream> stream,
    scoped_refptr<RTCMediaTrack> track,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  std::string kind = track->kind();
  if (0 == kind.compare("audio")) {
    stream->RemoveTrack(static_cast<RTCAudioTrack*>(track.get()));
  } else if (0 == kind.compare("video")) {
    stream->RemoveTrack(static_cast<RTCVideoTrack*>(track.get()));
  }

  result_ptr->Success(nullptr);
}

void FlutterPeerConnection::AddTrack(
    RTCPeerConnection* pc,
    scoped_refptr<RTCMediaTrack> track,
    std::list<std::string> streamIds,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::string kind = track->kind();
  if (0 == kind.compare("audio")) {
    pc->AddTrack(
        (RTCAudioTrack*)track.get(), streamIds,
        [=](scoped_refptr<RTCRtpSender> render, const char* message) {});
  } else if (0 == kind.compare("video")) {
    pc->AddTrack(
        (RTCVideoTrack*)track.get(), streamIds,
        [=](scoped_refptr<RTCRtpSender> render, const char* message) {});
  }

  result->Success(nullptr);
}

void FlutterPeerConnection::RemoveTrack(
    RTCPeerConnection* pc,
    std::string senderId,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  result->Success(nullptr);
}

FlutterPeerConnectionObserver::FlutterPeerConnectionObserver(
    FlutterWebRTCBase* base,
    scoped_refptr<RTCPeerConnection> peerconnection,
    BinaryMessenger* messenger,
    const std::string& channel_name)
    : event_channel_(new EventChannel<EncodableValue>(
          messenger,
          channel_name,
          &StandardMethodCodec::GetInstance())),
      peerconnection_(peerconnection),
      base_(base) {
  auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
      [&](const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_sink_ = std::move(events);
        return nullptr;
      },
      [&](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_sink_ = nullptr;
        return nullptr;
      });

  event_channel_->SetStreamHandler(std::move(handler));
  peerconnection->RegisterRTCPeerConnectionObserver(this);
}

static const char* iceConnectionStateString(RTCIceConnectionState state) {
  switch (state) {
    case RTCIceConnectionStateNew:
      return "new";
    case RTCIceConnectionStateChecking:
      return "checking";
    case RTCIceConnectionStateConnected:
      return "connected";
    case RTCIceConnectionStateCompleted:
      return "completed";
    case RTCIceConnectionStateFailed:
      return "failed";
    case RTCIceConnectionStateDisconnected:
      return "disconnected";
    case RTCIceConnectionStateClosed:
      return "closed";
  }
  return "";
}

static const char* signalingStateString(RTCSignalingState state) {
  switch (state) {
    case RTCSignalingStateStable:
      return "stable";
    case RTCSignalingStateHaveLocalOffer:
      return "have-local-offer";
    case RTCSignalingStateHaveLocalPrAnswer:
      return "have-local-pranswer";
    case RTCSignalingStateHaveRemoteOffer:
      return "have-remote-offer";
    case RTCSignalingStateHaveRemotePrAnswer:
      return "have-remote-pranswer";
    case RTCSignalingStateClosed:
      return "closed";
  }
  return "";
}
void FlutterPeerConnectionObserver::OnSignalingState(RTCSignalingState state) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "signalingState";
    params[EncodableValue("state")] = signalingStateString(state);
    event_sink_->Success(EncodableValue(params));
  }
}

static const char* iceGatheringStateString(RTCIceGatheringState state) {
  switch (state) {
    case RTCIceGatheringStateNew:
      return "new";
    case RTCIceGatheringStateGathering:
      return "gathering";
    case RTCIceGatheringStateComplete:
      return "complete";
  }
  return "";
}

void FlutterPeerConnectionObserver::OnIceGatheringState(
    RTCIceGatheringState state) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "iceGatheringState";
    params[EncodableValue("state")] = iceGatheringStateString(state);
    event_sink_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnIceConnectionState(
    RTCIceConnectionState state) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "iceConnectionState";
    params[EncodableValue("state")] = iceConnectionStateString(state);
    event_sink_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnIceCandidate(
    scoped_refptr<RTCIceCandidate> candidate) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onCandidate";
    EncodableMap cand;
    cand[EncodableValue("candidate")] = candidate->candidate();
    cand[EncodableValue("sdpMLineIndex")] = candidate->sdp_mline_index();
    cand[EncodableValue("sdpMid")] = candidate->sdp_mid();
    params[EncodableValue("candidate")] = cand;
    event_sink_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnAddStream(
    scoped_refptr<RTCMediaStream> stream) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onAddStream";
    params[EncodableValue("streamId")] = stream->label();
    EncodableList audioTracks;
    for (auto track : stream->GetAudioTracks()) {
      EncodableMap audioTrack;
      audioTrack[EncodableValue("id")] = track->id();
      audioTrack[EncodableValue("label")] = track->id();
      audioTrack[EncodableValue("kind")] = track->kind();
      audioTrack[EncodableValue("enabled")] = track->enabled();
      audioTrack[EncodableValue("remote")] = true;
      audioTrack[EncodableValue("readyState")] = "live";

      audioTracks.push_back(EncodableValue(audioTrack));
    }
    params[EncodableValue("audioTracks")] = audioTracks;

    EncodableList videoTracks;
    for (auto track : stream->GetVideoTracks()) {
      EncodableMap videoTrack;

      videoTrack[EncodableValue("id")] = track->id();
      videoTrack[EncodableValue("label")] = track->id();
      videoTrack[EncodableValue("kind")] = track->kind();
      videoTrack[EncodableValue("enabled")] = track->enabled();
      videoTrack[EncodableValue("remote")] = true;
      videoTrack[EncodableValue("readyState")] = "live";

      videoTracks.push_back(EncodableValue(videoTrack));
    }

    remote_streams_[stream->label()] = scoped_refptr<RTCMediaStream>(stream);
    params[EncodableValue("videoTracks")] = videoTracks;
    event_sink_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnRemoveStream(
    scoped_refptr<RTCMediaStream> stream) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onRemoveStream";
    params[EncodableValue("streamId")] = stream->label();
    event_sink_->Success(EncodableValue(params));
  }
  RemoveStreamForId(stream->label());
}

void FlutterPeerConnectionObserver::OnAddTrack(
    scoped_refptr<RTCMediaStream> stream,
    scoped_refptr<RTCMediaTrack> track) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onAddTrack";
    params[EncodableValue("streamId")] = stream->label();
    params[EncodableValue("trackId")] = track->id();

    EncodableMap audioTrack;
    audioTrack[EncodableValue("id")] = track->id();
    audioTrack[EncodableValue("label")] = track->id();
    audioTrack[EncodableValue("kind")] = track->kind();
    audioTrack[EncodableValue("enabled")] = track->enabled();
    audioTrack[EncodableValue("remote")] = true;
    audioTrack[EncodableValue("readyState")] = "live";
    params[EncodableValue("track")] = audioTrack;

    event_sink_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnRemoveTrack(
    scoped_refptr<RTCMediaStream> stream,
    scoped_refptr<RTCMediaTrack> track) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onRemoveTrack";
    params[EncodableValue("streamId")] = stream->label();
    params[EncodableValue("trackId")] = track->id();

    EncodableMap videoTrack;
    videoTrack[EncodableValue("id")] = track->id();
    videoTrack[EncodableValue("label")] = track->id();
    videoTrack[EncodableValue("kind")] = track->kind();
    videoTrack[EncodableValue("enabled")] = track->enabled();
    videoTrack[EncodableValue("remote")] = true;
    videoTrack[EncodableValue("readyState")] = "live";
    params[EncodableValue("track")] = videoTrack;

    event_sink_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnDataChannel(
    scoped_refptr<RTCDataChannel> data_channel) {
  std::string event_channel =
      "FlutterWebRTC/dataChannelEvent" + std::to_string(data_channel->id());

  std::unique_ptr<FlutterRTCDataChannelObserver> observer(
      new FlutterRTCDataChannelObserver(data_channel, base_->messenger_,
                                        event_channel));

  base_->data_channel_observers_[data_channel->id()] = std::move(observer);
  if (event_sink_) {
    EncodableMap params;
    params[EncodableValue("event")] = "didOpenDataChannel";
    params[EncodableValue("id")] = data_channel->id();
    params[EncodableValue("label")] = data_channel->label();
    event_sink_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnRenegotiationNeeded() {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onRenegotiationNeeded";
    event_sink_->Success(EncodableValue(params));
  }
}

}  // namespace flutter_webrtc_plugin
