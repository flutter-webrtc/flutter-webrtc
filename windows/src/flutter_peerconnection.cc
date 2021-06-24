#include "flutter_peerconnection.h"
#include "base/scoped_ref_ptr.h"
#include "flutter_data_channel.h"
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
  }
  return "";
}

EncodableMap rtpParametersToMap(
    libwebrtc::scoped_refptr<libwebrtc::RTCRtpParameters> rtpParameters) {
  EncodableMap info;

  rtpParameters->GetTransactionId([&](char* p, size_t size) {
    info[EncodableValue("transactionId")] = std::string(p, size);
  });

  EncodableMap rtcp;
  rtpParameters->GetRtcp()->GetCname([&](char* p, size_t size) {
    rtcp[EncodableValue("cname")] = std::string(p, size);
  });
  rtcp[EncodableValue("reducedSize")] =
      rtpParameters->GetRtcp()->GetReducedSize();
  info[EncodableValue("rtcp")] = rtcp;

  EncodableList headerExtensions;

  rtpParameters->GetHeaderExtensions(
      [&](scoped_refptr<libwebrtc::RTCRtpExtension> extension) {
        EncodableMap map;
        extension->GetUri([&](char* p, size_t size) {
          map[EncodableValue("uri")] = std::string(p, size);
        });
        map[EncodableValue("id")] = extension->GetId();
        map[EncodableValue("encrypted")] = extension->GetEncrypt();

        headerExtensions.push_back(map);
      });
  info[EncodableValue("headerExtensions")] = headerExtensions;

  EncodableList encodings;
  rtpParameters->GetEncodings(
      [&](scoped_refptr<libwebrtc::RTCRtpEncodingParameters> encoding) {
        EncodableMap map;
        map[EncodableValue("active")] = encoding->GetActive();
        map[EncodableValue("maxBitrate")] = encoding->GetMaxBitrateBps();
        map[EncodableValue("minBitrate")] = encoding->GetMinBitrateBps();
        map[EncodableValue("maxFramerate")] = encoding->GetMaxFramerate();
        map[EncodableValue("maxFramerate")] = encoding->GetMaxFramerate();
        map[EncodableValue("scaleResolutionDownBy")] =
            encoding->GetScaleResolutionDownBy();
        map[EncodableValue("ssrc")] = (long)encoding->GetSsrc();

        encodings.push_back(map);
      });
  info[EncodableValue("encodings")] = encodings;

  EncodableList codecs;

  rtpParameters->GetCodecs([&](scoped_refptr<RTCRtpCodecParameters> codec) {
    EncodableMap map;
    codec->GetName([&](char* p, size_t size) {
      map[EncodableValue("name")] = std::string(p, size);
    });
    map[EncodableValue("payloadType")] = codec->GetPayloadType();
    map[EncodableValue("clockRate")] = codec->GetClockRate();
    map[EncodableValue("numChannels")] = codec->GetNumChannels();

    EncodableMap param;
    codec->GetParameters(
        [&](char* key, size_t key_size, char* val, size_t val_size) {
          param[EncodableValue(std::string(key, key_size))] =
              std::string(val, val_size);
        });
    map[EncodableValue("parameters")] = param;

    map[EncodableValue("kind")] = RTCMediaTypeToString(codec->GetKind());
  });
  info[EncodableValue("codecs")] = codecs;

  return info;
}

