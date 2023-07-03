#include "flutter_frame_capturer.h"
#include <stdio.h>
#include <stdlib.h>

#include <png.h>

namespace flutter_webrtc_plugin {

FlutterFrameCapturer::FlutterFrameCapturer(RTCVideoTrack* track,
                                           std::string path) {
  track_ = track;
  path_ = path;
}

void FlutterFrameCapturer::OnFrame(scoped_refptr<RTCVideoFrame> frame) {
  // TODO: convert frame to png and save to path_
  mutex_.unlock();
}

void FlutterFrameCapturer::Capture(std::unique_ptr<MethodResultProxy> result) {
  mutex_.lock();
  track_->AddRenderer(this);
  // Here the OnFrame method has to unlock the mutex
  mutex_.lock();
  track_->RemoveRenderer(this);
  mutex_.unlock();

  std::shared_ptr<MethodResultProxy> result_ptr(result.release());
  result_ptr->Success();
}

}  // namespace flutter_webrtc_plugin