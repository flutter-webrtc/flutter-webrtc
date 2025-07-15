//! [MediaStreamConstraints][1] for [`Webrtc::get_media()`] audio configuration.
//!
//! [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamconstraints

use crate::api::NoiseSuppressionLevel;
#[cfg(doc)]
use crate::{
    Webrtc,
    api::{AudioProcessingConfig, MediaStreamTrack},
};

/// Nature and settings of the audio [`MediaStreamTrack`] returned by
/// [`Webrtc::get_media()`].
#[derive(Debug)]
pub struct AudioConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// First device will be chosen if an empty [`String`] is provided.
    pub device_id: Option<String>,

    /// Audio processing configuration constraints of the [`MediaStreamTrack`].
    pub processing: AudioProcessingConstraints,
}

/// Constraints of an [`AudioProcessingConfig`].
#[derive(Debug, Default)]
pub struct AudioProcessingConstraints {
    /// Indicator whether the audio volume level should be automatically tuned
    /// to maintain a steady overall volume level.
    pub auto_gain_control: Option<bool>,

    /// Indicator whether a high-pass filter should be enabled to eliminate
    /// low-frequency noise.
    pub high_pass_filter: Option<bool>,

    /// Indicator whether noise suppression should be enabled to reduce
    /// background sounds.
    pub noise_suppression: Option<bool>,

    /// Level of aggressiveness for noise suppression.
    pub noise_suppression_level: Option<NoiseSuppressionLevel>,

    /// Indicator whether echo cancellation should be enabled to prevent
    /// feedback.
    pub echo_cancellation: Option<bool>,
}
