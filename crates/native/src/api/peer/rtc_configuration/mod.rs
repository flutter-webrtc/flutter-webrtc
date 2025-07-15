//! Configuration of a [`PeerConnection`].

pub mod bundle_policy;
pub mod ice_transports_type;
pub mod rtc_ice_server;

pub use self::{
    bundle_policy::BundlePolicy, ice_transports_type::IceTransportsType,
    rtc_ice_server::RtcIceServer,
};
#[cfg(doc)]
use crate::PeerConnection;

/// [`PeerConnection`]'s configuration.
#[derive(Debug)]
pub struct RtcConfiguration {
    /// [iceTransportPolicy][1] configuration.
    ///
    /// Indicates which candidates the [ICE Agent][2] is allowed to use.
    ///
    /// [1]: https://tinyurl.com/icetransportpolicy
    /// [2]: https://w3.org/TR/webrtc#dfn-ice-agent
    pub ice_transport_policy: IceTransportsType,

    /// [bundlePolicy][1] configuration.
    ///
    /// Indicates which media-bundling policy to use when gathering ICE
    /// candidates.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-bundlepolicy
    pub bundle_policy: BundlePolicy,

    /// [iceServers][1] configuration.
    ///
    /// An array of objects describing servers available to be used by ICE,
    /// such as STUN and TURN servers.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-iceservers
    pub ice_servers: Vec<RtcIceServer>,
}
