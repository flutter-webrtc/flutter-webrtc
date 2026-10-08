#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#include "flutter_frame_capturer.h"
#include <stdio.h>
#include <stdlib.h>
#include <chrono>
#include <utility>
#include <vector>
#include "svpng.hpp"

namespace flutter_webrtc_plugin {

namespace {

// CaptureFrame() blocks the platform thread until the track delivers its next
// frame, so the wait has to be bounded. A live source delivers well inside
// this; a track that does not is stalled or no longer receiving, and the
// caller gets an error instead of a method call that never returns.
constexpr std::chrono::milliseconds kFrameTimeout(2000);

}  // namespace

FlutterFrameCapturer::FlutterFrameCapturer(RTCVideoTrack* track,
                                           std::string path)
    : track_(track), path_(std::move(path)) {}

void FlutterFrameCapturer::OnFrame(scoped_refptr<RTCVideoFrame> frame) {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    if (frame_ != nullptr) {
      // Only the first frame after AddRenderer() is kept.
      return;
    }
    frame_ = frame->Copy();
  }
  frame_ready_.notify_one();
}

void FlutterFrameCapturer::CaptureFrame(
    std::unique_ptr<MethodResultProxy> result) {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    frame_ = nullptr;
  }
  track_->AddRenderer(this);
  bool got_frame = WaitForFrame();
  // RemoveRenderer() returns only once no OnFrame() is in flight, so from
  // here frame_ is stable and this object may go out of scope.
  track_->RemoveRenderer(this);

  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  if (!got_frame) {
    result_ptr->Error("captureFrame",
                      "captureFrame() timed out waiting for a video frame");
  } else if (SaveFrame()) {
    result_ptr->Success();
  } else {
    result_ptr->Error("1", "Cannot save the frame as .png file");
  }
}

bool FlutterFrameCapturer::WaitForFrame() {
  std::unique_lock<std::mutex> lock(mutex_);
  return frame_ready_.wait_for(lock, kFrameTimeout,
                               [this] { return frame_ != nullptr; });
}

// Reads frame_ without the lock, so it must run after RemoveRenderer().
bool FlutterFrameCapturer::SaveFrame() {
  if (frame_ == nullptr) {
    return false;
  }

  int width = frame_->width();
  int height = frame_->height();
  const int bytes_per_pixel = 4;
  std::vector<uint8_t> pixels(static_cast<size_t>(width) * height *
                              bytes_per_pixel);

  frame_->ConvertToARGB(RTCVideoFrame::Type::kABGR, pixels.data(),
                        /* unused */ -1, width, height);

  FILE* file = fopen(path_.c_str(), "wb");
  if (!file) {
    return false;
  }

  svpng(file, width, height, pixels.data(), 1);
  fclose(file);
  return true;
}

}  // namespace flutter_webrtc_plugin
