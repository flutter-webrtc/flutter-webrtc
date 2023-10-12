#pragma once

#include <mutex>
#include <optional>

#include "flutter/encodable_value.h"
#include "flutter/event_channel.h"
#include "flutter/event_stream_handler_functions.h"
#include "flutter/method_result.h"
#include "flutter/plugin_registrar.h"
#include "flutter/texture_registrar.h"
#include "medea_flutter_webrtc_native.h"

using namespace flutter;

namespace medea_flutter_webrtc {
template <typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template <typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

// Returns an `int64_t` value from the given `EncodableMap` by the given `key`
// if any, or a `-1` otherwise.
inline int64_t findLongInt(const EncodableMap& map, const std::string& key) {
  for (auto it : map) {
    if (key == GetValue<std::string>(it.first) &&
        (TypeIs<int64_t>(it.second) || TypeIs<int32_t>(it.second)))
      return GetValue<int64_t>(it.second);
  }

  return -1;
}

// Renderer of `VideoFrame`s on a Flutter texture.
class TextureVideoRenderer {
 public:
  // Creates a new `TextureVideoRenderer`.
  TextureVideoRenderer(TextureRegistrar* registrar, BinaryMessenger* messenger);

  // Constructs and returns a `FlutterDesktopPixelBuffer` from the current
  // `VideoFrame`.
  virtual FlutterDesktopPixelBuffer* CopyPixelBuffer(size_t width,
                                                     size_t height);

  // Called when a new `VideoFrame` is produced by the underlying source.
  virtual void OnFrame(VideoFrame frame);

  // Resets `TextureVideoRenderer` to the initial state.
  virtual void ResetRenderer();

  // Returns an ID of the Flutter texture associated with this renderer.
  int64_t texture_id() { return texture_id_; }

 private:
  // Indicates if at least one `VideoFrame` has been rendered.
  bool first_frame_rendered = false;

  // Object keeping track of external textures.
  TextureRegistrar* registrar_;

  // ID of the Flutter texture.
  int64_t texture_id_ = -1;

  // ID of the Flutter texture associated with this renderer.
  std::optional<VideoFrame> frame_;

  // Actual Flutter texture that incoming frames are rendered on.
  std::unique_ptr<flutter::TextureVariant> texture_;

  // Pointer to the `FlutterDesktopPixelBuffer` that is passed to the Flutter
  // texture.
  std::unique_ptr<FlutterDesktopPixelBuffer> pixel_buffer_;

  // Raw image buffer.
  std::unique_ptr<uint8_t> argb_buffer_;

  // Protects the `frame_`, `pixel_buffer_` and `argb_buffer_` fields that are
  // accessed from multiple threads.
  std::mutex mutex_;
};

// Manager storing and managing all the `TextureVideoRenderer`s.
class FlutterVideoRendererManager {
 public:
  FlutterVideoRendererManager(TextureRegistrar* registrar,
                              BinaryMessenger* messenger);

  // Creates a new `FlutterVideoRendererManager`.
  void CreateVideoRendererTexture(
      std::unique_ptr<MethodResult<EncodableValue>> result);

  // Changes a media source of the specific `TextureVideoRenderer`.
  void CreateFrameHandler(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  // Disposes the specific `TextureVideoRenderer`.
  void VideoRendererDispose(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

 private:
  // Object keeping track of external textures.
  TextureRegistrar* registrar_;

  // Channel to the Dart side renderers.
  BinaryMessenger* messenger_;

  // Map containing all the `TextureVideoRenderer`s.
  std::map<int64_t, std::shared_ptr<TextureVideoRenderer>> renderers_;
};

// `OnFrameCallbackInterface` forwarding all incoming `VideoFrame`s to a
// `TextureVideoRenderer`.
class FrameHandler : public OnFrameCallbackInterface {
 public:
  // Creates a new `FrameHandler`.
  FrameHandler(std::shared_ptr<TextureVideoRenderer> renderer);

  // `OnFrameCallbackInterface` implementation.
  void OnFrame(VideoFrame frame);

 private:
  // `TextureVideoRenderer` that the `VideoFrame`s will be passed to.
  std::shared_ptr<TextureVideoRenderer> renderer_;
};

}  // namespace medea_flutter_webrtc
