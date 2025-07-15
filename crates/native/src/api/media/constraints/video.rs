//! [MediaStreamConstraints][1] for [`Webrtc::get_media()`] video configuration.
//!
//! [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamconstraints

#[cfg(doc)]
use crate::{Webrtc, api::MediaStreamTrack};

/// Nature and settings of the video [`MediaStreamTrack`] returned by
/// [`Webrtc::get_media()`].
#[derive(Debug)]
pub struct VideoConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// The first device will be chosen if an empty [`String`] is provided.
    pub device_id: Option<String>,

    /// Width in pixels.
    pub width: u32,

    /// Height in pixels.
    pub height: u32,

    /// Exact frame rate (frames per second).
    pub frame_rate: u32,

    /// Indicator whether the request video track should be acquired via screen
    /// capturing.
    pub is_display: bool,
}
