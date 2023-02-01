#include "flutter_peerconnection.h"

#include "base/scoped_ref_ptr.h"
#include "flutter_data_channel.h"
#include "rtc_dtmf_sender.h"
#include "rtc_rtp_parameters.h"

namespace flutter_webrtc_plugin {

std::string RTCMediaTypeToString(RTCMediaType type) {
  switch (type) {
    case libwebrtc::RTCMediaType::ANY:
      return "any";
    case libwebrtc::RTCMediaType::AUDIO:
      return "audio";
    case libwebrtc::RTCMediaType::VIDEO:
      return "video";
    case libwebrtc::RTCMediaType::DATA:
      return "data";
    default:
      return "";
  }
}
std::string transceiverDirectionString(RTCRtpTransceiverDirection direction) {
  switch (direction) {
    case RTCRtpTransceiverDirection::kSendRecv:
      return "sendrecv";
    case RTCRtpTransceiverDirection::kSendOnly:
      return "sendonly";
    case RTCRtpTransceiverDirection::kRecvOnly:
      return "recvonly";
    case RTCRtpTransceiverDirection::kInactive:
      return "inactive";
    case RTCRtpTransceiverDirection::kStopped:
      return "stoped";
  }
  return "";
}

EncodableMap rtpParametersToMap(
    libwebrtc::scoped_refptr<libwebrtc::RTCRtpParameters> rtpParameters) {
  EncodableMap info;
  info[EncodableValue("transactionId")] =
      EncodableValue(rtpParameters->transaction_id().std_string());

  EncodableMap rtcp;
  rtcp[EncodableValue("cname")] =
      EncodableValue(rtpParameters->rtcp_parameters()->cname().std_string());
  rtcp[EncodableValue("reducedSize")] =
      EncodableValue(rtpParameters->rtcp_parameters()->reduced_size());

  info[EncodableValue("rtcp")] = EncodableValue((rtcp));

  EncodableList headerExtensions;
  auto header_extensions = rtpParameters->header_extensions();
  for (scoped_refptr<libwebrtc::RTCRtpExtension> extension :
       header_extensions.std_vector()) {
    EncodableMap map;
    map[EncodableValue("uri")] = EncodableValue(extension->uri().std_string());
    map[EncodableValue("id")] = EncodableValue(extension->id());
    map[EncodableValue("encrypted")] = EncodableValue(extension->encrypt());
    headerExtensions.push_back(EncodableValue(map));
  }
  info[EncodableValue("headerExtensions")] = EncodableValue(headerExtensions);

  EncodableList encodings_info;
  auto encodings = rtpParameters->encodings();
  for (scoped_refptr<libwebrtc::RTCRtpEncodingParameters> encoding :
       encodings.std_vector()) {
    EncodableMap map;
    map[EncodableValue("active")] = EncodableValue(encoding->active());
    map[EncodableValue("maxBitrate")] =
        EncodableValue(encoding->max_bitrate_bps());
    map[EncodableValue("minBitrate")] =
        EncodableValue(encoding->min_bitrate_bps());
    map[EncodableValue("maxFramerate")] =
        EncodableValue((int)encoding->max_framerate());
    map[EncodableValue("scaleResolutionDownBy")] =
        EncodableValue(encoding->scale_resolution_down_by());
    map[EncodableValue("ssrc")] = EncodableValue((long)encoding->ssrc());
    encodings_info.push_back(EncodableValue(map));
  }
  info[EncodableValue("encodings")] = EncodableValue(encodings_info);

  EncodableList codecs_info;
  auto codecs = rtpParameters->codecs();
  for (scoped_refptr<RTCRtpCodecParameters> codec : codecs.std_vector()) {
    EncodableMap map;
    map[EncodableValue("name")] = EncodableValue(codec->name().std_string());
    map[EncodableValue("payloadType")] = EncodableValue(codec->payload_type());
    map[EncodableValue("clockRate")] = EncodableValue(codec->clock_rate());
    map[EncodableValue("numChannels")] = EncodableValue(codec->num_channels());

    EncodableMap param;
    auto parameters = codec->parameters();
    for (auto item : parameters.std_vector()) {
      param[EncodableValue(item.first.std_string())] =
          EncodableValue(item.second.std_string());
    }
    map[EncodableValue("parameters")] = EncodableValue(param);

    map[EncodableValue("kind")] =
        EncodableValue(RTCMediaTypeToString(codec->kind()));

    codecs_info.push_back(EncodableValue(map));
  }
  info[EncodableValue("codecs")] = EncodableValue(codecs_info);

  return info;
}

EncodableMap dtmfSenderToMap(scoped_refptr<RTCDtmfSender> dtmfSender,
                             std::string id) {
  EncodableMap info;
  if (nullptr != dtmfSender.get()) {
    info[EncodableValue("dtmfSenderId")] = EncodableValue(id);
    if (dtmfSender.get()) {
      info[EncodableValue("interToneGap")] =
          EncodableValue(dtmfSender->inter_tone_gap());
      info[EncodableValue("duration")] = EncodableValue(dtmfSender->duration());
    }
  }
  return info;
}

EncodableMap mediaTrackToMap(
    libwebrtc::scoped_refptr<libwebrtc::RTCMediaTrack> track) {
  EncodableMap info;
  if (nullptr == track.get()) {
    return info;
  }
  info[EncodableValue("id")] = EncodableValue(track->id().std_string());
  info[EncodableValue("kind")] = EncodableValue(track->kind().std_string());
  std::string kind = track->kind().std_string();
  if (0 == kind.compare("video")) {
    info[EncodableValue("readyState")] =
        EncodableValue(static_cast<RTCVideoTrack*>(track.get())->state());
    info[EncodableValue("label")] = EncodableValue("video");
  } else if (0 == kind.compare("audio")) {
    info[EncodableValue("readyState")] =
        EncodableValue(static_cast<RTCAudioTrack*>(track.get())->state());
    info[EncodableValue("label")] = EncodableValue("audio");
  }
  info[EncodableValue("enabled")] = EncodableValue(track->enabled());

  return info;
}

EncodableMap rtpSenderToMap(
    libwebrtc::scoped_refptr<libwebrtc::RTCRtpSender> sender) {
  EncodableMap info;
  std::string id = sender->id().std_string();
  info[EncodableValue("senderId")] = EncodableValue(id);
  info[EncodableValue("ownsTrack")] = EncodableValue(true);
  info[EncodableValue("dtmfSender")] =
      EncodableValue(dtmfSenderToMap(sender->dtmf_sender(), id));
  info[EncodableValue("rtpParameters")] =
      EncodableValue(rtpParametersToMap(sender->parameters()));
  info[EncodableValue("track")] =
      EncodableValue(mediaTrackToMap(sender->track()));
  return info;
}

std::string trackStateToString(libwebrtc::RTCMediaTrack::RTCTrackState state) {
  switch (state) {
    case libwebrtc::RTCMediaTrack::kLive:
      return "live";
    case libwebrtc::RTCMediaTrack::kEnded:
      return "ended";
    default:
      return "";
  }
}

EncodableMap rtpReceiverToMap(
    libwebrtc::scoped_refptr<libwebrtc::RTCRtpReceiver> receiver) {
  EncodableMap info;
  info[EncodableValue("receiverId")] =
      EncodableValue(receiver->id().std_string());
  info[EncodableValue("rtpParameters")] =
      EncodableValue(rtpParametersToMap(receiver->parameters()));
  info[EncodableValue("track")] =
      EncodableValue(mediaTrackToMap(receiver->track()));
  return info;
}

EncodableMap transceiverToMap(scoped_refptr<RTCRtpTransceiver> transceiver) {
  EncodableMap info;
  std::string mid = transceiver->mid().std_string();
  info[EncodableValue("transceiverId")] = EncodableValue(mid);
  info[EncodableValue("mid")] = EncodableValue(mid);
  info[EncodableValue("direction")] =
      EncodableValue(transceiverDirectionString(transceiver->direction()));
  info[EncodableValue("sender")] =
      EncodableValue(rtpSenderToMap(transceiver->sender()));
  info[EncodableValue("receiver")] =
      EncodableValue(rtpReceiverToMap(transceiver->receiver()));
  return info;
}

EncodableMap mediaStreamToMap(scoped_refptr<RTCMediaStream> stream,
                              std::string id) {
  EncodableMap params;
  params[EncodableValue("streamId")] =
      EncodableValue(stream->id().std_string());
  params[EncodableValue("ownerTag")] = EncodableValue(id);
  EncodableList audioTracks;
  auto audio_tracks = stream->audio_tracks();
  for (scoped_refptr<RTCAudioTrack> val : audio_tracks.std_vector()) {
    audioTracks.push_back(EncodableValue(mediaTrackToMap(val)));
  }
  params[EncodableValue("audioTracks")] = EncodableValue(audioTracks);

  EncodableList videoTracks;
  auto video_tracks = stream->video_tracks();
  for (scoped_refptr<RTCVideoTrack> val : video_tracks.std_vector()) {
    videoTracks.push_back(EncodableValue(mediaTrackToMap(val)));
  }
  params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);
  return params;
}

