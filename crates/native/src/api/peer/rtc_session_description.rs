//! [RTCSessionDescription] definitions.
//!
//! [RTCSessionDescription]: https://w3.org/TR/webrtc#dom-rtcsessiondescription

use std::sync::{Arc, mpsc};

use libwebrtc_sys as sys;

use crate::{PeerConnection, api::RX_TIMEOUT, frb_generated::RustOpaque};

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

/// Sets the specified session description as the remote peer's current offer or
/// answer.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_remote_description(
    peer: RustOpaque<Arc<PeerConnection>>,
    kind: SdpType,
    sdp: String,
) -> anyhow::Result<()> {
    peer.set_remote_description(kind.into(), &sdp)
}

/// Changes the local description associated with the connection.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_local_description(
    peer: RustOpaque<Arc<PeerConnection>>,
    kind: SdpType,
    sdp: String,
) -> anyhow::Result<()> {
    let (tx, rx) = mpsc::channel();

    peer.set_local_description(kind.into(), &sdp, tx);

    rx.recv_timeout(RX_TIMEOUT)?
}
