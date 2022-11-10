use std::{
    sync::{
        atomic::{AtomicBool, Ordering},
        mpsc, Mutex,
    },
    time::Duration,
};

use flutter_rust_bridge::StreamSink;
use libwebrtc_sys as sys;

use crate::{devices, renderer::FrameHandler, Webrtc};

lazy_static::lazy_static! {
    static ref WEBRTC: Mutex<Webrtc> = Mutex::new(Webrtc::new().unwrap());
}

/// Timeout for [`mpsc::Receiver::recv_timeout()`] operations.
pub static RX_TIMEOUT: Duration = Duration::from_secs(5);

/// Indicator whether application is configured to use fake media devices.
static FAKE_MEDIA: AtomicBool = AtomicBool::new(false);

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

/// [RTCIceCandidateType] represents the type of the ICE candidate, as defined
/// in [Section 15.1 of RFC 5245][1].
///
/// [RTCIceCandidateType]: https://w3.org/TR/webrtc#rtcicecandidatetype-enum
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CandidateType {
    /// Host candidate, as defined in [Section 4.1.1.1 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.1
    Host,

    /// Server reflexive candidate, as defined in
    /// [Section 4.1.1.2 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
    Srflx,

    /// Peer reflexive candidate, as defined in
    /// [Section 4.1.1.2 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
    Prflx,

    /// Relay candidate, as defined in [Section 7.1.3.2.1 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.1
    Relay,
}

impl From<sys::CandidateType> for CandidateType {
    fn from(kind: sys::CandidateType) -> Self {
        match kind {
            sys::CandidateType::kHost => Self::Host,
            sys::CandidateType::kSrflx => Self::Srflx,
            sys::CandidateType::kPrflx => Self::Prflx,
            sys::CandidateType::kRelay => Self::Relay,
            _ => unreachable!(),
        }
    }
}

/// [MediaStreamTrack.kind][1] representation.
///
/// [1]: https://w3.org/TR/mediacapture-streams#dfn-kind
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackKind {
    /// Audio track.
    Audio,

    /// Video track.
    Video,
}

impl From<sys::TrackKind> for TrackKind {
    fn from(kind: sys::TrackKind) -> Self {
        match kind {
            sys::TrackKind::Audio => Self::Audio,
            sys::TrackKind::Video => Self::Video,
        }
    }
}

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

/// Each candidate pair in the check list has a foundation and a state.
/// The foundation is the combination of the foundations of the local and remote
/// candidates in the pair. The state is assigned once the check list for each
/// media stream has been computed. There are five potential values that the
/// state can have.
pub enum RtcStatsIceCandidatePairState {
    /// Check for this pair hasn't been performed, and it can't yet be performed
    /// until some other check succeeds, allowing this pair to unfreeze and move
    /// into the [`RtcStatsIceCandidatePairState::Waiting`] state.
    Frozen,

    /// Check has not been performed for this pair, and can be performed as soon
    /// as it is the highest-priority Waiting pair on the check list.
    Waiting,

    /// Check has been sent for this pair, but the transaction is in progress.
    InProgress,

    /// Check for this pair was already done and failed, either never producing
    /// any response or producing an unrecoverable failure response.
    Failed,

    /// Check for this pair was already done and produced a successful result.
    Succeeded,
}

impl From<sys::RTCStatsIceCandidatePairState>
    for RtcStatsIceCandidatePairState
{
    fn from(state: sys::RTCStatsIceCandidatePairState) -> Self {
        match state {
            sys::RTCStatsIceCandidatePairState::kFrozen => Self::Frozen,
            sys::RTCStatsIceCandidatePairState::kWaiting => Self::Waiting,
            sys::RTCStatsIceCandidatePairState::kInProgress => Self::InProgress,
            sys::RTCStatsIceCandidatePairState::kFailed => Self::Failed,
            sys::RTCStatsIceCandidatePairState::kSucceeded => Self::Succeeded,
            _ => unreachable!(),
        }
    }
}

/// Transport protocols used in [WebRTC].
///
/// [WebRTC]: https://w3.org/TR/webrtc
pub enum Protocol {
    /// [Transmission Control Protocol][1].
    ///
    /// [1]: https://en.wikipedia.org/wiki/Transmission_Control_Protocol
    Tcp,

    /// [User Datagram Protocol][1].
    ///
    /// [1]: https://en.wikipedia.org/wiki/User_Datagram_Protocol
    Udp,
}

impl From<sys::Protocol> for Protocol {
    fn from(protocol: sys::Protocol) -> Self {
        match protocol {
            sys::Protocol::Tcp => Self::Tcp,
            sys::Protocol::Udp => Self::Udp,
        }
    }
}

/// Variants of [ICE roles][1].
///
/// More info in the [RFC 5245].
///
/// [RFC 5245]: https://tools.ietf.org/html/rfc5245
/// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
#[derive(Debug, Copy, Clone)]
pub enum IceRole {
    /// Agent whose role as defined by [Section 3 in RFC 5245][1], has not yet
    /// been determined.
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Unknown,

