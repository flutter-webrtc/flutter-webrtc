//! Representation of state changes in a [`MediaStreamTrack`].

#[cfg(doc)]
use crate::api::MediaStreamTrack;

/// Indication of the current state of a [`MediaStreamTrack`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackEvent {
    /// Ended event of the [`MediaStreamTrack`] interface is fired when playback
    /// or streaming has stopped because the end of the media was reached or
    /// because no further data is available.
    Ended,

    /// Event indicating an audio level change in the [`MediaStreamTrack`].
    AudioLevelUpdated(u32),

    /// Event indicating that the [`MediaStreamTrack`] has completely
    /// initialized and can be used on Flutter side.
    TrackCreated,
}
