//! [RTCRtpEncodingParameters][0] definitions.
//!
//! [0]: https://w3.org/TR/webrtc#rtcrtpencodingparameters

use libwebrtc_sys as sys;

/// Representation of [RTCRtpEncodingParameters][0].
///
/// [0]: https://w3.org/TR/webrtc#rtcrtpencodingparameters
pub struct RtcRtpEncodingParameters {
    /// [RTP stream ID (RID)][0] to be sent using the RID header extension.
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodingparameters-rid
    pub rid: String,

    /// Indicator whether the described [`RtcRtpEncodingParameters`] are
    /// currently actively being used.
    pub active: bool,

    /// Maximum number of bits per second to allow for these
    /// [`RtcRtpEncodingParameters`].
    pub max_bitrate: Option<i32>,

    /// Maximum number of frames per second to allow for these
    /// [`RtcRtpEncodingParameters`].
    pub max_framerate: Option<f64>,

    /// Factor for scaling down the video with these
    /// [`RtcRtpEncodingParameters`].
    pub scale_resolution_down_by: Option<f64>,

    /// Scalability mode describing layers within the media stream.
    pub scalability_mode: Option<String>,
}

impl From<&sys::RtpEncodingParameters> for RtcRtpEncodingParameters {
    fn from(sys: &sys::RtpEncodingParameters) -> Self {
        Self {
            rid: sys.rid(),
            active: sys.active(),
            max_bitrate: sys.max_bitrate(),
            max_framerate: sys.max_framerate(),
            scale_resolution_down_by: sys.scale_resolution_down_by(),
            scalability_mode: sys.scalability_mode(),
        }
    }
}
