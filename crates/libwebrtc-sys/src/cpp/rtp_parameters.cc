#include "libwebrtc-sys/src/bridge.rs.h"
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

// Updates the `RtpParameters.encodings` with the provided values.
void rtp_parameters_set_encodings(
    webrtc::RtpParameters& parameters,
    const RtpEncodingParametersContainer& encodings) {
  for (int i = 0; i < parameters.encodings.size(); i++) {
    if (parameters.encodings[i].rid == encodings.ptr->rid) {
      parameters.encodings[i] = *encodings.ptr;
      return;
    }
  }
}

}  // namespace bridge
