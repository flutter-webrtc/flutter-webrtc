#ifndef FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX
#define FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX

#include "flutter_webrtc_base.h"

#include "rtc_video_frame.h"
#include "rtc_video_renderer.h"

namespace flutter_webrtc_plugin {

using namespace libwebrtc;
using namespace flutter;

class FlutterVideoRenderer : public Texture,
      public RTCVideoRenderer<scoped_refptr<RTCVideoFrame>> {
 public:
  FlutterVideoRenderer(TextureRegistrar *registrar, BinaryMessenger *messenger);

  virtual std::shared_ptr<uint8_t> CopyTextureBuffer(size_t width,
                                                     size_t height) override;

  virtual void OnFrame(scoped_refptr<RTCVideoFrame> frame) override;

  void SetVideoTrack(RTCVideoTrack *track);

  int64_t texture_id() { return texture_id_; }

 private:
  struct FrameSize {
    size_t width;
    size_t height;
  };
  FrameSize dest_frame_size_ = {0, 0};
  FrameSize frame_size_ = {0, 0};
  bool first_frame_rendered = false;
  TextureRegistrar *registrar_ = nullptr;
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;
  const EventSink<EncodableValue> *event_sink_ = nullptr;
  int64_t texture_id_ = -1;
  RTCVideoTrack *track_ = nullptr;
  scoped_refptr<RTCVideoFrame> frame_;
  std::shared_ptr<uint8_t> frame_buffer_;
};

class FlutterVideoRendererManager {
 public:
  FlutterVideoRendererManager(FlutterWebRTCBase *base);

  void CreateVideoRendererTexture(
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void SetMediaStream(int64_t texture_id, const std::string &stream_id);

  void VideoRendererDispose(int64_t texture_id,
                            std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  FlutterWebRTCBase *base_;
  std::map<int64_t, std::unique_ptr<FlutterVideoRenderer>> renderers_;
};

};  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_VIDEO_RENDERER_HXX