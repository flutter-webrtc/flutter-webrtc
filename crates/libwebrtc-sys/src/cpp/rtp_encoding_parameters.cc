#include "libwebrtc-sys/src/bridge.rs.h"
#include "rtp_encoding_parameters.h"

namespace bridge {

// Returns the `RtpEncodingParameters.rid` field value.
rust::String rtp_encoding_parameters_rid(
    const webrtc::RtpEncodingParameters& encoding) {
  return rust::String(encoding.rid.c_str());
}

// Sets the `RtpEncodingParameters.rid` field value.
void set_rtp_encoding_parameters_rid(webrtc::RtpEncodingParameters& encoding,
                                     rust::String rid) {
  encoding.rid = std::string(rid.c_str());
}

// Returns the `RtpEncodingParameters.active` field value.
bool rtp_encoding_parameters_active(
    const webrtc::RtpEncodingParameters& encoding) {
  return encoding.active;
}

// Returns the `RtpEncodingParameters.maxBitrate` field value.
rust::Box<bridge::OptionI32> rtp_encoding_parameters_max_bitrate(
    const webrtc::RtpEncodingParameters& encoding) {
  auto max_bitrate = init_option_i32();

  if (encoding.max_bitrate_bps) {
    max_bitrate->set_value(encoding.max_bitrate_bps.value());
  }

  return max_bitrate;
}

// Sets the `RtpEncodingParameters.active` field value.
void set_rtp_encoding_parameters_active(webrtc::RtpEncodingParameters& encoding,
                                        bool active) {
  encoding.active = active;
}

// Returns the `RtpEncodingParameters.minBitrate` field value.
rust::Box<bridge::OptionI32> rtp_encoding_parameters_min_bitrate(
    const webrtc::RtpEncodingParameters& encoding) {
  auto min_bitrate = init_option_i32();

  if (encoding.min_bitrate_bps) {
    min_bitrate->set_value(encoding.min_bitrate_bps.value());
  }

  return min_bitrate;
}

// Returns the `RtpEncodingParameters.maxBitrate` field value.
void set_rtp_encoding_parameters_max_bitrate(
    webrtc::RtpEncodingParameters& encoding,
    int32_t max_bitrate) {
  encoding.max_bitrate_bps = max_bitrate;
}

// Returns the `RtpEncodingParameters.maxFramerate` field value.
rust::Box<bridge::OptionF64> rtp_encoding_parameters_max_framerate(
    const webrtc::RtpEncodingParameters& encoding) {
  auto max_framerate = init_option_f64();

  if (encoding.max_framerate) {
    max_framerate->set_value(encoding.max_framerate.value());
  }

  return max_framerate;
}

// Sets the `RtpEncodingParameters.maxFramerate` field value.
void set_rtp_encoding_parameters_max_framerate(
    webrtc::RtpEncodingParameters& encoding,
    double max_framrate) {
  encoding.max_framerate = max_framrate;
}

// Returns the `RtpEncodingParameters.ssrc` field value.
rust::Box<bridge::OptionI32> rtp_encoding_parameters_ssrc(
    const webrtc::RtpEncodingParameters& encoding) {
  auto ssrc = init_option_i32();

  if (encoding.ssrc) {
    ssrc->set_value(encoding.ssrc.value());
  }

  return ssrc;
}

// Returns the `RtpEncodingParameters.scale_resolution_down_by` field value.
rust::Box<bridge::OptionF64> rtp_encoding_parameters_scale_resolution_down_by(
    const webrtc::RtpEncodingParameters& encoding) {
  auto scale_resolution_down_by = init_option_f64();

  if (encoding.scale_resolution_down_by) {
    scale_resolution_down_by->set_value(
        encoding.scale_resolution_down_by.value());
  }

  return scale_resolution_down_by;
}

// Sets the `RtpEncodingParameters.scale_resolution_down_by` field value.
void set_rtp_encoding_parameters_scale_resolution_down_by(
    webrtc::RtpEncodingParameters& encoding,
    double scale_resolution_down_by) {
  encoding.scale_resolution_down_by = scale_resolution_down_by;
}

// Returns the `RtpEncodingParameters.scalability_mode` field value.
rust::Box<bridge::OptionString> rtp_encoding_parameters_scalability_mode(
    const webrtc::RtpEncodingParameters& encoding) {
  auto scalability_mode = init_option_string();

  if (encoding.scalability_mode) {
    scalability_mode->set_value(
        rust::String(encoding.scalability_mode.value()));
  }

  return scalability_mode;
}

// Sets the `RtpEncodingParameters.scalability_mode` field value.
void set_rtp_encoding_parameters_scalability_mode(
    webrtc::RtpEncodingParameters& encoding,
    rust::String scalability_mode) {
  encoding.scalability_mode = std::string(scalability_mode);
}

}  // namespace bridge
