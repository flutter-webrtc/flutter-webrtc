#include "flutter_webrtc_base.h"
#include "flutter_data_channel.h"
#include "flutter_peerconnection.h"

namespace flutter_webrtc_plugin {

FlutterWebRTCBase::FlutterWebRTCBase(BinaryMessenger *messenger,
                                     TextureRegistrar *textures)
    : messenger_(messenger), textures_(textures) {
  LibWebRTC::Initialize();
  factory_ = LibWebRTC::CreateRTCPeerConnectionFactory();
  audio_device_ = factory_->GetAudioDevice();
  video_device_ = factory_->GetVideoDevice();
  memset(&configuration_.ice_servers, 0, sizeof(configuration_.ice_servers));
}

FlutterWebRTCBase::~FlutterWebRTCBase() { LibWebRTC::Terminate(); }

std::string FlutterWebRTCBase::GenerateUUID() {
  return uuidxx::uuid::Generate().ToString(false);
}

RTCPeerConnection *FlutterWebRTCBase::PeerConnectionForId(
    const std::string &id) {
  auto it = peerconnections_.find(id);

  if (it != peerconnections_.end()) return (*it).second.get();

  return nullptr;
}

void FlutterWebRTCBase::RemovePeerConnectionForId(const std::string &id){
    auto it = peerconnections_.find(id);
    if (it != peerconnections_.end())
        peerconnections_.erase(it);
}

scoped_refptr<RTCMediaStream> FlutterWebRTCBase::MediaStreamForId(
    const std::string &id) {
  auto it = media_streams_.find(id);

  if (it != media_streams_.end()) return (*it).second;

  return nullptr;
}

void FlutterWebRTCBase::RemoveStreamForId(const std::string &id) {
    auto it = media_streams_.find(id);
    if (it != media_streams_.end())
        media_streams_.erase(it);
}

bool FlutterWebRTCBase::ParseConstraints(const EncodableMap &constraints,
                                         RTCConfiguration *configuration) {
  memset(&configuration->ice_servers, 0, sizeof(configuration->ice_servers));
  return false;
}

void FlutterWebRTCBase::ParseConstraints(
    const EncodableMap& src, scoped_refptr<RTCMediaConstraints> mediaConstraints,
    ParseConstraintType type /*= kMandatory*/) {
  for (auto kv : src) {
    EncodableValue k =  kv.first;
    EncodableValue v = kv.second;
    std::string key(k.StringValue());
    std::string value;
    if (v.IsList() ||
        v.IsMap()) {
    } else if (v.IsString()) {
        value = v.StringValue();
    } else if (v.IsDouble()) {
        value = std::to_string(v.DoubleValue());
    } else if (v.IsInt()) {
        value = std::to_string(v.IntValue());
    } else if (v.IsBool()) {
        value = v.BoolValue() ? RTCMediaConstraints::kValueTrue
                                     : RTCMediaConstraints::kValueFalse;
    } else {
        value = std::to_string(v.IntValue());
    }
    if (type == kMandatory)
      mediaConstraints->AddMandatoryConstraint(key.c_str(), value.c_str());
    else
      mediaConstraints->AddOptionalConstraint(key.c_str(), value.c_str());
  }
}

scoped_refptr<RTCMediaConstraints> FlutterWebRTCBase::ParseMediaConstraints(
    const EncodableMap & constraints) {
  scoped_refptr<RTCMediaConstraints> media_constraints =
      RTCMediaConstraints::Create();

  if (constraints.find(EncodableValue("mandatory")) != constraints.end()) {
    auto it = constraints.find(EncodableValue("mandatory"));
    const EncodableMap mandatory = it->second.MapValue();
    ParseConstraints(mandatory, media_constraints, kMandatory);
  } else {
    // Log.d(TAG, "mandatory constraints are not a map");
  }
  
  auto it = constraints.find(EncodableValue("optional"));
  if (it != constraints.end()) {
      const EncodableValue optional = it->second;
      switch (optional.type())
      {
      case EncodableValue::Type::kMap: {
          ParseConstraints(optional.MapValue(), media_constraints, kOptional);
      }
      break;
      case EncodableValue::Type::kList:
      {
          const EncodableList list = optional.ListValue();
          for (size_t i = 0; i < list.size(); i++) {
              ParseConstraints(list[i].MapValue(), media_constraints, kOptional);
          }
      }
      break;
      default:
          break;
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
    EncodableMap iceServerMap = iceServersArray[i].MapValue();
    boolean hasUsernameAndCredential = iceServerMap.find(EncodableValue("username")) != iceServerMap.end() &&
                                       iceServerMap.find(EncodableValue("credential")) != iceServerMap.end();
    auto it = iceServerMap.find(EncodableValue("url"));
    if (it != iceServerMap.end() && it->second.IsString()) {
      if (hasUsernameAndCredential) {
        std::string username = iceServerMap.find(EncodableValue("username"))->second.StringValue();
        std::string credential = iceServerMap.find(EncodableValue("credential"))->second.StringValue();
        std::string uri = it->second.StringValue();
        strncpy(ice_server.username, username.c_str(), username.size());
        strncpy(ice_server.password, credential.c_str(), credential.size());
        strncpy(ice_server.uri, uri.c_str(), uri.size());
      } else {
        std::string uri = it->second.StringValue();
        strncpy(ice_server.uri, uri.c_str(), uri.size());
      }
    }
    it = iceServerMap.find(EncodableValue("urls"));
    if (it != iceServerMap.end()) {
        if (it->second.IsString()) {
            if (hasUsernameAndCredential) {
                std::string username = iceServerMap.find(EncodableValue("username"))->second.StringValue();
                std::string credential = iceServerMap.find(EncodableValue("credential"))->second.StringValue();
                std::string uri = it->second.StringValue();
                strncpy(ice_server.username, username.c_str(), username.size());
                strncpy(ice_server.password, credential.c_str(), credential.size());
                strncpy(ice_server.uri, uri.c_str(), uri.size());
            }
            else {
                std::string uri = it->second.StringValue();
                strncpy(ice_server.uri, uri.c_str(), uri.size());
            }
        }
        if (it->second.IsList()) {
            const EncodableList urls = it->second.ListValue();
            for ( auto url : urls) {
                const EncodableMap map = url.MapValue();
                std::string url;
                auto it2 = map.find(EncodableValue("url"));
                if (it2 != map.end()) {
                    url = it2->second.StringValue();
                    if (hasUsernameAndCredential) {
                        std::string username = iceServerMap.find(EncodableValue("username"))->second.StringValue();
                        std::string credential = iceServerMap.find(EncodableValue("credential"))->second.StringValue();
                        strncpy(ice_server.username, username.c_str(), username.size());
                        strncpy(ice_server.password, credential.c_str(),
                            credential.size());
                        strncpy(ice_server.uri, url.c_str(), url.size());
                    }
                    else {
                        strncpy(ice_server.uri, url.c_str(), url.size());
                    }
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
      const EncodableList iceServersArray = it->second.ListValue();
      CreateIceServers(iceServersArray, conf.ice_servers);
  }
  // iceTransportPolicy (public API)
  it = map.find(EncodableValue("iceTransportPolicy"));
  if (it != map.end() && it->second.IsString()) {
    std::string v = it->second.StringValue();
    if (v == "all")  // public
      conf.type = kAll;
    else if (v == "relay")
      conf.type = kRelay;
    else if (v == "nohost")
      conf.type = kNoHost;
    else if (v == "none")
      conf.type = kNone;
  }

  // bundlePolicy (public api)
  it = map.find(EncodableValue("bundlePolicy"));
  if (it != map.end() && it->second.IsString()) {
      std::string v = it->second.StringValue();
    if (v == "balanced")  // public
      conf.bundle_policy = kBundlePolicyBalanced;
    else if (v == "max-compat")  // public
      conf.bundle_policy = kBundlePolicyMaxCompat;
    else if (v == "max-bundle")  // public
      conf.bundle_policy = kBundlePolicyMaxBundle;
  }

  // rtcpMuxPolicy (public api)
  it = map.find(EncodableValue("rtcpMuxPolicy"));
  if (it != map.end() && it->second.IsString()) {
     std::string v = it->second.StringValue();
    if (v == "negotiate")  // public
      conf.rtcp_mux_policy = kRtcpMuxPolicyNegotiate;
    else if (v == "require")  // public
      conf.rtcp_mux_policy = kRtcpMuxPolicyRequire;
  }

  // FIXME: peerIdentity of type DOMString (public API)
  // FIXME: certificates of type sequence<RTCCertificate> (public API)
  // iceCandidatePoolSize of type unsigned short, defaulting to 0
  it = map.find(EncodableValue("iceCandidatePoolSize"));
  if (it != map.end() && it->second.IsInt()) {
    int v = it->second.IntValue();
    conf.ice_candidate_pool_size = v;
  }

  return true;
}

};  // namespace flutter_webrtc_plugin
