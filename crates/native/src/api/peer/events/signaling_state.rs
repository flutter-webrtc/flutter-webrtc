//! [RTCSignalingState] definitions.
//!
//! [RTCSignalingState]: https://w3.org/TR/webrtc#state-definitions

use libwebrtc_sys as sys;

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
