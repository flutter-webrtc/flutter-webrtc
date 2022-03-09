#pragma once

#include <string>

namespace rust {

inline namespace cxxbridge1 {

class String;

} // namespace cxxbridge1

} // namespace rust

struct VideoFrame;
struct RtcTrackEvent;

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
  virtual void OnFrame(VideoFrame) = 0;

  virtual ~OnFrameCallbackInterface() = default;
};

// Handler of events firing from a `PeerConnectionInterface`.
//
// Implementations must be thread safe, since these methods will be called on
// the `PeerConnection`'s signalling thread.
class PeerConnectionObserverInterface {
 public:
  // Called when a `connectionstatechange` event occurs.
  //
  // See: https://w3.org/TR/webrtc#event-connectionstatechange
  virtual void OnConnectionStateChange(const std::string& new_state) = 0;

  // Called when an `icecandidate` event occurs.
  //
  // See: https://w3.org/TR/webrtc#event-icecandidate
  virtual void OnIceCandidate(const rust::String candidate,
                              const rust::String mid,
                              int mline_index) = 0;

  // Called when an `icecandidateerror` event occurs.
  //
  // See: https://www.w3.org/TR/webrtc/#event-icecandidateerror
  virtual void OnIceCandidateError(const std::string& address,
                                   int port,
                                   const std::string& url,
                                   int error_code,
                                   const std::string& error_text) = 0;

  // Called when an `iceconnectionstatechange` event occurs.
  //
  // See: https://w3.org/TR/webrtc#event-iceconnectionstatechange
  virtual void OnIceConnectionStateChange(const std::string& new_state) = 0;

  // Called when an `icegatheringstatechange` event occurs.
  //
  // See: https://w3.org/TR/webrtc#event-icegatheringstatechange
  virtual void OnIceGatheringStateChange(const std::string& new_state) = 0;

  // Called when a `negotiation` event occurs.
  //
  // See: https://w3.org/TR/webrtc#event-negotiation
  virtual void OnNegotiationNeeded() = 0;

  // Called when a `signalingstatechange` event occurs.
  //
  // See: https://w3.org/TR/webrtc#event-signalingstatechange
  virtual void OnSignalingChange(const std::string& new_state) = 0;

  // Called when a `track` event occurs.
  //
  // See: https://w3.org/TR/webrtc#event-track
  virtual void OnTrack(RtcTrackEvent event) = 0;

  virtual ~PeerConnectionObserverInterface() = default;
};

// Handler of events firing from a `MediaStreamTrackInterface`.
class TrackObserverInterface {
 public:
  // Called when an `ended` event occurs.
  //
  // See: https://w3.org/TR/mediacapture-streams#event-mediastreamtrack-ended
  virtual void OnEnded() = 0;

  virtual ~TrackObserverInterface() = default;
};

// Completion callback for the `webrtc::AddIceCandidate`.
class AddIceCandidateCallbackInterface {
 public:
  // Called when the operation succeeds.
  virtual void OnSuccess() = 0;

  // Called when the operation fails with the `error`.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~AddIceCandidateCallbackInterface() = default;
};

// Callback, called whenever a set of available media devices changes.
class OnDeviceChangeCallback {
 public:
  // Called whenever a set of available media devices changes.
  virtual void OnDeviceChange() = 0;

  virtual ~OnDeviceChangeCallback() = default;
};