void FlutterPeerConnection::CreateRTCPeerConnection(
    const EncodableMap& configurationMap,
    const EncodableMap& constraintsMap,
    std::unique_ptr<MethodResultProxy> result) {
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

  std::string event_channel = "FlutterWebRTC/peerConnectionEvent" + uuid;

  std::unique_ptr<FlutterPeerConnectionObserver> observer(
      new FlutterPeerConnectionObserver(base_, pc, base_->messenger_,
                                        event_channel, uuid));

  base_->peerconnection_observers_[uuid] = std::move(observer);

  EncodableMap params;
  params[EncodableValue("peerConnectionId")] = EncodableValue(uuid);
  result->Success(EncodableValue(params));
}

void FlutterPeerConnection::RTCPeerConnectionClose(
    RTCPeerConnection* pc,
    const std::string& uuid,
    std::unique_ptr<MethodResultProxy> result) {
  pc->Close();
  result->Success();
}

void FlutterPeerConnection::RTCPeerConnectionDispose(
    RTCPeerConnection* pc,
    const std::string& uuid,
    std::unique_ptr<MethodResultProxy> result) {
  auto it = base_->peerconnection_observers_.find(uuid);
  if (it != base_->peerconnection_observers_.end())
    base_->peerconnection_observers_.erase(it);
  auto it2 = base_->peerconnections_.find(uuid);
  if (it2 != base_->peerconnections_.end())
    base_->peerconnections_.erase(it2);
  result->Success();
}

