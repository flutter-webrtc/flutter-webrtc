#include <memory>

#include <flutter_webrtc_native.h>
#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "flutter_webrtc/flutter_webrtc_plugin.h"

using namespace rust::cxxbridge1;

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

template<typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template<typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

// Returns an `EncodableMap` value from the given `EncodableMap` by the given
// `key` if any, or an empty `EncodableMap` otherwise.
inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableMap>(it->second))
    return GetValue<EncodableMap>(it->second);
  return EncodableMap();
}

// Returns an `std::string` value from the given `EncodableMap` by the given
// `key` if any, or an empty `std::string` otherwise.
inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

// Calls Rust `EnumerateDevices()` and converts the received Rust vector of
// `MediaDeviceInfo` info for Dart.
void enumerate_device(rust::Box<Webrtc>& webrtc,
                      std::unique_ptr<MethodResult<EncodableValue>> result);

// Parses the received constraints from Dart and passes them to Rust
// `GetUserMedia()`, then converts the backed `MediaStream` info for Dart.
void get_user_media(const flutter::MethodCall<EncodableValue>& method_call,
                    Box<Webrtc>& webrtc,
                    std::unique_ptr<MethodResult<EncodableValue>> result);

// Parses video constraints received from Dart to Rust `VideoConstraints`.
VideoConstraints parse_video_constraints(const EncodableValue video_arg);

// Parses audio constraints received from Dart to Rust `AudioConstraints`.
AudioConstraints parse_audio_constraints(const EncodableValue audio_arg);

// Converts Rust `VideoConstraints` or `AudioConstraints` to `EncodableList`
// for passing to Dart according to `TrackKind`.
EncodableList get_params(TrackKind type, MediaStream& user_media);

// Disposes some media stream calling Rust `DisposeStream`.
void dispose_stream(const flutter::MethodCall<EncodableValue>& method_call,
                    Box<Webrtc>& webrtc,
                    std::unique_ptr<MethodResult<EncodableValue>> result);
