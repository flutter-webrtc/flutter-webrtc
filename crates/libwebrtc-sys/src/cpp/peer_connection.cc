#include "libwebrtc-sys/src/bridge.rs.h"

namespace bridge {

// Creates a new `PeerConnectionObserver` backed by the provided
// `DynPeerConnectionEventsHandler`.
PeerConnectionObserver::PeerConnectionObserver(
    rust::Box<bridge::DynPeerConnectionEventsHandler> cb)
    : cb_(std::move(cb)) {};

// Propagates the new `SignalingState` to the Rust side.
void PeerConnectionObserver::OnSignalingChange(
    webrtc::PeerConnectionInterface::SignalingState new_state) {
  bridge::on_signaling_change(*cb_, new_state);
}

// Propagates the `event_id` to the Rust side.
void PeerConnectionObserver::OnNegotiationNeededEvent(uint32_t event_id) {
  bridge::on_negotiation_needed_event(*cb_, event_id);
}

// Propagates the new `IceConnectionState` to the Rust side.
void PeerConnectionObserver::OnStandardizedIceConnectionChange(
    webrtc::PeerConnectionInterface::IceConnectionState new_state) {
  bridge::on_standardized_ice_connection_change(*cb_, new_state);
}

// Propagates the new `PeerConnectionState` to the Rust side.
void PeerConnectionObserver::OnConnectionChange(
    webrtc::PeerConnectionInterface::PeerConnectionState new_state) {
  bridge::on_connection_change(*cb_, new_state);
}

// Propagates the new `IceGatheringState` to the Rust side.
void PeerConnectionObserver::OnIceGatheringChange(
    webrtc::PeerConnectionInterface::IceGatheringState new_state) {
  bridge::on_ice_gathering_change(*cb_, new_state);
}

// Propagates the discovered `IceCandidateInterface` to the Rust side.
void PeerConnectionObserver::OnIceCandidate(
    const webrtc::IceCandidateInterface* candidate) {
  std::unique_ptr<webrtc::IceCandidateInterface> candidate_copy(
      webrtc::CreateIceCandidate(candidate->sdp_mid(),
                                 candidate->sdp_mline_index(),
                                 candidate->candidate()));

  bridge::on_ice_candidate(*cb_, std::move(candidate_copy));
}

// Propagates received error information to the Rust side.
void PeerConnectionObserver::OnIceCandidateError(const std::string& address,
                                                 int port,
                                                 const std::string& url,
                                                 int err_code,
                                                 const std::string& err_text) {
  bridge::on_ice_candidate_error(*cb_, address, port, url, err_code, err_text);
}

// Propagates the removed `Candidate`s to the Rust side.
void PeerConnectionObserver::OnIceCandidatesRemoved(
    const std::vector<cricket::Candidate>& candidates) {
  bridge::on_ice_candidates_removed(*cb_, candidates);
}

// Propagates the new ICE connection receiving status to the Rust side.
void PeerConnectionObserver::OnIceConnectionReceivingChange(bool receiving) {
  bridge::on_ice_connection_receiving_change(*cb_, receiving);
}

// Propagates the received `CandidatePairChangeEvent` to the Rust side.
void PeerConnectionObserver::OnIceSelectedCandidatePairChanged(
    const cricket::CandidatePairChangeEvent& event) {
  bridge::on_ice_selected_candidate_pair_changed(*cb_, event);
}

// Propagates the received `RtpTransceiverInterface` to the Rust side.
void PeerConnectionObserver::OnTrack(
    rtc::scoped_refptr<webrtc::RtpTransceiverInterface> transceiver) {
  bridge::on_track(
      *cb_, std::make_unique<bridge::RtpTransceiverInterface>(transceiver));
}

// Propagates the received `RtpReceiverInterface` to the Rust side.
void PeerConnectionObserver::OnRemoveTrack(
    rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver) {
  bridge::on_remove_track(
      *cb_, std::make_unique<bridge::RtpReceiverInterface>(receiver));
}

// Does nothing since we do not use `DataChannel`s at the moment.
void PeerConnectionObserver::OnDataChannel(
    rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {};

// Does nothing since we do not plan to support "Plan B" semantics.
void PeerConnectionObserver::OnAddTrack(
    rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver,
    const std::vector<rtc::scoped_refptr<webrtc::MediaStreamInterface>>&
        streams) {}

// Creates a new `CreateSessionDescriptionObserver` backed by the provided
// `bridge::DynCreateSdpCallback`.
CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::Box<bridge::DynCreateSdpCallback> cb)
    : cb_(std::move(cb)) {};

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
    rust::Box<bridge::DynSetDescriptionCallback> cb)
    : cb_(std::move(cb)) {};

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
    rust::Box<bridge::DynSetDescriptionCallback> cb)
    : cb_(std::move(cb)) {};

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

