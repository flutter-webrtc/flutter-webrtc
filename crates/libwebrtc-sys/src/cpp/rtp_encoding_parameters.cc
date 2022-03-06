#include "rtp_encoding_parameters.h"

namespace bridge {

// Returns the `RtpEncodingParameters.active` field value.
bool rtp_encoding_parameters_active(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.active;
}

// Returns the `RtpEncodingParameters.maxBitrate` field value.
int32_t rtp_encoding_parameters_maxBitrate(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.max_bitrate_bps.value();
}

// Returns the `RtpEncodingParameters.minBitrate` field value.
int32_t rtp_encoding_parameters_minBitrate(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.min_bitrate_bps.value();
}

// Returns the `RtpEncodingParameters.maxFramerate` field value.
double rtp_encoding_parameters_maxFramerate(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.max_framerate.value();
}

// Returns the `RtpEncodingParameters.ssrc` field value.
int64_t rtp_encoding_parameters_ssrc(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.ssrc.value();
}

// Returns the `RtpEncodingParameters.scale_resolution_down_by` field value.
double rtp_encoding_parameters_scale_resolution_down_by(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.scale_resolution_down_by.value();
}

}  // namespace bridge