    /// Controlling agent as defined by [Section 3 in RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Controlling,

    /// Controlled agent as defined by [Section 3 in RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Controlled,
}

impl From<sys::IceRole> for IceRole {
    fn from(role: sys::IceRole) -> Self {
        match role {
            sys::IceRole::Unknown => Self::Unknown,
            sys::IceRole::Controlling => Self::Controlling,
            sys::IceRole::Controlled => Self::Controlled,
        }
    }
}

/// Properties of a `candidate` in [Section 15.1 of RFC 5245][1].
/// It corresponds to an [RTCIceTransport] object.
///
/// [`RtcIceCandidateStats::Local`] or [`RtcIceCandidateStats::Remote`] variant.
///
/// [Full doc on W3C][2].
///
/// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
/// [2]: https://w3.org/TR/webrtc-stats#icecandidate-dict%2A
pub struct IceCandidateStats {
    /// Unique ID that is associated to the object that was inspected to produce
    /// the [RTCTransportStats][1] associated with this candidate.
    ///
    /// [1]: https://w3.org/TR/webrtc-stats#transportstats-dict%2A
    pub transport_id: Option<String>,

    /// Address of the candidate, allowing for IPv4 addresses, IPv6 addresses,
    /// and fully qualified domain names (FQDNs).
    pub address: Option<String>,

    /// Port number of the candidate.
    pub port: Option<i32>,

    /// Valid values for transport is one of `udp` and `tcp`.
    pub protocol: Protocol,

    /// Type of the ICE candidate.
    pub candidate_type: CandidateType,

    /// Calculated as defined in [Section 15.1 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
    pub priority: Option<i32>,

    /// For local candidates this is the URL of the ICE server from which the
    /// candidate was obtained. It is the same as the [url][2] surfaced in the
    /// [RTCPeerConnectionIceEvent][1].
    ///
    /// [`None`] for remote candidates.
    ///
    /// [1]: https://w3.org/TR/webrtc#rtcpeerconnectioniceevent
    /// [2]: https://w3.org/TR/webrtc#dom-rtcpeerconnectioniceevent-url
    pub url: Option<String>,

    /// Protocol used by the endpoint to communicate with the TURN server.
    ///
    /// Only present for local candidates.
    pub relay_protocol: Option<Protocol>,
}

impl From<sys::IceCandidateStats> for IceCandidateStats {
    fn from(val: sys::IceCandidateStats) -> Self {
        let sys::IceCandidateStats {
            transport_id,
            address,
            port,
            protocol,
            candidate_type,
            priority,
            url,
        } = val;
        Self {
            transport_id,
            address,
            port,
            protocol: protocol.into(),
            candidate_type: candidate_type.into(),
            priority,
            url,
            relay_protocol: None,
        }
    }
}

/// [`IceCandidateStats`] of either local or remote candidate.
pub enum RtcIceCandidateStats {
    /// [`IceCandidateStats`] of local candidate.
    Local(IceCandidateStats),

    /// [`IceCandidateStats`] of remote candidate.
    Remote(IceCandidateStats),
}

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
            T::Video {
                frame_width,
                frame_height,
                frames_per_second,
            } => Self::Video {
                frame_width,
                frame_height,
                frames_per_second,
            },
        }
    }
}

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
    #[allow(clippy::too_many_lines)]
    fn from(kind: sys::RtcStatsType) -> Self {
        use sys::RtcStatsType as T;

        match kind {
            T::RtcMediaSourceStats {
                track_identifier,
                kind,
            } => Self::RtcMediaSourceStats {
                track_identifier,
                kind: kind.into(),
            },
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
        let sys::RtcStats {
            id,
            timestamp_us,
            kind,
        } = stats;
        Self {
            id,
            timestamp_us,
            kind: RtcStatsType::from(kind),
        }
    }
}

/// Indicator of the current state of a [`MediaStreamTrack`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackEvent {
    /// Ended event of the [`MediaStreamTrack`] interface is fired when playback
    /// or streaming has stopped because the end of the media was reached or
    /// because no further data is available.
    Ended,
}

/// [RTCIceGatheringState][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum IceGatheringState {
    /// [RTCIceGatheringState.new][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate-new
    New,

    /// [RTCIceGatheringState.gathering][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate-gathering
    Gathering,

    /// [RTCIceGatheringState.complete][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate-complete
    Complete,
}

impl From<sys::IceGatheringState> for IceGatheringState {
    fn from(state: sys::IceGatheringState) -> Self {
        match state {
            sys::IceGatheringState::kIceGatheringNew => Self::New,
            sys::IceGatheringState::kIceGatheringGathering => Self::Gathering,
            sys::IceGatheringState::kIceGatheringComplete => Self::Complete,
            _ => unreachable!(),
        }
    }
}

/// Representation of [`PeerConnection`]'s events.
#[derive(Clone, Debug)]
pub enum PeerConnectionEvent {
    /// [`PeerConnection`] has been created.
    PeerCreated {
        /// ID of the created [`PeerConnection`].
        id: u64,
    },

