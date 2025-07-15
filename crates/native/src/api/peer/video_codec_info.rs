//! Information about [`VideoCodec`]s.

/// Supported video codecs.
pub enum VideoCodec {
    /// [AV1] AOMedia Video 1.
    ///
    /// [AV1]: https://en.wikipedia.org/wiki/AV1
    AV1,

    /// [H.264] Advanced Video Coding (AVC).
    ///
    /// [H.264]: https://en.wikipedia.org/wiki/Advanced_Video_Coding
    H264,

    /// [H.265] High Efficiency Video Coding (HEVC).
    ///
    /// [H.265]: https://en.wikipedia.org/wiki/High_Efficiency_Video_Coding
    H265,

    /// [VP8] codec.
    ///
    /// [VP8]: https://en.wikipedia.org/wiki/VP8
    VP8,

    /// [VP9] codec.
    ///
    /// [VP9]: https://en.wikipedia.org/wiki/VP9
    VP9,
}

/// [`VideoCodec`] info for encoding/decoding.
pub struct VideoCodecInfo {
    /// Indicator whether hardware acceleration should be used.
    pub is_hardware_accelerated: bool,

    /// [`VideoCodec`] to be used for encoding/decoding.
    pub codec: VideoCodec,
}

/// Returns all [`VideoCodecInfo`]s of the supported video encoders.
#[must_use]
pub fn video_encoders() -> Vec<VideoCodecInfo> {
    // TODO: Implement HW acceleration probing for desktop.
    vec![
        VideoCodecInfo {
            is_hardware_accelerated: false,
            codec: VideoCodec::VP8,
        },
        VideoCodecInfo {
            is_hardware_accelerated: false,
            codec: VideoCodec::VP9,
        },
        VideoCodecInfo {
            is_hardware_accelerated: false,
            codec: VideoCodec::AV1,
        },
    ]
}

/// Returns all [`VideoCodecInfo`]s of the supported video decoders.
#[must_use]
pub fn video_decoders() -> Vec<VideoCodecInfo> {
    // TODO: Implement HW acceleration probing for desktop.
    vec![
        VideoCodecInfo {
            is_hardware_accelerated: false,
            codec: VideoCodec::VP8,
        },
        VideoCodecInfo {
            is_hardware_accelerated: false,
            codec: VideoCodec::VP9,
        },
        VideoCodecInfo {
            is_hardware_accelerated: false,
            codec: VideoCodec::AV1,
        },
    ]
}
