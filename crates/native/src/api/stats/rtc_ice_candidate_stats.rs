//! Properties of a `candidate` in [Section 15.1 of RFC 5245][1].
//!
//! [1]: https://tools.ietf.org/html/rfc5245#section-15.1

use libwebrtc_sys as sys;

/// [RTCIceCandidateType] represents the type of the ICE candidate, as defined
/// in [Section 15.1 of RFC 5245][1].
///
/// [RTCIceCandidateType]: https://w3.org/TR/webrtc#rtcicecandidatetype-enum
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CandidateType {
    /// Host candidate, as defined in [Section 4.1.1.1 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.1
    Host,

    /// Server reflexive candidate, as defined in
    /// [Section 4.1.1.2 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
    Srflx,

    /// Peer reflexive candidate, as defined in
    /// [Section 4.1.1.2 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
    Prflx,

    /// Relay candidate, as defined in [Section 7.1.3.2.1 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.1
    Relay,
}

impl From<sys::CandidateType> for CandidateType {
    fn from(kind: sys::CandidateType) -> Self {
        match kind {
            sys::CandidateType::kHost => Self::Host,
            sys::CandidateType::kSrflx => Self::Srflx,
            sys::CandidateType::kPrflx => Self::Prflx,
            sys::CandidateType::kRelay => Self::Relay,
            _ => unreachable!(),
        }
    }
}

/// Transport protocols used in [WebRTC].
///
/// [WebRTC]: https://w3.org/TR/webrtc
pub enum Protocol {
    /// [Transmission Control Protocol][1].
    ///
    /// [1]: https://en.wikipedia.org/wiki/Transmission_Control_Protocol
    Tcp,

    /// [User Datagram Protocol][1].
    ///
    /// [1]: https://en.wikipedia.org/wiki/User_Datagram_Protocol
    Udp,
}

impl From<sys::Protocol> for Protocol {
    fn from(protocol: sys::Protocol) -> Self {
        match protocol {
            sys::Protocol::Tcp => Self::Tcp,
            sys::Protocol::Udp => Self::Udp,
        }
    }
}

/// Properties of a `candidate` in [Section 15.1 of RFC 5245][1].
/// It corresponds to an [RTCIceTransport] object.
///
/// [`RtcIceCandidateStats::Local`] or [`RtcIceCandidateStats::Remote`] variant.
///
/// [Full doc on W3C][2].
///
/// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
/// [2]: https://w3.org/TR/webrtc-stats#icecandidate-dict%2A
pub struct IceCandidateStats {
    /// Unique ID that is associated to the object that was inspected to produce
    /// the [RTCTransportStats][1] associated with this candidate.
    ///
    /// [1]: https://w3.org/TR/webrtc-stats#transportstats-dict%2A
    pub transport_id: Option<String>,

    /// Address of the candidate, allowing for IPv4 addresses, IPv6 addresses,
    /// and fully qualified domain names (FQDNs).
    pub address: Option<String>,

    /// Port number of the candidate.
    pub port: Option<i32>,

    /// Valid values for transport is one of `udp` and `tcp`.
    pub protocol: Protocol,

    /// Type of the ICE candidate.
    pub candidate_type: CandidateType,

    /// Calculated as defined in [Section 15.1 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
    pub priority: Option<i32>,

    /// For local candidates this is the URL of the ICE server from which the
    /// candidate was obtained. It is the same as the [url][2] surfaced in the
    /// [RTCPeerConnectionIceEvent][1].
    ///
    /// [`None`] for remote candidates.
    ///
    /// [1]: https://w3.org/TR/webrtc#rtcpeerconnectioniceevent
    /// [2]: https://w3.org/TR/webrtc#dom-rtcpeerconnectioniceevent-url
    pub url: Option<String>,

    /// Protocol used by the endpoint to communicate with the TURN server.
    ///
    /// Only present for local candidates.
    pub relay_protocol: Option<Protocol>,
}

impl From<sys::IceCandidateStats> for IceCandidateStats {
    fn from(val: sys::IceCandidateStats) -> Self {
        let sys::IceCandidateStats {
            transport_id,
            address,
            port,
            protocol,
            candidate_type,
            priority,
            url,
        } = val;
        Self {
            transport_id,
            address,
            port,
            protocol: protocol.into(),
            candidate_type: candidate_type.into(),
            priority,
            url,
            relay_protocol: None,
        }
    }
}

/// [`IceCandidateStats`] of either local or remote candidate.
pub enum RtcIceCandidateStats {
    /// [`IceCandidateStats`] of local candidate.
    Local(IceCandidateStats),

    /// [`IceCandidateStats`] of remote candidate.
    Remote(IceCandidateStats),
}
