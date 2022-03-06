#pragma once

#include "bridge.h"

namespace bridge {

// Returns the `track` of the provided `RtpReceiverInterface`.
std::unique_ptr<MediaStreamTrackInterface> rtp_receiver_track(
    const RtpReceiverInterface& receiver);

// Returns the `stream_ids` of the provided `RtpReceiverInterface`.
std::unique_ptr<std::vector<std::string>> rtp_receiver_stream_ids(
    const RtpReceiverInterface& receiver);

// Returns the `parameters` of the provided `RtpReceiverInterface`.
std::unique_ptr<webrtc::RtpParameters> rtp_receiver_parameters(
    const RtpReceiverInterface& receiver);

}  // namespace bridge
