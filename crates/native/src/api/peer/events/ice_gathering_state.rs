//! [RTCIceGatheringState][1] definitions.
//!
//! [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate

use libwebrtc_sys as sys;

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
