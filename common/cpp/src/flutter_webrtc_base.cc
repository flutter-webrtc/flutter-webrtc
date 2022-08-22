#include "flutter_webrtc_base.h"

#include "flutter_data_channel.h"
#include "flutter_peerconnection.h"

namespace flutter_webrtc_plugin {

const char *kEventChannelName = "FlutterWebRTC.Event";

FlutterWebRTCBase::FlutterWebRTCBase(BinaryMessenger *messenger,
                                     TextureRegistrar *textures)
    : messenger_(messenger), textures_(textures) {
  LibWebRTC::Initialize();
  factory_ = LibWebRTC::CreateRTCPeerConnectionFactory();
  audio_device_ = factory_->GetAudioDevice();
  video_device_ = factory_->GetVideoDevice();
  desktop_device_ = factory_->GetDesktopDevice();

  event_channel_.reset(new EventChannel<EncodableValue>(
      messenger_, kEventChannelName, &StandardMethodCodec::GetInstance()));

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
}

FlutterWebRTCBase::~FlutterWebRTCBase() {
  LibWebRTC::Terminate();
}

EventSink<EncodableValue> *FlutterWebRTCBase::event_sink() {
  return event_sink_? event_sink_.get() : nullptr;
}

std::string FlutterWebRTCBase::GenerateUUID() {
  return uuidxx::uuid::Generate().ToString(false);
}

RTCPeerConnection *FlutterWebRTCBase::PeerConnectionForId(
    const std::string &id) {
  auto it = peerconnections_.find(id);

  if (it != peerconnections_.end()) return (*it).second.get();

  return nullptr;
}

void FlutterWebRTCBase::RemovePeerConnectionForId(const std::string &id) {
  auto it = peerconnections_.find(id);
  if (it != peerconnections_.end()) peerconnections_.erase(it);
}

RTCMediaTrack* FlutterWebRTCBase ::MediaTrackForId(const std::string& id) {
  auto it = local_tracks_.find(id);

  if (it != local_tracks_.end())
    return (*it).second.get();

  for (auto kv : peerconnection_observers_) {
      auto pco = kv.second.get();
      auto track = pco->MediaTrackForId(id);
      if (track != nullptr) return track;
  }

  return nullptr;
}

void FlutterWebRTCBase::RemoveMediaTrackForId(const std::string& id) {
  auto it = local_tracks_.find(id);
  if (it != local_tracks_.end())
    local_tracks_.erase(it);
}

FlutterPeerConnectionObserver* FlutterWebRTCBase::PeerConnectionObserversForId(
    const std::string& id) {
  auto it = peerconnection_observers_.find(id);

  if (it != peerconnection_observers_.end())
    return (*it).second.get();

  return nullptr;
}

void FlutterWebRTCBase::RemovePeerConnectionObserversForId(
    const std::string& id) {
  auto it = peerconnection_observers_.find(id);
  if (it != peerconnection_observers_.end())
    peerconnection_observers_.erase(it);
}

scoped_refptr<RTCMediaStream> FlutterWebRTCBase::MediaStreamForId(
    const std::string& id) {
  auto it = local_streams_.find(id);
  if (it != local_streams_.end()) {
    return (*it).second;
  }

  for (auto kv : peerconnection_observers_) {
    auto pco = kv.second.get();
    auto stream = pco->MediaStreamForId(id);
    if (stream != nullptr) return stream;
  }

  return nullptr;
}

void FlutterWebRTCBase::RemoveStreamForId(const std::string &id) {
  auto it = local_streams_.find(id);
  if (it != local_streams_.end()) local_streams_.erase(it);
}

bool FlutterWebRTCBase::ParseConstraints(const EncodableMap &constraints,
                                         RTCConfiguration *configuration) {
  memset(&configuration->ice_servers, 0, sizeof(configuration->ice_servers));
  return false;
}

void FlutterWebRTCBase::ParseConstraints(
    const EncodableMap &src,
    scoped_refptr<RTCMediaConstraints> mediaConstraints,
    ParseConstraintType type /*= kMandatory*/) {
  for (auto kv : src) {
    EncodableValue k = kv.first;
    EncodableValue v = kv.second;
    std::string key = GetValue<std::string>(k);
    std::string value;
    if (TypeIs<EncodableList>(v) || TypeIs<EncodableMap>(v)) {
    } else if (TypeIs<std::string>(v)) {
      value = GetValue<std::string>(v);
    } else if (TypeIs<double>(v)) {
      value = std::to_string(GetValue<double>(v));
    } else if (TypeIs<int>(v)) {
      value = std::to_string(GetValue<int>(v));
    } else if (TypeIs<bool>(v)) {
      value = GetValue<bool>(v) ? RTCMediaConstraints::kValueTrue
                                : RTCMediaConstraints::kValueFalse;
    } else {
      value = std::to_string(GetValue<int>(v));
    }
    if (type == kMandatory) {
      mediaConstraints->AddMandatoryConstraint(key.c_str(), value.c_str());
    } else {
      mediaConstraints->AddOptionalConstraint(key.c_str(), value.c_str());
      if (key == "DtlsSrtpKeyAgreement") {
        configuration_.srtp_type = GetValue<bool>(v)
                                       ? MediaSecurityType::kDTLS_SRTP
                                       : MediaSecurityType::kSDES_SRTP;
      }
    }
  }
}

scoped_refptr<RTCMediaConstraints> FlutterWebRTCBase::ParseMediaConstraints(
    const EncodableMap &constraints) {
  scoped_refptr<RTCMediaConstraints> media_constraints =
      RTCMediaConstraints::Create();

  if (constraints.find(EncodableValue("mandatory")) != constraints.end()) {
    auto it = constraints.find(EncodableValue("mandatory"));
    const EncodableMap mandatory = GetValue<EncodableMap>(it->second);
    ParseConstraints(mandatory, media_constraints, kMandatory);
  } else {
    // Log.d(TAG, "mandatory constraints are not a map");
  }

  auto it = constraints.find(EncodableValue("optional"));
  if (it != constraints.end()) {
    const EncodableValue optional = it->second;
    if (TypeIs<EncodableMap>(optional)) {
      ParseConstraints(GetValue<EncodableMap>(optional), media_constraints,
                       kOptional);
    } else if (TypeIs<EncodableList>(optional)) {
      const EncodableList list = GetValue<EncodableList>(optional);
      for (size_t i = 0; i < list.size(); i++) {
        ParseConstraints(GetValue<EncodableMap>(list[i]), media_constraints, kOptional);
      }
    }
  } else {
    // Log.d(TAG, "optional constraints are not an array");
  }

  return media_constraints;
}

bool FlutterWebRTCBase::CreateIceServers(const EncodableList &iceServersArray,
                                         IceServer *ice_servers) {
  size_t size = iceServersArray.size();
  for (size_t i = 0; i < size; i++) {
    IceServer &ice_server = ice_servers[i];
    EncodableMap iceServerMap = GetValue<EncodableMap>(iceServersArray[i]);
    
    if (iceServerMap.find(EncodableValue("username")) != iceServerMap.end()) {;
          ice_server.username = GetValue<std::string>(
              iceServerMap.find(EncodableValue("username"))->second);
    }
    if (iceServerMap.find(EncodableValue("credential")) != iceServerMap.end()) {
          ice_server.password = GetValue<std::string>(
              iceServerMap.find(EncodableValue("credential"))->second);
    }

    auto it = iceServerMap.find(EncodableValue("url"));
    if (it != iceServerMap.end() && TypeIs<std::string>(it->second)) {
      ice_server.uri = GetValue<std::string>(it->second);
    }
    it = iceServerMap.find(EncodableValue("urls"));
    if (it != iceServerMap.end()) {
      if (TypeIs<std::string>(it->second)) {
        ice_server.uri = GetValue<std::string>(it->second);
      }
      if (TypeIs<EncodableList>(it->second)) {
        const EncodableList urls = GetValue<EncodableList>(it->second);
        for (auto url : urls) {
          if (TypeIs<EncodableMap>(url)) {
            const EncodableMap map = GetValue<EncodableMap>(url);
            std::string value;
            auto it2 = map.find(EncodableValue("url"));
            if (it2 != map.end()) {
              ice_server.uri = GetValue<std::string>(it2->second);
            }
          } else if (TypeIs<std::string>(url)) {
            ice_server.uri = GetValue<std::string>(url);
          }
        }
      }
    }
  }
  return size > 0;
}

bool FlutterWebRTCBase::ParseRTCConfiguration(const EncodableMap &map,
                                              RTCConfiguration &conf) {
  auto it = map.find(EncodableValue("iceServers"));
  if (it != map.end()) {
    const EncodableList iceServersArray = GetValue<EncodableList>(it->second);
    CreateIceServers(iceServersArray, conf.ice_servers);
  }
  // iceTransportPolicy (public API)
  it = map.find(EncodableValue("iceTransportPolicy"));
  if (it != map.end() && TypeIs<std::string>(it->second)) {
    std::string v = GetValue<std::string>(it->second);
    if (v == "all")  // public
      conf.type = IceTransportsType::kAll;
    else if (v == "relay")
      conf.type = IceTransportsType::kRelay;
    else if (v == "nohost")
      conf.type = IceTransportsType::kNoHost;
    else if (v == "none")
      conf.type = IceTransportsType::kNone;
  }

  // bundlePolicy (public api)
  it = map.find(EncodableValue("bundlePolicy"));
  if (it != map.end() && TypeIs<std::string>(it->second)) {
    std::string v = GetValue<std::string>(it->second);
    if (v == "balanced")  // public
      conf.bundle_policy = kBundlePolicyBalanced;
    else if (v == "max-compat")  // public
      conf.bundle_policy = kBundlePolicyMaxCompat;
    else if (v == "max-bundle")  // public
      conf.bundle_policy = kBundlePolicyMaxBundle;
  }

  // rtcpMuxPolicy (public api)
  it = map.find(EncodableValue("rtcpMuxPolicy"));
  if (it != map.end() && TypeIs<std::string>(it->second)) {
    std::string v = GetValue<std::string>(it->second);
    if (v == "negotiate")  // public
      conf.rtcp_mux_policy = RtcpMuxPolicy::kRtcpMuxPolicyNegotiate;
    else if (v == "require")  // public
      conf.rtcp_mux_policy = RtcpMuxPolicy::kRtcpMuxPolicyRequire;
  }

  // FIXME: peerIdentity of type DOMString (public API)
  // FIXME: certificates of type sequence<RTCCertificate> (public API)
  // iceCandidatePoolSize of type unsigned short, defaulting to 0
  it = map.find(EncodableValue("iceCandidatePoolSize"));
  if (it != map.end()) {
    conf.ice_candidate_pool_size = GetValue<int>(it->second);
  }

  // sdpSemantics (public api)
  it = map.find(EncodableValue("sdpSemantics"));
  if (it != map.end() && TypeIs<std::string>(it->second)) {
    std::string v = GetValue<std::string>(it->second);
    if (v == "plan-b")  // public
      conf.sdp_semantics = SdpSemantics::kPlanB;
    else if (v == "unified-plan")  // public
      conf.sdp_semantics = SdpSemantics::kUnifiedPlan;
  }
  return true;
}


scoped_refptr<RTCMediaTrack> FlutterWebRTCBase::MediaTracksForId(
    const std::string& id) {
  auto it = local_tracks_.find(id);
  if (it != local_tracks_.end()) {
    return (*it).second;
  }

  for(auto it2 : peerconnection_observers_) {
      auto pco = it2.second;
      auto t = pco->MediaTrackForId(id);
      if(t != nullptr) {
        return t;
      }
  }

  return nullptr;
}

void FlutterWebRTCBase::RemoveTracksForId(const std::string& id) {
  auto it = local_tracks_.find(id);
  if (it != local_tracks_.end())
    local_tracks_.erase(it);
}


}  // namespace flutter_webrtc_plugin
