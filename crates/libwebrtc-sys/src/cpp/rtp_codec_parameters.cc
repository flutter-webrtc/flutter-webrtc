#include "rtp_codec_parameters.h"

namespace bridge {

// Returns the `RtpCodecParameters.name` field value.
std::unique_ptr<std::string> rtp_codec_parameters_name(
    const webrtc::RtpCodecParameters& codec) {
  return std::make_unique<std::string>(codec.name);
}

// Returns the `RtpCodecParameters.payload_type` field value.
int32_t rtp_codec_parameters_payload_type(
    const webrtc::RtpCodecParameters& codec) {
  return codec.payload_type;
}

// Returns the `RtpCodecParameters.clock_rate` field value.
int32_t rtp_codec_parameters_clock_rate(
    const webrtc::RtpCodecParameters& codec) {
  return codec.clock_rate.value();
}

// Returns the `RtpCodecParameters.num_channels` field value.
int32_t rtp_codec_parameters_num_channels(
    const webrtc::RtpCodecParameters& codec) {
  return codec.num_channels.value();
}

// Returns the `RtpCodecParameters.kind` field value.
MediaType rtp_codec_parameters_kind(const webrtc::RtpCodecParameters& codec) {
  return codec.kind;
}

}  // namespace bridge
