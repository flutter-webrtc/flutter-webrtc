#pragma once

#include "bridge.h"

namespace bridge {

// Returns the `kind` of the provided `MediaStreamTrackInterface`.
std::unique_ptr<std::string> media_stream_track_kind(
    const MediaStreamTrackInterface& track);

// Returns the `id` of the provided `MediaStreamTrackInterface`.
std::unique_ptr<std::string> media_stream_track_id(
    const MediaStreamTrackInterface& track);

// Returns the `state` of the provided `MediaStreamTrackInterface`.
TrackState media_stream_track_state(const MediaStreamTrackInterface& track);

// Returns the `enabled` property of the provided `MediaStreamTrackInterface`.
bool media_stream_track_enabled(const MediaStreamTrackInterface& track);

// Downcasts the provided `MediaStreamTrackInterface` to a
// `VideoTrackInterface`.
std::unique_ptr<VideoTrackInterface>
media_stream_track_interface_downcast_video_track(
    std::unique_ptr<MediaStreamTrackInterface> track);

// Downcasts the provided `MediaStreamTrackInterface` to an
// `AudioTrackInterface`.
std::unique_ptr<AudioTrackInterface>
media_stream_track_interface_downcast_audio_track(
    std::unique_ptr<MediaStreamTrackInterface> track);

}  // namespace bridge