void FlutterPeerConnection::CreateOffer(
    const EncodableMap& constraintsMap,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  scoped_refptr<RTCMediaConstraints> constraints =
      base_->ParseMediaConstraints(constraintsMap);
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  pc->CreateOffer(
      [result_ptr](const libwebrtc::string sdp, const libwebrtc::string type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = EncodableValue(sdp.std_string());
        params[EncodableValue("type")] = EncodableValue(type.std_string());
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
    std::unique_ptr<MethodResultProxy> result) {
  scoped_refptr<RTCMediaConstraints> constraints =
      base_->ParseMediaConstraints(constraintsMap);
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  pc->CreateAnswer(
      [result_ptr](const libwebrtc::string sdp, const libwebrtc::string type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = EncodableValue(sdp.std_string());
        params[EncodableValue("type")] = EncodableValue(type.std_string());
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
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  pc->SetLocalDescription(
      sdp->sdp(), sdp->type(), [result_ptr]() { result_ptr->Success(); },
      [result_ptr](const char* error) {
        result_ptr->Error("setLocalDescriptionFailed", error);
      });
}

void FlutterPeerConnection::SetRemoteDescription(
    RTCSessionDescription* sdp,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  pc->SetRemoteDescription(
      sdp->sdp(), sdp->type(), [result_ptr]() { result_ptr->Success(); },
      [result_ptr](const char* error) {
        result_ptr->Error("setRemoteDescriptionFailed", error);
      });
}

void FlutterPeerConnection::GetLocalDescription(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  pc->GetLocalDescription(
      [result_ptr](const char* sdp, const char* type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = sdp;
        params[EncodableValue("type")] = type;
        result_ptr->Success(EncodableValue(params));
      },
      [result_ptr](const std::string& error) { result_ptr->Success(); });
}

void FlutterPeerConnection::GetRemoteDescription(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  pc->GetRemoteDescription(
      [result_ptr](const char* sdp, const char* type) {
        EncodableMap params;
        params[EncodableValue("sdp")] = sdp;
        params[EncodableValue("type")] = type;
        result_ptr->Success(EncodableValue(params));
      },
      [result_ptr](const std::string& error) { result_ptr->Success(); });
}

scoped_refptr<RTCRtpTransceiverInit>
FlutterPeerConnection::mapToRtpTransceiverInit(const EncodableMap& params) {
  EncodableList streamIds = findList(params, "streamIds");

  std::vector<string> stream_ids;
  for (auto item : streamIds) {
    std::string id = GetValue<std::string>(item);
    stream_ids.push_back(id.c_str());
  }
  RTCRtpTransceiverDirection dir = RTCRtpTransceiverDirection::kInactive;
  EncodableValue direction = findEncodableValue(params, "direction");
  if (!direction.IsNull()) {
    dir = stringToTransceiverDirection(GetValue<std::string>(direction));
  }
  EncodableList sendEncodings = findList(params, "sendEncodings");
  std::vector<scoped_refptr<RTCRtpEncodingParameters>> encodings;
  for (EncodableValue value : sendEncodings) {
    encodings.push_back(mapToEncoding(GetValue<EncodableMap>(value)));
  }
  scoped_refptr<RTCRtpTransceiverInit> init =
      RTCRtpTransceiverInit::Create(dir, stream_ids, encodings);
  return init;
}

RTCRtpTransceiverDirection FlutterPeerConnection::stringToTransceiverDirection(
    std::string direction) {
  if (0 == direction.compare("sendrecv")) {
    return RTCRtpTransceiverDirection::kSendRecv;
  } else if (0 == direction.compare("sendonly")) {
    return RTCRtpTransceiverDirection::kSendOnly;
  } else if (0 == direction.compare("recvonly")) {
    return RTCRtpTransceiverDirection::kRecvOnly;
  } else if (0 == direction.compare("stoped")) {
    return RTCRtpTransceiverDirection::kStopped;
  } else if (0 == direction.compare("inactive")) {
    return RTCRtpTransceiverDirection::kInactive;
  }
  return RTCRtpTransceiverDirection::kInactive;
}

libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters>
FlutterPeerConnection::mapToEncoding(const EncodableMap& params) {
  libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters> encoding =
      RTCRtpEncodingParameters::Create();

  encoding->set_active(true);
  encoding->set_scale_resolution_down_by(1.0);

  EncodableValue value = findEncodableValue(params, "active");
  if (!value.IsNull()) {
    encoding->set_active(GetValue<bool>(value));
  }

  value = findEncodableValue(params, "rid");
  if (!value.IsNull()) {
    const std::string rid = GetValue<std::string>(value);
    encoding->set_rid(rid.c_str());
  }

  value = findEncodableValue(params, "ssrc");
  if (!value.IsNull()) {
    encoding->set_ssrc((uint32_t)GetValue<int>(value));
  }

  value = findEncodableValue(params, "minBitrate");
  if (!value.IsNull()) {
    encoding->set_min_bitrate_bps(GetValue<int>(value));
  }

  value = findEncodableValue(params, "maxBitrate");
  if (!value.IsNull()) {
    encoding->set_max_bitrate_bps(GetValue<int>(value));
  }

  value = findEncodableValue(params, "maxFramerate");
  if (!value.IsNull()) {
    encoding->set_max_framerate(GetValue<int>(value));
  }

  value = findEncodableValue(params, "numTemporalLayers");
  if (!value.IsNull()) {
    encoding->set_num_temporal_layers(GetValue<int>(value));
  }

  value = findEncodableValue(params, "scaleResolutionDownBy");
  if (!value.IsNull()) {
    encoding->set_scale_resolution_down_by(GetValue<double>(value));
  }

  return encoding;
}

RTCMediaType stringToMediaType(const std::string& mediaType) {
  RTCMediaType type = RTCMediaType::ANY;
  if (mediaType == "audio")
    type = RTCMediaType::AUDIO;
  else if (mediaType == "video")
    type = RTCMediaType::VIDEO;
  return type;
}

void FlutterPeerConnection::AddTransceiver(
    RTCPeerConnection* pc,
    const std::string& trackId,
    const std::string& mediaType,
    const EncodableMap& transceiverInit,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  RTCMediaTrack* track = base_->MediaTrackForId(trackId);
  RTCMediaType type = stringToMediaType(mediaType);

  if (0 < transceiverInit.size()) {
    auto transceiver =
        track != nullptr ? pc->AddTransceiver(
                               track, mapToRtpTransceiverInit(transceiverInit))
                         : pc->AddTransceiver(
                               type, mapToRtpTransceiverInit(transceiverInit));
    if (nullptr != transceiver.get()) {
      result_ptr->Success(EncodableValue(transceiverToMap(transceiver)));
      return;
    }
    result_ptr->Error("AddTransceiver(track | mediaType, init)",
                      "AddTransceiver error");
  } else {
    auto transceiver =
        track != nullptr ? pc->AddTransceiver(track) : pc->AddTransceiver(type);
    if (nullptr != transceiver.get()) {
      result_ptr->Success(EncodableValue(transceiverToMap(transceiver)));
      return;
    }
    result_ptr->Error("AddTransceiver(track, mediaType)",
                      "AddTransceiver error");
  }
}

void FlutterPeerConnection::GetTransceivers(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  EncodableMap map;
  EncodableList info;
  auto transceivers = pc->transceivers();
  for (scoped_refptr<RTCRtpTransceiver> transceiver :
       transceivers.std_vector()) {
    info.push_back(EncodableValue(transceiverToMap(transceiver)));
  }
  map[EncodableValue("transceivers")] = EncodableValue(info);
  result_ptr->Success(EncodableValue(map));
}

void FlutterPeerConnection::GetReceivers(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  EncodableMap map;
  EncodableList info;
  auto receivers = pc->receivers();
  for (scoped_refptr<RTCRtpReceiver> receiver : receivers.std_vector()) {
    info.push_back(EncodableValue(rtpReceiverToMap(receiver)));
  }
  map[EncodableValue("receivers")] = EncodableValue(info);
  result_ptr->Success(EncodableValue(map));
}

void FlutterPeerConnection::RtpSenderDispose(
    RTCPeerConnection* pc,
    std::string rtpSenderId,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  auto sender = GetRtpSenderById(pc, rtpSenderId);
  if (nullptr == sender.get()) {
    result_ptr->Error("rtpSenderDispose", "sender is null");
    return;
  }
  // TODO RtpSenderDispose
  result_ptr->Success();
}

void FlutterPeerConnection::RtpSenderSetTrack(
    RTCPeerConnection* pc,
    RTCMediaTrack* track,
    std::string rtpSenderId,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  auto sender = GetRtpSenderById(pc, rtpSenderId);
  if (nullptr == sender.get()) {
    result_ptr->Error("rtpSenderDispose", "sender is null");
    return;
  }
  sender->set_track(track);
  result_ptr->Success();
}

void FlutterPeerConnection::RtpSenderReplaceTrack(
    RTCPeerConnection* pc,
    RTCMediaTrack* track,
    std::string rtpSenderId,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  auto sender = GetRtpSenderById(pc, rtpSenderId);
  if (nullptr == sender.get()) {
    result_ptr->Error("rtpSenderDispose", "sender is null");
    return;
  }

  sender->set_track(track);

  result_ptr->Success();
}

scoped_refptr<RTCRtpParameters> FlutterPeerConnection::updateRtpParameters(
    EncodableMap newParameters,
    scoped_refptr<RTCRtpParameters> parameters) {
  EncodableList encodings = findList(newParameters, "encodings");
  auto encoding = encodings.begin();
  auto params = parameters->encodings();
  for (auto param : params.std_vector()) {
    if (encoding != encodings.end()) {
      EncodableMap map = GetValue<EncodableMap>(*encoding);
      EncodableValue value = findEncodableValue(map, "active");
      if (!value.IsNull()) {
        param->set_active(GetValue<bool>(value));
      }

      value = findEncodableValue(map, "maxBitrate");
      if (!value.IsNull()) {
        param->set_max_bitrate_bps(GetValue<int>(value));
      }

      value = findEncodableValue(map, "minBitrate");
      if (!value.IsNull()) {
        param->set_min_bitrate_bps(GetValue<int>(value));
      }

      value = findEncodableValue(map, "maxFramerate");
      if (!value.IsNull()) {
        param->set_max_framerate(GetValue<int>(value));
      }
      value = findEncodableValue(map, "numTemporalLayers");
      if (!value.IsNull()) {
        param->set_num_temporal_layers(GetValue<int>(value));
      }
      value = findEncodableValue(map, "scaleResolutionDownBy");
      if (!value.IsNull()) {
        param->set_scale_resolution_down_by(GetValue<int>(value));
      }

      encoding++;
    }
  }

  return parameters;
}

void FlutterPeerConnection::RtpSenderSetParameters(
    RTCPeerConnection* pc,
    std::string rtpSenderId,
    const EncodableMap& parameters,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  auto sender = GetRtpSenderById(pc, rtpSenderId);
  if (nullptr == sender.get()) {
    result_ptr->Error("rtpSenderDispose", "sender is null");
    return;
  }

  auto param = sender->parameters();
  param = updateRtpParameters(parameters, param);
  sender->set_parameters(param);

  result_ptr->Success();
}

void FlutterPeerConnection::RtpTransceiverStop(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  auto transceiver = getRtpTransceiverById(pc, rtpTransceiverId);
  if (nullptr == transceiver.get()) {
    result_ptr->Error("rtpTransceiverStop", "transceiver is null");
  }
  transceiver->StopInternal();
  result_ptr->Success();
}

void FlutterPeerConnection::RtpTransceiverGetCurrentDirection(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  auto transceiver = getRtpTransceiverById(pc, rtpTransceiverId);
  if (nullptr == transceiver.get()) {
    result_ptr->Error("rtpTransceiverGetCurrentDirection",
                      "transceiver is null");
  }
  EncodableMap map;
  map[EncodableValue("result")] =
      EncodableValue(transceiverDirectionString(transceiver->direction()));
  result_ptr->Success(EncodableValue(map));
}

void FlutterPeerConnection::SetConfiguration(
    RTCPeerConnection* pc,
    const EncodableMap& configuration,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  // TODO pc->SetConfiguration();

  result_ptr->Success();
}

void FlutterPeerConnection::CaptureFrame(
    RTCVideoTrack* track,
    std::string path,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  // TODO pc->CaptureFrame();

  result_ptr->Success();
}

scoped_refptr<RTCRtpTransceiver> FlutterPeerConnection::getRtpTransceiverById(
    RTCPeerConnection* pc,
    std::string id) {
  scoped_refptr<RTCRtpTransceiver> result;
  auto transceivers = pc->transceivers();
  for (scoped_refptr<RTCRtpTransceiver> transceiver :
       transceivers.std_vector()) {
    std::string mid = transceiver->mid().std_string();
    if (nullptr == result.get() && 0 == id.compare(mid)) {
      result = transceiver;
    }
  }
  return result;
}

void FlutterPeerConnection::RtpTransceiverSetDirection(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::string direction,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  auto transceiver = getRtpTransceiverById(pc, rtpTransceiverId);
  if (nullptr == transceiver.get()) {
    result_ptr->Error("RtpTransceiverSetDirection", " transceiver is null ");
    return;
  }
  auto res = transceiver->SetDirectionWithError(
      stringToTransceiverDirection(direction));
  if (res.std_string() == "") {
    result_ptr->Success();
  } else {
    result_ptr->Error("RtpTransceiverSetDirection", res.std_string());
  }
}

void FlutterPeerConnection::RtpTransceiverSetCodecPreferences(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    const EncodableList codecs,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  auto transceiver = getRtpTransceiverById(pc, rtpTransceiverId);
  if (nullptr == transceiver.get()) {
    result_ptr->Error("RtpTransceiverSetCodecPreferences", " transceiver is null ");
    return;
  }
  std::vector<scoped_refptr<RTCRtpCodecCapability>> codecList;
  for(auto codec : codecs) {
    auto codecMap = GetValue<EncodableMap>(codec);
    auto codecMimeType = findString(codecMap, "mimeType");
    auto codecClockRate = findInt(codecMap, "clockRate");
    auto codecNumChannels = findInt(codecMap, "channels");
    auto codecSdpFmtpLine = findString(codecMap, "sdpFmtpLine");
    auto codecCapability = RTCRtpCodecCapability::Create();
    if(codecSdpFmtpLine != std::string())
      codecCapability->set_sdp_fmtp_line(codecSdpFmtpLine);
    codecCapability->set_clock_rate(codecClockRate);
    if (codecNumChannels != -1)
      codecCapability->set_channels(codecNumChannels);
    codecCapability->set_mime_type(codecMimeType);
    codecList.push_back(codecCapability);
  }
  transceiver->SetCodecPreferences(codecList);
 }

void FlutterPeerConnection::GetSenders(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());

  EncodableMap map;
  EncodableList info;
  auto senders = pc->senders();
  for (scoped_refptr<RTCRtpSender> sender : senders.std_vector()) {
    info.push_back(EncodableValue(rtpSenderToMap(sender)));
  }
  map[EncodableValue("senders")] = EncodableValue(info);
  result_ptr->Success(EncodableValue(map));
}

void FlutterPeerConnection::AddIceCandidate(
    RTCIceCandidate* candidate,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  pc->AddCandidate(candidate->sdp_mid(), candidate->sdp_mline_index(),
                   candidate->candidate());

  result->Success();
}

EncodableMap statsToMap(const scoped_refptr<MediaRTCStats>& stats) {
  EncodableMap report_map;
  report_map[EncodableValue("id")] = EncodableValue(stats->id().std_string());
  report_map[EncodableValue("type")] =
      EncodableValue(stats->type().std_string());
  report_map[EncodableValue("timestamp")] =
      EncodableValue(double(stats->timestamp_us()));
  EncodableMap values;
  auto members = stats->Members();
  for (int i = 0; i < members.size(); i++) {
    auto member = members[i];
    if (!member->IsDefined()) {
      continue;
    }
    switch (member->GetType()) {
      case RTCStatsMember::Type::kBool:
        values[EncodableValue(member->GetName().std_string())] =
            EncodableValue(member->ValueBool());
        break;
      case RTCStatsMember::Type::kInt32:
        values[EncodableValue(member->GetName().std_string())] =
            EncodableValue(member->ValueInt32());
        break;
      case RTCStatsMember::Type::kUint32:
        values[EncodableValue(member->GetName().std_string())] =
            EncodableValue((int64_t)member->ValueUint32());
        break;
      case RTCStatsMember::Type::kInt64:
        values[EncodableValue(member->GetName().std_string())] =
            EncodableValue(member->ValueInt64());
        break;
      case RTCStatsMember::Type::kUint64:
        values[EncodableValue(member->GetName().std_string())] =
            EncodableValue((int64_t)member->ValueUint64());
        break;
      case RTCStatsMember::Type::kDouble:
        values[EncodableValue(member->GetName().std_string())] =
            EncodableValue(member->ValueDouble());
        break;
      case RTCStatsMember::Type::kString:
        values[EncodableValue(member->GetName().std_string())] =
            EncodableValue(member->ValueString().std_string());
        break;
      default:
        break;
    }
  }
  report_map[EncodableValue("values")] = EncodableValue(values);
  return report_map;
}

void FlutterPeerConnection::GetStats(
    const std::string& track_id,
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  scoped_refptr<RTCMediaTrack> track = base_->MediaTracksForId(track_id);
  if (track != nullptr) {
    bool found = false;
    auto receivers = pc->receivers();
    for (auto receiver : receivers.std_vector()) {
      if (receiver->track()->id().c_string() == track_id) {
        found = true;
        pc->GetStats(
            receiver,
            [result_ptr](const vector<scoped_refptr<MediaRTCStats>> reports) {
              std::vector<EncodableValue> list;
              for (int i = 0; i < reports.size(); i++) {
                list.push_back(EncodableValue(statsToMap(reports[i])));
              }
              EncodableMap params;
              params[EncodableValue("stats")] = EncodableValue(list);
              result_ptr->Success(EncodableValue(params));
            },
            [result_ptr](const char* error) {
              result_ptr->Error("GetStats", error);
            });
        return;
      }
    }
    auto senders = pc->senders();
    for (auto sender : senders.std_vector()) {
      if (sender->track()->id().c_string() == track_id) {
        found = true;
        pc->GetStats(
            sender,
            [result_ptr](const vector<scoped_refptr<MediaRTCStats>> reports) {
              std::vector<EncodableValue> list;
              for (int i = 0; i < reports.size(); i++) {
                list.push_back(EncodableValue(statsToMap(reports[i])));
              }
              EncodableMap params;
              params[EncodableValue("stats")] = EncodableValue(list);
              result_ptr->Success(EncodableValue(params));
            },
            [result_ptr](const char* error) {
              result_ptr->Error("GetStats", error);
            });
        return;
      }
    }
    if (!found) {
      result_ptr->Error("GetStats", "Track not found");
    }
  } else {
    pc->GetStats(
        [result_ptr](const vector<scoped_refptr<MediaRTCStats>> reports) {
          std::vector<EncodableValue> list;
          for (int i = 0; i < reports.size(); i++) {
            list.push_back(EncodableValue(statsToMap(reports[i])));
          }
          EncodableMap params;
          params[EncodableValue("stats")] = EncodableValue(list);
          result_ptr->Success(EncodableValue(params));
        },
        [result_ptr](const char* error) {
          result_ptr->Error("GetStats", error);
        });
  }
}

void FlutterPeerConnection::MediaStreamAddTrack(
    scoped_refptr<RTCMediaStream> stream,
    scoped_refptr<RTCMediaTrack> track,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  std::string kind = track->kind().std_string();
  if (0 == kind.compare("audio")) {
    stream->AddTrack(static_cast<RTCAudioTrack*>(track.get()));
  } else if (0 == kind.compare("video")) {
    stream->AddTrack(static_cast<RTCVideoTrack*>(track.get()));
  }

  result_ptr->Success();
}

void FlutterPeerConnection::MediaStreamRemoveTrack(
    scoped_refptr<RTCMediaStream> stream,
    scoped_refptr<RTCMediaTrack> track,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  std::string kind = track->kind().std_string();
  if (0 == kind.compare("audio")) {
    stream->RemoveTrack(static_cast<RTCAudioTrack*>(track.get()));
  } else if (0 == kind.compare("video")) {
    stream->RemoveTrack(static_cast<RTCVideoTrack*>(track.get()));
  }

  result_ptr->Success();
}

void FlutterPeerConnection::AddTrack(
    RTCPeerConnection* pc,
    scoped_refptr<RTCMediaTrack> track,
    std::list<std::string> streamIds,
    std::unique_ptr<MethodResultProxy> result) {
  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  std::string kind = track->kind().std_string();
  std::vector<string> streamids;
  for (std::string item : streamIds) {
    streamids.push_back(item.c_str());
  }
  if (0 == kind.compare("audio")) {
    auto sender = pc->AddTrack((RTCAudioTrack*)track.get(), streamids);
    if (sender.get() != nullptr) {
      result_ptr->Success(EncodableValue(rtpSenderToMap(sender)));
      return;
    }
  } else if (0 == kind.compare("video")) {
    auto sender = pc->AddTrack((RTCVideoTrack*)track.get(), streamids);
    if (sender.get() != nullptr) {
      result_ptr->Success(EncodableValue(rtpSenderToMap(sender)));
      return;
    }
  }
  result->Success();
}

libwebrtc::scoped_refptr<libwebrtc::RTCRtpSender>
FlutterPeerConnection::GetRtpSenderById(RTCPeerConnection* pc, std::string id) {
  libwebrtc::scoped_refptr<libwebrtc::RTCRtpSender> result;
  auto senders = pc->senders();
  for (scoped_refptr<RTCRtpSender> item : senders.std_vector()) {
    std::string itemId = item->id().std_string();
    if (nullptr == result.get() && 0 == id.compare(itemId)) {
      result = item;
    }
  }
  return result;
}

void FlutterPeerConnection::RemoveTrack(
    RTCPeerConnection* pc,
    std::string senderId,
    std::unique_ptr<MethodResultProxy> result) {
  auto sender = GetRtpSenderById(pc, senderId);
  if (nullptr == sender.get()) {
    result->Error("RemoveTrack", "not find RtpSender ");
    return;
  }

  EncodableMap map;
  map[EncodableValue("result")] = EncodableValue(pc->RemoveTrack(sender));

  result->Success(EncodableValue(map));
}

FlutterPeerConnectionObserver::FlutterPeerConnectionObserver(
    FlutterWebRTCBase* base,
    scoped_refptr<RTCPeerConnection> peerconnection,
    BinaryMessenger* messenger,
    const std::string& channel_name,
    std::string& peerConnectionId)
    : event_channel_(EventChannelProxy::Create(messenger, channel_name)),
      peerconnection_(peerconnection),
      base_(base),
      id_(peerConnectionId) {
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
    case RTCIceConnectionStateMax:
      return "statemax";
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
  EncodableMap params;
  params[EncodableValue("event")] = "signalingState";
  params[EncodableValue("state")] = signalingStateString(state);
  event_channel_->Success(EncodableValue(params));
}

static const char* peerConnectionStateString(RTCPeerConnectionState state) {
  switch (state) {
    case RTCPeerConnectionStateNew:
      return "new";
    case RTCPeerConnectionStateConnecting:
      return "connecting";
    case RTCPeerConnectionStateConnected:
      return "connected";
    case RTCPeerConnectionStateDisconnected:
      return "disconnected";
    case RTCPeerConnectionStateFailed:
      return "failed";
    case RTCPeerConnectionStateClosed:
      return "closed";
  }
  return "";
}

void FlutterPeerConnectionObserver::OnPeerConnectionState(
    RTCPeerConnectionState state) {
  EncodableMap params;
  params[EncodableValue("event")] = "peerConnectionState";
  params[EncodableValue("state")] = peerConnectionStateString(state);
  event_channel_->Success(EncodableValue(params));
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
  EncodableMap params;
  params[EncodableValue("event")] = "iceGatheringState";
  params[EncodableValue("state")] = iceGatheringStateString(state);
  event_channel_->Success(EncodableValue(params));
}

void FlutterPeerConnectionObserver::OnIceConnectionState(
    RTCIceConnectionState state) {
  EncodableMap params;
  params[EncodableValue("event")] = "iceConnectionState";
  params[EncodableValue("state")] = iceConnectionStateString(state);
  event_channel_->Success(EncodableValue(params));
}

void FlutterPeerConnectionObserver::OnIceCandidate(
    scoped_refptr<RTCIceCandidate> candidate) {
  EncodableMap params;
  params[EncodableValue("event")] = "onCandidate";
  EncodableMap cand;
  cand[EncodableValue("candidate")] =
      EncodableValue(candidate->candidate().std_string());
  cand[EncodableValue("sdpMLineIndex")] =
      EncodableValue(candidate->sdp_mline_index());
  cand[EncodableValue("sdpMid")] =
      EncodableValue(candidate->sdp_mid().std_string());
  params[EncodableValue("candidate")] = EncodableValue(cand);
  event_channel_->Success(EncodableValue(params));
}

void FlutterPeerConnectionObserver::OnAddStream(
    scoped_refptr<RTCMediaStream> stream) {
  std::string streamId = stream->id().std_string();

  EncodableMap params;
  params[EncodableValue("event")] = "onAddStream";
  params[EncodableValue("streamId")] = EncodableValue(streamId);
  EncodableList audioTracks;
  auto audio_tracks = stream->audio_tracks();
  for (scoped_refptr<RTCAudioTrack> track : audio_tracks.std_vector()) {
    EncodableMap audioTrack;
    audioTrack[EncodableValue("id")] = EncodableValue(track->id().std_string());
    audioTrack[EncodableValue("label")] =
        EncodableValue(track->id().std_string());
    audioTrack[EncodableValue("kind")] =
        EncodableValue(track->kind().std_string());
    audioTrack[EncodableValue("enabled")] = EncodableValue(track->enabled());
    audioTrack[EncodableValue("remote")] = EncodableValue(true);
    audioTrack[EncodableValue("readyState")] = "live";

    audioTracks.push_back(EncodableValue(audioTrack));
  }
  params[EncodableValue("audioTracks")] = EncodableValue(audioTracks);

  EncodableList videoTracks;
  auto video_tracks = stream->video_tracks();
  for (scoped_refptr<RTCVideoTrack> track : video_tracks.std_vector()) {
    EncodableMap videoTrack;

    videoTrack[EncodableValue("id")] = EncodableValue(track->id().std_string());
    videoTrack[EncodableValue("label")] =
        EncodableValue(track->id().std_string());
    videoTrack[EncodableValue("kind")] =
        EncodableValue(track->kind().std_string());
    videoTrack[EncodableValue("enabled")] = EncodableValue(track->enabled());
    videoTrack[EncodableValue("remote")] = EncodableValue(true);
    videoTrack[EncodableValue("readyState")] = "live";

    videoTracks.push_back(EncodableValue(videoTrack));
  }
  remote_streams_[streamId] = scoped_refptr<RTCMediaStream>(stream);
  params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);

  event_channel_->Success(EncodableValue(params));
}

void FlutterPeerConnectionObserver::OnRemoveStream(
    scoped_refptr<RTCMediaStream> stream) {
  EncodableMap params;
  params[EncodableValue("event")] = "onRemoveStream";
  params[EncodableValue("streamId")] =
      EncodableValue(stream->label().std_string());
  event_channel_->Success(EncodableValue(params));
  RemoveStreamForId(stream->label().std_string());
}

void FlutterPeerConnectionObserver::OnAddTrack(
    vector<scoped_refptr<RTCMediaStream>> streams,
    scoped_refptr<RTCRtpReceiver> receiver) {
  auto track = receiver->track();

  std::vector<scoped_refptr<RTCMediaStream>> mediaStreams;
  for (scoped_refptr<RTCMediaStream> stream : streams.std_vector()) {
    mediaStreams.push_back(stream);
    EncodableMap params;
    params[EncodableValue("event")] = "onAddTrack";
    params[EncodableValue("streamId")] =
        EncodableValue(stream->label().std_string());
    params[EncodableValue("trackId")] =
        EncodableValue(track->id().std_string());

    EncodableMap audioTrack;
    audioTrack[EncodableValue("id")] = EncodableValue(track->id().std_string());
    audioTrack[EncodableValue("label")] =
        EncodableValue(track->id().std_string());
    audioTrack[EncodableValue("kind")] =
        EncodableValue(track->kind().std_string());
    audioTrack[EncodableValue("enabled")] = EncodableValue(track->enabled());
    audioTrack[EncodableValue("remote")] = EncodableValue(true);
    audioTrack[EncodableValue("readyState")] = "live";
    params[EncodableValue("track")] = EncodableValue(audioTrack);

    event_channel_->Success(EncodableValue(params));
  }
}

void FlutterPeerConnectionObserver::OnTrack(
    scoped_refptr<RTCRtpTransceiver> transceiver) {
  auto receiver = transceiver->receiver();
  EncodableMap params;
  EncodableList streams_info;
  auto streams = receiver->streams();
  for (scoped_refptr<RTCMediaStream> item : streams.std_vector()) {
    streams_info.push_back(EncodableValue(mediaStreamToMap(item, id_)));
  }
  params[EncodableValue("event")] = "onTrack";
  params[EncodableValue("streams")] = EncodableValue(streams_info);
  params[EncodableValue("track")] =
      EncodableValue(mediaTrackToMap(receiver->track()));
  params[EncodableValue("receiver")] =
      EncodableValue(rtpReceiverToMap(receiver));
  params[EncodableValue("transceiver")] =
      EncodableValue(transceiverToMap(transceiver));

  event_channel_->Success(EncodableValue(params));
}

void FlutterPeerConnectionObserver::OnRemoveTrack(
    scoped_refptr<RTCRtpReceiver> receiver) {
  auto track = receiver->track();

  EncodableMap params;
  params[EncodableValue("event")] = "onRemoveTrack";
  params[EncodableValue("trackId")] = EncodableValue(track->id().std_string());
  params[EncodableValue("track")] = EncodableValue(mediaTrackToMap(track));
  params[EncodableValue("receiver")] =
      EncodableValue(rtpReceiverToMap(receiver));
  event_channel_->Success(EncodableValue(params));
}

// void FlutterPeerConnectionObserver::OnRemoveTrack(
//    scoped_refptr<RTCMediaStream> stream,
//    scoped_refptr<RTCMediaTrack> track) {

//    EncodableMap params;
//    params[EncodableValue("event")] = "onRemoveTrack";
//    params[EncodableValue("streamId")] = stream->label();
//    params[EncodableValue("trackId")] = track->id();
//
//    EncodableMap videoTrack;
//    videoTrack[EncodableValue("id")] = track->id();
//    videoTrack[EncodableValue("label")] = track->id();
//    videoTrack[EncodableValue("kind")] = track->kind();
//    videoTrack[EncodableValue("enabled")] = track->enabled();
//    videoTrack[EncodableValue("remote")] = true;
//    videoTrack[EncodableValue("readyState")] = "live";
//    params[EncodableValue("track")] = videoTrack;
//
//    event_channel_->Success(EncodableValue(params));

//}

void FlutterPeerConnectionObserver::OnDataChannel(
    scoped_refptr<RTCDataChannel> data_channel) {
  int channel_id = data_channel->id();
  std::string channel_uuid = base_->GenerateUUID();

  std::string event_channel =
      "FlutterWebRTC/dataChannelEvent" + id_ + channel_uuid;

  std::unique_ptr<FlutterRTCDataChannelObserver> observer(
      new FlutterRTCDataChannelObserver(data_channel, base_->messenger_,
                                        event_channel));

  base_->lock();
  base_->data_channel_observers_[channel_uuid] = std::move(observer);
  base_->unlock();

  EncodableMap params;
  params[EncodableValue("event")] = "didOpenDataChannel";
  params[EncodableValue("id")] = EncodableValue(channel_id);
  params[EncodableValue("label")] =
      EncodableValue(data_channel->label().std_string());
  params[EncodableValue("flutterId")] = EncodableValue(channel_uuid);
  event_channel_->Success(EncodableValue(params));
}

void FlutterPeerConnectionObserver::OnRenegotiationNeeded() {
  EncodableMap params;
  params[EncodableValue("event")] = "onRenegotiationNeeded";
  event_channel_->Success(EncodableValue(params));
}

scoped_refptr<RTCMediaStream> FlutterPeerConnectionObserver::MediaStreamForId(
    const std::string& id) {
  auto it = remote_streams_.find(id);
  if (it != remote_streams_.end())
    return (*it).second;
  return nullptr;
}

scoped_refptr<RTCMediaTrack> FlutterPeerConnectionObserver::MediaTrackForId(
    const std::string& id) {
  for (auto it = remote_streams_.begin(); it != remote_streams_.end(); it++) {
    auto remoteStream = (*it).second;
    auto audio_tracks = remoteStream->audio_tracks();
    for (auto track : audio_tracks.std_vector()) {
      if (track->id().std_string() == id) {
        return track;
      }
    }
    auto video_tracks = remoteStream->video_tracks();
    for (auto track : video_tracks.std_vector()) {
      if (track->id().std_string() == id) {
        return track;
      }
    }
  }
  return nullptr;
}

void FlutterPeerConnectionObserver::RemoveStreamForId(const std::string& id) {
  auto it = remote_streams_.find(id);
  if (it != remote_streams_.end())
    remote_streams_.erase(it);
}

}  // namespace flutter_webrtc_plugin
