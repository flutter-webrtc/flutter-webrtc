//! [RTCIceTransportPolicy][1] definitions.
//!
//! [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy

use libwebrtc_sys as sys;

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
