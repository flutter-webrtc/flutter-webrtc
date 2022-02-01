
#include "libwebrtc-sys\include\peer_connection_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace observer {

// Does nothing at the moment.
void PeerConnectionObserver::OnIceGatheringChange(
    webrtc::PeerConnectionInterface::IceGatheringState new_state) {}

// Does nothing at the moment.
void PeerConnectionObserver::OnIceCandidate(
    const webrtc::IceCandidateInterface* candidate) {}

// Does nothing at the moment.
void PeerConnectionObserver::OnDataChannel(
    rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {}

// Does nothing at the moment.
void PeerConnectionObserver::OnSignalingChange(
    webrtc::PeerConnectionInterface::SignalingState new_state) {}

// Creates a new `CreateSessionDescriptionObserver` backed by the provided
// `bridge::DynCreateSdpCallback`.
CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::Box<bridge::DynCreateSdpCallback> cb) {
  this->cb_ = std::move(cb);
}

// Propagates the received SDP to the Rust side.
void CreateSessionDescriptionObserver::OnSuccess(
    webrtc::SessionDescriptionInterface* desc) {
  if (cb_) {
    auto cb = std::move(*cb_);

    std::string sdp;
    desc->ToString(&sdp);
    bridge::create_sdp_success(std::move(cb), sdp, desc->GetType());
  }
  delete desc;
}

// Propagates the received error to the Rust side.
void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
  if (cb_) {
    auto cb = std::move(*cb_);

    std::string err = std::string(error.message());
    bridge::create_sdp_fail(std::move(cb), err);
  }
}

// Creates a new `SetLocalDescriptionObserver` backed by the provided
// `DynSetDescriptionCallback`.
SetLocalDescriptionObserver::SetLocalDescriptionObserver(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  this->cb_ = std::move(cb);
}

// Propagates the completion result to the Rust side.
void SetLocalDescriptionObserver::OnSetLocalDescriptionComplete(
    webrtc::RTCError error) {
  if (cb_) {
    auto cb = std::move(*cb_);

    if (error.ok()) {
      bridge::set_description_success(std::move(cb));
    } else {
      std::string err = std::string(error.message());
      bridge::set_description_fail(std::move(cb), err);
    }
  }
}

// Creates a new `SetRemoteDescriptionObserver` backed by the provided
// `DynSetDescriptionCallback`.
SetRemoteDescriptionObserver::SetRemoteDescriptionObserver(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  this->cb_ = std::move(cb);
}

// Propagates the completion result to the Rust side.
void SetRemoteDescriptionObserver::OnSetRemoteDescriptionComplete(
    webrtc::RTCError error) {
  if (cb_) {
    auto cb = std::move(*cb_);

    if (error.ok()) {
      bridge::set_description_success(std::move(cb));
    } else {
      std::string err = std::string(error.message());
      bridge::set_description_fail(std::move(cb), err);
    }
  }
}

}  // namespace observer
