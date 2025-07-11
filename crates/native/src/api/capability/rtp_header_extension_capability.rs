//! Capabilities/preferences of a header extension of [`RtpCapabilities`].

use libwebrtc_sys as sys;

#[cfg(doc)]
use crate::api::RtpCapabilities;
use crate::api::RtpTransceiverDirection;

/// Representation of capabilities/preferences of an implementation for a header
/// extension of [`RtpCapabilities`].
#[derive(Debug)]
pub struct RtpHeaderExtensionCapability {
    /// [URI] of this extension, as defined in [RFC 8285].
    ///
    /// [RFC 8285]: https://tools.ietf.org/html/rfc8285
    /// [URI]: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier
    pub uri: String,

    /// Preferred value of ID that goes in the packet.
    pub preferred_id: Option<i32>,

    /// If [`true`], it's preferred that the value in the header is encrypted.
    pub preferred_encrypted: bool,

    /// Direction of the extension.
    ///
    /// [`RtpTransceiverDirection::Stopped`] value is only used with
    /// `RtpTransceiverInterface::SetHeaderExtensionsToNegotiate()` and
    /// `SetHeaderExtensionsToNegotiate()`.
    pub direction: RtpTransceiverDirection,
}

impl From<sys::RtpHeaderExtensionCapability> for RtpHeaderExtensionCapability {
    fn from(value: sys::RtpHeaderExtensionCapability) -> Self {
        Self {
            uri: value.uri(),
            preferred_id: value.preferred_id(),
            preferred_encrypted: value.preferred_encrypted(),
            direction: value.direction().into(),
        }
    }
}
