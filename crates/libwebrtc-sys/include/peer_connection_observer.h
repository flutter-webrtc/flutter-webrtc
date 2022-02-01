#pragma once

#include <functional>
#include <optional>
#include "api/peer_connection_interface.h"
#include "rust/cxx.h"

namespace bridge {

struct DynSetDescriptionCallback;
struct DynCreateSdpCallback;

}  // namespace bridge

namespace observer {

// `PeerConnectionObserver` handling `RTCPeerConnection` events.
class PeerConnectionObserver : public webrtc::PeerConnectionObserver {
  // Called when the `IceGatheringState` changes.
  void OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state);

  // Called when a new ICE candidate has been discovered.
  void OnIceCandidate(const webrtc::IceCandidateInterface* candidate);

  // Called when a remote peer opens a data channel.
  void OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel);

  // Called when the `SignalingState` changes.
  void OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state);
};

// `CreateSessionDescriptionObserver` propagating completion result to the Rust
// side.
class CreateSessionDescriptionObserver
    : public rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver> {
 public:
  // Creates a new `CreateSessionDescriptionObserver`.
  CreateSessionDescriptionObserver(rust::Box<bridge::DynCreateSdpCallback> cb);

  // Called when a `CreateOffer` or a `CreateAnswer` operation succeeds.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Called when a `CreateOffer` or a `CreateAnswer` operation fails.
  void OnFailure(webrtc::RTCError error);

 private:
  // Rust side callback.
  std::optional<rust::Box<bridge::DynCreateSdpCallback>> cb_;
};

// `SetLocalDescriptionObserverInterface` propagating completion result to the
// Rust side.
class SetLocalDescriptionObserver
    : public rtc::RefCountedObject<
        webrtc::SetLocalDescriptionObserverInterface> {
 public:
  // Creates a new `SetLocalDescriptionObserver`.
  SetLocalDescriptionObserver(rust::Box<bridge::DynSetDescriptionCallback> cb);

  // Called when a `SetLocalDescription` completes.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

 private:
  // Rust side callback.
  std::optional<rust::Box<bridge::DynSetDescriptionCallback>> cb_;
};

// `SetRemoteDescriptionObserver` propagating completion result to the Rust
// side.
class SetRemoteDescriptionObserver
    : public rtc::RefCountedObject<
        webrtc::SetRemoteDescriptionObserverInterface> {
 public:
  // Creates a new `SetRemoteDescriptionObserver`.
  SetRemoteDescriptionObserver(rust::Box<bridge::DynSetDescriptionCallback> cb);

  // Called when a `SetRemoteDescription` completes.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

 private:
  // Rust side callback.
  std::optional<rust::Box<bridge::DynSetDescriptionCallback>> cb_;
};

}  // namespace observer
