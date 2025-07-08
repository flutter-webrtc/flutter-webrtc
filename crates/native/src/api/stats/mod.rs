//! [Stats object] representation.
//!
//! [Full doc on W3C][1].
//!
//! [Stats object]: https://w3.org/TR/webrtc-stats#dfn-stats-object
//! [1]: https://w3.org/TR/webrtc#rtcstats-dictionary

pub mod ice_role;
pub mod rtc_ice_candidate_stats;
pub mod rtc_inbound_rtp_stream_media_type;
pub mod rtc_media_source_stats_media_type;
pub mod rtc_outbound_rtp_stream_media_type;
pub mod rtc_stats_ice_candidate_pair_state;

use std::sync::{Arc, mpsc};

use libwebrtc_sys as sys;

pub use self::{
    ice_role::IceRole,
    rtc_ice_candidate_stats::{
        CandidateType, IceCandidateStats, Protocol, RtcIceCandidateStats,
    },
    rtc_inbound_rtp_stream_media_type::RtcInboundRtpStreamMediaType,
    rtc_media_source_stats_media_type::RtcMediaSourceStatsMediaType,
    rtc_outbound_rtp_stream_media_type::RtcOutboundRtpStreamStatsMediaType,
    rtc_stats_ice_candidate_pair_state::RtcStatsIceCandidatePairState,
};
use crate::{PeerConnection, api::RX_TIMEOUT, frb_generated::RustOpaque};

/// All known types of [`RtcStats`].
///
/// [List of all RTCStats types on W3C][1].
///
/// [1]: https://w3.org/TR/webrtc-stats#rtctatstype-%2A
pub enum RtcStatsType {
    /// Statistics for the media produced by a [MediaStreamTrack][1] that is
    /// currently attached to an [RTCRtpSender]. This reflects the media that is
    /// fed to the encoder after [getUserMedia()] constraints have been applied
    /// (i.e. not the raw media produced by the camera).
    ///
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#rtcrtpsender-interface
    /// [getUserMedia()]: https://tinyurl.com/sngpyr6
    /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
    RtcMediaSourceStats {
        /// Value of the [MediaStreamTrack][1]'s ID attribute.
        ///
        /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
        track_identifier: Option<String>,

        /// Fields which should be in these [`RtcStats`] based on their `kind`.
        kind: RtcMediaSourceStatsMediaType,
    },

    /// ICE remote candidate statistics related to the [RTCIceTransport]
    /// objects.
    ///
    /// A remote candidate is [deleted][1] when the [RTCIceTransport] does an
    /// ICE restart, and the candidate is no longer a member of any non-deleted
    /// candidate pair.
    ///
    /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
    /// [1]: https://w3.org/TR/webrtc-stats#dfn-deleted
    RtcIceCandidateStats(RtcIceCandidateStats),

    /// Statistics for an outbound [RTP] stream that is currently sent with
    /// [RTCPeerConnection] object.
    ///
    /// When there are multiple [RTP] streams connected to the same sender, such
    /// as when using simulcast or RTX, there will be one
    /// [RTCOutboundRtpStreamStats][5] per RTP stream, with distinct values of
    /// the [SSRC] attribute, and all these senders will have a reference to the
    /// same "sender" object (of type [RTCAudioSenderStats][1] or
    /// [RTCVideoSenderStats][2]) and "track" object (of type
    /// [RTCSenderAudioTrackAttachmentStats][3] or
    /// [RTCSenderVideoTrackAttachmentStats][4]).
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
    /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosenderstats
    /// [2]: https://w3.org/TR/webrtc-stats#dom-rtcvideosenderstats
    /// [3]: https://tinyurl.com/sefa5z4
    /// [4]: https://tinyurl.com/rkuvpl4
    /// [5]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
    RtcOutboundRtpStreamStats {
        /// ID of the stats object representing the current track attachment to
        /// the sender of the stream.
        track_id: Option<String>,

        /// Fields which should be in these [`RtcStats`] based on their
        /// `media_type`.
        media_type: RtcOutboundRtpStreamStatsMediaType,

        /// Total number of bytes sent for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        bytes_sent: Option<u64>,

        /// Total number of RTP packets sent for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        packets_sent: Option<u32>,

        /// ID of the stats object representing the track currently attached to
        /// the sender of the stream.
        media_source_id: Option<String>,
    },

    /// Statistics for an inbound [RTP] stream that is currently received with
    /// [RTCPeerConnection] object.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcInboundRtpStreamStats {
        /// ID of the stats object representing the receiving track.
        remote_id: Option<String>,

        /// Total number of bytes received for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        bytes_received: Option<u64>,

