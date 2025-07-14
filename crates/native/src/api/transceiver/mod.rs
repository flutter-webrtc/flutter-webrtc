//! Permanent pair of an [RTCRtpSender] and an [RTCRtpReceiver].
//!
//! [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
//! [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver

pub mod direction;
pub mod init;

use std::sync::Arc;

pub use self::{direction::RtpTransceiverDirection, init::RtpTransceiverInit};
use crate::{
    PeerConnection, RtpTransceiver, Webrtc, api::MediaType,
    frb_generated::RustOpaque,
};

/// Representation of a permanent pair of an [RTCRtpSender] and an
/// [RTCRtpReceiver], along with some shared state.
///
/// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
/// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
#[derive(Clone)]
pub struct RtcRtpTransceiver {
    /// [`PeerConnection`] that this [`RtcRtpTransceiver`] belongs to.
    pub peer: RustOpaque<Arc<PeerConnection>>,

    /// Rust side [`RtpTransceiver`].
    pub transceiver: RustOpaque<Arc<RtpTransceiver>>,

    /// [Negotiated media ID (mid)][1] which the local and remote peers have
    /// agreed upon to uniquely identify the [MediaStream]'s pairing of sender
    /// and receiver.
    ///
    /// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub mid: Option<String>,

    /// Preferred [`direction`][1] of this [`RtcRtpTransceiver`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver-direction
    pub direction: RtpTransceiverDirection,
}

/// Creates a new [`RtcRtpTransceiver`] and adds it to the set of transceivers
/// of the specified [`PeerConnection`].
pub fn add_transceiver(
    peer: RustOpaque<Arc<PeerConnection>>,
    media_type: MediaType,
    init: RtpTransceiverInit,
) -> anyhow::Result<RtcRtpTransceiver> {
    PeerConnection::add_transceiver(peer, media_type.into(), init)
}

/// Returns a sequence of [`RtcRtpTransceiver`] objects representing the RTP
/// transceivers currently attached to the specified [`PeerConnection`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn get_transceivers(
    peer: RustOpaque<Arc<PeerConnection>>,
) -> Vec<RtcRtpTransceiver> {
    Webrtc::get_transceivers(&peer)
}

/// Changes the preferred `direction` of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_transceiver_direction(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    direction: RtpTransceiverDirection,
) -> anyhow::Result<()> {
    transceiver.set_direction(direction)
}

/// Changes the receive direction of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_transceiver_recv(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    recv: bool,
) -> anyhow::Result<()> {
    transceiver.set_recv(recv)
}

/// Changes the send direction of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_transceiver_send(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    send: bool,
) -> anyhow::Result<()> {
    transceiver.set_send(send)
}

/// Returns the [negotiated media ID (mid)][1] of the specified
/// [`RtcRtpTransceiver`].
///
/// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn get_transceiver_mid(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> Option<String> {
    transceiver.mid()
}

/// Returns the preferred direction of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn get_transceiver_direction(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> RtpTransceiverDirection {
    transceiver.direction().into()
}

/// Irreversibly marks the specified [`RtcRtpTransceiver`] as stopping, unless
/// it's already stopped.
///
/// This will immediately cause the transceiver's sender to no longer send, and
/// its receiver to no longer receive.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn stop_transceiver(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> anyhow::Result<()> {
    transceiver.stop()
}
