#ifndef EXAMPLE_CPP_VIDEO_PROCESSOR_CHANNEL_H_
#define EXAMPLE_CPP_VIDEO_PROCESSOR_CHANNEL_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

#include "video_processor_sample.h"

// Forwards the "flutter_webrtc_example/video_processor" method channel to a
// VideoProcessorSample, for the embedders that use the Flutter C++ client
// wrapper (Windows and eLinux). The Linux runner does the same with the GTK
// API in my_application.cc.
class VideoProcessorChannel {
 public:
  VideoProcessorChannel(
      flutter::BinaryMessenger* messenger,
      VideoProcessorSample::SharedInstanceGetter get_shared_instance)
      : sample_(get_shared_instance),
        channel_(messenger, "flutter_webrtc_example/video_processor",
                 &flutter::StandardMethodCodec::GetInstance()) {
    channel_.SetMethodCallHandler([this](const auto& call, auto result) {
      HandleMethodCall(call, std::move(result));
    });
  }

  ~VideoProcessorChannel() { channel_.SetMethodCallHandler(nullptr); }

 private:
  using EncodableValue = flutter::EncodableValue;

  template <typename T>
  static const T* GetArg(const flutter::EncodableMap& map, const char* key) {
    auto it = map.find(EncodableValue(key));
    return it == map.end() ? nullptr : std::get_if<T>(&it->second);
  }

  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
    const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
    const std::string* track_id =
        args ? GetArg<std::string>(*args, "trackId") : nullptr;
    if (!track_id) {
      result->Error("bad_args", "trackId is required");
      return;
    }

    if (call.method_name() == "setGrayscale") {
      const bool* enabled = GetArg<bool>(*args, "enabled");
      if (!enabled) {
        result->Error("bad_args", "enabled is required");
      } else if (!sample_.SetGrayscale(*track_id, *enabled)) {
        result->Error("no_track",
                      "not a local video track of flutter_webrtc: " +
                          *track_id);
      } else {
        result->Success();
      }
    } else if (call.method_name() == "remove") {
      result->Success(EncodableValue(sample_.Remove(*track_id)));
    } else {
      result->NotImplemented();
    }
  }

  VideoProcessorSample sample_;
  flutter::MethodChannel<EncodableValue> channel_;
};

#endif  // EXAMPLE_CPP_VIDEO_PROCESSOR_CHANNEL_H_
