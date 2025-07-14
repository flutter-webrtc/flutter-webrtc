//! [RTCRtpTransceiverInit][0] definitions.
//!
//! [0]: https://w3.org/TR/webrtc#dom-rtcrtptransceiverinit

use crate::api::{RtcRtpEncodingParameters, RtpTransceiverDirection};

/// Representation of an [RTCRtpTransceiverInit][0].
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtptransceiverinit
pub struct RtpTransceiverInit {
    /// Direction of the [RTCRtpTransceiver].
    ///
    /// [RTCRtpTransceiver]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
    pub direction: RtpTransceiverDirection,

    /// Sequence containing parameters for sending [RTP] encodings of media.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    pub send_encodings: Vec<RtcRtpEncodingParameters>,
}
