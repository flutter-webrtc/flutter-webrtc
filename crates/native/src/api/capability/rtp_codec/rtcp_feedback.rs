//! [RTCP] feedback message.
//!
//! [RTCP]: https://en.wikipedia.org/wiki/RTP_Control_Protocol

use libwebrtc_sys as sys;

/// [RTCP] feedback message intended to enable congestion control for
/// interactive real-time traffic using [RTP].
///
/// [RTCP]: https://en.wikipedia.org/wiki/RTP_Control_Protocol
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
#[derive(Debug)]
pub struct RtcpFeedback {
    /// Message type of this [`RtcpFeedback`].
    pub message_type: Option<RtcpFeedbackMessageType>,

    /// Kind of this [`RtcpFeedback`].
    pub kind: RtcpFeedbackType,
}

impl From<sys::RtcpFeedback> for RtcpFeedback {
    fn from(value: sys::RtcpFeedback) -> Self {
        Self {
            message_type: value.message_type().map(Into::into),
            kind: value.kind().into(),
        }
    }
}

/// Possible types of an [`RtcpFeedback`].
#[derive(Debug, Eq, Hash, PartialEq)]
#[repr(i32)]
pub enum RtcpFeedbackType {
    /// Codec control messages.
    Ccm,

    /// Loss notification feedback.
    Lntf,

    /// Negative acknowledgemen.
    Nack,

    /// Receiver estimated maximum bitrate.
    Remb,

    /// Transport wide congestion control.
    TransportCC,
}

impl From<sys::RtcpFeedbackType> for RtcpFeedbackType {
    fn from(value: sys::RtcpFeedbackType) -> Self {
        match value {
            sys::RtcpFeedbackType::CCM => Self::Ccm,
            sys::RtcpFeedbackType::LNTF => Self::Lntf,
            sys::RtcpFeedbackType::NACK => Self::Nack,
            sys::RtcpFeedbackType::REMB => Self::Remb,
            sys::RtcpFeedbackType::TRANSPORT_CC => Self::TransportCC,
            _ => unreachable!(),
        }
    }
}

/// Possible message types of an [`RtcpFeedback`], when is type is
/// [`RtcpFeedbackType::Nack`] or [`RtcpFeedbackType::Ccm`].
#[derive(Debug, Eq, Hash, PartialEq)]
#[repr(i32)]
pub enum RtcpFeedbackMessageType {
    /// Equivalent to `{ type: "nack", parameter: undefined }` in ORTC.
    GenericNACK,

    /// Usable with [`RtcpFeedbackType::Nack`].
    Pli,

    /// Usable with [`RtcpFeedbackType::Ccm`].
    Fir,
}

impl From<sys::RtcpFeedbackMessageType> for RtcpFeedbackMessageType {
    fn from(value: sys::RtcpFeedbackMessageType) -> Self {
        match value {
            sys::RtcpFeedbackMessageType::GENERIC_NACK => Self::GenericNACK,
            sys::RtcpFeedbackMessageType::PLI => Self::Pli,
            sys::RtcpFeedbackMessageType::FIR => Self::Fir,
            _ => unreachable!(),
        }
    }
}