        /// Total number of RTP data packets received for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        packets_received: Option<u32>,

        /// Total number of RTP data packets for this [SSRC] that have been lost
        /// since the beginning of reception.
        ///
        /// This number is defined to be the number of packets expected less the
        /// number of packets actually received, where the number of packets
        /// received includes any which are late or duplicates. Thus, packets
        /// that arrive late are not counted as lost, and the loss
        /// **may be negative** if there are duplicates.
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        packets_lost: Option<u64>,

        /// Packet jitter measured in seconds for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        jitter: Option<f64>,

        /// Total number of seconds that have been spent decoding the
        /// [framesDecoded] frames of the stream.
        ///
        /// The average decode time can be calculated by dividing this value
        /// with [framesDecoded]. The time it takes to decode one frame is the
        /// time passed between feeding the decoder a frame and the decoder
        /// returning decoded data for that frame.
        ///
        /// [framesDecoded]: https://tinyurl.com/srfwrwt
        total_decode_time: Option<f64>,

        /// Total number of audio samples or video frames that have come out of
        /// the jitter buffer (increasing [jitterBufferDelay]).
        ///
        /// [jitterBufferDelay]: https://tinyurl.com/qvoojt5
        jitter_buffer_emitted_count: Option<u64>,

        /// Fields which should be in these [`RtcStats`] based on their
        /// `media_type`.
        media_type: Option<RtcInboundRtpStreamMediaType>,
    },

    /// ICE candidate pair statistics related to the [RTCIceTransport] objects.
    ///
    /// A candidate pair that is not the current pair for a transport is
    /// [deleted] when the [RTCIceTransport] does an ICE restart, at the time
    /// the state changes to [new].
    ///
    /// The candidate pair that is the current pair for a transport is [deleted]
    /// after an ICE restart when the [RTCIceTransport] switches to using a
    /// candidate pair generated from the new candidates; this time doesn't
    /// correspond to any other externally observable event.
    ///
    /// [deleted]: https://w3.org/TR/webrtc-stats#dfn-deleted
    /// [new]: https://w3.org/TR/webrtc#dom-rtcicetransportstate-new
    /// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
    RtcIceCandidatePairStats {
        /// State of the checklist for the local and remote candidates in a
        /// pair.
        state: RtcStatsIceCandidatePairState,

        /// Related to updating the nominated flag described in
        /// [Section 7.1.3.2.4 of RFC 5245][1].
        ///
        /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.4
        nominated: Option<bool>,

        /// Total number of payload bytes sent on this candidate pair, i.e. not
        /// including headers or padding.
        bytes_sent: Option<u64>,

        /// Total number of payload bytes received on this candidate pair, i.e.
        /// not including headers or padding.
        bytes_received: Option<u64>,

        /// Sum of all round trip time measurements in seconds since the
        /// beginning of the session, based on STUN connectivity check
        /// [STUN-PATH-CHAR] responses ([responsesReceived][2]), including those
        /// that reply to requests that are sent in order to verify consent
        /// [RFC 7675].
        ///
        /// The average round trip time can be computed from
        /// [totalRoundTripTime][1] by dividing it by [responsesReceived][2].
        ///
        /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
        /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
        /// [1]: https://tinyurl.com/tgr543a
        /// [2]: https://tinyurl.com/r3zo2um
        total_round_trip_time: Option<f64>,

        /// Latest round trip time measured in seconds, computed from both STUN
        /// connectivity checks [STUN-PATH-CHAR], including those that are sent
        /// for consent verification [RFC 7675].
        ///
        /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
        /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
        current_round_trip_time: Option<f64>,

        /// Calculated by the underlying congestion control by combining the
        /// available bitrate for all the outgoing RTP streams using this
        /// candidate pair. The bitrate measurement does not count the size of
        /// the IP or other transport layers like TCP or UDP. It is similar to
        /// the TIAS defined in [RFC 3890], i.e. it is measured in bits per
        /// second and the bitrate is calculated over a 1 second window.
        ///
        /// Implementations that do not calculate a sender-side estimate MUST
        /// leave this undefined. Additionally, the value MUST be undefined for
        /// candidate pairs that were never used. For pairs in use, the estimate
        /// is normally no lower than the bitrate for the packets sent at
        /// [lastPacketSentTimestamp][1], but might be higher. For candidate
        /// pairs that are not currently in use but were used before,
        /// implementations MUST return undefined.
        ///
        /// [RFC 3890]: https://tools.ietf.org/html/rfc3890
        /// [1]: https://tinyurl.com/rfc72eh
        available_outgoing_bitrate: Option<f64>,
    },

    /// Transport statistics related to the [RTCPeerConnection] object.
    ///
    /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcTransportStats {
        /// Total number of packets sent over this transport.
        packets_sent: Option<u64>,

        /// Total number of packets received on this transport.
        packets_received: Option<u64>,

        /// Total number of payload bytes sent on this [RTCPeerConnection], i.e.
        /// not including headers or padding.
        ///
        /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
        bytes_sent: Option<u64>,

        /// Total number of bytes received on this [RTCPeerConnection], i.e. not
        /// including headers or padding.
        ///
        /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
        bytes_received: Option<u64>,

        /// Set to the current value of the [role][1] of the underlying
        /// [RTCDtlsTransport][2]'s [transport][3].
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
        /// [2]: https://w3.org/TR/webrtc#rtcdtlstransport-interface
        /// [3]: https://w3.org/TR/webrtc#dom-rtcdtlstransport-icetransport
        ice_role: Option<IceRole>,
    },

    /// Statistics for the remote endpoint's inbound [RTP] stream corresponding
    /// to an outbound stream that is currently sent with [RTCPeerConnection]
    /// object.
    ///
    /// It is measured at the remote endpoint and reported in a RTCP Receiver
    /// Report (RR) or RTCP Extended Report (XR).
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcRemoteInboundRtpStreamStats {
        /// [localId] is used for looking up the local
        /// [RTCOutboundRtpStreamStats][1] object for the same [SSRC].
        ///
        /// [localId]: https://tinyurl.com/r8uhbo9
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
        local_id: Option<String>,

        /// Packet jitter measured in seconds for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        jitter: Option<f64>,

        /// Estimated round trip time for this [SSRC] based on the RTCP
        /// timestamps in the RTCP Receiver Report (RR) and measured in seconds.
        /// Calculated as defined in [Section 6.4.1 of RFC 3550][1].
        /// If no RTCP Receiver Report is received with a DLSR value other than
        /// 0, the round trip time is left undefined.
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
        round_trip_time: Option<f64>,

        /// Fraction packet loss reported for this [SSRC].
        /// Calculated as defined in [Section 6.4.1 of RFC 3550][1] and
        /// [Appendix A.3][2].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
        /// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
        fraction_lost: Option<f64>,

        /// Total number of RTCP RR blocks received for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        reports_received: Option<u64>,

        /// Total number of RTCP RR blocks received for this [SSRC] that contain
        /// a valid round trip time. This counter will increment if the
        /// [roundTripTime] is undefined.
        ///
        /// [roundTripTime]: https://tinyurl.com/ssg83hq
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        round_trip_time_measurements: Option<i32>,
    },

    /// Statistics for the remote endpoint's outbound [RTP] stream corresponding
    /// to an inbound stream that is currently received with [RTCPeerConnection]
    /// object.
    ///
    /// It is measured at the remote endpoint and reported in an RTCP Sender
    /// Report (SR).
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcRemoteOutboundRtpStreamStats {
        /// [localId] is used for looking up the local
        /// [RTCInboundRtpStreamStats][1] object for the same [SSRC].
        ///
        /// [localId]: https://tinyurl.com/vu9tb2e
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcinboundrtpstreamstats
        local_id: Option<String>,

        /// [remoteTimestamp] (as [HIGHRES-TIME]) is the remote timestamp at
        /// which these statistics were sent by the remote endpoint. This
        /// differs from timestamp, which represents the time at which the
        /// statistics were generated or received by the local endpoint. The
        /// [remoteTimestamp], if present, is derived from the NTP timestamp in
        /// an RTCP Sender Report (SR) block, which reflects the remote
        /// endpoint's clock. That clock may not be synchronized with the local
        /// clock.
        ///
        /// [HIGRES-TIME]: https://w3.org/TR/webrtc-stats#bib-highres-time
        /// [remoteTimestamp]: https://tinyurl.com/rzlhs87
        remote_timestamp: Option<f64>,

        /// Total number of RTCP SR blocks sent for this [SSRC].
        ///
        /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
        reports_sent: Option<u64>,
    },

    /// Unimplemented stats.
    Unimplemented,
}

