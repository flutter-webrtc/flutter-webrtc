#ifndef FLUTTER_WEBRTC_COMMON_HXX
#define FLUTTER_WEBRTC_COMMON_HXX

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>

#include <list>
#include <memory>
#include <mutex>
#include <optional>
#include <queue>
#include <string>

typedef flutter::EncodableValue EncodableValue;
typedef flutter::EncodableMap EncodableMap;
typedef flutter::EncodableList EncodableList;
typedef flutter::BinaryMessenger BinaryMessenger;
typedef flutter::TextureRegistrar TextureRegistrar;
typedef flutter::PluginRegistrar PluginRegistrar;
typedef flutter::MethodChannel<EncodableValue> MethodChannel;
typedef flutter::EventChannel<EncodableValue> EventChannel;
typedef flutter::EventSink<EncodableValue> EventSink;
typedef flutter::MethodCall<EncodableValue> MethodCall;
typedef flutter::MethodResult<EncodableValue> MethodResult;

class TaskRunner;

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

inline bool findBoolean(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<bool>(it->second))
    return GetValue<bool>(it->second);
  return false;
}

inline double findDouble(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<double>(it->second))
    return GetValue<double>(it->second);
  return 0.0;
}

inline std::optional<double> maybeFindDouble(const EncodableMap& map,
                                             const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<double>(it->second))
    return GetValue<double>(it->second);
  return std::nullopt;
}

inline std::vector<uint8_t> findVector(const EncodableMap& map,
                                       const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::vector<uint8_t>>(it->second))
    return GetValue<std::vector<uint8_t>>(it->second);
  return std::vector<uint8_t>();
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

inline int toInt(flutter::EncodableValue inputVal, int defaultVal) {
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

class MethodCallProxy {
 public:
  static std::unique_ptr<MethodCallProxy> Create(const MethodCall& call);
  virtual ~MethodCallProxy() = default;
  // The name of the method being called.
  virtual const std::string& method_name() const = 0;

  // The arguments to the method call, or NULL if there are none.
  virtual const EncodableValue* arguments() const = 0;
};

class MethodResultProxy {
 public:
  static std::unique_ptr<MethodResultProxy> Create(
      std::unique_ptr<MethodResult> method_result);

  virtual ~MethodResultProxy() = default;

  // Reports success with no result.
  virtual void Success() = 0;

  // Reports success with a result.
  virtual void Success(const EncodableValue& result) = 0;

  // Reports an error.
  virtual void Error(const std::string& error_code,
                     const std::string& error_message,
                     const EncodableValue& error_details) = 0;

  // Reports an error with a default error code and no details.
  virtual void Error(const std::string& error_code,
                     const std::string& error_message = "") = 0;

  virtual void NotImplemented() = 0;
};

class EventChannelProxy {
 public:
  static std::unique_ptr<EventChannelProxy> Create(
      BinaryMessenger* messenger,
      TaskRunner* task_runner,
      const std::string& channelName);

  virtual ~EventChannelProxy() = default;

  virtual void Success(const EncodableValue& event,
                       bool cache_event = true) = 0;
};

#endif  // FLUTTER_WEBRTC_COMMON_HXX
