//! API surface and implementation for Flutter.

pub mod capability;
pub mod media;
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
    sync::{Arc, LazyLock, Mutex},
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
    media::{
        AudioConstraints, AudioProcessingConstraints, MediaStreamConstraints,
        VideoConstraints, enable_fake_media, enumerate_devices,
        enumerate_displays, is_fake_media, microphone_volume,
        microphone_volume_is_available, set_audio_playout_device,
        set_microphone_volume, set_on_device_changed,
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
    Webrtc,
    frb::{FrbHandler, new_frb_handler},
    frb_generated::{FLUTTER_RUST_BRIDGE_CODEGEN_VERSION, RustOpaque},
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
