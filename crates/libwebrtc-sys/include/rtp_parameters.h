#pragma once

#include "bridge.h"

namespace bridge {

// Returns the `RtpParameters.transaction_id` field value.
std::unique_ptr<std::string> rtp_parameters_transaction_id(
    const webrtc::RtpParameters& parameters);

// Returns the `RtpParameters.mid` field value.
std::unique_ptr<std::string> rtp_parameters_mid(
    const webrtc::RtpParameters& parameters);

// Returns the `RtpParameters.rtcp` field value.
std::unique_ptr<webrtc::RtcpParameters> rtp_parameters_rtcp(
    const webrtc::RtpParameters& parameters);

}  // namespace bridge
