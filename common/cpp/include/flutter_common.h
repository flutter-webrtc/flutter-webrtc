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

// foo.StringValue() becomes std::get<std::string>(foo)
// foo.IsString() becomes std::holds_alternative<std::string>(foo)

template <typename T>
inline bool TypeIs(const flutter::EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template <typename T>
inline const T GetValue(flutter::EncodableValue val) {
  return std::get<T>(val);
}

inline flutter::EncodableValue findEncodableValue(
    const flutter::EncodableMap& map,
    const std::string& key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it != map.end())
    return it->second;
  return flutter::EncodableValue();
}

inline flutter::EncodableMap findMap(const flutter::EncodableMap& map,
                                     const std::string& key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it != map.end() && TypeIs<flutter::EncodableMap>(it->second))
    return GetValue<flutter::EncodableMap>(it->second);
  return flutter::EncodableMap();
}

inline flutter::EncodableList findList(const flutter::EncodableMap& map,
                                       const std::string& key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it != map.end() && TypeIs<flutter::EncodableList>(it->second))
    return GetValue<flutter::EncodableList>(it->second);
  return flutter::EncodableList();
}

inline std::string findString(const flutter::EncodableMap& map,
                              const std::string& key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

inline int findInt(const flutter::EncodableMap& map, const std::string& key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it != map.end() && TypeIs<int>(it->second))
    return GetValue<int>(it->second);
  return -1;
}

inline double findDouble(const flutter::EncodableMap& map,
                         const std::string& key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it != map.end() && TypeIs<double>(it->second))
    return GetValue<double>(it->second);
  return 0.0;
}

inline int64_t findLongInt(const flutter::EncodableMap& map,
                           const std::string& key) {
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

class EventChannelProxy {
 public:
  EventChannelProxy(BinaryMessenger* messenger, const std::string& channelName)
      : channel_(std::make_unique<EventChannel>(
            messenger,
            channelName,
            &flutter::StandardMethodCodec::GetInstance())) {
    auto handler = std::make_unique<
        flutter::StreamHandlerFunctions<EncodableValue>>(
        [&](const EncodableValue* arguments,
            std::unique_ptr<flutter::EventSink<EncodableValue>>&& events)
            -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
          sink_ = std::move(events);
          for (auto& event : event_queue_) {
            sink_->Success(event);
          }
          event_queue_.clear();
          return nullptr;
        },
        [&](const EncodableValue* arguments)
            -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
          sink_.reset();
          return nullptr;
        });

    channel_->SetStreamHandler(std::move(handler));
  }

  void Success(const EncodableValue& event, bool cache_event = true) {
    if (sink_) {
      sink_->Success(event);
    } else {
      if (cache_event) {
        event_queue_.push_back(event);
      }
    }
  }

 private:
  std::unique_ptr<EventChannel> channel_;
  std::unique_ptr<EventSink> sink_;
  std::list<EncodableValue> event_queue_;
};

#endif  // FLUTTER_WEBRTC_COMMON_HXX