impl From<sys::RtcStatsType> for RtcStatsType {
    #[expect(clippy::too_many_lines, reason = "trivial code")]
    fn from(kind: sys::RtcStatsType) -> Self {
        use sys::RtcStatsType as T;

        match kind {
            T::RtcMediaSourceStats { track_identifier, kind } => {
                Self::RtcMediaSourceStats {
                    track_identifier,
                    kind: kind.into(),
                }
            }
            T::RtcIceCandidateStats(stats) => match stats {
                sys::RtcIceCandidateStats::RtcLocalIceCandidateStats(
                    candidate,
                ) => Self::RtcIceCandidateStats(RtcIceCandidateStats::Local(
                    candidate.into(),
                )),
                sys::RtcIceCandidateStats::RtcRemoteIceCandidateStats(
                    candidate,
                ) => Self::RtcIceCandidateStats(RtcIceCandidateStats::Remote(
                    candidate.into(),
                )),
            },
            T::RtcOutboundRtpStreamStats {
                track_id,
                media_type,
                bytes_sent,
                packets_sent,
                media_source_id,
            } => Self::RtcOutboundRtpStreamStats {
                track_id,
                media_type: media_type.into(),
                bytes_sent,
                packets_sent,
                media_source_id,
            },
            T::RtcInboundRtpStreamStats {
                remote_id,
                bytes_received,
                packets_received,
                total_decode_time,
                jitter_buffer_emitted_count,
                media_type,
            } => Self::RtcInboundRtpStreamStats {
                remote_id,
                bytes_received,
                packets_received,
                total_decode_time,
                jitter_buffer_emitted_count,
                media_type: media_type.map(RtcInboundRtpStreamMediaType::from),
                packets_lost: None,
                jitter: None,
            },
            T::RtcIceCandidatePairStats {
                state,
                nominated,
                bytes_sent,
                bytes_received,
                total_round_trip_time,
                current_round_trip_time,
                available_outgoing_bitrate,
            } => Self::RtcIceCandidatePairStats {
                state: state.into(),
                nominated,
                bytes_sent,
                bytes_received,
                total_round_trip_time,
                current_round_trip_time,
                available_outgoing_bitrate,
            },
            T::RtcTransportStats {
                packets_sent,
                packets_received,
                bytes_sent,
                bytes_received,
            } => Self::RtcTransportStats {
                packets_sent,
                packets_received,
                bytes_sent,
                bytes_received,
                ice_role: None,
            },
            T::RtcRemoteInboundRtpStreamStats {
                local_id,
                round_trip_time,
                fraction_lost,
                round_trip_time_measurements,
            } => Self::RtcRemoteInboundRtpStreamStats {
                local_id,
                round_trip_time,
                fraction_lost,
                round_trip_time_measurements,
                jitter: None,
                reports_received: None,
            },
            T::RtcRemoteOutboundRtpStreamStats {
                local_id,
                remote_timestamp,
                reports_sent,
            } => Self::RtcRemoteOutboundRtpStreamStats {
                local_id,
                remote_timestamp,
                reports_sent,
            },
            T::Unimplemented => Self::Unimplemented,
        }
    }
}

