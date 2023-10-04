#include "rtp_encoding_parameters.h"

namespace bridge {

// Sets the `RtpEncodingParameters.rid` field value.
void set_rtp_encoding_parameters_rid(webrtc::RtpEncodingParameters& encoding,
                                     rust::String rid) {
  encoding.rid = std::string(rid);
}

// Returns the `RtpEncodingParameters.active` field value.
bool rtp_encoding_parameters_active(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.active;
}

// Returns the `RtpEncodingParameters.maxBitrate` field value.
int32_t rtp_encoding_parameters_max_bitrate(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.max_bitrate_bps.value();
}

// Sets the `RtpEncodingParameters.active` field value.
void set_rtp_encoding_parameters_active(webrtc::RtpEncodingParameters& encoding,
                                        bool active) {
  encoding.active = active;
}

// Returns the `RtpEncodingParameters.minBitrate` field value.
int32_t rtp_encoding_parameters_min_bitrate(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.min_bitrate_bps.value();
}

// Returns the `RtpEncodingParameters.maxBitrate` field value.
void set_rtp_encoding_parameters_max_bitrate(
    webrtc::RtpEncodingParameters& encoding,
    int32_t max_bitrate) {
  encoding.max_bitrate_bps = max_bitrate;
}

// Returns the `RtpEncodingParameters.maxFramerate` field value.
double rtp_encoding_parameters_max_framerate(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.max_framerate.value();
}

// Sets the `RtpEncodingParameters.maxFramerate` field value.
void set_rtp_encoding_parameters_max_framerate(
    webrtc::RtpEncodingParameters& encoding,
    double max_framrate) {
  encoding.max_framerate = max_framrate;
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

// Sets the `RtpEncodingParameters.scale_resolution_down_by` field value.
void set_rtp_encoding_parameters_scale_resolution_down_by(
    webrtc::RtpEncodingParameters& encoding,
    double scale_resolution_down_by) {
  encoding.scale_resolution_down_by = scale_resolution_down_by;
}

// Sets the `RtpEncodingParameters.scalability_mode` field value.
void set_rtp_encoding_parameters_scalability_mode(
    webrtc::RtpEncodingParameters& encoding,
    rust::String scalability_mode) {
  encoding.scalability_mode = std::string(scalability_mode);
}

}  // namespace bridge
