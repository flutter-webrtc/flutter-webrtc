//! [`PeerConnection`]'s events.

pub mod ice_connection_state;
pub mod ice_gathering_state;
pub mod peer_connection_state;
pub mod rtc_track_event;
pub mod signaling_state;

use std::sync::Arc;

pub use self::{
    ice_connection_state::IceConnectionState,
    ice_gathering_state::IceGatheringState,
    peer_connection_state::PeerConnectionState, rtc_track_event::RtcTrackEvent,
    signaling_state::SignalingState,
};
use crate::{PeerConnection, frb_generated::RustOpaque};

/// Representation of [`PeerConnection`]'s events.
#[derive(Clone)]
pub enum PeerConnectionEvent {
    /// [`PeerConnection`] has been created.
    PeerCreated {
        /// Rust side [`PeerConnection`].
        peer: RustOpaque<Arc<PeerConnection>>,
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
