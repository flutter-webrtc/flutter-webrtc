//! Capabilities of an [RTP] endpoint.
//!
//! [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol

pub mod rtp_codec;
pub mod rtp_header_extension_capability;

use libwebrtc_sys as sys;

pub use self::{
    rtp_codec::{
        RtcpFeedback, RtcpFeedbackMessageType, RtcpFeedbackType,
        RtpCodecCapability, ScalabilityMode, set_codec_preferences,
    },
    rtp_header_extension_capability::RtpHeaderExtensionCapability,
};
#[cfg(doc)]
use crate::RtpParameters;
use crate::api::{MediaType, WEBRTC};

/// Representation of the static capabilities of an endpoint.
///
/// Applications can use these capabilities to construct [`RtpParameters`].
#[derive(Debug)]
pub struct RtpCapabilities {
    /// Supported codecs.
    pub codecs: Vec<RtpCodecCapability>,

    /// Supported [RTP] header extensions.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    pub header_extensions: Vec<RtpHeaderExtensionCapability>,
}

impl From<sys::RtpCapabilities> for RtpCapabilities {
    fn from(value: sys::RtpCapabilities) -> Self {
        Self {
            codecs: value.codecs().into_iter().map(Into::into).collect(),
            header_extensions: value
                .header_extensions()
                .into_iter()
                .map(Into::into)
                .collect(),
        }
    }
}

/// Returns the capabilities of an [RTP] sender of the provided [`MediaType`].
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
#[must_use]
pub fn get_rtp_sender_capabilities(kind: MediaType) -> RtpCapabilities {
    RtpCapabilities::from(
        WEBRTC
            .lock()
            .unwrap()
            .peer_connection_factory
            .get_rtp_sender_capabilities(kind.into()),
    )
}

/// Returns the capabilities of an [RTP] receiver of the provided [`MediaType`].
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
#[must_use]
pub fn get_rtp_receiver_capabilities(kind: MediaType) -> RtpCapabilities {
    RtpCapabilities::from(
        WEBRTC
            .lock()
            .unwrap()
            .peer_connection_factory
            .get_rtp_receiver_capabilities(kind.into()),
    )
}