EncodableMap dtmfSenderToMap(
    libwebrtc::scoped_refptr<libwebrtc::RTCDtmfSender> dtmfSender,
    std::string id) {
  EncodableMap info;
  if (nullptr != dtmfSender.get()) {
    info[EncodableValue("dtmfSenderId")] = EncodableValue(id);
    if (dtmfSender.get()) {
      info[EncodableValue("interToneGap")] =
          EncodableValue(dtmfSender->InterToneGap());
      info[EncodableValue("duration")] = EncodableValue(dtmfSender->Duration());
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
  info[EncodableValue("id")] = EncodableValue(track->id());
  info[EncodableValue("kind")] = EncodableValue(track->kind());
  std::string kind(track->kind());
  if (0 == kind.compare("voide")) {
    info[EncodableValue("readyState")] =
        EncodableValue(static_cast<RTCVideoTrack*>(track.get())->state());
    info[EncodableValue("label")] = EncodableValue("voide");
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
  std::string id;
  sender->Id([&](char* p, size_t size) {
    id = std::string(p, size);
    info[EncodableValue("senderId")] = id;
  });

  info[EncodableValue("ownsTrack")] = true;
  info[EncodableValue("dtmfSender")] =
      dtmfSenderToMap(sender->GetDtmfSender(), id);
  info[EncodableValue("rtpParameters")] =
      rtpParametersToMap(sender->GetParameters());
  info[EncodableValue("track")] = mediaTrackToMap(sender->GetTrack());
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
  receiver->Id([&](char* p, size_t size) {
    info[EncodableValue("receiverId")] = std::string(p, size);
  });
  info[EncodableValue("rtpParameters")] =
      rtpParametersToMap(receiver->GetParameters());
  info[EncodableValue("track")] = mediaTrackToMap(receiver->Track());
  return info;
}

EncodableMap transceiverToMap(scoped_refptr<RTCRtpTransceiver> transceiver) {
  EncodableMap info;
  transceiver->GetMid([&](char* p, size_t size) {
    std::string mid(p, size);
    info[EncodableValue("transceiverId")] = mid;
    info[EncodableValue("mid")] = mid;
  });

  info[EncodableValue("direction")] =
      transceiverDirectionString(transceiver->Direction());

  info[EncodableValue("sender")] = rtpSenderToMap(transceiver->Sender());

  info[EncodableValue("receiver")] = rtpReceiverToMap(transceiver->Receiver());
  return info;
}

EncodableMap mediaStreamToMap(scoped_refptr<RTCMediaStream> stream,
                              std::string id) {
  EncodableMap params;
  stream->GetId([&](char* p, size_t size) {
    params[EncodableValue("streamId")] = std::string(p, size);
    params[EncodableValue("ownerTag")] = id;
  });
  EncodableList audioTracks;
  stream->GetAudioTracks([&](scoped_refptr<RTCAudioTrack> val) {
    audioTracks.push_back(mediaTrackToMap(val));
  });
  params[EncodableValue("audioTracks")] = audioTracks;

  EncodableList videoTracks;
  stream->GetVideoTracks([&](scoped_refptr<RTCVideoTrack> val) {
    videoTracks.push_back(mediaTrackToMap(val));
  });
  params[EncodableValue("videoTracks")] = videoTracks;
  return params;
}

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
                                        event_channel, uuid));

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
      [result_ptr](const std::string& error) { result_ptr->Success(); });
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
      [result_ptr](const std::string& error) { result_ptr->Success(); });
}

scoped_refptr<RTCRtpTransceiverInit>
FlutterPeerConnection::mapToRtpTransceiverInit(const EncodableMap& params) {
  scoped_refptr<RTCRtpTransceiverInit> init = RTCRtpTransceiverInit::Create();

  EncodableValue val = findEncodableValue(params, "streamIds");
  EncodableList streamIds = findList(params, "streamIds");
  if (0 < streamIds.size()) {
    init->SetStreamIds([=](OnString on) {
      for (auto item : streamIds) {
        std::string id = GetValue<std::string>(item);
        on((char*)id.c_str(), id.size());
      }
    });
  }

  EncodableValue direction = findEncodableValue(params, "direction");
  if (!direction.IsNull()) {
    direction = "sendrecv";
    init->SetDirection(
        stringToTransceiverDirection(GetValue<std::string>(direction)));
  }

  EncodableList sendEncodings = findList(params, "sendEncodings");
  if (0 < sendEncodings.size()) {
    init->SetSendEncodings([&](OnRTCRtpEncodingParameters param) {
      for (EncodableValue value : sendEncodings) {
        param(mapToEncoding(GetValue<EncodableMap>(value)));
      }
    });
  }

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
  } else if (0 == direction.compare("inactive")) {
    return RTCRtpTransceiverDirection::kInactive;
  }
  return RTCRtpTransceiverDirection::kInactive;
}

libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters>
FlutterPeerConnection::mapToEncoding(const EncodableMap& params) {
  libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters> encoding =
      RTCRtpEncodingParameters::Create();

  encoding->SetActive(true);
  encoding->SetScaleResolutionDownBy(1.0);

  EncodableValue value = findEncodableValue(params, "active");
  if (!value.IsNull()) {
    encoding->SetActive(GetValue<bool>(value));
  }

  value = findEncodableValue(params, "rid");
  if (!value.IsNull()) {
    const std::string rid = GetValue<std::string>(value);
    encoding->SetRid((char*)rid.c_str(), rid.size());
  }

  value = findEncodableValue(params, "ssrc");
  if (!value.IsNull()) {
    encoding->SetSsrc((uint32_t)GetValue<int>(value));
  }

  value = findEncodableValue(params, "minBitrate");
  if (!value.IsNull()) {
    encoding->SetMinBitrateBps(GetValue<int>(value));
  }

  value = findEncodableValue(params, "maxBitrate");
  if (!value.IsNull()) {
    encoding->SetMaxBitrateBps(GetValue<int>(value));
  }

  value = findEncodableValue(params, "maxFramerate");
  if (!value.IsNull()) {
    encoding->SetMaxFramerate(GetValue<int>(value));
  }

  value = findEncodableValue(params, "numTemporalLayers");
  if (!value.IsNull()) {
    encoding->SetNumTemporalLayers(GetValue<int>(value));
  }

  value = findEncodableValue(params, "scaleResolutionDownBy");
  if (!value.IsNull()) {
    encoding->SetScaleResolutionDownBy(GetValue<double>(value));
  }

  return encoding;
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
          if (nullptr != transceiver.get()) {
            result_ptr->Success(transceiverToMap(transceiver));
          } else {
            result_ptr->Error("AddTransceiver", message);
          }
        });
  } else {
    pc->AddTransceiver(track, [=](scoped_refptr<RTCRtpTransceiver> transceiver,
                                  const char* message) {
      if (nullptr != transceiver.get()) {
        result_ptr->Success(transceiverToMap(transceiver));
      } else {
        result_ptr->Error("AddTransceiver", message);
      }
    });
  }
}

void FlutterPeerConnection::GetTransceivers(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  EncodableMap map;
  EncodableList transceivers;
  pc->GetTransceivers([&](scoped_refptr<RTCRtpTransceiver> transceiver) {
    transceivers.push_back(transceiverToMap(transceiver));
  });
  map[EncodableValue("transceivers")] = transceivers;
  result_ptr->Success(map);
}

void FlutterPeerConnection::GetReceivers(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  EncodableMap map;
  EncodableList receivers;
  pc->GetReceivers([&](scoped_refptr<RTCRtpReceiver> receiver) {
    receivers.push_back(rtpReceiverToMap(receiver));
  });
  map[EncodableValue("receivers")] = receivers;
  result_ptr->Success(map);
}

void FlutterPeerConnection::RtpSenderDispose(
    RTCPeerConnection* pc,
    std::string rtpSenderId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

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
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  auto sender = GetRtpSenderById(pc, rtpSenderId);
  if (nullptr == sender.get()) {
    result_ptr->Error("rtpSenderDispose", "sender is null");
    return;
  }
  sender->SetTrack(track);
  result_ptr->Success();
}

void FlutterPeerConnection::RtpSenderReplaceTrack(
    RTCPeerConnection* pc,
    RTCMediaTrack* track,
    std::string rtpSenderId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  auto sender = GetRtpSenderById(pc, rtpSenderId);
  if (nullptr == sender.get()) {
    result_ptr->Error("rtpSenderDispose", "sender is null");
    return;
  }
  // TODO RtpSenderReplaceTrack
  result_ptr->Success();
}

scoped_refptr<RTCRtpParameters> FlutterPeerConnection::updateRtpParameters(
    EncodableMap newParameters,
    scoped_refptr<RTCRtpParameters> parameters) {
  EncodableList encodings = findList(newParameters, "encodings");
  auto encoding = encodings.begin();
  parameters->GetEncodings([&](scoped_refptr<RTCRtpEncodingParameters> param) {
    if (encoding != encodings.end()) {
      EncodableMap map = GetValue<EncodableMap>(*encoding);
      EncodableValue value = findEncodableValue(map, "active");
      if (!value.IsNull()) {
        param->SetActive(GetValue<bool>(value));
      }

      value = findEncodableValue(map, "maxBitrate");
      if (!value.IsNull()) {
        param->SetMaxBitrateBps(GetValue<int>(value));
      }

      value = findEncodableValue(map, "minBitrate");
      if (!value.IsNull()) {
        param->SetMinBitrateBps(GetValue<int>(value));
      }

      value = findEncodableValue(map, "maxFramerate");
      if (!value.IsNull()) {
        param->SetMaxFramerate(GetValue<int>(value));
      }
      value = findEncodableValue(map, "numTemporalLayers");
      if (!value.IsNull()) {
        param->SetNumTemporalLayers(GetValue<int>(value));
      }
      value = findEncodableValue(map, "scaleResolutionDownBy");
      if (!value.IsNull()) {
        param->SetScaleResolutionDownBy(GetValue<int>(value));
      }

      encoding++;
    }
  });

  return parameters;
}

void FlutterPeerConnection::RtpSenderSetParameters(
    RTCPeerConnection* pc,
    std::string rtpSenderId,
    const EncodableMap& parameters,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

  auto sender = GetRtpSenderById(pc, rtpSenderId);
  if (nullptr == sender.get()) {
    result_ptr->Error("rtpSenderDispose", "sender is null");
    return;
  }

  auto params = sender->GetParameters();
  params = updateRtpParameters(parameters, params);
  sender->SetParameters(params);

  result_ptr->Success();
}