    /// [RTCIceCandidate][1] has been discovered.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
    IceCandidate {
        /// Media stream "identification-tag" defined in [RFC 5888] for the
        /// media component the discovered [RTCIceCandidate][1] is associated
        /// with.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
        /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
        sdp_mid: String,

        /// Index (starting at zero) of the media description in the SDP this
        /// [RTCIceCandidate][1] is associated with.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
        sdp_mline_index: i32,

        /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
        ///
        /// If this [RTCIceCandidate][1] represents an end-of-candidates
        /// indication or a peer reflexive remote candidate, candidate is an
        /// empty string.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
        /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
        candidate: String,
    },

    /// [`PeerConnection`]'s ICE gathering state has changed.
    IceGatheringStateChange(IceGatheringState),

    /// Failure occurred when gathering [RTCIceCandidate][1].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
    IceCandidateError {
        /// Local IP address used to communicate with the STUN or TURN server.
        address: String,

        /// Port used to communicate with the STUN or TURN server.
        port: i32,

        /// STUN or TURN URL identifying the STUN or TURN server for which the
        /// failure occurred.
        url: String,

        /// Numeric STUN error code returned by the STUN or TURN server
        /// [`STUN-PARAMETERS`][1].
        ///
        /// If no host candidate can reach the server, it will be set to the
        /// value `701` which is outside the STUN error code range.
        ///
        /// [1]: https://tinyurl.com/stun-parameters-6
        error_code: i32,

        /// STUN reason text returned by the STUN or TURN server
        /// [`STUN-PARAMETERS`][1].
        ///
        /// If the server could not be reached, it will be set to an
        /// implementation-specific value providing details about the error.
        ///
        /// [1]: https://tinyurl.com/stun-parameters-6
        error_text: String,
    },

    /// Negotiation or renegotiation of the [`PeerConnection`] needs to be
    /// performed.
    NegotiationNeeded,

    /// [`PeerConnection`]'s [`SignalingState`] has been changed.
    SignallingChange(SignalingState),

    /// [`PeerConnection`]'s [`IceConnectionState`] has been changed.
    IceConnectionStateChange(IceConnectionState),

    /// [`PeerConnection`]'s [`PeerConnectionState`] has been changed.
    ConnectionStateChange(PeerConnectionState),

    /// New incoming media has been negotiated.
    Track(RtcTrackEvent),
}

/// [RTCSignalingState] representation.
///
/// [RTCSignalingState]: https://w3.org/TR/webrtc#state-definitions
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SignalingState {
    /// [RTCSignalingState.stable][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsignalingstate-stable
    Stable,

    /// [RTCSignalingState.have-local-offer][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsignalingstate-have-local-offer
    HaveLocalOffer,

    /// [RTCSignalingState.have-local-pranswer][1] representation.
    ///
    /// [1]: https://tinyurl.com/have-local-pranswer
    HaveLocalPrAnswer,

    /// [RTCSignalingState.have-remote-offer][1] representation.
    ///
    /// [1]: https://tinyurl.com/have-remote-offer
    HaveRemoteOffer,

    /// [RTCSignalingState.have-remote-pranswer][1] representation.
    ///
    /// [1]: https://tinyurl.com/have-remote-pranswer
    HaveRemotePrAnswer,

    /// [RTCSignalingState.closed][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsignalingstate-closed
    Closed,
}

impl From<sys::SignalingState> for SignalingState {
    fn from(state: sys::SignalingState) -> Self {
        match state {
            sys::SignalingState::kStable => Self::Stable,
            sys::SignalingState::kHaveLocalOffer => Self::HaveLocalOffer,
            sys::SignalingState::kHaveLocalPrAnswer => Self::HaveLocalPrAnswer,
            sys::SignalingState::kHaveRemoteOffer => Self::HaveRemoteOffer,
            sys::SignalingState::kHaveRemotePrAnswer => {
                Self::HaveRemotePrAnswer
            }
            sys::SignalingState::kClosed => Self::Closed,
            _ => unreachable!(),
        }
    }
}

/// [RTCIceConnectionState][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum IceConnectionState {
    /// [RTCIceConnectionState.new][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-new
    New,

    /// [RTCIceConnectionState.checking][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-checking
    Checking,

    /// [RTCIceConnectionState.connected][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-connected
    Connected,

    /// [RTCIceConnectionState.completed][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-completed
    Completed,

    /// [RTCIceConnectionState.failed][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-failed
    Failed,

    /// [RTCIceConnectionState.disconnected][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-disconnected
    Disconnected,

    /// [RTCIceConnectionState.closed][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-closed
    Closed,
}

impl From<sys::IceConnectionState> for IceConnectionState {
    fn from(state: sys::IceConnectionState) -> Self {
        match state {
            sys::IceConnectionState::kIceConnectionNew => Self::New,
            sys::IceConnectionState::kIceConnectionChecking => Self::Checking,
            sys::IceConnectionState::kIceConnectionConnected => Self::Connected,
            sys::IceConnectionState::kIceConnectionCompleted => Self::Completed,
            sys::IceConnectionState::kIceConnectionFailed => Self::Failed,
            sys::IceConnectionState::kIceConnectionDisconnected => {
                Self::Disconnected
            }
            sys::IceConnectionState::kIceConnectionClosed => Self::Closed,
            _ => unreachable!(),
        }
    }
}

