//! [RTCIceConnectionState][1] definitions.
//!
//! [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate

use libwebrtc_sys as sys;

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
