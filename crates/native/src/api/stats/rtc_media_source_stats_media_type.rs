//! Statistics for the media produced by a [MediaStreamTrack][1] related to its
//! kind.
//!
//! [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
use libwebrtc_sys as sys;

#[cfg(doc)]
use crate::api::RtcStatsType;

/// Fields of [`RtcStatsType::RtcMediaSourceStats`] variant.
pub enum RtcMediaSourceStatsMediaType {
    /// Video source fields.
    RtcVideoSourceStats {
        /// Width (in pixels) of the last frame originating from the source.
        /// Before a frame has been produced this attribute is missing.
        width: Option<u32>,

        /// Height (in pixels) of the last frame originating from the source.
        /// Before a frame has been produced this attribute is missing.
        height: Option<u32>,

        /// Total number of frames originating from this source.
        frames: Option<u32>,

        /// Number of frames originating from the source, measured during the
        /// last second. For the first second of this object's lifetime this
        /// attribute is missing.
        frames_per_second: Option<f64>,
    },

    /// Audio source fields.
    RtcAudioSourceStats {
        /// Audio level of the media source.
        audio_level: Option<f64>,

        /// Audio energy of the media source.
        total_audio_energy: Option<f64>,

        /// Audio duration of the media source.
        total_samples_duration: Option<f64>,

        /// Only exists when the [MediaStreamTrack][1] is sourced from a
        /// microphone where echo cancellation is applied.
        ///
        /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
        echo_return_loss: Option<f64>,

        /// Only exists when the [MediaStreamTrack][1] is sourced from a
        /// microphone where echo cancellation is applied.
        ///
        /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
        echo_return_loss_enhancement: Option<f64>,
    },
}

impl From<sys::RtcMediaSourceStatsMediaType> for RtcMediaSourceStatsMediaType {
    fn from(kind: sys::RtcMediaSourceStatsMediaType) -> Self {
        match kind {
            sys::RtcMediaSourceStatsMediaType::RtcVideoSourceStats {
                width,
                height,
                frames,
                frames_per_second,
            } => Self::RtcVideoSourceStats {
                width,
                height,
                frames,
                frames_per_second,
            },
            sys::RtcMediaSourceStatsMediaType::RtcAudioSourceStats {
                audio_level,
                total_audio_energy,
                total_samples_duration,
                echo_return_loss,
                echo_return_loss_enhancement,
            } => Self::RtcAudioSourceStats {
                audio_level,
                total_audio_energy,
                total_samples_duration,
                echo_return_loss,
                echo_return_loss_enhancement,
            },
        }
    }
}
