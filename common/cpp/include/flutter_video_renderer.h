#ifndef FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX
#define FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_video_frame.h"
#include "rtc_video_renderer.h"

#include <mutex>

#if defined(__linux__)

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#define FL_TYPE_WEBRTC_VIDEO_TEXTURE fl_webrtc_video_texture_get_type()
G_DECLARE_FINAL_TYPE(FlWebrtcVideoTexture,
                     fl_webrtc_video_texture,
                     FL,
                     WEBRTC_VIDEO_TEXTURE,
                     FlPixelBufferTexture)

typedef gboolean (*FlWebrtcVideoTextureCopyHandler)(
    FlWebrtcVideoTexture* texture,
    const uint8_t** out_buffer,
    uint32_t* width,
    uint32_t* height,
    GError** error,
    gpointer user_data);

FlWebrtcVideoTexture *fl_webrtc_video_texture_new(void) {
  FlWebrtcVideoTexture *self;
  self = FL_WEBRTC_VIDEO_TEXTURE((g_object_new(fl_webrtc_video_texture_get_type(), NULL)));
  return self;
}

int64_t fl_webrtc_video_texture_id(FlWebrtcVideoTexture *self) {
  return reinterpret_cast<int64_t>(self);
}

void fl_webrtc_video_texture_set_handler(FlWebrtcVideoTexture *self,
    FlWebrtcVideoTextureCopyHandler on_copy, gpointer user_data, GDestroyNotify destroy_notify) {
  if (self->user_data && self->destroy_notify)
    self->destroy_notify(self->user_data);

  self->on_copy = on_copy;
  self->user_data = user_data;
  self->destroy_notify = destroy_notify;
  return;
}

G_END_DECLS

struct FlutterDesktopPixelBuffer {
    FlutterDesktopPixelBuffer():buffer(nullptr), width(0), height(0){}
    const uint8_t *buffer;
    size_t width;
    size_t height;
};
#endif

namespace flutter_webrtc_plugin {

using namespace libwebrtc;

class FlutterVideoRenderer
    : public RTCVideoRenderer<scoped_refptr<RTCVideoFrame>> {
 public:
  FlutterVideoRenderer(TextureRegistrar* registrar, BinaryMessenger* messenger);

  virtual const FlutterDesktopPixelBuffer* CopyPixelBuffer(size_t width,
                                                           size_t height) const;

  virtual void OnFrame(scoped_refptr<RTCVideoFrame> frame) override;

  void SetVideoTrack(scoped_refptr<RTCVideoTrack> track);

  int64_t texture_id() { return texture_id_; }

  bool CheckMediaStream(std::string mediaId);

  bool CheckVideoTrack(std::string mediaId);

  std::string media_stream_id;

 private:
  struct FrameSize {
    size_t width;
    size_t height;
  };
  FrameSize last_frame_size_ = {0, 0};
  bool first_frame_rendered = false;
  TextureRegistrar* registrar_ = nullptr;
  std::unique_ptr<EventChannelProxy> event_channel_;
  int64_t texture_id_ = -1;
  scoped_refptr<RTCVideoTrack> track_ = nullptr;
  scoped_refptr<RTCVideoFrame> frame_;
#if defined(_WINDOWS)
  std::unique_ptr<flutter::TextureVariant> texture_;
#else
  FlWebrtcVideoTexture *texture_;
#endif
  std::shared_ptr<FlutterDesktopPixelBuffer> pixel_buffer_;
  mutable std::shared_ptr<uint8_t> rgb_buffer_;
  mutable std::mutex mutex_;
  RTCVideoFrame::VideoRotation rotation_ = RTCVideoFrame::kVideoRotation_0;
};

class FlutterVideoRendererManager {
 public:
  FlutterVideoRendererManager(FlutterWebRTCBase* base);

  void CreateVideoRendererTexture(std::unique_ptr<MethodResultProxy> result);

  void SetMediaStream(int64_t texture_id, const std::string& stream_id);

  void VideoRendererDispose(int64_t texture_id,
                            std::unique_ptr<MethodResultProxy> result);

 private:
  FlutterWebRTCBase* base_;
  std::map<int64_t, std::unique_ptr<FlutterVideoRenderer>> renderers_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX