//! Representation of a [`MediaStreamTrack`] event.

#[cfg(doc)]
use crate::PeerConnection;
use crate::api::{MediaStreamTrack, RtcRtpTransceiver};

/// Representation of a track event, sent when a new [`MediaStreamTrack`] is
/// added to an [`RtcRtpTransceiver`] as part of a [`PeerConnection`].
#[derive(Clone)]
pub struct RtcTrackEvent {
    /// [`MediaStreamTrack`] associated with the [RTCRtpReceiver] identified
    /// by the receiver.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    pub track: MediaStreamTrack,

    /// [`RtcRtpTransceiver`] object associated with the event.
    pub transceiver: RtcRtpTransceiver,
}
