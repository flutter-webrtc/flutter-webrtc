#pragma once

#include "bridge.h"

namespace bridge {

// Returns the `parameters` of the provided `RtpSenderInterface`.
std::unique_ptr<webrtc::RtpParameters> rtp_sender_parameters(
    const RtpSenderInterface& sender);

// Returns the `track` of the provided `RtpSenderInterface`.
std::unique_ptr<MediaStreamTrackInterface> rtp_sender_track(
    const RtpSenderInterface& sender);

// Replaces the track currently being used as the `sender`'s source with a new
// `VideoTrackInterface`.
bool replace_sender_video_track(
    const RtpSenderInterface& sender,
    const std::unique_ptr<VideoTrackInterface>& track);

// Replaces the track currently being used as the `sender`'s source with a new
// `AudioTrackInterface`.
bool replace_sender_audio_track(
    const RtpSenderInterface& sender,
    const std::unique_ptr<AudioTrackInterface>& track);

}  // namespace bridge
