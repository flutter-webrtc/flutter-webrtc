#ifndef FLUTTER_WEBRTC_BASE_HXX
#define FLUTTER_WEBRTC_BASE_HXX

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/texture_registrar.h>
#include <flutter/standard_method_codec.h >
#include <flutter/standard_message_codec.h>


#include "libwebrtc.h"
#include "rtc_audio_device.h"
#include "rtc_media_stream.h"
#include "rtc_media_track.h"
#include "rtc_mediaconstraints.h"
#include "rtc_peerconnection.h"
#include "rtc_peerconnection_factory.h"
#include "rtc_video_device.h"

#include "uuidxx.h"

#include <list>
#include <map>
#include <memory>

namespace flutter_webrtc_plugin {

using namespace libwebrtc;
using namespace flutter;

class FlutterVideoRenderer;
class FlutterRTCDataChannelObserver;
class FlutterPeerConnectionObserver;

inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
    auto it = map.find(EncodableValue(key));
    if (it != map.end() && it->second.IsMap())
        return it->second.MapValue();
    return EncodableMap();
}

inline std::string findString(const EncodableMap& map, const std::string& key) {
    auto it = map.find(EncodableValue(key));
    if (it != map.end() && it->second.IsString())
        return it->second.StringValue();
    return std::string();
}

inline int findInt(const EncodableMap& map, const std::string& key) {
    auto it = map.find(EncodableValue(key));
    if (it != map.end() && it->second.IsInt())
        return it->second.IntValue();
    return -1;
}

class FlutterWebRTCBase {
 public:
  friend class FlutterMediaStream;
  friend class FlutterPeerConnection;
  friend class FlutterVideoRendererManager;
  friend class FlutterDataChannel;
  friend class FlutterPeerConnectionObserver;
  enum ParseConstraintType { kMandatory, kOptional };
 public:
  FlutterWebRTCBase(BinaryMessenger *messenger, TextureRegistrar *textures);
  ~FlutterWebRTCBase();

  std::string GenerateUUID();

  RTCPeerConnection *PeerConnectionForId(const std::string &id);

  scoped_refptr<RTCMediaStream> MediaStreamForId(const std::string &id);

  bool ParseConstraints(const EncodableMap& constraints,
                            RTCConfiguration *configuration);

  scoped_refptr<RTCMediaConstraints> ParseMediaConstraints(
      const EncodableMap& constraints);

  bool ParseRTCConfiguration(const EncodableMap& map,
                             RTCConfiguration &configuration);
 private:
  void ParseConstraints(const EncodableMap& src,
                        scoped_refptr<RTCMediaConstraints> mediaConstraints,
                        ParseConstraintType type = kMandatory);

  bool CreateIceServers(const EncodableList& iceServersArray,
                        IceServer *ice_servers);
 protected:
  scoped_refptr<RTCPeerConnectionFactory> factory_;
  scoped_refptr<RTCAudioDevice> audio_device_;
  scoped_refptr<RTCVideoDevice> video_device_;
  RTCConfiguration configuration_;

  std::map<std::string, scoped_refptr<RTCPeerConnection>> peerconnections_;
  std::map<std::string, scoped_refptr<RTCMediaStream>> media_streams_;
  std::map<std::string, scoped_refptr<RTCMediaTrack>> media_tracks_;
  std::map<std::string, scoped_refptr<RTCDataChannel>> data_channels_;
  std::map<int64_t, std::shared_ptr<FlutterVideoRenderer>> renders_;
  std::map<int, std::unique_ptr<FlutterRTCDataChannelObserver>>
      data_channel_observers_;
  std::map<std::string, std::unique_ptr<FlutterPeerConnectionObserver>>
      peerconnection_observers_;

 protected:
  BinaryMessenger *messenger_;
  TextureRegistrar *textures_;
};

};  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_BASE_HXX
