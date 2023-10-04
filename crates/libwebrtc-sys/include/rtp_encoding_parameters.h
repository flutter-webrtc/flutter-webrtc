#pragma once

#include "bridge.h"
#include "rust/cxx.h"

namespace bridge {

// Sets the `RtpEncodingParameters.rid` field value.
void set_rtp_encoding_parameters_rid(webrtc::RtpEncodingParameters& encoding,
                                     rust::String rid);

// Returns the `RtpEncodingParameters.active` field value.
bool rtp_encoding_parameters_active(
    const webrtc::RtpEncodingParameters& encoding);

// Sets the `RtpEncodingParameters.active` field value.
void set_rtp_encoding_parameters_active(webrtc::RtpEncodingParameters& encoding,
                                        bool active);

// Returns the `RtpEncodingParameters.maxBitrate` field value.
int32_t rtp_encoding_parameters_max_bitrate(
    const webrtc::RtpEncodingParameters& encoding);

// Returns the `RtpEncodingParameters.maxBitrate` field value.
void set_rtp_encoding_parameters_max_bitrate(
    webrtc::RtpEncodingParameters& encoding,
    int32_t max_bitrate);

// Returns the `RtpEncodingParameters.minBitrate` field value.
int32_t rtp_encoding_parameters_min_bitrate(
    const webrtc::RtpEncodingParameters& encoding);

// Returns the `RtpEncodingParameters.maxFramerate` field value.
double rtp_encoding_parameters_max_framerate(
    const webrtc::RtpEncodingParameters& encoding);

// Sets the `RtpEncodingParameters.maxFramerate` field value.
void set_rtp_encoding_parameters_max_framerate(
    webrtc::RtpEncodingParameters& encoding,
    double max_framrate);

// Returns the `RtpEncodingParameters.ssrc` field value.
int64_t rtp_encoding_parameters_ssrc(
    const webrtc::RtpEncodingParameters& encoding);

// Returns the `RtpEncodingParameters.scale_resolution_down_by` field value.
double rtp_encoding_parameters_scale_resolution_down_by(
    const webrtc::RtpEncodingParameters& encoding);

// Sets the `RtpEncodingParameters.scale_resolution_down_by` field value.
void set_rtp_encoding_parameters_scale_resolution_down_by(
    webrtc::RtpEncodingParameters& encoding,
    double scale_resolution_down_by);

// Sets the `RtpEncodingParameters.scalability_mode` field value.
void set_rtp_encoding_parameters_scalability_mode(
    webrtc::RtpEncodingParameters& encoding,
    rust::String scalability_mode);

}  // namespace bridge
