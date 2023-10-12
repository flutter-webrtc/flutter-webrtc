#include "flutter/method_channel.h"
#include "flutter/standard_method_codec.h"
#include "medea_flutter_webrtc_native.h"
#include "video_renderer.h"

namespace medea_flutter_webrtc {

// Creates a new `FlutterVideoRendererManager`.
FlutterVideoRendererManager::FlutterVideoRendererManager(
    TextureRegistrar* registrar,
    BinaryMessenger* messenger)
    : registrar_(registrar), messenger_(messenger) {}

// Creates a new `TextureVideoRenderer`.
void FlutterVideoRendererManager::CreateVideoRendererTexture(
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::shared_ptr<TextureVideoRenderer> texture(
      new TextureVideoRenderer(registrar_, messenger_));

  int64_t texture_id = texture->texture_id();
  renderers_[texture_id] = std::move(texture);
  EncodableMap params;
  params[EncodableValue("textureId")] = EncodableValue(texture_id);

  result->Success(EncodableValue(params));
}

// Changes a media source of the specific `TextureVideoRenderer`.
void FlutterVideoRendererManager::CreateFrameHandler(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  int64_t texture_id = findLongInt(params, "textureId");

  auto it = renderers_.find(texture_id);
  auto handler_ptr = std::make_unique<FrameHandler>(it->second).release();
  EncodableMap res;
  res[EncodableValue("handler_ptr")] = EncodableValue((int64_t) handler_ptr);
  result->Success(EncodableValue(res));
}

// Disposes the specific `TextureVideoRenderer`.
void FlutterVideoRendererManager::VideoRendererDispose(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  int64_t texture_id = findLongInt(params, "textureId");

  auto it = renderers_.find(texture_id);
  if (it != renderers_.end()) {
    std::shared_ptr<TextureVideoRenderer> renderer = it->second;
    registrar_->UnregisterTexture(texture_id, [renderer] {});
    renderers_.erase(it);
    result->Success();
    return;
  }
  result->Error("VideoRendererDisposeFailed",
                "VideoRendererDispose() texture not found!");
}

// Creates a new `TextureVideoRenderer`.
TextureVideoRenderer::TextureVideoRenderer(TextureRegistrar* registrar,
                                           BinaryMessenger* messenger)
    : registrar_(registrar) {
  texture_ =
      std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
          [this](size_t width,
                 size_t height) -> const FlutterDesktopPixelBuffer* {
            return this->CopyPixelBuffer(width, height);
          }));

  texture_id_ = registrar_->RegisterTexture(texture_.get());
}

// Constructs and returns `FlutterDesktopPixelBuffer` from the current
// `VideoFrame`.
FlutterDesktopPixelBuffer* TextureVideoRenderer::CopyPixelBuffer(size_t width,
                                                                 size_t height) {
  mutex_.lock();
  if (pixel_buffer_.get() && frame_) {
    if (pixel_buffer_->width != frame_->width ||
        pixel_buffer_->height != frame_->height) {
      size_t buffer_size = frame_->buffer_size;
      argb_buffer_.reset(new uint8_t[buffer_size]);
      pixel_buffer_->width = frame_->width;
      pixel_buffer_->height = frame_->height;
    }

    frame_->GetABGRBytes(argb_buffer_.get());

    pixel_buffer_->buffer = argb_buffer_.get();

    mutex_.unlock();
    return pixel_buffer_.get();
  }
  mutex_.unlock();
  return nullptr;
}

// Saves the provided `VideoFrame` and calls
// `TextureRegistrar->MarkTextureFrameAvailable()` to notify the Flutter side
// about a new frame being ready for polling.
void TextureVideoRenderer::OnFrame(VideoFrame frame) {
  if (!first_frame_rendered) {
    pixel_buffer_.reset(new FlutterDesktopPixelBuffer());
    pixel_buffer_->width = 0;
    pixel_buffer_->height = 0;
    first_frame_rendered = true;
  }
  mutex_.lock();
  frame_.emplace(std::move(frame));
  mutex_.unlock();
  registrar_->MarkTextureFrameAvailable(texture_id_);
}

// Resets a `TextureVideoRenderer` to the initial state.
void TextureVideoRenderer::ResetRenderer() {
  mutex_.lock();
  frame_.reset();
  mutex_.unlock();
  frame_ = std::nullopt;
  first_frame_rendered = false;
}

// Creates a new `FrameHandler`.
FrameHandler::FrameHandler(
    std::shared_ptr<TextureVideoRenderer> ctx) {
  renderer_ = std::move(ctx);
}

// Forwards the received `VideoFrame` to the `TextureVideoRenderer->OnFrame()`.
void FrameHandler::OnFrame(VideoFrame frame) {
  renderer_->OnFrame(std::move(frame));
}

}  // namespace medea_flutter_webrtc