/// Indicator of the current state of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum PeerConnectionState {
    /// At least one of the connection's ICE transports is in the new state,
    /// and none of them are in one of the following states: `connecting`,
    /// `checking`, `failed`, `disconnected`, or all of the connection's
    /// transports are in the `closed` state.
    New,

    /// One or more of the ICE transports are currently in the process of
    /// establishing a connection. That is, their [`IceConnectionState`] is
    /// either [`IceConnectionState::Checking`] or
    /// [`IceConnectionState::Connected`], and no transports are in the
    /// `failed` state.
    Connecting,

    /// Every ICE transport used by the connection is either in use (state
    /// `connected` or `completed`) or is closed (state `closed`). In addition,
    /// at least one transport is either `connected` or `completed`.
    Connected,

    /// At least one of the ICE transports for the connection is in the
    /// `disconnected` state and none of the other transports are in the state
    /// `failed`, `connecting` or `checking`.
    Disconnected,

    /// One or more of the ICE transports on the connection is in the `failed`
    /// state.
    Failed,

    /// Peer connection is closed.
    Closed,
}

impl From<sys::PeerConnectionState> for PeerConnectionState {
    fn from(state: sys::PeerConnectionState) -> Self {
        match state {
            sys::PeerConnectionState::kNew => Self::New,
            sys::PeerConnectionState::kConnecting => Self::Connecting,
            sys::PeerConnectionState::kConnected => Self::Connected,
            sys::PeerConnectionState::kDisconnected => Self::Disconnected,
            sys::PeerConnectionState::kFailed => Self::Failed,
            sys::PeerConnectionState::kClosed => Self::Closed,
            _ => unreachable!(),
        }
    }
}

/// Possible kinds of media devices.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MediaDeviceKind {
    /// Audio input device (for example, a microphone).
    AudioInput,

    /// Audio output device (for example, a pair of headphones).
    AudioOutput,

    /// Video input device (for example, a webcam).
    VideoInput,
}

/// Indicator of the current [MediaStreamTrackState][0] of a
/// [`MediaStreamTrack`].
///
/// [0]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrackstate
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackState {
    /// [MediaStreamTrackState.live][0] representation.
    ///
    /// [0]: https://tinyurl.com/w3mcs#idl-def-MediaStreamTrackState.live
    Live,

    /// [MediaStreamTrackState.ended][0] representation.
    ///
    /// [0]: https://tinyurl.com/w3mcs#idl-def-MediaStreamTrackState.ended
    Ended,
}

impl From<sys::TrackState> for TrackState {
    fn from(state: sys::TrackState) -> Self {
        match state {
            sys::TrackState::kLive => Self::Live,
            sys::TrackState::kEnded => Self::Ended,
            _ => unreachable!(),
        }
    }
}

/// [RTCRtpTransceiverDirection][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiverdirection
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum RtpTransceiverDirection {
    /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will offer to send RTP, and
    /// will send RTP if the remote peer accepts. The [`RTCRtpTransceiver`]'s
    /// [RTCRtpReceiver] will offer to receive RTP, and will receive RTP if the
    /// remote peer accepts.
    ///
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    SendRecv,

    /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will offer to send RTP, and
    /// will send RTP if the remote peer accepts. The [`RTCRtpTransceiver`]'s
    /// [RTCRtpReceiver] will not offer to receive RTP, and will not receive
    /// RTP.
    ///
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    SendOnly,

    /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will not offer to send RTP,
    /// and will not send RTP. The [`RTCRtpTransceiver`]'s [RTCRtpReceiver] will
    /// offer to receive RTP, and will receive RTP if the remote peer accepts.
    ///
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    RecvOnly,

    /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will not offer to send RTP,
    /// and will not send RTP. The [`RTCRtpTransceiver`]'s [RTCRtpReceiver] will
    /// not offer to receive RTP, and will not receive RTP.
    ///
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    Inactive,

    /// The [`RTCRtpTransceiver`] will neither send nor receive RTP. It will
    /// generate a zero port in the offer. In answers, its [RTCRtpSender] will
    /// not offer to send RTP, and its [RTCRtpReceiver] will not offer to
    /// receive RTP. This is a terminal state.
    ///
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    Stopped,
}

impl From<sys::RtpTransceiverDirection> for RtpTransceiverDirection {
    fn from(state: sys::RtpTransceiverDirection) -> Self {
        match state {
            sys::RtpTransceiverDirection::kSendRecv => Self::SendRecv,
            sys::RtpTransceiverDirection::kSendOnly => Self::SendOnly,
            sys::RtpTransceiverDirection::kRecvOnly => Self::RecvOnly,
            sys::RtpTransceiverDirection::kInactive => Self::Inactive,
            sys::RtpTransceiverDirection::kStopped => Self::Stopped,
            _ => unreachable!(),
        }
    }
}

