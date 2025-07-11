//! Configuration of audio processing.

use libwebrtc_sys as sys;

#[cfg(doc)]
use crate::api::MediaStreamTrack;
use crate::api::WEBRTC;

/// Audio processing configuration for some local audio [`MediaStreamTrack`].
#[expect(clippy::struct_excessive_bools, reason = "that's ok")]
#[derive(Debug)]
pub struct AudioProcessingConfig {
    /// Indicator whether the audio volume level should be automatically tuned
    /// to maintain a steady overall volume level.
    pub auto_gain_control: bool,

    /// Indicator whether a high-pass filter should be enabled to eliminate
    /// low-frequency noise.
    pub high_pass_filter: bool,

    /// Indicator whether noise suppression should be enabled to reduce
    /// background sounds.
    pub noise_suppression: bool,

    /// Level of aggressiveness for noise suppression.
    pub noise_suppression_level: NoiseSuppressionLevel,

    /// Indicator whether echo cancellation should be enabled to prevent
    /// feedback.
    pub echo_cancellation: bool,
}

/// [`AudioProcessingConfig`] noise suppression aggressiveness.
#[derive(Clone, Copy, Debug)]
pub enum NoiseSuppressionLevel {
    /// Minimal noise suppression.
    Low,

    /// Moderate level of suppression.
    Moderate,

    /// Aggressive noise suppression.
    High,

    /// Maximum suppression.
    VeryHigh,
}

impl From<NoiseSuppressionLevel> for sys::NoiseSuppressionLevel {
    fn from(level: NoiseSuppressionLevel) -> Self {
        match level {
            NoiseSuppressionLevel::Low => Self::kLow,
            NoiseSuppressionLevel::Moderate => Self::kModerate,
            NoiseSuppressionLevel::High => Self::kHigh,
            NoiseSuppressionLevel::VeryHigh => Self::kVeryHigh,
        }
    }
}

impl From<sys::NoiseSuppressionLevel> for NoiseSuppressionLevel {
    fn from(level: sys::NoiseSuppressionLevel) -> Self {
        match level {
            sys::NoiseSuppressionLevel::kLow => Self::Low,
            sys::NoiseSuppressionLevel::kModerate => Self::Moderate,
            sys::NoiseSuppressionLevel::kHigh => Self::High,
            sys::NoiseSuppressionLevel::kVeryHigh => Self::VeryHigh,
            _ => unreachable!(),
        }
    }
}

/// Returns the current [`AudioProcessingConfig`] for the specified local audio
/// track.
pub fn get_audio_processing_config(
    track_id: String,
) -> anyhow::Result<AudioProcessingConfig> {
    WEBRTC.lock().unwrap().get_audio_processing_config(track_id)
}
