#include "rtp_parameters.h"

namespace bridge {

// Returns the `RtpParameters.transaction_id` field value.
std::unique_ptr<std::string> rtp_parameters_transaction_id(
    const webrtc::RtpParameters& parameters) {
  return std::make_unique<std::string>(parameters.transaction_id);
}

// Returns the `RtpParameters.mid` field value.
std::unique_ptr<std::string> rtp_parameters_mid(
    const webrtc::RtpParameters& parameters) {
  return std::make_unique<std::string>(parameters.mid);
}

// Returns the `RtpParameters.rtcp` field value.
std::unique_ptr<webrtc::RtcpParameters> rtp_parameters_rtcp(
    const webrtc::RtpParameters& parameters) {
  return std::make_unique<webrtc::RtcpParameters>(parameters.rtcp);
}

}  // namespace bridge
