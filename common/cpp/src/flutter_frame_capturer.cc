#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

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
  catch_frame_ = true;
}

void FlutterFrameCapturer::CaptureFrame(
    std::unique_ptr<MethodResultProxy> result) {
  mutex_.lock();
  // Here init catch_frame_ flag
  catch_frame_ = false;

  track_->AddRenderer(this);
  // Here waiting for catch_frame_ is set to true
  while(!catch_frame_){}
  // Here unlock the mutex
  mutex_.unlock();

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

  FILE* file = fopen(path_.c_str(), "wb");
  if (!file) {
    return false;
  }

  svpng(file, width, height, pixels, 1);
  fclose(file);
  return true;
}

}  // namespace flutter_webrtc_plugin