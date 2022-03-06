#include "rtp_receiver_interface.h"

namespace bridge {

// Returns the `track` of the provided `RtpReceiverInterface`.
std::unique_ptr<MediaStreamTrackInterface> rtp_receiver_track(
    const RtpReceiverInterface& receiver) {
  return std::make_unique<MediaStreamTrackInterface>(receiver->track());
}

// Returns the `stream_ids` of the provided `RtpReceiverInterface`.
std::unique_ptr<std::vector<std::string>> rtp_receiver_stream_ids(
    const RtpReceiverInterface& receiver) {
  return std::make_unique<std::vector<std::string>>(receiver->stream_ids());
}

// Returns the `Parameters` of the provided `RtpReceiverInterface`.
std::unique_ptr<webrtc::RtpParameters> rtp_receiver_parameters(
    const RtpReceiverInterface& receiver) {
  return std::make_unique<webrtc::RtpParameters>(receiver->GetParameters());
}

}  // namespace bridge
