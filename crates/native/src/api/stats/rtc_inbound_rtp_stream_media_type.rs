//! Stats related to `media_type` of an inbound [RTP] stream.
//!
//! [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
use libwebrtc_sys as sys;

#[cfg(doc)]
use crate::api::RtcStatsType;

/// Fields of [`RtcStatsType::RtcInboundRtpStreamStats`] variant.
pub enum RtcInboundRtpStreamMediaType {
    /// `audio` media type fields.
    Audio {
        /// Indicator whether the last RTP packet whose frame was delivered to
        /// the [RTCRtpReceiver]'s [MediaStreamTrack][1] for playout contained
        /// voice activity or not based on the presence of the V bit in the
        /// extension header, as defined in [RFC 6464].
        ///
        /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#rtcrtpreceiver-interface
        /// [RFC 6464]: https://tools.ietf.org/html/rfc6464#page-3
        /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
        voice_activity_flag: Option<bool>,

        /// Total number of samples that have been received on this RTP stream.
        /// This includes [concealedSamples].
        ///
        /// [concealedSamples]: https://tinyurl.com/s6c4qe4
        total_samples_received: Option<u64>,

        /// Total number of samples that are concealed samples.
        ///
        /// A concealed sample is a sample that was replaced with synthesized
        /// samples generated locally before being played out.
        /// Examples of samples that have to be concealed are samples from lost
        /// packets (reported in [packetsLost]) or samples from packets that
        /// arrive too late to be played out (reported in [packetsDiscarded]).
        ///
        /// [packetsLost]: https://tinyurl.com/u2gq965
        /// [packetsDiscarded]: https://tinyurl.com/yx7qyox3
        concealed_samples: Option<u64>,

        /// Total number of concealed samples inserted that are "silent".
        ///
        /// Playing out silent samples results in silence or comfort noise.
        /// This is a subset of [concealedSamples].
        ///
        /// [concealedSamples]: https://tinyurl.com/s6c4qe4
        silent_concealed_samples: Option<u64>,

        /// Audio level of the receiving track.
        audio_level: Option<f64>,

        /// Audio energy of the receiving track.
        total_audio_energy: Option<f64>,

        /// Audio duration of the receiving track.
        ///
        /// For audio durations of tracks attached locally, see
        /// [RTCAudioSourceStats][1] instead.
        ///
        /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosourcestats
        total_samples_duration: Option<f64>,
    },

    /// `video` media type fields.
    Video {
        /// Total number of frames correctly decoded for this RTP stream, i.e.
        /// frames that would be displayed if no frames are dropped.
        frames_decoded: Option<u32>,

        /// Total number of key frames, such as key frames in VP8 [RFC 6386] or
        /// IDR-frames in H.264 [RFC 6184], successfully decoded for this RTP
        /// media stream.
        ///
        /// This is a subset of [framesDecoded].
        /// [framesDecoded] - [keyFramesDecoded] gives you the number of delta
        /// frames decoded.
        ///
        /// [RFC 6386]: https://w3.org/TR/webrtc-stats#bib-rfc6386
        /// [RFC 6184]: https://w3.org/TR/webrtc-stats#bib-rfc6184
        /// [framesDecoded]: https://tinyurl.com/srfwrwt
        /// [keyFramesDecoded]: https://tinyurl.com/qtdmhtm
        key_frames_decoded: Option<u32>,

        /// Width of the last decoded frame.
        ///
        /// Before the first frame is decoded this attribute is missing.
        frame_width: Option<u32>,

        /// Height of the last decoded frame.
        ///
        /// Before the first frame is decoded this attribute is missing.
        frame_height: Option<u32>,

        /// Sum of the interframe delays in seconds between consecutively
        /// decoded frames, recorded just after a frame has been decoded.
        total_inter_frame_delay: Option<f64>,

        /// Number of decoded frames in the last second.
        frames_per_second: Option<f64>,

        /// Total number of Full Intra Request (FIR) packets sent by this
        /// receiver.
        fir_count: Option<u32>,

        /// Total number of Picture Loss Indication (PLI) packets sent by this
        /// receiver.
        pli_count: Option<u32>,

        /// Total number of Slice Loss Indication (SLI) packets sent by this
        /// receiver.
        sli_count: Option<u32>,

        /// Number of concealment events.
        ///
        /// This counter increases every time a concealed sample is synthesized
        /// after a non-concealed sample. That is, multiple consecutive
        /// concealed samples will increase the [concealedSamples] count
        /// multiple times but is a single concealment event.
        ///
        /// [concealedSamples]: https://tinyurl.com/s6c4qe4
        concealment_events: Option<u64>,

        /// Total number of complete frames received on this RTP stream.
        ///
        /// This metric is incremented when the complete frame is received.
        frames_received: Option<i32>,
    },
}

impl From<sys::RtcInboundRtpStreamMediaType> for RtcInboundRtpStreamMediaType {
    fn from(media_type: sys::RtcInboundRtpStreamMediaType) -> Self {
        match media_type {
            sys::RtcInboundRtpStreamMediaType::Audio {
                total_samples_received,
                concealed_samples,
                silent_concealed_samples,
                audio_level,
                total_audio_energy,
                total_samples_duration,
            } => Self::Audio {
                total_samples_received,
                concealed_samples,
                silent_concealed_samples,
                audio_level,
                total_audio_energy,
                total_samples_duration,
                voice_activity_flag: None,
            },
            sys::RtcInboundRtpStreamMediaType::Video {
                frames_decoded,
                key_frames_decoded,
                frame_width,
                frame_height,
                total_inter_frame_delay,
                frames_per_second,
                fir_count,
                pli_count,
                concealment_events,
                frames_received,
            } => Self::Video {
                frames_decoded,
                key_frames_decoded,
                frame_width,
                frame_height,
                total_inter_frame_delay,
                frames_per_second,
                fir_count,
                pli_count,
                concealment_events,
                frames_received,
                sli_count: None,
            },
        }
    }
}
