#pragma once

struct VideoFrame;

// Callback for video frames handlers provided to the
// `Webrtc::create_video_sink()` function.
class OnFrameCallbackInterface {
 public:
  // Called when the underlying video engine produces a new video frame.
  virtual void OnFrame(VideoFrame) = 0;

  virtual ~OnFrameCallbackInterface() = default;
};