/// Represents the [stats object] constructed by inspecting a specific
/// [monitored object].
///
/// [Full doc on W3C][1].
///
/// [stats object]: https://w3.org/TR/webrtc-stats#dfn-stats-object
/// [monitored object]: https://w3.org/TR/webrtc-stats#dfn-monitored-object
/// [1]: https://w3.org/TR/webrtc#rtcstats-dictionary
pub struct RtcStats {
    /// Unique ID that is associated with the object that was inspected to
    /// produce this [RTCStats] object.
    ///
    /// [RTCStats]: https://w3.org/TR/webrtc#dom-rtcstats
    pub id: String,

    /// Timestamp associated with this object.
    ///
    /// The time is relative to the UNIX epoch (Jan 1, 1970, UTC).
    ///
    /// For statistics that came from a remote source (e.g., from received RTCP
    /// packets), timestamp represents the time at which the information
    /// arrived at the local endpoint. The remote timestamp can be found in an
    /// additional field in an [`RtcStats`]-derived dictionary, if applicable.
    pub timestamp_us: i64,

    /// Actual stats of these [`RtcStats`].
    ///
    /// All possible stats are described in the [`RtcStatsType`] enum.
    pub kind: RtcStatsType,
}

impl From<sys::RtcStats> for RtcStats {
    fn from(stats: sys::RtcStats) -> Self {
        let sys::RtcStats { id, timestamp_us, kind } = stats;
        Self { id, timestamp_us, kind: RtcStatsType::from(kind) }
    }
}

/// Returns [`RtcStats`] of the [`PeerConnection`] by its ID.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn get_peer_stats(
    peer: RustOpaque<Arc<PeerConnection>>,
) -> anyhow::Result<Vec<RtcStats>> {
    let (tx, rx) = mpsc::channel();

    peer.get_stats(tx);
    let report = rx.recv_timeout(RX_TIMEOUT)?;

    Ok(report.get_stats()?.into_iter().map(RtcStats::from).collect())
}