void FlutterPeerConnection::RtpTransceiverStop(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

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
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

  auto transceiver = getRtpTransceiverById(pc, rtpTransceiverId);
  if (nullptr == transceiver.get()) {
    result_ptr->Error("rtpTransceiverGetCurrentDirection",
                      "transceiver is null");
  }
  EncodableMap map;
  map[EncodableValue("result")] =
      transceiverDirectionString(transceiver->Direction());
  result_ptr->Success(map);
}

void FlutterPeerConnection::SetConfiguration(
    RTCPeerConnection* pc,
    const EncodableMap& configuration,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

  // TODO pc->SetConfiguration();

  result_ptr->Success();
}

void FlutterPeerConnection::CaptureFrame(
    RTCVideoTrack* track,
    std::string path,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

  // TODO pc->CaptureFrame();

  result_ptr->Success();
}

scoped_refptr<RTCRtpTransceiver> FlutterPeerConnection::getRtpTransceiverById(
    RTCPeerConnection* pc,
    std::string id) {
  scoped_refptr<RTCRtpTransceiver> ret;
  pc->GetTransceivers([&](scoped_refptr<RTCRtpTransceiver> param) {
    std::string mid;
    param->GetMid([&](char* p, size_t size) { mid = std::string(p, size); });

    if (nullptr == ret.get() && 0 == id.compare(mid)) {
      ret = param;
    }
  });

  return ret;
}

void FlutterPeerConnection::RtpTransceiverSetDirection(
    RTCPeerConnection* pc,
    std::string rtpTransceiverId,
    std::string direction,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());
  auto transceiver = getRtpTransceiverById(pc, rtpTransceiverId);
  if (nullptr == transceiver.get()) {
    result_ptr->Error("RtpTransceiverSetDirection", " transceiver is null ");
    return;
  }
  transceiver->SetDirectionWithError(
      stringToTransceiverDirection(direction), [&](char* p, size_t size) {
        if (nullptr == p) {
          result_ptr->Success(nullptr);
        } else {
          result_ptr->Error("RtpTransceiverSetDirection", std::string(p, size));
        }
      });
}

void FlutterPeerConnection::GetSenders(
    RTCPeerConnection* pc,
    std::unique_ptr<MethodResult<EncodableValue>> resulte) {
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(resulte.release());

  EncodableMap map;
  EncodableList senders;
  pc->GetSenders([&](scoped_refptr<RTCRtpSender> sender) {
    senders.push_back(rtpSenderToMap(sender));
  });
  map[EncodableValue("senders")] = senders;
  result_ptr->Success(map);
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
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  // TODO
}

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
  std::shared_ptr<MethodResult<EncodableValue>> result_ptr(result.release());
  std::string kind = track->kind();
  if (0 == kind.compare("audio")) {
    pc->AddTrack((RTCAudioTrack*)track.get(),
                 [&](OnString on) {
                   for (std::string item : streamIds) {
                     on((char*)item.c_str(), item.size());
                   }
                 },
                 [=](scoped_refptr<RTCRtpSender> render, const char* message) {
                   result_ptr->Success(rtpSenderToMap(render));
                 });
  } else if (0 == kind.compare("video")) {
    pc->AddTrack((RTCVideoTrack*)track.get(),
                 [&](OnString on) {
                   for (std::string item : streamIds) {
                     on((char*)item.c_str(), item.size());
                   }
                 },
                 [=](scoped_refptr<RTCRtpSender> render, const char* message) {
                   result_ptr->Success(rtpSenderToMap(render));
                 });
  }

  result->Success(nullptr);
}

libwebrtc::scoped_refptr<libwebrtc::RTCRtpSender>
FlutterPeerConnection::GetRtpSenderById(RTCPeerConnection* pc, std::string id) {
  libwebrtc::scoped_refptr<libwebrtc::RTCRtpSender> ret;
  pc->GetSenders([&](scoped_refptr<RTCRtpSender> item) {
    std::string itemId;
    item->Id([&](char* p, size_t size) { itemId = std::string(p, size); });

    if (nullptr == ret.get() && 0 == id.compare(itemId)) {
      ret = item;
    }
  });
  return ret;
}

void FlutterPeerConnection::RemoveTrack(
    RTCPeerConnection* pc,
    std::string senderId,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto sender = GetRtpSenderById(pc, senderId);
  if (nullptr == sender.get()) {
    result->Error("RemoveTrack", "not find RtpSender ");
  }

  EncodableMap map;
  map[EncodableValue("result")] = pc->RemoveTrack(sender);

  result->Success(map);
}

