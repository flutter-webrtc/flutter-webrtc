//! [ICE role][1] representation.
//!
//! [1]: https://w3.org/TR/webrtc#dom-icetransport-role

use libwebrtc_sys as sys;

/// Variants of [ICE roles][1].
///
/// More info in the [RFC 5245].
///
/// [RFC 5245]: https://tools.ietf.org/html/rfc5245
/// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
#[derive(Clone, Copy, Debug)]
pub enum IceRole {
    /// Agent whose role, as defined by [Section 3 in RFC 5245][1], has not yet
    /// been determined.
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Unknown,

    /// Controlling agent as defined by [Section 3 in RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Controlling,

    /// Controlled agent as defined by [Section 3 in RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Controlled,
}

impl From<sys::IceRole> for IceRole {
    fn from(role: sys::IceRole) -> Self {
        match role {
            sys::IceRole::Unknown => Self::Unknown,
            sys::IceRole::Controlling => Self::Controlling,
            sys::IceRole::Controlled => Self::Controlled,
        }
    }
}