// `RTCStatsCollectorCallback` propagating completion result to the Rust side.
RTCStatsCollectorCallback::RTCStatsCollectorCallback(
    rust::Box<bridge::DynRTCStatsCollectorCallback> cb)
    : cb_(std::move(cb)) {};

// Propagates the completion result to the Rust side.
void RTCStatsCollectorCallback::OnStatsDelivered(const RTCStatsReport& report) {
  if (cb_) {
    auto cb = std::move(*cb_);

    bridge::on_stats_delivered(std::move(cb),
                               std::make_unique<RTCStatsReport>(report));
  }
}

// Calls `PeerConnectionInterface->CreateOffer`.
void create_offer(PeerConnectionInterface& peer_connection_interface,
                  const RTCOfferAnswerOptions& options,
                  std::unique_ptr<CreateSessionDescriptionObserver> obs) {
  peer_connection_interface->CreateOffer(obs.release(), options);
}

// Calls `PeerConnectionInterface->CreateAnswer`.
void create_answer(PeerConnectionInterface& peer_connection_interface,
                   const RTCOfferAnswerOptions& options,
                   std::unique_ptr<CreateSessionDescriptionObserver> obs) {
  peer_connection_interface->CreateAnswer(obs.release(), options);
}

// Calls `PeerConnectionInterface->SetLocalDescription`.
void set_local_description(PeerConnectionInterface& peer_connection_interface,
                           std::unique_ptr<SessionDescriptionInterface> desc,
                           std::unique_ptr<SetLocalDescriptionObserver> obs) {
  auto observer =
      rtc::scoped_refptr<webrtc::SetLocalDescriptionObserverInterface>(
          obs.release());
  peer_connection_interface->SetLocalDescription(std::move(desc), observer);
}

// Calls `PeerConnectionInterface->SetRemoteDescription`.
void set_remote_description(PeerConnectionInterface& peer_connection_interface,
                            std::unique_ptr<SessionDescriptionInterface> desc,
                            std::unique_ptr<SetRemoteDescriptionObserver> obs) {
  auto observer =
      rtc::scoped_refptr<SetRemoteDescriptionObserver>(obs.release());
  peer_connection_interface->SetRemoteDescription(std::move(desc), observer);
}

// Calls `PeerConnectionInterface->AddTransceiver`.
std::unique_ptr<RtpTransceiverInterface> add_transceiver(
    PeerConnectionInterface& peer,
    webrtc::MediaType media_type,
    const RtpTransceiverInit& init) {
  return std::make_unique<RtpTransceiverInterface>(
      peer->AddTransceiver(media_type, init).MoveValue());
}

// Calls `PeerConnectionInterface->GetTransceivers`.
rust::Vec<TransceiverContainer> get_transceivers(
    const PeerConnectionInterface& peer) {
  rust::Vec<TransceiverContainer> transceivers;

  for (auto transceiver : peer->GetTransceivers()) {
    TransceiverContainer container = {
        std::make_unique<RtpTransceiverInterface>(transceiver)};
    transceivers.push_back(std::move(container));
  }

  return transceivers;
}

// Calls `PeerConnectionInterface::AddIceCandidate`.
void add_ice_candidate(const PeerConnectionInterface& peer,
                       std::unique_ptr<webrtc::IceCandidateInterface> candidate,
                       rust::Box<bridge::DynAddIceCandidateCallback> cb) {
  peer->AddIceCandidate(std::move(candidate), [&](webrtc::RTCError err) {
    if (err.ok()) {
      add_ice_candidate_success(std::move(cb));
    } else {
      add_ice_candidate_fail(std::move(cb), err.message());
    }
  });
}

// Calls `PeerConnectionInterface->RestartIce`.
void restart_ice(const PeerConnectionInterface& peer) {
  peer->RestartIce();
}

// Calls `PeerConnectionInterface->Close`.
void close_peer_connection(const PeerConnectionInterface& peer) {
  peer->Close();
}

// Calls `PeerConnectionInterface->GetStats`.
void peer_connection_get_stats(const PeerConnectionInterface& peer,
                               rust::Box<DynRTCStatsCollectorCallback> cb) {
  auto callback = new RTCStatsCollectorCallback(std::move(cb));
  peer->GetStats(callback);
}

}  // namespace bridge