FlutterPeerConnectionObserver::FlutterPeerConnectionObserver(
    FlutterWebRTCBase* base,
    scoped_refptr<RTCPeerConnection> peerconnection,
    BinaryMessenger* messenger,
    const std::string& channel_name,
    std::string& peerConnectionId)
    : event_channel_(new EventChannel<EncodableValue>(
          messenger,
          channel_name,
          &StandardMethodCodec::GetInstance())),
      peerconnection_(peerconnection),
      base_(base),
      id_(peerConnectionId) {
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
  std::string streamId;
  stream->GetId([&](char* p, size_t size) { streamId = std::string(p, size); });

  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onAddStream";
    params[EncodableValue("streamId")] = streamId;
    EncodableList audioTracks;
    stream->GetAudioTracks([&](scoped_refptr<RTCAudioTrack> track) {
      EncodableMap audioTrack;
      audioTrack[EncodableValue("id")] = track->id();
      audioTrack[EncodableValue("label")] = track->id();
      audioTrack[EncodableValue("kind")] = track->kind();
      audioTrack[EncodableValue("enabled")] = track->enabled();
      audioTrack[EncodableValue("remote")] = true;
      audioTrack[EncodableValue("readyState")] = "live";

      audioTracks.push_back(audioTrack);
    });
    params[EncodableValue("audioTracks")] = audioTracks;

    EncodableList videoTracks;

    stream->GetVideoTracks([&](scoped_refptr<RTCVideoTrack> track) {
      EncodableMap videoTrack;

      videoTrack[EncodableValue("id")] = track->id();
      videoTrack[EncodableValue("label")] = track->id();
      videoTrack[EncodableValue("kind")] = track->kind();
      videoTrack[EncodableValue("enabled")] = track->enabled();
      videoTrack[EncodableValue("remote")] = true;
      videoTrack[EncodableValue("readyState")] = "live";

      videoTracks.push_back(EncodableValue(videoTrack));
    });

    remote_streams_[streamId] = scoped_refptr<RTCMediaStream>(stream);
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
    OnVectorRTCMediaStream on,
    scoped_refptr<RTCRtpReceiver> receiver) {
  auto track = receiver->Track();

  std::vector<scoped_refptr<RTCMediaStream>> mediaStreams;
  on([&](scoped_refptr<RTCMediaStream> stream) {
    mediaStreams.push_back(stream);

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
  });


}


void FlutterPeerConnectionObserver::OnTrack(
    scoped_refptr<RTCRtpTransceiver> transceiver) {
  if (event_sink_ != nullptr) {
    auto receiver= transceiver->Receiver();
    EncodableMap params;
    EncodableList streams;
    receiver->Streams([&](scoped_refptr<RTCMediaStream> val) {
      streams.push_back(mediaStreamToMap(val, id_));
        });

    params[EncodableValue("event")] = "onTrack";
    params[EncodableValue("streams")] = streams;
    params[EncodableValue("track")] = mediaTrackToMap(receiver->Track());
    params[EncodableValue("receiver")] = rtpReceiverToMap(receiver);
    params[EncodableValue("transceiver")] = transceiverToMap(transceiver);

    event_sink_->Success(params);
  }
}

void FlutterPeerConnectionObserver::OnRemoveTrack(
    scoped_refptr<RTCRtpReceiver> receiver) {
  if (event_sink_ != nullptr) {
    EncodableMap params;
    params[EncodableValue("event")] = "onRemoveTrack";
    params[EncodableValue("receiver")] = rtpReceiverToMap(receiver);

    event_sink_->Success(EncodableValue(params));
  }
}

// void FlutterPeerConnectionObserver::OnRemoveTrack(
//    scoped_refptr<RTCMediaStream> stream,
//    scoped_refptr<RTCMediaTrack> track) {
//  if (event_sink_ != nullptr) {
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
//    event_sink_->Success(EncodableValue(params));
//  }
//}

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

scoped_refptr<RTCMediaStream> FlutterPeerConnectionObserver::MediaStreamForId(
    const std::string& id) {
  auto it = remote_streams_.find(id);
  if (it != remote_streams_.end())
    return (*it).second;
  return nullptr;
}

void FlutterPeerConnectionObserver::RemoveStreamForId(const std::string& id) {
  auto it = remote_streams_.find(id);
  if (it != remote_streams_.end())
    remote_streams_.erase(it);
}

}  // namespace flutter_webrtc_plugin
