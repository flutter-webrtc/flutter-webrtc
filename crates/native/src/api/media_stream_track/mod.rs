//! Representation of a [MediaStreamTrack][0].
//!
//! [0]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack

pub mod audio_processing_config;
pub mod media_type;
pub mod track_event;
pub mod track_state;

#[cfg(doc)]
use libwebrtc_sys as sys;

pub use self::{
    audio_processing_config::{
        AudioProcessingConfig, NoiseSuppressionLevel,
        get_audio_processing_config,
    },
    media_type::MediaType,
    track_event::TrackEvent,
    track_state::TrackState,
};
#[cfg(doc)]
use crate::PeerConnection;
use crate::{
    api::{
        AudioProcessingConstraints, MediaStreamConstraints, TextureEvent,
        WEBRTC,
    },
    frb_generated::StreamSink,
    media::TrackOrigin,
    pc::PeerConnectionId,
    renderer::FrameHandler,
};

/// Representation of a single media track within a [MediaStream].
///
/// Typically, these are audio or video tracks, but other track types may exist
/// as well.
///
/// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
#[derive(Clone, Debug)]
pub struct MediaStreamTrack {
    /// Unique identifier (GUID) of this [`MediaStreamTrack`].
    pub id: String,

    /// Unique identifier of the [`PeerConnection`] from which this
    /// [`MediaStreamTrack`] was received.
    ///
    /// Always [`None`] for local [`MediaStreamTrack`]s.
    pub peer_id: Option<u32>,

    /// Label identifying the track source, as in "internal microphone".
    pub device_id: String,

    /// [`MediaType`] of this [`MediaStreamTrack`].
    pub kind: MediaType,

    /// Indicator whether this [`MediaStreamTrack`] is allowed to render the
    /// source stream.
    ///
    /// This can be used to intentionally mute a track.
    pub enabled: bool,
}

/// [`get_media()`] function result.
pub enum GetMediaResult {
    /// Requested media tracks.
    Ok(Vec<MediaStreamTrack>),

    /// Failed to get requested media.
    Err(GetMediaError),
}

/// Media acquisition error.
pub enum GetMediaError {
    /// Could not acquire audio track.
    Audio(String),

    /// Could not acquire video track.
    Video(String),
}

/// Creates a [MediaStream] with tracks according to provided
/// [`MediaStreamConstraints`].
///
/// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
#[must_use]
pub fn get_media(constraints: MediaStreamConstraints) -> GetMediaResult {
    #[expect(clippy::significant_drop_in_scrutinee, reason = "no problems")]
    match WEBRTC.lock().unwrap().get_media(constraints) {
        Ok(tracks) => GetMediaResult::Ok(tracks),
        Err(err) => GetMediaResult::Err(err),
    }
}

/// Disposes the specified [`MediaStreamTrack`].
pub fn dispose_track(track_id: String, peer_id: Option<u32>, kind: MediaType) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().dispose_track(track_origin, track_id, kind, false);
}

/// Returns the [readyState][0] property of the [`MediaStreamTrack`] by its ID
/// and [`MediaType`].
///
/// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
pub fn track_state(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> TrackState {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().track_state(track_id, track_origin, kind)
}

/// Returns the [height] property of the media track by its ID and
/// [`MediaType`].
///
/// Blocks until the [height] is initialized.
///
/// [height]: https://w3.org/TR/mediacapture-streams#dfn-height
pub fn track_height(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> Option<i32> {
    if kind == MediaType::Audio {
        return None;
    }

    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().track_height(track_id, track_origin)
}

/// Returns the [width] property of the media track by its ID and [`MediaType`].
///
/// Blocks until the [width] is initialized.
///
/// [width]: https://w3.org/TR/mediacapture-streams#dfn-height
pub fn track_width(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> Option<i32> {
    if kind == MediaType::Audio {
        return None;
    }

    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().track_width(track_id, track_origin)
}

/// Changes the [enabled][1] property of the [`MediaStreamTrack`] by its ID and
/// [`MediaType`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
pub fn set_track_enabled(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
    enabled: bool,
) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().set_track_enabled(
        track_id,
        track_origin,
        kind,
        enabled,
    );
}

/// Clones the specified [`MediaStreamTrack`].
pub fn clone_track(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> Option<MediaStreamTrack> {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().clone_track(track_id, track_origin, kind)
}

/// Registers an observer to the [`MediaStreamTrack`] events.
pub fn register_track_observer(
    cb: StreamSink<TrackEvent>,
    peer_id: Option<u32>,
    track_id: String,
    kind: MediaType,
) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().register_track_observer(
        track_id,
        track_origin,
        kind,
        cb,
    );
}

/// Enables or disables audio level observing of the audio [`MediaStreamTrack`]
/// with the provided `track_id`.
pub fn set_audio_level_observer_enabled(
    track_id: String,
    peer_id: Option<u32>,
    enabled: bool,
) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));
    WEBRTC.lock().unwrap().set_audio_level_observer_enabled(
        track_id,
        track_origin,
        enabled,
    );
}

/// Applies the provided [`AudioProcessingConstraints`] to specified local audio
/// track.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn update_audio_processing(
    track_id: String,
    conf: AudioProcessingConstraints,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().apply_audio_processing_config(track_id, &conf)
}

/// Creates a new [`VideoSink`] attached to the specified video track.
///
/// `callback_ptr` argument should be a pointer to an [`UniquePtr`] pointing to
/// an [`sys::OnFrameCallback`].
///
/// [`UniquePtr`]: cxx::UniquePtr
/// [`VideoSink`]: crate::VideoSink
pub fn create_video_sink(
    cb: StreamSink<TextureEvent>,
    sink_id: i64,
    peer_id: Option<u32>,
    track_id: String,
    callback_ptr: i64,
    texture_id: i64,
) {
    let handler = FrameHandler::new(callback_ptr as _, cb, texture_id);
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().create_video_sink(
        sink_id,
        track_id,
        track_origin,
        handler,
    );
}

/// Destroys a [`VideoSink`] by the provided ID.
///
/// [`VideoSink`]: crate::VideoSink
pub fn dispose_video_sink(sink_id: i64) {
    WEBRTC.lock().unwrap().dispose_video_sink(sink_id);
}
