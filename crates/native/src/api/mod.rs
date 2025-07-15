//! API surface and implementation for Flutter.

pub mod capability;
pub mod media_info;
pub mod media_stream_track;
pub mod peer;
pub mod rtc_rtp_encoding_parameters;
pub mod rtc_rtp_send_parameters;
pub mod stats;
pub mod transceiver;

#[cfg(doc)]
use std::sync::mpsc;
use std::{
    sync::{
        Arc, LazyLock, Mutex,
        atomic::{AtomicBool, Ordering},
    },
    time::Duration,
};

use flutter_rust_bridge::for_generated::FLUTTER_RUST_BRIDGE_RUNTIME_VERSION;
use libwebrtc_sys as sys;

pub use self::{
    capability::{
        RtcpFeedback, RtcpFeedbackMessageType, RtcpFeedbackType,
        RtpCapabilities, RtpCodecCapability, RtpHeaderExtensionCapability,
        ScalabilityMode, get_rtp_receiver_capabilities,
        get_rtp_sender_capabilities, set_codec_preferences,
    },
    media_info::{MediaDeviceInfo, MediaDeviceKind, MediaDisplayInfo},
    media_stream_track::{
        AudioProcessingConfig, GetMediaError, GetMediaResult, MediaStreamTrack,
        MediaType, NoiseSuppressionLevel, TrackEvent, TrackState, clone_track,
        create_video_sink, dispose_track, dispose_video_sink,
        get_audio_processing_config, get_media, register_track_observer,
        set_audio_level_observer_enabled, set_track_enabled, track_height,
        track_state, track_width, update_audio_processing,
    },
    peer::{
        BundlePolicy, IceConnectionState, IceGatheringState, IceTransportsType,
        PeerConnectionEvent, PeerConnectionState, RtcConfiguration,
        RtcIceServer, RtcSessionDescription, RtcTrackEvent, SdpType,
        SignalingState, VideoCodec, VideoCodecInfo, add_ice_candidate,
        create_answer, create_offer, create_peer_connection,
        dispose_peer_connection, restart_ice, set_local_description,
        set_remote_description, video_decoders, video_encoders,
    },
    rtc_rtp_encoding_parameters::RtcRtpEncodingParameters,
    rtc_rtp_send_parameters::RtcRtpSendParameters,
    stats::{
        CandidateType, IceCandidateStats, IceRole, Protocol,
        RtcIceCandidateStats, RtcInboundRtpStreamMediaType,
        RtcMediaSourceStatsMediaType, RtcOutboundRtpStreamStatsMediaType,
        RtcStats, RtcStatsIceCandidatePairState, RtcStatsType, get_peer_stats,
    },
    transceiver::{
        RtcRtpTransceiver, RtpTransceiverDirection, RtpTransceiverInit,
        add_transceiver, get_transceiver_direction, get_transceiver_mid,
        get_transceivers, set_transceiver_direction, set_transceiver_recv,
        set_transceiver_send, stop_transceiver,
    },
};
// Re-exporting since it is used in the generated code.
pub use crate::{
    PeerConnection, RtpEncodingParameters, RtpParameters, RtpTransceiver,
    renderer::TextureEvent,
};
use crate::{
    Webrtc, devices,
    frb::{FrbHandler, new_frb_handler},
    frb_generated::{
        FLUTTER_RUST_BRIDGE_CODEGEN_VERSION, RustOpaque, StreamSink,
    },
};

/// Custom [`Handler`] for executing Rust code called from Dart.
///
/// [`Handler`]: flutter_rust_bridge::Handler
// Must be named `FLUTTER_RUST_BRIDGE_HANDLER` for `flutter_rust_bridge` to
// discover it.
pub static FLUTTER_RUST_BRIDGE_HANDLER: LazyLock<FrbHandler> =
    LazyLock::new(|| {
        const {
            if !crate::str_eq(
                FLUTTER_RUST_BRIDGE_CODEGEN_VERSION,
                FLUTTER_RUST_BRIDGE_RUNTIME_VERSION,
            ) {
                panic!("`flutter_rust_bridge` versions mismatch");
            }
        }

        new_frb_handler()
    });

pub(crate) static WEBRTC: LazyLock<Mutex<Webrtc>> =
    LazyLock::new(|| Mutex::new(Webrtc::new().unwrap()));

/// Timeout for [`mpsc::Receiver::recv_timeout()`] operations.
pub static RX_TIMEOUT: Duration = Duration::from_secs(5);

/// Indicator whether application is configured to use fake media devices.
static FAKE_MEDIA: AtomicBool = AtomicBool::new(false);

/// [MediaStreamTrack.kind][1] representation.
///
/// [1]: https://w3.org/TR/mediacapture-streams#dfn-kind
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackKind {
    /// Audio track.
    Audio,

    /// Video track.
    Video,
}

impl From<sys::TrackKind> for TrackKind {
    fn from(kind: sys::TrackKind) -> Self {
        match kind {
            sys::TrackKind::Audio => Self::Audio,
            sys::TrackKind::Video => Self::Video,
        }
    }
}