impl From<RtpTransceiverDirection> for sys::RtpTransceiverDirection {
    fn from(state: RtpTransceiverDirection) -> Self {
        match state {
            RtpTransceiverDirection::SendRecv => Self::kSendRecv,
            RtpTransceiverDirection::SendOnly => Self::kSendOnly,
            RtpTransceiverDirection::RecvOnly => Self::kRecvOnly,
            RtpTransceiverDirection::Inactive => Self::kInactive,
            RtpTransceiverDirection::Stopped => Self::kStopped,
        }
    }
}

/// Possible media types of a [`MediaStreamTrack`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MediaType {
    /// Audio [`MediaStreamTrack`].
    Audio,

    /// Video [`MediaStreamTrack`].
    Video,
}

impl From<MediaType> for sys::MediaType {
    fn from(state: MediaType) -> Self {
        match state {
            MediaType::Audio => Self::MEDIA_TYPE_AUDIO,
            MediaType::Video => Self::MEDIA_TYPE_VIDEO,
        }
    }
}

/// [RTCSdpType] representation.
///
/// [RTCSdpType]: https://w3.org/TR/webrtc#dom-rtcsdptype
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SdpType {
    /// [RTCSdpType.offer][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-offer
    Offer,

    /// [RTCSdpType.pranswer][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-pranswer
    PrAnswer,

    /// [RTCSdpType.answer][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-answer
    Answer,

    /// [RTCSdpType.rollback][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-rollback
    Rollback,
}

impl From<SdpType> for sys::SdpType {
    fn from(kind: SdpType) -> Self {
        match kind {
            SdpType::Offer => Self::kOffer,
            SdpType::PrAnswer => Self::kPrAnswer,
            SdpType::Answer => Self::kAnswer,
            SdpType::Rollback => Self::kRollback,
        }
    }
}

impl From<sys::SdpType> for SdpType {
    fn from(kind: sys::SdpType) -> Self {
        match kind {
            sys::SdpType::kOffer => Self::Offer,
            sys::SdpType::kPrAnswer => Self::PrAnswer,
            sys::SdpType::kAnswer => Self::Answer,
            sys::SdpType::kRollback => Self::Rollback,
            _ => unreachable!(),
        }
    }
}

/// [RTCSessionDescription] representation.
///
/// [RTCSessionDescription]: https://w3.org/TR/webrtc#dom-rtcsessiondescription
#[derive(Debug)]
pub struct RtcSessionDescription {
    /// String representation of the SDP.
    pub sdp: String,

    /// Type of this [`RtcSessionDescription`].
    pub kind: SdpType,
}

/// Information describing a single media input or output device.
#[derive(Debug)]
pub struct MediaDeviceInfo {
    /// Unique identifier for the represented device.
    pub device_id: String,

    /// Kind of the represented device.
    pub kind: MediaDeviceKind,

    /// Label describing the represented device.
    pub label: String,
}

/// Information describing a display.
#[derive(Debug)]
pub struct MediaDisplayInfo {
    /// Unique identifier of the device representing the display.
    pub device_id: String,

    /// Title describing the represented display.
    pub title: Option<String>,
}

/// [MediaStreamConstraints], used to instruct what sort of
/// [`MediaStreamTrack`]s to include in the [`MediaStream`] returned by
/// [`Webrtc::get_users_media()`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamconstraints
#[derive(Debug)]
pub struct MediaStreamConstraints {
    /// Specifies the nature and settings of the audio [`MediaStreamTrack`].
    pub audio: Option<AudioConstraints>,

    /// Specifies the nature and settings of the video [`MediaStreamTrack`].
    pub video: Option<VideoConstraints>,
}

/// Nature and settings of the video [`MediaStreamTrack`] returned by
/// [`Webrtc::get_users_media()`].
#[derive(Debug)]
pub struct VideoConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// First device will be chosen if an empty [`String`] is provided.
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

/// Nature and settings of the audio [`MediaStreamTrack`] returned by
/// [`Webrtc::get_users_media()`].
#[derive(Debug)]
pub struct AudioConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// First device will be chosen if an empty [`String`] is provided.
    ///
    /// **NOTE**: There can be only one active recording device at a time, so
    ///           changing device will affect all previously obtained audio
    ///           tracks.
    pub device_id: Option<String>,
}

/// Representation of a single media track within a [`MediaStream`].
///
/// Typically, these are audio or video tracks, but other track types may exist
/// as well.
#[derive(Clone, Debug)]
pub struct MediaStreamTrack {
    /// Unique identifier (GUID) of this [`MediaStreamTrack`].
    pub id: String,

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

/// Representation of a permanent pair of an [RTCRtpSender] and an
/// [RTCRtpReceiver], along with some shared state.
///
/// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
/// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
#[derive(Clone, Debug)]
pub struct RtcRtpTransceiver {
    /// ID of the [`PeerConnection`] that this [`RtcRtpTransceiver`] belongs to.
    pub peer_id: u64,

