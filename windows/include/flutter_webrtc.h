#pragma once

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <flutter_webrtc_native.h>

#include <string.h>
#include <list>
#include <map>
#include <memory>

#include "flutter_webrtc_native.h"

using namespace flutter;
using namespace rust::cxxbridge1;

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

// Returns an `bool` value from the given `EncodableMap` by the given
// `key` if any, or false otherwise.
inline bool findBool(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<bool>(it->second))
    return GetValue<bool>(it->second);
  return bool();
}

// Returns an `EncodableList` value from the given `EncodableMap` by the given
// `key` if any, or an empty `EncodableList` otherwise.
inline EncodableList findList(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableList>(it->second))
    return GetValue<EncodableList>(it->second);
  return EncodableList();
}

namespace flutter_webrtc_plugin {

class FlutterWebRTCPlugin : public flutter::Plugin {
 public:
  virtual flutter::BinaryMessenger* messenger() = 0;

  virtual flutter::TextureRegistrar* textures() = 0;
};

class FlutterWebRTC {
 public:
  FlutterWebRTC(FlutterWebRTCPlugin* plugin);
  virtual ~FlutterWebRTC();

  Box<Webrtc> webrtc = Init();

  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);
};

}  // namespace flutter_webrtc_plugin