/// [MediaStreamConstraints], used to instruct what sort of
/// [`MediaStreamTrack`]s to return by the [`Webrtc::get_media()`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamconstraints
#[derive(Debug)]
pub struct MediaStreamConstraints {
    /// Specifies the nature and settings of the audio [`MediaStreamTrack`].
    pub audio: Option<AudioConstraints>,

    /// Specifies the nature and settings of the video [`MediaStreamTrack`].
    pub video: Option<VideoConstraints>,
}

/// Nature and settings of the video [`MediaStreamTrack`] returned by
/// [`Webrtc::get_media()`].
#[derive(Debug)]
pub struct VideoConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// The first device will be chosen if an empty [`String`] is provided.
    pub device_id: Option<String>,

    /// Width in pixels.
    pub width: u32,

    /// Height in pixels.
    pub height: u32,

    /// Exact frame rate (frames per second).
    pub frame_rate: u32,

    /// Indicator whether the request video track should be acquired via screen
    /// capturing.
    pub is_display: bool,
}

/// Nature and settings of the audio [`MediaStreamTrack`] returned by
/// [`Webrtc::get_media()`].
#[derive(Debug)]
pub struct AudioConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// First device will be chosen if an empty [`String`] is provided.
    pub device_id: Option<String>,

    /// Audio processing configuration constraints of the [`MediaStreamTrack`].
    pub processing: AudioProcessingConstraints,
}

/// Constraints of an [`AudioProcessingConfig`].
#[derive(Debug, Default)]
pub struct AudioProcessingConstraints {
    /// Indicator whether the audio volume level should be automatically tuned
    /// to maintain a steady overall volume level.
    pub auto_gain_control: Option<bool>,

    /// Indicator whether a high-pass filter should be enabled to eliminate
    /// low-frequency noise.
    pub high_pass_filter: Option<bool>,

    /// Indicator whether noise suppression should be enabled to reduce
    /// background sounds.
    pub noise_suppression: Option<bool>,

    /// Level of aggressiveness for noise suppression.
    pub noise_suppression_level: Option<NoiseSuppressionLevel>,

    /// Indicator whether echo cancellation should be enabled to prevent
    /// feedback.
    pub echo_cancellation: Option<bool>,
}

/// Configures media acquisition to use fake devices instead of actual camera
/// and microphone.
pub fn enable_fake_media() {
    FAKE_MEDIA.store(true, Ordering::Release);
}

/// Indicates whether application is configured to use fake media devices.
pub fn is_fake_media() -> bool {
    FAKE_MEDIA.load(Ordering::Acquire)
}

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
pub fn enumerate_devices() -> anyhow::Result<Vec<MediaDeviceInfo>> {
    WEBRTC.lock().unwrap().enumerate_devices()
}

/// Returns a list of all available displays that can be used for screen
/// capturing.
#[must_use]
pub fn enumerate_displays() -> Vec<MediaDisplayInfo> {
    devices::enumerate_displays()
}

/// Replaces the specified [`AudioTrack`] (or [`VideoTrack`]) on the
/// [`sys::RtpTransceiverInterface`]'s `sender`.
///
/// [`AudioTrack`]: crate::AudioTrack
/// [`VideoTrack`]: crate::VideoTrack
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn sender_replace_track(
    peer: RustOpaque<Arc<PeerConnection>>,
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    track_id: Option<String>,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().sender_replace_track(&peer, &transceiver, track_id)
}

/// Returns [`RtpParameters`] from the provided [`RtpTransceiver`]'s `sender`.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn sender_get_parameters(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> RtcRtpSendParameters {
    RtcRtpSendParameters::from(transceiver.sender_get_parameters())
}

/// Sets [`RtpParameters`] into the provided [`RtpTransceiver`]'s `sender`.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn sender_set_parameters(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    params: RtcRtpSendParameters,
) -> anyhow::Result<()> {
    transceiver.sender_set_parameters(params)
}

/// Sets the specified `audio playout` device.
pub fn set_audio_playout_device(device_id: String) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_audio_playout_device(device_id)
}

/// Indicates whether the microphone is available to set volume.
pub fn microphone_volume_is_available() -> anyhow::Result<bool> {
    WEBRTC.lock().unwrap().microphone_volume_is_available()
}

/// Sets the microphone system volume according to the specified `level` in
/// percents.
///
/// Valid values range is `[0; 100]`.
pub fn set_microphone_volume(level: u8) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_microphone_volume(level)
}

/// Returns the current level of the microphone volume in `[0; 100]` range.
pub fn microphone_volume() -> anyhow::Result<u32> {
    WEBRTC.lock().unwrap().microphone_volume()
}

/// Sets the provided `OnDeviceChangeCallback` as the callback to be called
/// whenever a set of available media devices changes.
///
/// Only one callback can be set at a time, so the previous one will be dropped,
/// if any.
pub fn set_on_device_changed(cb: StreamSink<()>) {
    WEBRTC.lock().unwrap().set_on_device_changed(cb);
}