    /// ID of this [`RtcRtpTransceiver`].
    ///
    /// It's not unique across all possible [`RtcRtpTransceiver`]s, but only
    /// within a specific peer.
    pub index: u64,

    /// [Negotiated media ID (mid)][1] which the local and remote peers have
    /// agreed upon to uniquely identify the [`MediaStream`]'s pairing of
    /// sender and receiver.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub mid: Option<String>,

    /// Preferred [`direction`][1] of this [`RtcRtpTransceiver`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver-direction
    pub direction: RtpTransceiverDirection,
}

/// Representation of a track event, sent when a new [`MediaStreamTrack`] is
/// added to an [`RtcRtpTransceiver`] as part of a [`PeerConnection`].
#[derive(Clone, Debug)]
pub struct RtcTrackEvent {
    /// [`MediaStreamTrack`] associated with the [RTCRtpReceiver] identified
    /// by the receiver.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    pub track: MediaStreamTrack,

    /// [`RtcRtpTransceiver`] object associated with the event.
    pub transceiver: RtcRtpTransceiver,
}

/// [`PeerConnection`]'s configuration.
#[derive(Debug)]
pub struct RtcConfiguration {
    /// [iceTransportPolicy][1] configuration.
    ///
    /// Indicates which candidates the [ICE Agent][2] is allowed to use.
    ///
    /// [1]: https://tinyurl.com/icetransportpolicy
    /// [2]: https://w3.org/TR/webrtc#dfn-ice-agent
    pub ice_transport_policy: IceTransportsType,

    /// [bundlePolicy][1] configuration.
    ///
    /// Indicates which media-bundling policy to use when gathering ICE
    /// candidates.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-bundlepolicy
    pub bundle_policy: BundlePolicy,

    /// [iceServers][1] configuration.
    ///
    /// An array of objects describing servers available to be used by ICE,
    /// such as STUN and TURN servers.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-iceservers
    pub ice_servers: Vec<RtcIceServer>,
}

/// [RTCIceTransportPolicy][1] representation.
///
/// It defines an ICE candidate policy the [ICE Agent][2] uses to surface
/// the permitted candidates to the application. Only these candidates will
/// be used for connectivity checks.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy
/// [2]: https://w3.org/TR/webrtc#dfn-ice-agent
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum IceTransportsType {
    /// [RTCIceTransportPolicy.all][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy-all
    All,

    /// [RTCIceTransportPolicy.relay][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy-relay
    Relay,

    /// ICE Agent can't use `typ host` candidates when this value is specified.
    ///
    /// Non-spec-compliant variant.
    NoHost,

    /// No ICE candidate offered.
    None,
}

impl From<IceTransportsType> for sys::IceTransportsType {
    fn from(kind: IceTransportsType) -> Self {
        match kind {
            IceTransportsType::All => Self::kAll,
            IceTransportsType::Relay => Self::kRelay,
            IceTransportsType::NoHost => Self::kNoHost,
            IceTransportsType::None => Self::kNone,
        }
    }
}

/// [RTCBundlePolicy][1] representation.
///
/// Affects which media tracks are negotiated if the remote endpoint is not
/// bundle-aware, and what ICE candidates are gathered. If the remote endpoint
/// is bundle-aware, all media tracks and data channels are bundled onto the
/// same transport.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum BundlePolicy {
    /// [RTCBundlePolicy.balanced][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-balanced
    Balanced,

    /// [RTCBundlePolicy.max-bundle][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-bundle
    MaxBundle,

    /// [RTCBundlePolicy.max-compat][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-compat
    MaxCompat,
}

impl From<BundlePolicy> for sys::BundlePolicy {
    fn from(policy: BundlePolicy) -> Self {
        match policy {
            BundlePolicy::Balanced => Self::kBundlePolicyBalanced,
            BundlePolicy::MaxBundle => Self::kBundlePolicyMaxBundle,
            BundlePolicy::MaxCompat => Self::kBundlePolicyMaxCompat,
        }
    }
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

/// Description of STUN and TURN servers that can be used by an [ICE Agent][1]
/// to establish a connection with a peer.
///
/// [1]: https://w3.org/TR/webrtc#dfn-ice-agent
#[derive(Debug)]
pub struct RtcIceServer {
    /// STUN or TURN URI(s).
    pub urls: Vec<String>,

    /// If this [`RtcIceServer`] object represents a TURN server, then this
    /// attribute specifies the [username][1] to use with that TURN server.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-username
    pub username: String,

