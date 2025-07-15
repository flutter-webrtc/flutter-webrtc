//! [`PeerConnection`] API.

pub mod events;
pub mod rtc_configuration;
pub mod rtc_session_description;
pub mod video_codec_info;

use std::sync::{Arc, mpsc};

pub use self::{
    events::{
        IceConnectionState, IceGatheringState, PeerConnectionEvent,
        PeerConnectionState, RtcTrackEvent, SignalingState,
    },
    rtc_configuration::{
        BundlePolicy, IceTransportsType, RtcConfiguration, RtcIceServer,
    },
    rtc_session_description::{
        RtcSessionDescription, SdpType, set_local_description,
        set_remote_description,
    },
    video_codec_info::{
        VideoCodec, VideoCodecInfo, video_decoders, video_encoders,
    },
};
use crate::{
    PeerConnection,
    api::{RX_TIMEOUT, WEBRTC},
    frb_generated::{RustOpaque, StreamSink},
};

/// Creates a new [`PeerConnection`] and returns its ID.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn create_peer_connection(
    cb: StreamSink<PeerConnectionEvent>,
    configuration: RtcConfiguration,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().create_peer_connection(&cb, configuration)
}

/// Initiates the creation of an SDP offer for the purpose of starting a new
/// WebRTC connection to a remote peer.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn create_offer(
    peer: RustOpaque<Arc<PeerConnection>>,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) -> anyhow::Result<RtcSessionDescription> {
    let (tx, rx) = mpsc::channel();

    peer.create_offer(voice_activity_detection, ice_restart, use_rtp_mux, tx);

    rx.recv_timeout(RX_TIMEOUT)?
}

/// Creates an SDP answer to an offer received from a remote peer during an
/// offer/answer negotiation of a WebRTC connection.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn create_answer(
    peer: RustOpaque<Arc<PeerConnection>>,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) -> anyhow::Result<RtcSessionDescription> {
    let (tx, rx) = mpsc::channel();

    peer.create_answer(voice_activity_detection, ice_restart, use_rtp_mux, tx);

    rx.recv_timeout(RX_TIMEOUT)?
}

/// Adds the new ICE `candidate` to the given [`PeerConnection`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn add_ice_candidate(
    peer: RustOpaque<Arc<PeerConnection>>,
    candidate: String,
    sdp_mid: String,
    sdp_mline_index: i32,
) -> anyhow::Result<()> {
    let (tx, rx) = mpsc::channel();

    peer.add_ice_candidate(candidate, sdp_mid, sdp_mline_index, tx)?;

    rx.recv_timeout(RX_TIMEOUT)?
}

/// Closes the [`PeerConnection`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn dispose_peer_connection(peer: RustOpaque<Arc<PeerConnection>>) {
    WEBRTC.lock().unwrap().dispose_peer_connection(&peer);
}

/// Tells the [`PeerConnection`] that ICE should be restarted.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn restart_ice(peer: RustOpaque<Arc<PeerConnection>>) {
    peer.restart_ice();
}
