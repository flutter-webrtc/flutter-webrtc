//! Static codec capabilities.

pub mod rtcp_feedback;
pub mod scalability_mode;

use std::sync::Arc;

use libwebrtc_sys as sys;

pub use self::{
    rtcp_feedback::{RtcpFeedback, RtcpFeedbackMessageType, RtcpFeedbackType},
    scalability_mode::ScalabilityMode,
};
use crate::{RtpTransceiver, api::MediaType, frb_generated::RustOpaque};

/// Representation of static capabilities of an endpoint's implementation of a
/// codec.
#[derive(Debug)]
pub struct RtpCodecCapability {
    /// Default payload type for the codec.
    ///
    /// Mainly needed for codecs that have statically assigned payload types.
    pub preferred_payload_type: Option<i32>,

    /// List of [`ScalabilityMode`]s supported by the video codec.
    pub scalability_modes: Vec<ScalabilityMode>,

    /// Built [MIME "type/subtype"][0] string from `name` and `kind`.
    ///
    /// [0]: https://en.wikipedia.org/wiki/Media_type
    pub mime_type: String,

    /// Used to identify the codec. Equivalent to [MIME subtype][0].
    ///
    /// [0]: https://en.wikipedia.org/wiki/Media_type#Subtypes
    pub name: String,

    /// [`MediaType`] of this codec. Equivalent to [MIME] top-level type.
    ///
    /// [MIME]: https://en.wikipedia.org/wiki/Media_type
    pub kind: MediaType,

    /// If [`None`], the implementation default is used.
    pub clock_rate: Option<i32>,

    /// Number of audio channels used.
    ///
    /// [`None`] for video codecs.
    ///
    /// If [`None`] for audio, the implementation default is used.
    pub num_channels: Option<i32>,

    /// Codec-specific parameters that must be signaled to the remote party.
    ///
    /// Corresponds to `a=fmtp` parameters in [SDP].
    ///
    /// Contrary to ORTC, these parameters are named using all lowercase
    /// strings. This helps make the mapping to [SDP] simpler, if an application
    /// is using [SDP]. Boolean values are represented by the string "1".
    ///
    /// [SDP]: https://en.wikipedia.org/wiki/Session_Description_Protocol
    pub parameters: Vec<(String, String)>,

    /// Feedback mechanisms to be used for this codec.
    pub feedback: Vec<RtcpFeedback>,
}

impl From<sys::RtpCodecCapability> for RtpCodecCapability {
    fn from(value: sys::RtpCodecCapability) -> Self {
        Self {
            preferred_payload_type: value.preferred_payload_type(),
            scalability_modes: value
                .scalability_modes()
                .into_iter()
                .map(Into::into)
                .collect(),
            mime_type: value.mime_type(),
            name: value.name(),
            kind: value.kind().into(),
            clock_rate: value.clock_rate(),
            num_channels: value.num_channels(),
            parameters: value.parameters().into_iter().collect(),
            feedback: value
                .rtcp_feedback()
                .into_iter()
                .map(Into::into)
                .collect(),
        }
    }
}

/// Changes the preferred [`RtpTransceiver`] codecs to the provided
/// [`Vec`]`<`[`RtpCodecCapability`]`>`.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_codec_preferences(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    codecs: Vec<RtpCodecCapability>,
) {
    transceiver.set_codec_preferences(codecs);
}