    /// If this [`RtcIceServer`] object represents a TURN server, then this
    /// attribute specifies the [credential][1] to use with that TURN
    /// server.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-credential
    pub credential: String,
}

/// Configures media acquisition to use fake devices instead of actual camera
/// and microphone.
pub fn enable_fake_media() {
    FAKE_MEDIA.store(true, Ordering::Release);
}

/// Indicates whether application is configured to use fake media devices.
pub fn is_fake_media() -> bool {
    FAKE_MEDIA.load(Ordering::Acquire)
}

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
pub fn enumerate_devices() -> anyhow::Result<Vec<MediaDeviceInfo>> {
    WEBRTC.lock().unwrap().enumerate_devices()
}

/// Returns a list of all available displays that can be used for screen
/// capturing.
pub fn enumerate_displays() -> Vec<MediaDisplayInfo> {
    devices::enumerate_displays()
}

/// Creates a new [`PeerConnection`] and returns its ID.
#[allow(clippy::needless_pass_by_value)]
pub fn create_peer_connection(
    cb: StreamSink<PeerConnectionEvent>,
    configuration: RtcConfiguration,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .create_peer_connection(&(cb.into()), configuration)
}

/// Initiates the creation of an SDP offer for the purpose of starting a new
/// WebRTC connection to a remote peer.
pub fn create_offer(
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) -> anyhow::Result<RtcSessionDescription> {
    let (tx, rx) = mpsc::channel();

    WEBRTC.lock().unwrap().create_offer(
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
        tx,
    )?;

    rx.recv_timeout(RX_TIMEOUT)?
}

/// Creates an SDP answer to an offer received from a remote peer during an
/// offer/answer negotiation of a WebRTC connection.
pub fn create_answer(
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) -> anyhow::Result<RtcSessionDescription> {
    let (tx, rx) = mpsc::channel();

    WEBRTC.lock().unwrap().create_answer(
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
        tx,
    )?;

    rx.recv_timeout(RX_TIMEOUT)?
}

/// Changes the local description associated with the connection.
pub fn set_local_description(
    peer_id: u64,
    kind: SdpType,
    sdp: String,
) -> anyhow::Result<()> {
    let (tx, rx) = mpsc::channel();

    WEBRTC.lock().unwrap().set_local_description(
        peer_id,
        kind.into(),
        sdp,
        tx,
    )?;

    rx.recv_timeout(RX_TIMEOUT)?
}

/// Sets the specified session description as the remote peer's current offer or
/// answer.
pub fn set_remote_description(
    peer_id: u64,
    kind: SdpType,
    sdp: String,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .set_remote_description(peer_id, kind.into(), sdp)
}

/// Creates a new [`RtcRtpTransceiver`] and adds it to the set of transceivers
/// of the specified [`PeerConnection`].
pub fn add_transceiver(
    peer_id: u64,
    media_type: MediaType,
    direction: RtpTransceiverDirection,
) -> anyhow::Result<RtcRtpTransceiver> {
    WEBRTC.lock().unwrap().add_transceiver(
        peer_id,
        media_type.into(),
        direction.into(),
    )
}

/// Returns a sequence of [`RtcRtpTransceiver`] objects representing the RTP
/// transceivers currently attached to the specified [`PeerConnection`].
pub fn get_transceivers(
    peer_id: u64,
) -> anyhow::Result<Vec<RtcRtpTransceiver>> {
    WEBRTC.lock().unwrap().get_transceivers(peer_id)
}

/// Changes the preferred `direction` of the specified [`RtcRtpTransceiver`].
pub fn set_transceiver_direction(
    peer_id: u64,
    transceiver_index: u32,
    direction: RtpTransceiverDirection,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_transceiver_direction(
        peer_id,
        transceiver_index,
        direction,
    )
}

/// Changes the receive direction of the specified [`RtcRtpTransceiver`].
pub fn set_transceiver_recv(
    peer_id: u64,
    transceiver_index: u32,
    recv: bool,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_transceiver_recv(
        peer_id,
        transceiver_index,
        recv,
    )
}

/// Changes the send direction of the specified [`RtcRtpTransceiver`].
pub fn set_transceiver_send(
    peer_id: u64,
    transceiver_index: u32,
    send: bool,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_transceiver_send(
        peer_id,
        transceiver_index,
        send,
    )
}

/// Returns the [negotiated media ID (mid)][1] of the specified
/// [`RtcRtpTransceiver`].
///
/// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
pub fn get_transceiver_mid(
    peer_id: u64,
    transceiver_index: u32,
) -> anyhow::Result<Option<String>> {
    WEBRTC
        .lock()
        .unwrap()
        .get_transceiver_mid(peer_id, transceiver_index)
}

/// Returns the preferred direction of the specified [`RtcRtpTransceiver`].
pub fn get_transceiver_direction(
    peer_id: u64,
    transceiver_index: u32,
) -> anyhow::Result<RtpTransceiverDirection> {
    WEBRTC
        .lock()
        .unwrap()
        .get_transceiver_direction(peer_id, transceiver_index)
        .map(Into::into)
}

/// Returns [`RtcStats`] of the [`PeerConnection`] by its ID.
pub fn get_peer_stats(peer_id: u64) -> anyhow::Result<Vec<RtcStats>> {
    let (tx, rx) = mpsc::channel();

    WEBRTC.lock().unwrap().get_stats(peer_id, tx)?;
    let report = rx.recv_timeout(RX_TIMEOUT)?;

    Ok(report
        .get_stats()?
        .into_iter()
        .map(RtcStats::from)
        .collect())
}

/// Irreversibly marks the specified [`RtcRtpTransceiver`] as stopping, unless
/// it's already stopped.
///
/// This will immediately cause the transceiver's sender to no longer send, and
/// its receiver to no longer receive.
pub fn stop_transceiver(
    peer_id: u64,
    transceiver_index: u32,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .stop_transceiver(peer_id, transceiver_index)
}

/// Replaces the specified [`AudioTrack`] (or [`VideoTrack`]) on the
/// [`sys::Transceiver`]'s `sender`.
pub fn sender_replace_track(
    peer_id: u64,
    transceiver_index: u32,
    track_id: Option<String>,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().sender_replace_track(
        peer_id,
        transceiver_index,
        track_id,
    )
}

/// Adds the new ICE `candidate` to the given [`PeerConnection`].
#[allow(clippy::needless_pass_by_value)]
pub fn add_ice_candidate(
    peer_id: u64,
    candidate: String,
    sdp_mid: String,
    sdp_mline_index: i32,
) -> anyhow::Result<()> {
    let (tx, rx) = mpsc::channel();

    WEBRTC.lock().unwrap().add_ice_candidate(
        peer_id,
        candidate,
        sdp_mid,
        sdp_mline_index,
        tx,
    )?;

    rx.recv_timeout(RX_TIMEOUT)?
}

/// Tells the [`PeerConnection`] that ICE should be restarted.
pub fn restart_ice(peer_id: u64) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().restart_ice(peer_id)
}

