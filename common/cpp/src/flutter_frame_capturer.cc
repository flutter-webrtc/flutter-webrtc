#include "flutter_frame_capturer.h"
#include <stdio.h>
#include <stdlib.h>
#include "svpng.hpp"

namespace flutter_webrtc_plugin {

FlutterFrameCapturer::FlutterFrameCapturer(RTCVideoTrack* track,
                                           std::string path) {
  track_ = track;
  path_ = path;
}

void FlutterFrameCapturer::OnFrame(scoped_refptr<RTCVideoFrame> frame) {
  if (frame_ != nullptr) {
    return;
  }

  frame_ = frame.get()->Copy();
  mutex_.unlock();
}

void FlutterFrameCapturer::CaptureFrame(
    std::unique_ptr<MethodResultProxy> result) {
  mutex_.lock();
  track_->AddRenderer(this);
  // Here the OnFrame method has to unlock the mutex
  mutex_.lock();
  track_->RemoveRenderer(this);

  bool success = SaveFrame();
  mutex_.unlock();

  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  if (success) {
    result_ptr->Success();
  } else {
    result_ptr->Error("1", "Cannot save the frame as .png file");
  }
}

bool FlutterFrameCapturer::SaveFrame() {
  if (frame_ == nullptr) {
    return false;
  }

  int width = frame_.get()->width();
  int height = frame_.get()->height();
  int bytes_per_pixel = 4;
  uint8_t* pixels = new uint8_t[width * height * bytes_per_pixel];

  frame_.get()->ConvertToARGB(RTCVideoFrame::Type::kABGR, pixels,
                              /* unused */ -1, width, height);

  FILE* file;
#if defined(_WINDOWS)
  file = fopen_s(path_.c_str(), "wb");
#else
  file = fopen(path_.c_str(), "wb");
#endif
  if (!file) {
    return false;
  }

  svpng(file, width, height, pixels, 1);
  fclose(file);
  return true;
}

}  // namespace flutter_webrtc_plugin