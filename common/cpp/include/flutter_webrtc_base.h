#ifndef FLUTTER_WEBRTC_BASE_HXX
#define FLUTTER_WEBRTC_BASE_HXX

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>

#include <string.h>
#include <list>
#include <map>
#include <memory>
#include <mutex>

#include "libwebrtc.h"
#include "rtc_audio_device.h"
#include "rtc_media_stream.h"
#include "rtc_media_track.h"
#include "rtc_mediaconstraints.h"
#include "rtc_peerconnection.h"
#include "rtc_peerconnection_factory.h"
#include "rtc_video_device.h"
#include "uuidxx.h"

namespace flutter_webrtc_plugin {

using namespace libwebrtc;
using namespace flutter;

class FlutterVideoRenderer;
class FlutterRTCDataChannelObserver;
class FlutterPeerConnectionObserver;

// foo.StringValue() becomes std::get<std::string>(foo)
// foo.IsString() becomes std::holds_alternative<std::string>(foo)

template <typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template <typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

inline EncodableValue findEncodableValue(const EncodableMap& map,
                                         const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end())
    return it->second;
  return EncodableValue();
}

inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableMap>(it->second))
    return GetValue<EncodableMap>(it->second);
  return EncodableMap();
}

inline EncodableList findList(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableList>(it->second))
    return GetValue<EncodableList>(it->second);
  return EncodableList();
}

inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

inline int findInt(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<int>(it->second))
    return GetValue<int>(it->second);
  return -1;
}

inline double findDouble(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<double>(it->second))
    return GetValue<double>(it->second);
  return 0.0;
}

inline int64_t findLongInt(const EncodableMap& map, const std::string& key) {
  for (auto it : map) {
    if (key == GetValue<std::string>(it.first)) {
      if (TypeIs<int64_t>(it.second)) {
        return GetValue<int64_t>(it.second);
      } else if (TypeIs<int32_t>(it.second)) {
        return GetValue<int32_t>(it.second);
      }
    }
  }

  return -1;
}

inline int toInt(EncodableValue inputVal, int defaultVal) {
  int intValue = defaultVal;
  if (TypeIs<int>(inputVal)) {
    intValue = GetValue<int>(inputVal);
  } else if (TypeIs<int32_t>(inputVal)) {
    intValue = GetValue<int32_t>(inputVal);
  } else if (TypeIs<std::string>(inputVal)) {
    intValue = atoi(GetValue<std::string>(inputVal).c_str());
  }
  return intValue;
}

class FlutterWebRTCBase {
 public:
  friend class FlutterMediaStream;
  friend class FlutterPeerConnection;
  friend class FlutterVideoRendererManager;
  friend class FlutterDataChannel;
  friend class FlutterPeerConnectionObserver;
  friend class FlutterScreenCapture;
  enum ParseConstraintType { kMandatory, kOptional };

 public:
  FlutterWebRTCBase(BinaryMessenger* messenger, TextureRegistrar* textures);
  ~FlutterWebRTCBase();

  std::string GenerateUUID();

  RTCPeerConnection* PeerConnectionForId(const std::string& id);

  void RemovePeerConnectionForId(const std::string& id);

  RTCMediaTrack* MediaTrackForId(const std::string& id);

  void RemoveMediaTrackForId(const std::string& id);

  FlutterPeerConnectionObserver* PeerConnectionObserversForId(
      const std::string& id);

  void RemovePeerConnectionObserversForId(const std::string& id);

  scoped_refptr<RTCMediaStream> MediaStreamForId(const std::string& id);

  void RemoveStreamForId(const std::string& id);

  bool ParseConstraints(const EncodableMap& constraints,
                        RTCConfiguration* configuration);

  scoped_refptr<RTCMediaConstraints> ParseMediaConstraints(
      const EncodableMap& constraints);

  bool ParseRTCConfiguration(const EncodableMap& map,
                             RTCConfiguration& configuration);

  scoped_refptr<RTCMediaTrack> MediaTracksForId(const std::string& id);

  void RemoveTracksForId(const std::string& id);

  EventSink<EncodableValue> *event_sink();

 private:
  void ParseConstraints(const EncodableMap& src,
                        scoped_refptr<RTCMediaConstraints> mediaConstraints,
                        ParseConstraintType type = kMandatory);

  bool CreateIceServers(const EncodableList& iceServersArray,
                        IceServer* ice_servers);

 protected:
  scoped_refptr<RTCPeerConnectionFactory> factory_;
  scoped_refptr<RTCAudioDevice> audio_device_;
  scoped_refptr<RTCVideoDevice> video_device_;
  scoped_refptr<RTCDesktopDevice> desktop_device_;
  RTCConfiguration configuration_;

  std::map<std::string, scoped_refptr<RTCPeerConnection>> peerconnections_;
  std::map<std::string, scoped_refptr<RTCMediaStream>> local_streams_;
  std::map<std::string, scoped_refptr<RTCMediaTrack>> local_tracks_;
  std::map<int64_t, std::shared_ptr<FlutterVideoRenderer>> renders_;
  std::map<std::string, std::shared_ptr<FlutterRTCDataChannelObserver>>
      data_channel_observers_;
  std::map<std::string, std::shared_ptr<FlutterPeerConnectionObserver>>
      peerconnection_observers_;
  mutable std::mutex mutex_;

  void lock() { mutex_.lock(); }
  void unlock() { mutex_.unlock(); }

 protected:
  BinaryMessenger* messenger_;
  TextureRegistrar* textures_;
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_BASE_HXX