/// Closes the [`PeerConnection`].
pub fn dispose_peer_connection(peer_id: u64) {
    WEBRTC.lock().unwrap().dispose_peer_connection(peer_id);
}

/// Creates a [`MediaStream`] with tracks according to provided
/// [`MediaStreamConstraints`].
pub fn get_media(constraints: MediaStreamConstraints) -> GetMediaResult {
    match WEBRTC.lock().unwrap().get_media(constraints) {
        Ok(tracks) => GetMediaResult::Ok(tracks),
        Err(err) => GetMediaResult::Err(err),
    }
}

/// Sets the specified `audio playout` device.
pub fn set_audio_playout_device(device_id: String) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_audio_playout_device(device_id)
}

/// Indicates whether the microphone is available to set volume.
pub fn microphone_volume_is_available() -> anyhow::Result<bool> {
    WEBRTC.lock().unwrap().microphone_volume_is_available()
}

/// Sets the microphone system volume according to the specified `level` in
/// percents.
///
/// Valid values range is `[0; 100]`.
pub fn set_microphone_volume(level: u8) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_microphone_volume(level)
}

/// Returns the current level of the microphone volume in `[0; 100]` range.
pub fn microphone_volume() -> anyhow::Result<u32> {
    WEBRTC.lock().unwrap().microphone_volume()
}

/// Disposes the specified [`MediaStreamTrack`].
pub fn dispose_track(track_id: String, kind: MediaType) {
    WEBRTC.lock().unwrap().dispose_track(track_id, kind);
}

/// Returns the [readyState][0] property of the [`MediaStreamTrack`] by its ID
/// and [`MediaType`].
///
/// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
pub fn track_state(
    track_id: String,
    kind: MediaType,
) -> anyhow::Result<TrackState> {
    WEBRTC.lock().unwrap().track_state(track_id, kind)
}

/// Changes the [enabled][1] property of the [`MediaStreamTrack`] by its ID and
/// [`MediaType`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
pub fn set_track_enabled(
    track_id: String,
    kind: MediaType,
    enabled: bool,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .set_track_enabled(track_id, kind, enabled)
}

/// Clones the specified [`MediaStreamTrack`].
pub fn clone_track(
    track_id: String,
    kind: MediaType,
) -> anyhow::Result<MediaStreamTrack> {
    WEBRTC.lock().unwrap().clone_track(track_id, kind)
}

/// Registers an observer to the [`MediaStreamTrack`] events.
pub fn register_track_observer(
    cb: StreamSink<TrackEvent>,
    track_id: String,
    kind: MediaType,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .register_track_observer(track_id, kind, cb.into())
}

/// Sets the provided [`OnDeviceChangeCallback`] as the callback to be called
/// whenever a set of available media devices changes.
///
/// Only one callback can be set at a time, so the previous one will be dropped,
/// if any.
pub fn set_on_device_changed(cb: StreamSink<()>) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_on_device_changed(cb.into())
}

/// Creates a new [`VideoSink`] attached to the specified video track.
///
/// `callback_ptr` argument should be a pointer to an [`UniquePtr`] pointing to
/// an [`OnFrameCallbackInterface`].
pub fn create_video_sink(
    sink_id: i64,
    track_id: String,
    callback_ptr: u64,
) -> anyhow::Result<()> {
    let handler = FrameHandler::new(callback_ptr as _);

    WEBRTC
        .lock()
        .unwrap()
        .create_video_sink(sink_id, track_id, handler)
}

/// Destroys the [`VideoSink`] by the provided ID.
pub fn dispose_video_sink(sink_id: i64) {
    WEBRTC.lock().unwrap().dispose_video_sink(sink_id);
}
