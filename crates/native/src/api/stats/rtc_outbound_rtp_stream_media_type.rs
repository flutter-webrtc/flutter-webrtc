//! Stats related to `media_type` of an outbound [RTP] stream.
//!
//! [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
use libwebrtc_sys as sys;

#[cfg(doc)]
use crate::api::RtcStatsType;

/// Fields of [`RtcStatsType::RtcOutboundRtpStreamStats`] variant.
pub enum RtcOutboundRtpStreamStatsMediaType {
    /// `audio` media type fields.
    Audio {
        /// Total number of samples that have been sent over the RTP stream.
        total_samples_sent: Option<u64>,

        /// Whether the last RTP packet sent contained voice activity or not
        /// based on the presence of the V bit in the extension header.
        voice_activity_flag: Option<bool>,
    },

    /// `video` media type fields.
    Video {
        /// Width of the last encoded frame.
        ///
        /// The resolution of the encoded frame may be lower than the media
        /// source (see [RTCVideoSourceStats.width][1]).
        ///
        /// Before the first frame is encoded this attribute is missing.
        ///
        /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-width
        frame_width: Option<u32>,

        /// Height of the last encoded frame.
        ///
        /// The resolution of the encoded frame may be lower than the media
        /// source (see [RTCVideoSourceStats.height][1]).
        ///
        /// Before the first frame is encoded this attribute is missing.
        ///
        /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-height
        frame_height: Option<u32>,

        /// Number of encoded frames during the last second.
        ///
        /// This may be lower than the media source frame rate (see
        /// [RTCVideoSourceStats.framesPerSecond][1]).
        ///
        /// [1]: https://tinyurl.com/rrmkrfk
        frames_per_second: Option<f64>,
    },
}

impl From<sys::RtcOutboundRtpStreamStatsMediaType>
    for RtcOutboundRtpStreamStatsMediaType
{
    fn from(kind: sys::RtcOutboundRtpStreamStatsMediaType) -> Self {
        use sys::RtcOutboundRtpStreamStatsMediaType as T;

        match kind {
            T::Audio => Self::Audio {
                total_samples_sent: None,
                voice_activity_flag: None,
            },
            T::Video { frame_width, frame_height, frames_per_second } => {
                Self::Video { frame_width, frame_height, frames_per_second }
            }
        }
    }
}
