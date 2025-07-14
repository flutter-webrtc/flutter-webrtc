//! [RTCRtpSendParameters][0] definitions.
//!
//! [0]: https://w3.org/TR/webrtc#dom-rtcrtpsendparameters

use std::sync::Arc;

use crate::{
    RtpEncodingParameters, RtpParameters, api::RtcRtpEncodingParameters,
    frb_generated::RustOpaque,
};

/// Representation of [RTCRtpSendParameters][0].
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpsendparameters
pub struct RtcRtpSendParameters {
    /// Sequence containing parameters for sending [RTP] encodings of media.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    pub encodings:
        Vec<(RtcRtpEncodingParameters, RustOpaque<Arc<RtpEncodingParameters>>)>,

    /// Reference to the Rust side [`RtpParameters`].
    pub inner: RustOpaque<Arc<RtpParameters>>,
}

impl From<RtpParameters> for RtcRtpSendParameters {
    fn from(v: RtpParameters) -> Self {
        let encodings = v
            .get_encodings()
            .into_iter()
            .map(|e| {
                (
                    RtcRtpEncodingParameters::from(&e),
                    RustOpaque::new(Arc::new(RtpEncodingParameters::from(e))),
                )
            })
            .collect();

        Self { encodings, inner: RustOpaque::new(Arc::new(v)) }
    }
}
