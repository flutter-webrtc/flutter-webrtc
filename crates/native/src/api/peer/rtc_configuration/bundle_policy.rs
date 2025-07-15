//! [RTCBundlePolicy][1] definitions.
//!
//! [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy

use libwebrtc_sys as sys;

/// [RTCBundlePolicy][1] representation.
///
/// Affects which media tracks are negotiated if the remote endpoint is not
/// bundle-aware, and what ICE candidates are gathered. If the remote endpoint
/// is bundle-aware, all media tracks and data channels are bundled onto the
/// same transport.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum BundlePolicy {
    /// [RTCBundlePolicy.balanced][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-balanced
    Balanced,

    /// [RTCBundlePolicy.max-bundle][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-bundle
    MaxBundle,

    /// [RTCBundlePolicy.max-compat][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-compat
    MaxCompat,
}

impl From<BundlePolicy> for sys::BundlePolicy {
    fn from(policy: BundlePolicy) -> Self {
        match policy {
            BundlePolicy::Balanced => Self::kBundlePolicyBalanced,
            BundlePolicy::MaxBundle => Self::kBundlePolicyMaxBundle,
            BundlePolicy::MaxCompat => Self::kBundlePolicyMaxCompat,
        }
    }
}
