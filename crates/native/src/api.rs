use std::{mem, sync::Mutex};

use cxx::UniquePtr;
use flutter_rust_bridge::{StreamSink, SyncReturn};
use libwebrtc_sys as sys;

use crate::{cpp_api::OnFrameCallbackInterface, Webrtc};

lazy_static::lazy_static! {
    static ref WEBRTC: Mutex<Webrtc> = Mutex::new(Webrtc::new().unwrap());
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

impl RtcSessionDescription {
    /// Creates a new [`RtcSessionDescription`].
    pub fn new(sdp: String, kind: sys::SdpType) -> Self {
        Self {
            sdp,
            kind: kind.into(),
        }
    }
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
    /// __NOTE__: There can be only one active recording device at a time, so
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

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
pub fn enumerate_devices() -> anyhow::Result<Vec<MediaDeviceInfo>> {
    WEBRTC.lock().unwrap().enumerate_devices()
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
    WEBRTC.lock().unwrap().create_offer(
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
    )
}

/// Creates an SDP answer to an offer received from a remote peer during an
/// offer/answer negotiation of a WebRTC connection.
pub fn create_answer(
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) -> anyhow::Result<RtcSessionDescription> {
    WEBRTC.lock().unwrap().create_answer(
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
    )
}

/// Changes the local description associated with the connection.
pub fn set_local_description(
    peer_id: u64,
    kind: SdpType,
    sdp: String,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .set_local_description(peer_id, kind.into(), sdp)
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
    WEBRTC.lock().unwrap().add_ice_candidate(
        peer_id,
        candidate,
        sdp_mid,
        sdp_mline_index,
    )
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
    let handler = unsafe {
        let ptr: *mut OnFrameCallbackInterface = mem::transmute(callback_ptr);
        UniquePtr::from_raw(ptr)
    };
    WEBRTC
        .lock()
        .unwrap()
        .create_video_sink(sink_id, track_id, handler)
}

/// Destroys the [`VideoSink`] by the provided ID.
// TODO: Fix return type when SyncReturn allows other types.
pub fn dispose_video_sink(sink_id: i64) -> SyncReturn<Vec<u8>> {
    WEBRTC.lock().unwrap().dispose_video_sink(sink_id);
    SyncReturn(Vec::new())
}
