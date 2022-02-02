#pragma once

#include <string>

struct VideoFrame;

// Completion callback for the `Webrtc::CreateOffer` and `Webrtc::CreateAnswer`
// functions.
class CreateSdpCallbackInterface {
 public:
  // Called when an operation succeeds.
  virtual void OnSuccess(const std::string& sdp, const std::string& kind) = 0;

  // Called when an operation fails with the `error`.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~CreateSdpCallbackInterface() = default;
};

// Completion callback for the `Webrtc::SetLocalDescription` and
// `Webrtc::SetRemoteDescription` functions.
class SetDescriptionCallbackInterface {
 public:
  // Called when an operation succeeds.
  virtual void OnSuccess() = 0;

  // Called when an operation fails with the `error`.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~SetDescriptionCallbackInterface() = default;
};

// Callback for video frames handlers provided to the
// `Webrtc::create_video_sink()` function.
class OnFrameCallbackInterface {
 public:
  // Called when the underlying video engine produces a new video frame.
  //
  // The provided frame is a pointer to the `rust::Box<VideoFrame>`. Its
  // ownership can be transferred back to the Rust side using the
  // `rust::Box::from_raw()`.
  virtual void OnFrame(VideoFrame) = 0;

  virtual ~OnFrameCallbackInterface() = default;
};
