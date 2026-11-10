#include "video_processor_sample.h"

#include <atomic>
#include <cstdint>
#include <cstring>
#include <vector>

#include "flutter_webrtc.h"
#include "rtc_video_frame.h"
#include "rtc_video_processor.h"

// Removes the color of I420 frames: keeps the Y (luma) plane and sets both
// chroma planes to 128, the neutral value, which gives a black and white
// picture. Process() runs on the capture thread while set_enabled() is called
// from the platform thread, hence the atomic.
class GrayscaleProcessor : public libwebrtc::RTCVideoProcessor {
 public:
  ~GrayscaleProcessor() override = default;

  void set_enabled(bool enabled) { enabled_ = enabled; }

  libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> Process(
      libwebrtc::scoped_refptr<libwebrtc::RTCVideoFrame> frame) override {
    if (!enabled_)
      return frame;

    const int width = frame->width();
    const int height = frame->height();
    const int chroma_width = (width + 1) / 2;
    const int chroma_height = (height + 1) / 2;

    // The input frame must not be modified, so copy the luma into our own
    // plane and build a new frame from it.
    y_.resize(static_cast<size_t>(width) * height);
    const uint8_t* src_y = frame->DataY();
    const int stride_y = frame->StrideY();
    for (int row = 0; row < height; ++row)
      std::memcpy(y_.data() + static_cast<size_t>(row) * width,
                  src_y + static_cast<size_t>(row) * stride_y, width);

    const size_t chroma_size = static_cast<size_t>(chroma_width) * chroma_height;
    if (chroma_.size() != chroma_size)
      chroma_.assign(chroma_size, 128);

    return libwebrtc::RTCVideoFrame::Create(width, height, y_.data(), width,
                                            chroma_.data(), chroma_width,
                                            chroma_.data(), chroma_width);
  }

 private:
  std::atomic<bool> enabled_{false};
  // Scratch planes, only touched on the capture thread. The neutral chroma
  // plane is shared by U and V.
  std::vector<uint8_t> y_;
  std::vector<uint8_t> chroma_;
};

VideoProcessorSample::VideoProcessorSample(
    SharedInstanceGetter get_shared_instance)
    : get_shared_instance_(get_shared_instance) {}

VideoProcessorSample::~VideoProcessorSample() {
  // Detach whatever is still attached before freeing the processors.
  while (!processors_.empty())
    Remove(processors_.begin()->first);
}

bool VideoProcessorSample::SetGrayscale(const std::string& track_id,
                                        bool enabled) {
  auto it = processors_.find(track_id);
  if (it == processors_.end()) {
    flutter_webrtc_plugin::FlutterWebRTCBase* webrtc = get_shared_instance_();
    auto processor = std::make_unique<GrayscaleProcessor>();
    if (!webrtc || !webrtc->AddVideoProcessor(track_id, processor.get()))
      return false;
    it = processors_.emplace(track_id, std::move(processor)).first;
  }
  it->second->set_enabled(enabled);
  return true;
}

bool VideoProcessorSample::Remove(const std::string& track_id) {
  auto it = processors_.find(track_id);
  if (it == processors_.end())
    return false;
  // Returns false if the track was disposed first, in which case flutter_webrtc
  // has already detached the processor. Either way it is safe to free it now.
  flutter_webrtc_plugin::FlutterWebRTCBase* webrtc = get_shared_instance_();
  if (webrtc)
    webrtc->RemoveVideoProcessor(track_id, it->second.get());
  processors_.erase(it);
  return true;
}
