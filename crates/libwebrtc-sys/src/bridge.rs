use std::fmt;

use anyhow::anyhow;
use cxx::{CxxString, CxxVector, UniquePtr};

use crate::{
    AddIceCandidateCallback, CreateSdpCallback, IceCandidateInterface,
    OnFrameCallback, PeerConnectionEventsHandler, RtpReceiverInterface,
    RtpTransceiverInterface, SetDescriptionCallback, TrackEventCallback,
};

/// [`CreateSdpCallback`] transferable to the C++ side.
type DynCreateSdpCallback = Box<dyn CreateSdpCallback>;

/// [`SetDescriptionCallback`] transferable to the C++ side.
type DynSetDescriptionCallback = Box<dyn SetDescriptionCallback>;

/// [`OnFrameCallback`] transferable to the C++ side.
type DynOnFrameCallback = Box<dyn OnFrameCallback>;

/// [`PeerConnectionEventsHandler`] transferable to the C++ side.
type DynPeerConnectionEventsHandler = Box<dyn PeerConnectionEventsHandler>;

/// [`AddIceCandidateCallback`] transferable to the C++ side.
type DynAddIceCandidateCallback = Box<dyn AddIceCandidateCallback>;

/// [`TrackEventCallback`] transferable to the C++ side.
type DynTrackEventCallback = Box<dyn TrackEventCallback>;

#[allow(
    clippy::expl_impl_clone_on_copy,
    clippy::items_after_statements,
    clippy::ptr_as_ptr,
    clippy::trait_duplication_in_bounds
)]
#[cxx::bridge(namespace = "bridge")]
pub(crate) mod webrtc {
    /// Wrapper for a `(String, String)` tuple transferable via FFI boundaries.
    pub struct StringPair {
        first: String,
        second: String,
    }
    // TODO: Remove once `cxx` crate allows using pointers to opaque types in
    //       vectors: https://github.com/dtolnay/cxx/issues/741
    /// Wrapper for an [`RtpEncodingParameters`] usable in Rust/C++ vectors.
    pub struct RtpEncodingParametersContainer {
        ptr: UniquePtr<RtpEncodingParameters>,
    }

    // TODO: Remove once `cxx` crate allows using pointers to opaque types in
    //       vectors: https://github.com/dtolnay/cxx/issues/741
    /// Wrapper for an [`RtpExtension`] usable in Rust/C++ vectors.
    pub struct RtpExtensionContainer {
        ptr: UniquePtr<RtpExtension>,
    }

    // TODO: Remove once `cxx` crate allows using pointers to opaque types in
    //       vectors: https://github.com/dtolnay/cxx/issues/741
    /// Wrapper for an [`RtpCodecParameters`] usable in Rust/C++ vectors.
    pub struct RtpCodecParametersContainer {
        ptr: UniquePtr<RtpCodecParameters>,
    }

    /// [MediaStreamTrackState][0] representation.
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrackstate
    #[rustfmt::skip]
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum TrackState {
        /// [MediaStreamTrackState.live][0] representation.
        ///
        /// [0]: https://tinyurl.com/w3mcs#idl-def-MediaStreamTrackState.live
        kLive,

        /// [MediaStreamTrackState.ended][0] representation.
        ///
        /// [0]: https://tinyurl.com/w3mcs#idl-def-MediaStreamTrackState.ended
        kEnded,
    }

    /// Possible kinds of audio devices implementation.
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum AudioLayer {
        kPlatformDefaultAudio = 0,
        kWindowsCoreAudio,
        kWindowsCoreAudio2,
        kLinuxAlsaAudio,
        kLinuxPulseAudio,
        kAndroidJavaAudio,
        kAndroidOpenSLESAudio,
        kAndroidJavaInputAndOpenSLESOutputAudio,
        kAndroidAAudioAudio,
        kAndroidJavaInputAndAAudioOutputAudio,
        kDummyAudio,
    }

    /// [RTCSdpType] representation.
    ///
    /// [RTCSdpType]: https://w3.org/TR/webrtc#dom-rtcsdptype
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum SdpType {
        /// [RTCSdpType.offer][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-offer
        kOffer,

        /// [RTCSdpType.pranswer][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-pranswer
        kPrAnswer,

        /// [RTCSdpType.answer][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-answer
        kAnswer,

        /// [RTCSdpType.rollback][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-rollback
        kRollback,
    }

    /// Possible kinds of an [`RtpTransceiverInterface`].
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum MediaType {
        MEDIA_TYPE_AUDIO = 0,
        MEDIA_TYPE_VIDEO,
        MEDIA_TYPE_DATA,
        MEDIA_TYPE_UNSUPPORTED,
    }

    /// [RTCRtpTransceiverDirection][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiverdirection
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum RtpTransceiverDirection {
        /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will offer to send RTP,
        /// and will send RTP if the remote peer accepts.
        /// The [`RTCRtpTransceiver`]'s [RTCRtpReceiver] will offer to receive
        /// RTP, and will receive RTP if the remote peer accepts.
        ///
        /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
        /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
        kSendRecv = 0,

        /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will offer to send RTP,
        /// and will send RTP if the remote peer accepts.
        /// The [`RTCRtpTransceiver`]'s [RTCRtpReceiver] will not offer
        /// to receive RTP, and will not receive RTP.
        ///
        /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
        /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
        kSendOnly,

        /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will not offer to send
        /// RTP, and will not send RTP. The [`RTCRtpTransceiver`]'s
        /// [RTCRtpReceiver] will offer to receive RTP, and will receive RTP
        /// if the remote peer accepts.
        ///
        /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
        /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
        kRecvOnly,

        /// The [`RTCRtpTransceiver`]'s [RTCRtpSender] will not offer to send
        /// RTP, and will not send RTP. The [`RTCRtpTransceiver`]'s
        /// [RTCRtpReceiver] will not offer to receive RTP, and will not
        /// receive RTP.
        ///
        /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
        /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
        kInactive,

        /// The [`RTCRtpTransceiver`] will neither send nor receive RTP. It will
        /// generate a zero port in the offer. In answers, its [RTCRtpSender]
        /// will not offer to send RTP, and its [RTCRtpReceiver] will not offer
        /// to receive RTP. This is a terminal state.
        ///
        /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
        /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
        kStopped,
    }

    /// Possible variants of a [`VideoFrame`]'s rotation.
    #[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum VideoRotation {
        kVideoRotation_0 = 0,
        kVideoRotation_90 = 90,
        kVideoRotation_180 = 180,
        kVideoRotation_270 = 270,
    }

    // TODO: Remove once `cxx` crate allows using pointers to opaque types in
    //       vectors: https://github.com/dtolnay/cxx/issues/741
    /// Wrapper for an [`RtpTransceiverInterface`] that can be used in Rust/C++
    /// vectors.
    struct TransceiverContainer {
        /// Wrapped [`RtpTransceiverInterface`].
        pub ptr: UniquePtr<RtpTransceiverInterface>,
    }

    /// [RTCSignalingState] representation.
    ///
    /// [RTCSignalingState]: https://w3.org/TR/webrtc#state-definitions
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum SignalingState {
        /// [RTCSignalingState.stable][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcsignalingstate-stable
        kStable,

        /// [RTCSignalingState.have-local-offer][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcsignalingstate-have-local-offer
        kHaveLocalOffer,

        /// [RTCSignalingState.have-local-pranswer][1] representation.
        ///
        /// [1]: https://tinyurl.com/have-local-pranswer
        kHaveLocalPrAnswer,

        /// [RTCSignalingState.have-remote-offer][1] representation.
        ///
        /// [1]: https://tinyurl.com/have-remote-offer
        kHaveRemoteOffer,

        /// [RTCSignalingState.have-remote-pranswer][1] representation.
        ///
        /// [1]: https://tinyurl.com/have-remote-pranswer
        kHaveRemotePrAnswer,

        /// [RTCSignalingState.closed][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcsignalingstate-closed
        kClosed,
    }

    /// [RTCIceGatheringState][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum IceGatheringState {
        /// [RTCIceGatheringState.new][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate-new
        kIceGatheringNew,

        /// [RTCIceGatheringState.gathering][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate-gathering
        kIceGatheringGathering,

        /// [RTCIceGatheringState.complete][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicegatheringstate-complete
        kIceGatheringComplete,
    }

    /// [RTCPeerConnectionState][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnectionstate
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum PeerConnectionState {
        /// [RTCPeerConnectionState.new][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnectionstate-new
        kNew,

        /// [RTCPeerConnectionState.connecting][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnectionstate-connecting
        kConnecting,

        /// [RTCPeerConnectionState.connected][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnectionstate-connected
        kConnected,

        /// [RTCPeerConnectionState.disconnected][1] representation.
        ///
        /// [1]: https://tinyurl.com/connectionstate-disconnected
        kDisconnected,

        /// [RTCPeerConnectionState.failed][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnectionstate-failed
        kFailed,

        /// [RTCPeerConnectionState.closed][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnectionstate-closed
        kClosed,
    }

    /// [RTCIceConnectionState][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum IceConnectionState {
        /// [RTCIceConnectionState.new][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-new
        kIceConnectionNew,

        /// [RTCIceConnectionState.checking][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-checking
        kIceConnectionChecking,

        /// [RTCIceConnectionState.connected][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-connected
        kIceConnectionConnected,

        /// [RTCIceConnectionState.completed][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-completed
        kIceConnectionCompleted,

        /// [RTCIceConnectionState.failed][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-failed
        kIceConnectionFailed,

        /// [RTCIceConnectionState.disconnected][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-disconnected
        kIceConnectionDisconnected,

        /// [RTCIceConnectionState.closed][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtciceconnectionstate-closed
        kIceConnectionClosed,

        /// Non-spec-compliant variant.
        ///
        /// [`libwertc` states that it's unreachable][1].
        ///
        /// [1]: https://tinyurl.com/kIceConnectionMax-unreachable
        kIceConnectionMax,
    }

    /// [RTCIceTransportPolicy][1] representation.
    ///
    /// It defines an ICE candidate policy the [ICE Agent][2] uses to surface
    /// the permitted candidates to the application. Only these candidates will
    /// be used for connectivity checks.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy
    /// [2]: https://w3.org/TR/webrtc#dfn-ice-agent
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum IceTransportsType {
        /// Non-spec-compliant variant.
        kNone,

        /// [RTCIceTransportPolicy.relay][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy-relay
        kRelay,

        /// ICE Agent can't use `typ host` candidates when this value is
        /// specified.
        ///
        /// Non-spec-compliant variant.
        kNoHost,

        /// [RTCIceTransportPolicy.all][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy-all
        kAll,
    }

    /// [RTCBundlePolicy][1] representation.
    ///
    /// Affects which media tracks are negotiated if the remote endpoint is not
    /// bundle-aware, and what ICE candidates are gathered. If the remote
    /// endpoint is bundle-aware, all media tracks and data channels are bundled
    /// onto the same transport.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy
    #[derive(Debug, Eq, Hash, PartialEq)]
    #[repr(i32)]
    pub enum BundlePolicy {
        /// [RTCBundlePolicy.balanced][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-balanced
        kBundlePolicyBalanced,

        /// [RTCBundlePolicy.max-bundle][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-bundle
        kBundlePolicyMaxBundle,

        /// [RTCBundlePolicy.max-compat][1] representation.
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-compat
        kBundlePolicyMaxCompat,
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        pub type PeerConnectionFactoryInterface;
        pub type TaskQueueFactory;
        pub type Thread;

        /// Creates a default [`TaskQueueFactory`] based on the current
        /// platform.
        #[namespace = "webrtc"]
        #[cxx_name = "CreateDefaultTaskQueueFactory"]
        pub fn create_default_task_queue_factory()
            -> UniquePtr<TaskQueueFactory>;

        /// Creates a new [`Thread`].
        pub fn create_thread() -> UniquePtr<Thread>;

        /// Creates a new [`Thread`] with an attached socket server.
        pub fn create_thread_with_socket_server() -> UniquePtr<Thread>;

        /// Starts the current [`Thread`].
        #[cxx_name = "Start"]
        pub fn start_thread(self: Pin<&mut Thread>) -> bool;

        /// Creates a new [`PeerConnectionFactoryInterface`].
        pub fn create_peer_connection_factory(
            network_thread: &UniquePtr<Thread>,
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
            default_adm: &UniquePtr<AudioDeviceModule>,
        ) -> UniquePtr<PeerConnectionFactoryInterface>;
    }

    unsafe extern "C++" {
        pub type AudioDeviceModule;
        pub type AudioLayer;

        /// Creates a new [`AudioDeviceModule`] for the given [`AudioLayer`].
        pub fn create_audio_device_module(
            worker_thread: Pin<&mut Thread>,
            audio_layer: AudioLayer,
            task_queue_factory: Pin<&mut TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;

        /// Creates a new fake [`AudioDeviceModule`], that will not try to
        /// access real media devices, but will generate pulsed noise.
        pub fn create_fake_audio_device_module(
            task_queue_factory: Pin<&mut TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;

        /// Initializes the given [`AudioDeviceModule`].
        pub fn init_audio_device_module(
            audio_device_module: &AudioDeviceModule,
        ) -> i32;

        /// Initializes the microphone in the [`AudioDeviceModule`].
        pub fn init_microphone(audio_device_module: &AudioDeviceModule) -> i32;

        /// Indicates whether the microphone of the [`AudioDeviceModule`] is
        /// initialized.
        pub fn microphone_is_initialized(
            audio_device_module: &AudioDeviceModule,
        ) -> bool;

        /// Sets the volume of the initialized microphone.
        pub fn set_microphone_volume(
            audio_device_module: &AudioDeviceModule,
            volume: u32,
        ) -> i32;

        /// Indicates whether the microphone is available to set volume.
        pub fn microphone_volume_is_available(
            audio_device_module: &AudioDeviceModule,
            is_available: &mut bool,
        ) -> i32;

        /// Returns the lowest possible level of the microphone volume.
        pub fn min_microphone_volume(
            audio_device_module: &AudioDeviceModule,
            volume: &mut u32,
        ) -> i32;

        /// Returns the highest possible level of the microphone volume.
        pub fn max_microphone_volume(
            audio_device_module: &AudioDeviceModule,
            volume: &mut u32,
        ) -> i32;

        /// Returns the current level of the microphone volume.
        pub fn microphone_volume(
            audio_device_module: &AudioDeviceModule,
            volume: &mut u32,
        ) -> i32;

        /// Returns count of available audio playout devices.
        pub fn playout_devices(audio_device_module: &AudioDeviceModule) -> i16;

        /// Returns count of available audio recording devices.
        pub fn recording_devices(
            audio_device_module: &AudioDeviceModule,
        ) -> i16;

        /// Writes device info to the provided `name` and `id` for the given
        /// audio playout device `index`.
        pub fn playout_device_name(
            audio_device_module: &AudioDeviceModule,
            index: i16,
            name: &mut String,
            id: &mut String,
        ) -> i32;

        /// Writes device info to the provided `name` and `id` for the given
        /// audio recording device `index`.
        pub fn recording_device_name(
            audio_device_module: &AudioDeviceModule,
            index: i16,
            name: &mut String,
            id: &mut String,
        ) -> i32;

        /// Specifies which microphone to use for recording audio using an index
        /// retrieved by the corresponding enumeration method which is
        /// [`AudiDeviceModule::RecordingDeviceName`].
        pub fn set_audio_recording_device(
            audio_device_module: &AudioDeviceModule,
            index: u16,
        ) -> i32;

        /// Specifies which speaker to use for playing out audio using an index
        /// retrieved by the corresponding enumeration method
        /// [`AudiDeviceModule::PlayoutDeviceName`].
        pub fn set_audio_playout_device(
            audio_device_module: &AudioDeviceModule,
            index: u16,
        ) -> i32;
    }

    unsafe extern "C++" {
        pub type VideoDeviceInfo;

        /// Creates a new [`VideoDeviceInfo`].
        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;

        /// Returns count of a video recording devices.
        #[namespace = "webrtc"]
        #[cxx_name = "NumberOfDevices"]
        pub fn number_of_video_devices(self: Pin<&mut VideoDeviceInfo>) -> u32;

        /// Writes device info to the provided `name` and `id` for the given
        /// video device `index`.
        pub fn video_device_name(
            device_info: Pin<&mut VideoDeviceInfo>,
            index: u32,
            name: &mut String,
            id: &mut String,
        ) -> i32;
    }

    extern "Rust" {
        pub type DynAddIceCandidateCallback;

        /// Calls the success [`DynAddIceCandidateCallback`].
        pub fn add_ice_candidate_success(
            mut cb: Box<DynAddIceCandidateCallback>,
        );

        /// Calls the fail [`DynAddIceCandidateCallback`].
        pub fn add_ice_candidate_fail(
            mut cb: Box<DynAddIceCandidateCallback>,
            error: &CxxString,
        );
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/media_stream_track_interface.h");

        pub type MediaStreamTrackInterface;

        /// Returns the `kind` of the provided [`MediaStreamTrackInterface`].
        #[must_use]
        pub fn media_stream_track_kind(
            track: &MediaStreamTrackInterface,
        ) -> UniquePtr<CxxString>;

        /// Returns the `id` of the provided [`MediaStreamTrackInterface`].
        #[must_use]
        pub fn media_stream_track_id(
            track: &MediaStreamTrackInterface,
        ) -> UniquePtr<CxxString>;

        /// Returns the `state` of the provided [`MediaStreamTrackInterface`].
        #[must_use]
        pub fn media_stream_track_state(
            track: &MediaStreamTrackInterface,
        ) -> TrackState;

        /// Returns the `enabled` property of the provided
        /// [`MediaStreamTrackInterface`].
        #[must_use]
        pub fn media_stream_track_enabled(
            track: &MediaStreamTrackInterface,
        ) -> bool;
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/rtp_codec_parameters.h");

        #[namespace = "webrtc"]
        pub type RtpCodecParameters;

        /// Returns the `name` of the provided [`RtpCodecParameters`].
        #[must_use]
        pub fn rtp_codec_parameters_name(
            codec: &RtpCodecParameters,
        ) -> UniquePtr<CxxString>;

        /// Returns the `payload_type` of the provided [`RtpCodecParameters`].
        #[must_use]
        pub fn rtp_codec_parameters_payload_type(
            codec: &RtpCodecParameters,
        ) -> i32;

        /// Returns the `clock_rate` of the provided [`RtpCodecParameters`].
        ///
        /// [`Result::Err`] means [`None`].
        pub fn rtp_codec_parameters_clock_rate(
            codec: &RtpCodecParameters,
        ) -> Result<i32>;

        /// Returns the `num_channels` of the provided [`RtpCodecParameters`].
        ///
        /// [`Result::Err`] means [`None`].
        pub fn rtp_codec_parameters_num_channels(
            codec: &RtpCodecParameters,
        ) -> Result<i32>;

        /// Returns the `parameters` of the provided [`RtpCodecParameters`].
        #[must_use]
        pub fn rtp_codec_parameters_parameters(
            codec: &RtpCodecParameters,
        ) -> UniquePtr<CxxVector<StringPair>>;

        /// Returns the [`MediaType`] of the provided [`RtpCodecParameters`].
        #[must_use]
        pub fn rtp_codec_parameters_kind(
            codec: &RtpCodecParameters,
        ) -> MediaType;
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/rtp_receiver_interface.h");

        pub type RtpReceiverInterface;

        /// Returns the [`MediaStreamTrackInterface`] of the provided
        /// [`RtpReceiverInterface`].
        #[must_use]
        pub fn rtp_receiver_track(
            receiver: &RtpReceiverInterface,
        ) -> UniquePtr<MediaStreamTrackInterface>;

        /// Returns the [`RtpParameters`] of the provided
        /// [`RtpReceiverInterface`].
        #[must_use]
        pub fn rtp_receiver_parameters(
            receiver: &RtpReceiverInterface,
        ) -> UniquePtr<RtpParameters>;
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/rtp_sender_interface.h");

        pub type RtpSenderInterface;

        /// Replaces the track currently being used as the `sender`'s source
        /// with a new [`VideoTrackInterface`].
        pub fn replace_sender_video_track(
            sender: &RtpSenderInterface,
            track: &UniquePtr<VideoTrackInterface>
        ) -> bool;

        /// Replaces the track currently being used as the `sender`'s source
        /// with a new [`AudioTrackInterface`].
        pub fn replace_sender_audio_track(
            sender: &RtpSenderInterface,
            track: &UniquePtr<AudioTrackInterface>
        ) -> bool;
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/rtp_encoding_parameters.h");

        #[namespace = "webrtc"]
        pub type RtpEncodingParameters;

        /// Returns the `active` of the provided [`RtpEncodingParameters`].
        #[must_use]
        pub fn rtp_encoding_parameters_active(
            encoding: &RtpEncodingParameters,
        ) -> bool;

        /// Returns the `maxBitrate` of the provided [`RtpEncodingParameters`].
        ///
        /// [`Result::Err`] means [`None`].
        pub fn rtp_encoding_parameters_maxBitrate(
            encoding: &RtpEncodingParameters,
        ) -> Result<i32>;

        /// Returns the `minBitrate` of the provided [`RtpEncodingParameters`].
        ///
        /// [`Result::Err`] means [`None`].
        pub fn rtp_encoding_parameters_minBitrate(
            encoding: &RtpEncodingParameters,
        ) -> Result<i32>;

        /// Returns the `maxFramerate` of the provided
        /// [`RtpEncodingParameters`].
        ///
        /// [`Result::Err`] means [`None`].
        pub fn rtp_encoding_parameters_maxFramerate(
            encoding: &RtpEncodingParameters,
        ) -> Result<f64>;

        /// Returns the `ssrc` of the provided [`RtpEncodingParameters`].
        ///
        /// [`Result::Err`] means [`None`].
        pub fn rtp_encoding_parameters_ssrc(
            encoding: &RtpEncodingParameters,
        ) -> Result<i64>;

        /// Returns the `scale_resolution_down_by` of the provided
        /// [`RtpEncodingParameters`].
        ///
        /// [`Result::Err`] means [`None`].
        pub fn rtp_encoding_parameters_scale_resolution_down_by(
            encoding: &RtpEncodingParameters,
        ) -> Result<f64>;
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/rtp_parameters.h");

        #[namespace = "webrtc"]
        pub type RtpParameters;

        /// Returns the `transaction_id` of the provided [`RtpParameters`].
        #[must_use]
        pub fn rtp_parameters_transaction_id(
            parameters: &RtpParameters,
        ) -> UniquePtr<CxxString>;

        /// Returns the `mid` of the provided [`RtpParameters`].
        #[must_use]
        pub fn rtp_parameters_mid(
            parameters: &RtpParameters,
        ) -> UniquePtr<CxxString>;

        /// Returns the [`RtpCodecParameters`]s of the provided
        /// [`RtpParameters`].
        #[must_use]
        pub fn rtp_parameters_codecs(
            parameters: &RtpParameters,
        ) -> Vec<RtpCodecParametersContainer>;

        /// Returns the [`RtpExtension`]s of the provided [`RtpParameters`].
        #[must_use]
        pub fn rtp_parameters_header_extensions(
            parameters: &RtpParameters,
        ) -> Vec<RtpExtensionContainer>;

        /// Returns the [`RtpEncodingParameters`]s of the provided
        /// [`RtpParameters`].
        #[must_use]
        pub fn rtp_parameters_encodings(
            parameters: &RtpParameters,
        ) -> Vec<RtpEncodingParametersContainer>;

        /// Returns the [`RtcpParameters`] of the provided [`RtpParameters`].
        #[must_use]
        pub fn rtp_parameters_rtcp(
            parameters: &RtpParameters,
        ) -> UniquePtr<RtcpParameters>;
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        #[namespace = "cricket"]
        pub type Candidate;
        #[namespace = "cricket"]
        pub type CandidatePairChangeEvent;
        pub type IceCandidateInterface;
        pub type MediaType;
        pub type TrackState;
        #[namespace = "cricket"]
        pub type CandidatePair;
        pub type CreateSessionDescriptionObserver;
        pub type IceConnectionState;
        pub type IceGatheringState;
        pub type PeerConnectionDependencies;
        pub type PeerConnectionInterface;
        pub type PeerConnectionObserver;
        pub type PeerConnectionState;
        pub type RTCConfiguration;
        pub type IceTransportsType;
        pub type BundlePolicy;
        pub type IceServer;
        pub type RTCOfferAnswerOptions;
        pub type RtpTransceiverDirection;
        pub type RtpTransceiverInterface;
        pub type SdpType;
        pub type SessionDescriptionInterface;
        pub type SetLocalDescriptionObserver;
        pub type SetRemoteDescriptionObserver;
        pub type SignalingState;

        /// Creates a default [`RTCConfiguration`].
        pub fn create_default_rtc_configuration()
            -> UniquePtr<RTCConfiguration>;

        /// Changes the configured [`IceTransportsType`] of the provided
        /// [`RTCConfiguration`].
        pub fn set_rtc_configuration_ice_transport_type(
            config: Pin<&mut RTCConfiguration>,
            transport_type: IceTransportsType
        );

        /// Changes the configured [`BundlePolicy`] of the provided
        /// [`RTCConfiguration`].
        pub fn set_rtc_configuration_bundle_policy(
            config: Pin<&mut RTCConfiguration>,
            bundle_policy: BundlePolicy
        );

        /// Adds an [`IceServer`] to the provided [`RTCConfiguration`].
        pub fn add_rtc_configuration_server(
            config: Pin<&mut RTCConfiguration>,
            server: Pin<&mut IceServer>
        );

        /// Creates a new empty [`IceServer`].
        pub fn create_ice_server() -> UniquePtr<IceServer>;

        /// Adds the spcified `url` to the provided [`IceServer`].
        pub fn add_ice_server_url(
            server: Pin<&mut IceServer>,
            url: String
        );

        /// Sets the credentials for the provided [`IceServer`].
        pub fn set_ice_server_credentials(
            server: Pin<&mut IceServer>,
            username: String,
            password: String
        );

        /// Creates a new [`PeerConnectionInterface`].
        ///
        /// If creation fails then an error will be written to the provided
        /// `error` and the returned [`UniquePtr`] will be `null`.
        pub fn create_peer_connection_or_error(
            peer_connection_factory: Pin<&mut PeerConnectionFactoryInterface>,
            conf: &RTCConfiguration,
            deps: UniquePtr<PeerConnectionDependencies>,
            error: &mut String,
        ) -> UniquePtr<PeerConnectionInterface>;

        /// Creates a new [`PeerConnectionObserver`].
        pub fn create_peer_connection_observer(
            cb: Box<DynPeerConnectionEventsHandler>,
        ) -> UniquePtr<PeerConnectionObserver>;

        /// Creates a [`PeerConnectionDependencies`] from the provided
        /// [`PeerConnectionObserver`].
        pub fn create_peer_connection_dependencies(
            observer: &UniquePtr<PeerConnectionObserver>,
        ) -> UniquePtr<PeerConnectionDependencies>;

        /// Creates a default [`RTCOfferAnswerOptions`].
        pub fn create_default_rtc_offer_answer_options(
        ) -> UniquePtr<RTCOfferAnswerOptions>;

        /// Creates a new [`RTCOfferAnswerOptions`] from the provided options.
        pub fn create_rtc_offer_answer_options(
            offer_to_receive_video: i32,
            offer_to_receive_audio: i32,
            voice_activity_detection: bool,
            ice_restart: bool,
            use_rtp_mux: bool,
        ) -> UniquePtr<RTCOfferAnswerOptions>;

        /// Creates a new [`CreateSessionDescriptionObserver`] from the
        /// provided [`DynCreateSdpCallback`].
        pub fn create_create_session_observer(
            cb: Box<DynCreateSdpCallback>,
        ) -> UniquePtr<CreateSessionDescriptionObserver>;

        /// Creates a new [`SetLocalDescriptionObserver`] from the provided
        /// [`DynSetDescriptionCallback`].
        pub fn create_set_local_description_observer(
            cb: Box<DynSetDescriptionCallback>,
        ) -> UniquePtr<SetLocalDescriptionObserver>;

        /// Creates a new [`SetRemoteDescriptionObserver`] from the provided
        /// [`DynSetDescriptionCallback`].
        pub fn create_set_remote_description_observer(
            cb: Box<DynSetDescriptionCallback>,
        ) -> UniquePtr<SetRemoteDescriptionObserver>;

        /// Calls the [RTCPeerConnection.createOffer()][1] on the provided
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection-createoffer
        pub fn create_offer(
            peer: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: UniquePtr<CreateSessionDescriptionObserver>,
        );

        /// Calls the [RTCPeerConnection.createAnswer()][1] on the provided
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection-createanswer
        pub fn create_answer(
            peer: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: UniquePtr<CreateSessionDescriptionObserver>,
        );

        /// Calls the [RTCPeerConnection.setLocalDescription()][1] on the
        /// provided [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-peerconnection-setlocaldescription
        pub fn set_local_description(
            peer: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: UniquePtr<SetLocalDescriptionObserver>,
        );

        /// Calls the [RTCPeerConnection.setRemoteDescription()][1] on the
        /// provided [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-peerconnection-setremotedescription
        pub fn set_remote_description(
            peer: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: UniquePtr<SetRemoteDescriptionObserver>,
        );

        /// Creates a new [`SessionDescriptionInterface`].
        #[namespace = "webrtc"]
        #[cxx_name = "CreateSessionDescription"]
        pub fn create_session_description(
            kind: SdpType,
            sdp: &CxxString,
        ) -> UniquePtr<SessionDescriptionInterface>;

        /// Creates a new [`IceCandidateInterface`] from the provided data.
        pub fn create_ice_candidate(
            sdp_mid: &str,
            sdp_mline_index: i32,
            candidate: &str,
            error: &mut String
        ) -> UniquePtr<IceCandidateInterface>;

        /// Returns the spec-compliant string representation of the provided
        /// [`IceCandidateInterface`].
        ///
        /// # Safety
        ///
        /// `candidate` must be a valid [`IceCandidateInterface`] pointer.
        #[must_use]
        pub fn ice_candidate_interface_to_string(
            candidate: &IceCandidateInterface
        ) -> UniquePtr<CxxString>;
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        /// Returns the [sdpMid][1] string of the provided
        /// [`IceCandidateInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-sdpmid
        #[must_use]
        pub fn sdp_mid_of_ice_candidate(
            candidate: &IceCandidateInterface
        ) -> UniquePtr<CxxString>;

        /// Returns the [sdpMLineIndex][1] of the provided
        /// [`IceCandidateInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-sdpmlineindex
        #[must_use]
        pub fn sdp_mline_index_of_ice_candidate(
            candidate: &IceCandidateInterface
        ) -> i32;

        /// Adds the specified [`IceCandidateInterface`] to the underlying
        /// [ICE agent][1] of the provided [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#dfn-ice-agent
        pub fn add_ice_candidate(
            peer: &PeerConnectionInterface,
            candidate: UniquePtr<IceCandidateInterface>,
            cb: Box<DynAddIceCandidateCallback>
        );

        /// Tells the provided [`PeerConnectionInterface`] that ICE should be
        /// restarted.
        ///
        /// Subsequent calls to [`create_offer()`] will create descriptions
        /// restarting ICE.
        pub fn restart_ice(peer: &PeerConnectionInterface);

        /// Closes the provided [`PeerConnectionInterface`].
        pub fn close_peer_connection(peer: &PeerConnectionInterface);

        /// Returns the spec-compliant string representation of the provided
        /// [`Candidate`].
        #[must_use]
        pub fn candidate_to_string(candidate: &Candidate) -> UniquePtr<CxxString>;

        /// Creates a new [`RtpTransceiverInterface`] and adds it to the set of
        /// transceivers of the given [`PeerConnectionInterface`].
        pub fn add_transceiver(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            media_type: MediaType,
            direction: RtpTransceiverDirection
        ) -> UniquePtr<RtpTransceiverInterface>;

        /// Returns a sequence of [`RtpTransceiverInterface`] objects
        /// representing the RTP transceivers currently attached to the given
        /// [`PeerConnectionInterface`] object.
        pub fn get_transceivers(
            peer_connection_interface: &PeerConnectionInterface
        ) -> Vec<TransceiverContainer>;

        /// Returns a [`MediaType`] of the given [`RtpTransceiverInterface`].
        pub fn get_transceiver_media_type(
            transceiver: &RtpTransceiverInterface
        ) -> MediaType;

        /// Returns a `mid` of the given [`RtpTransceiverInterface`].
        ///
        /// If an empty [`String`] is returned, then the given
        /// [`RtpTransceiverInterface`] hasn't been negotiated yet.
        pub fn get_transceiver_mid(
            transceiver: &RtpTransceiverInterface
        ) -> String;

        /// Returns a [`RtpTransceiverDirection`] of the given
        /// [`RtpTransceiverInterface`].
        pub fn get_transceiver_direction(
            transceiver: &RtpTransceiverInterface
        ) -> RtpTransceiverDirection;

        /// Changes the preferred direction of the given
        /// [`RtpTransceiverInterface`].
        pub fn set_transceiver_direction(
            transceiver: &RtpTransceiverInterface,
            new_direction: RtpTransceiverDirection,
        ) -> String;

        /// Irreversibly marks the given [`RtpTransceiverInterface`] as
        /// stopping, unless it's already stopped.
        ///
        /// This will immediately cause the `transceiver`'s sender to no longer
        /// send, and its receiver to no longer receive.
        pub fn stop_transceiver(
            transceiver: &RtpTransceiverInterface,
        ) -> String;

        /// Returns the [`RtpSenderInterface`] of the provided
        /// [`RtpTransceiverInterface`].
        #[must_use]
        pub fn transceiver_sender(
            transceiver: &RtpTransceiverInterface
        ) -> UniquePtr<RtpSenderInterface>;

        /// Returns the [`RtpReceiverInterface`] of the provided
        /// [`RtpTransceiverInterface`].
        #[must_use]
        pub fn transceiver_receiver(
            transceiver: &RtpTransceiverInterface,
        ) -> UniquePtr<RtpReceiverInterface>;
    }

    unsafe extern "C++" {
        pub type AudioSourceInterface;
        pub type AudioTrackInterface;
        pub type MediaStreamInterface;
        pub type VideoTrackInterface;
        pub type VideoTrackSourceInterface;
        #[namespace = "webrtc"]
        pub type VideoFrame;
        pub type VideoSinkInterface;
        pub type VideoRotation;
        #[namespace = "webrtc"]
        pub type RtpExtension;
        #[namespace = "webrtc"]
        pub type RtcpParameters;
        pub type TrackEventObserver;

        /// Creates a new [`VideoTrackSourceInterface`] sourced by a video input
        /// device with provided `device_index`.
        pub fn create_device_video_source(
            worker_thread: Pin<&mut Thread>,
            signaling_thread: Pin<&mut Thread>,
            width: usize,
            height: usize,
            fps: usize,
            device_index: u32,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        /// Creates a new fake [`VideoTrackSourceInterface`].
        pub fn create_fake_device_video_source(
            worker_thread: Pin<&mut Thread>,
            signaling_thread: Pin<&mut Thread>,
            width: usize,
            height: usize,
            fps: usize,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        /// Creates a new [`VideoTrackSourceInterface`] sourced by a screen
        /// capturing.
        pub fn create_display_video_source(
            worker_thread: Pin<&mut Thread>,
            signaling_thread: Pin<&mut Thread>,
            width: usize,
            height: usize,
            fps: usize,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        /// Creates a new [`AudioSourceInterface`].
        pub fn create_audio_source(
            peer_connection_factory: &PeerConnectionFactoryInterface,
        ) -> UniquePtr<AudioSourceInterface>;

        /// Creates a new [`VideoTrackInterface`].
        pub fn create_video_track(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            id: String,
            video_source: &VideoTrackSourceInterface,
        ) -> UniquePtr<VideoTrackInterface>;

        /// Creates a new [`AudioTrackInterface`].
        pub fn create_audio_track(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            id: String,
            audio_source: &AudioSourceInterface,
        ) -> UniquePtr<AudioTrackInterface>;

        /// Creates a new [`MediaStreamInterface`].
        pub fn create_local_media_stream(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            id: String,
        ) -> UniquePtr<MediaStreamInterface>;

        /// Adds the [`VideoTrackInterface`] to the [`MediaStreamInterface`].
        pub fn add_video_track(
            peer_connection_factory: &MediaStreamInterface,
            track: &VideoTrackInterface,
        ) -> bool;

        /// Returns the `AudioSourceInterface` of the provided
        /// [`AudioTrackInterface`].
        #[must_use]
        pub fn get_audio_track_source(
            track: &AudioTrackInterface,
        ) -> UniquePtr<AudioSourceInterface>;

        /// Returns the `VideoTrackSourceInterface` of the provided
        /// [`VideoTrackInterface`].
        #[must_use]
        pub fn get_video_track_source(
            track: &VideoTrackInterface,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        /// Adds the [`AudioTrackInterface`] to the [`MediaStreamInterface`].
        pub fn add_audio_track(
            peer_connection_factory: &MediaStreamInterface,
            track: &AudioTrackInterface,
        ) -> bool;

        /// Removes the [`VideoTrackInterface`] from the
        /// [`MediaStreamInterface`].
        pub fn remove_video_track(
            media_stream: &MediaStreamInterface,
            track: &VideoTrackInterface,
        ) -> bool;

        /// Removes the [`AudioTrackInterface`] from the
        /// [`MediaStreamInterface`].
        pub fn remove_audio_track(
            media_stream: &MediaStreamInterface,
            track: &AudioTrackInterface,
        ) -> bool;

        /// Changes the [enabled][1] property of the specified
        /// [`VideoTrackInterface`].
        ///
        /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
        pub fn set_video_track_enabled(
            track: &VideoTrackInterface,
            enabled: bool,
        );

        /// Changes the [enabled][1] property of the specified
        /// [`AudioTrackInterface`].
        ///
        /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
        pub fn set_audio_track_enabled(
            track: &AudioTrackInterface,
            enabled: bool,
        );

        /// Returns the [readyState][0] property of the specified
        /// [`VideoTrackInterface`].
        ///
        /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
        pub fn video_track_state(track: &VideoTrackInterface) -> TrackState;

        /// Returns the [readyState][0] property of the specified
        /// [`AudioTrackInterface`].
        ///
        /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
        pub fn audio_track_state(track: &AudioTrackInterface) -> TrackState;

        /// Registers the provided [`VideoSinkInterface`] for the given
        /// [`VideoTrackInterface`].
        ///
        /// Used to connect the given [`VideoTrackInterface`] to the underlying
        /// video engine.
        pub fn add_or_update_video_sink(
            track: &VideoTrackInterface,
            sink: Pin<&mut VideoSinkInterface>,
        );

        /// Detaches the provided [`VideoSinkInterface`] from the given
        /// [`VideoTrackInterface`].
        pub fn remove_video_sink(
            track: &VideoTrackInterface,
            sink: Pin<&mut VideoSinkInterface>,
        );

        /// Creates a new forwarding [`VideoSinkInterface`] backed by the
        /// provided [`DynOnFrameCallback`].
        pub fn create_forwarding_video_sink(
            handler: Box<DynOnFrameCallback>,
        ) -> UniquePtr<VideoSinkInterface>;

        /// Returns a width of this [`VideoFrame`].
        #[must_use]
        pub fn width(self: &VideoFrame) -> i32;

        /// Returns a height of this [`VideoFrame`].
        #[must_use]
        pub fn height(self: &VideoFrame) -> i32;

        /// Returns a [`VideoRotation`] of this [`VideoFrame`].
        #[must_use]
        pub fn rotation(self: &VideoFrame) -> VideoRotation;

        /// Converts the provided [`webrtc::VideoFrame`] pixels to the `ABGR`
        /// scheme and writes the result to the provided `buffer`.
        pub unsafe fn video_frame_to_abgr(frame: &VideoFrame, buffer: *mut u8);

        /// Returns the timestamp of when the last data was received from the
        /// provided [`CandidatePairChangeEvent`].
        #[must_use]
        pub fn get_last_data_received_ms(
            event: &CandidatePairChangeEvent,
        ) -> i64;

        /// Returns the reason causing the provided
        /// [`CandidatePairChangeEvent`].
        #[must_use]
        pub fn get_reason(
            event: &CandidatePairChangeEvent,
        ) -> UniquePtr<CxxString>;

        /// Returns the estimated disconnect time in milliseconds from the
        /// provided [`CandidatePairChangeEvent`].
        #[must_use]
        pub fn get_estimated_disconnected_time_ms(
            event: &CandidatePairChangeEvent,
        ) -> i64;

        /// Downcasts the provided [`MediaStreamTrackInterface`] to a
        /// [`VideoTrackInterface`].
        #[must_use]
        pub fn media_stream_track_interface_downcast_video_track(
            track: UniquePtr<MediaStreamTrackInterface>,
        ) -> UniquePtr<VideoTrackInterface>;

        /// Downcasts the provided [`MediaStreamTrackInterface`] to an
        /// [`AudioTrackInterface`].
        #[must_use]
        pub fn media_stream_track_interface_downcast_audio_track(
            track: UniquePtr<MediaStreamTrackInterface>,
        ) -> UniquePtr<AudioTrackInterface>;

        /// Returns the `cname` of the provided [`RtcpParameters`].
        #[must_use]
        pub fn rtcp_parameters_cname(
            rtcp: &RtcpParameters,
        ) -> UniquePtr<CxxString>;

        /// Returns the `reduced_size` of the provided [`RtcpParameters`].
        #[must_use]
        pub fn rtcp_parameters_reduced_size(rtcp: &RtcpParameters) -> bool;

        /// Returns the `uri` of the provided [`RtpExtension`].
        #[must_use]
        pub fn rtp_extension_uri(
            extension: &RtpExtension,
        ) -> UniquePtr<CxxString>;

        /// Returns the `id` of the provided [`RtpExtension`].
        #[must_use]
        pub fn rtp_extension_id(extension: &RtpExtension) -> i32;

        /// Returns the `encrypt` property of the provided [`RtpExtension`].
        #[must_use]
        pub fn rtp_extension_encrypt(extension: &RtpExtension) -> bool;

        /// Returns the [`CandidatePair`] from the provided
        /// [`CandidatePairChangeEvent`].
        #[must_use]
        pub fn get_candidate_pair(
            event: &CandidatePairChangeEvent,
        ) -> &CandidatePair;

        /// Returns the local [`Candidate`] of the provided [`CandidatePair`].
        #[must_use]
        pub fn local_candidate(self: &CandidatePair) -> &Candidate;

        /// Returns the remote [`Candidate`] of the provided [`CandidatePair`].
        #[must_use]
        pub fn remote_candidate(self: &CandidatePair) -> &Candidate;

        /// Creates a new [`DynTrackEventCallback`] backed by the provided
        /// [`DynOnFrameCallback`].
        pub fn create_track_event_observer(
            cb: Box<DynTrackEventCallback>,
        ) -> UniquePtr<TrackEventObserver>;

        /// Changes the `track` member of the provided [`TrackEventObserver`].
        pub fn set_track_observer_video_track(
            obs: Pin<&mut TrackEventObserver>,
            track: &VideoTrackInterface,
        );

        /// Changes the `track` member of the provided [`TrackEventObserver`].
        pub fn set_track_observer_audio_track(
            obs: Pin<&mut TrackEventObserver>,
            track: &AudioTrackInterface,
        );

        /// Registers the given [`TrackEventObserver`] to receive events from
        /// the provided [`AudioTrackInterface`].
        pub fn audio_track_register_observer(
            track: Pin<&mut AudioTrackInterface>,
            obs: Pin<&mut TrackEventObserver>,
        );

        /// Registers the given [`TrackEventObserver`] to receive events from
        /// the provided [`VideoTrackInterface`].
        pub fn video_track_register_observer(
            track: Pin<&mut VideoTrackInterface>,
            obs: Pin<&mut TrackEventObserver>,
        );

        /// Unregisters the given [`TrackEventObserver`] from the specified
        /// [`AudioTrackInterface`].
        pub fn audio_track_unregister_observer(
            track: Pin<&mut AudioTrackInterface>,
            obs: Pin<&mut TrackEventObserver>,
        );

        /// Unregisters the given [`TrackEventObserver`] from the specified
        /// [`VideoTrackInterface`].
        pub fn video_track_unregister_observer(
            track: Pin<&mut VideoTrackInterface>,
            obs: Pin<&mut TrackEventObserver>,
        );
    }

    extern "Rust" {
        pub type DynOnFrameCallback;

        /// Forwards the given [`webrtc::VideoFrame`] the the provided
        /// [`DynOnFrameCallback`].
        pub fn on_frame(
            cb: &mut DynOnFrameCallback,
            frame: UniquePtr<VideoFrame>,
        );
    }

    extern "Rust" {
        pub type DynTrackEventCallback;

        /// Forwards the [`ended`][1] event to the given
        /// [`DynTrackEventCallback`].
        ///
        /// [1]: https://tinyurl.com/w3-streams#event-mediastreamtrack-ended
        fn on_ended(cb: &mut DynTrackEventCallback);
    }

    extern "Rust" {
        pub type DynSetDescriptionCallback;
        pub type DynCreateSdpCallback;
        pub type DynPeerConnectionEventsHandler;

        /// Creates a new [`StringPair`] from the given [`CxxString`].
        pub fn new_string_pair(f: &CxxString, s: &CxxString) -> StringPair;

        /// Successfully completes the provided [`DynSetDescriptionCallback`].
        pub fn create_sdp_success(
            cb: Box<DynCreateSdpCallback>,
            sdp: &CxxString,
            kind: SdpType,
        );

        /// Completes the provided [`DynCreateSdpCallback`] with an error.
        pub fn create_sdp_fail(
            cb: Box<DynCreateSdpCallback>,
            error: &CxxString,
        );

        /// Successfully completes the provided [`DynSetDescriptionCallback`].
        pub fn set_description_success(cb: Box<DynSetDescriptionCallback>);

        /// Completes the provided [`DynSetDescriptionCallback`] with an error.
        pub fn set_description_fail(
            cb: Box<DynSetDescriptionCallback>,
            error: &CxxString,
        );

        /// Forwards the new [`SignalingState`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when a
        /// [`signalingstatechange`][1] event occurs in the attached
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-signalingstatechange
        pub fn on_signaling_change(
            cb: &mut DynPeerConnectionEventsHandler,
            state: SignalingState,
        );

        /// Forwards the new [`IceConnectionState`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when an
        /// [`iceconnectionstatechange`][1] event occurs in the attached
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-iceconnectionstatechange
        pub fn on_standardized_ice_connection_change(
            cb: &mut DynPeerConnectionEventsHandler,
            new_state: IceConnectionState,
        );

        /// Forwards the new [`PeerConnectionState`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when a
        /// [`connectionstatechange`][1] event occurs in the attached
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-connectionstatechange
        pub fn on_connection_change(
            cb: &mut DynPeerConnectionEventsHandler,
            new_state: PeerConnectionState,
        );

        /// Forwards the new [`IceGatheringState`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when an
        /// [`icegatheringstatechange`][1] event occurs in the attached
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-icegatheringstatechange
        pub fn on_ice_gathering_change(
            cb: &mut DynPeerConnectionEventsHandler,
            new_state: IceGatheringState,
        );

        /// Forwards a [`negotiation`][1] event to the provided
        /// [`DynPeerConnectionEventsHandler`] when it occurs in the attached
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-negotiation
        pub fn on_negotiation_needed_event(
            cb: &mut DynPeerConnectionEventsHandler,
            event_id: u32,
        );

        /// Forwards an [`icecandidateerror`][1] event's error information to
        /// the provided [`DynPeerConnectionEventsHandler`] when it occurs in
        /// the attached [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-icecandidateerror
        pub fn on_ice_candidate_error(
            cb: &mut DynPeerConnectionEventsHandler,
            address: &CxxString,
            port: i32,
            url: &CxxString,
            error_code: i32,
            error_text: &CxxString,
        );

        /// Forwards the new `receiving` status to the provided
        /// [`DynPeerConnectionEventsHandler`] when an ICE connection receiving
        /// status changes in the attached [`PeerConnectionInterface`].
        pub fn on_ice_connection_receiving_change(
            cb: &mut DynPeerConnectionEventsHandler,
            receiving: bool,
        );

        /// Forwards the discovered [`IceCandidateInterface`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when an [`icecandidate`][1] event
        /// occurs in the attached [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-icecandidate
        pub fn on_ice_candidate(
            cb: &mut DynPeerConnectionEventsHandler,
            candidate: UniquePtr<IceCandidateInterface>,
        );

        /// Forwards the removed [`Candidate`]s to the given
        /// [`DynPeerConnectionEventsHandler`] when some ICE candidates have
        /// been removed.
        pub fn on_ice_candidates_removed(
            cb: &mut DynPeerConnectionEventsHandler,
            candidates: &CxxVector<Candidate>,
        );

        /// Forwards the selected [`CandidatePairChangeEvent`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when a
        /// [`selectedcandidatepairchange`][1] event occurs in the attached
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://tinyurl.com/w3-selectedcandidatepairchange
        pub fn on_ice_selected_candidate_pair_changed(
            cb: &mut DynPeerConnectionEventsHandler,
            event: &CandidatePairChangeEvent,
        );

        /// Forwards the specified [`RtpTransceiverInterface`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when a [`track`][1] event occurs
        /// in the attached [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc#event-track
        pub fn on_track(
            cb: &mut DynPeerConnectionEventsHandler,
            transceiver: UniquePtr<RtpTransceiverInterface>,
        );

        /// Forwards the specified [`RtpTransceiverInterface`] to the provided
        /// [`DynPeerConnectionEventsHandler`] when a track is removed.
        ///
        /// This is a non-spec-compliant event.
        pub fn on_remove_track(
            cb: &mut DynPeerConnectionEventsHandler,
            receiver: UniquePtr<RtpReceiverInterface>,
        );
    }
}

/// Successfully completes the provided [`DynSetDescriptionCallback`].
#[allow(clippy::boxed_local)]
pub fn create_sdp_success(
    mut cb: Box<DynCreateSdpCallback>,
    sdp: &CxxString,
    kind: webrtc::SdpType,
) {
    cb.success(sdp, kind);
}

/// Completes the provided [`DynCreateSdpCallback`] with an error.
#[allow(clippy::boxed_local)]
pub fn create_sdp_fail(mut cb: Box<DynCreateSdpCallback>, error: &CxxString) {
    cb.fail(error);
}

/// Successfully completes the provided [`DynSetDescriptionCallback`].
#[allow(clippy::boxed_local)]
pub fn set_description_success(mut cb: Box<DynSetDescriptionCallback>) {
    cb.success();
}

/// Completes the provided [`DynSetDescriptionCallback`] with the given `error`.
#[allow(clippy::boxed_local)]
pub fn set_description_fail(
    mut cb: Box<DynSetDescriptionCallback>,
    error: &CxxString,
) {
    cb.fail(error);
}

/// Forwards the given [`webrtc::VideoFrame`] the the provided
/// [`DynOnFrameCallback`].
fn on_frame(cb: &mut DynOnFrameCallback, frame: UniquePtr<webrtc::VideoFrame>) {
    cb.on_frame(frame);
}

/// Forwards the new [`SignalingState`] to the provided
/// [`DynPeerConnectionEventsHandler`] when a [`signalingstatechange`][1] event
/// occurs in the attached [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [`SignalingState`]: webrtc::SignalingState
/// [1]: https://w3.org/TR/webrtc#event-signalingstatechange
pub fn on_signaling_change(
    cb: &mut DynPeerConnectionEventsHandler,
    state: webrtc::SignalingState,
) {
    cb.on_signaling_change(state);
}

/// Forwards the new [`IceConnectionState`] to the provided
/// [`DynPeerConnectionEventsHandler`] when an [`iceconnectionstatechange`][1]
/// event occurs in the attached [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [`IceConnectionState`]: webrtc::IceConnectionState
/// [1]: https://w3.org/TR/webrtc#event-iceconnectionstatechange
pub fn on_standardized_ice_connection_change(
    cb: &mut DynPeerConnectionEventsHandler,
    new_state: webrtc::IceConnectionState,
) {
    cb.on_standardized_ice_connection_change(new_state);
}

/// Forwards the new [`PeerConnectionState`] to the provided
/// [`DynPeerConnectionEventsHandler`] when a [`connectionstatechange`][1] event
/// occurs in the attached [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [`PeerConnectionState`]: webrtc::PeerConnectionState
/// [1]: https://w3.org/TR/webrtc#event-connectionstatechange
pub fn on_connection_change(
    cb: &mut DynPeerConnectionEventsHandler,
    new_state: webrtc::PeerConnectionState,
) {
    cb.on_connection_change(new_state);
}

/// Forwards the new [`IceGatheringState`] to the provided
/// [`DynPeerConnectionEventsHandler`] when an [`icegatheringstatechange`][1]
/// event occurs in the attached [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [`IceGatheringState`]: webrtc::IceGatheringState
/// [1]: https://w3.org/TR/webrtc#event-icegatheringstatechange
pub fn on_ice_gathering_change(
    cb: &mut DynPeerConnectionEventsHandler,
    new_state: webrtc::IceGatheringState,
) {
    cb.on_ice_gathering_change(new_state);
}

/// Forwards a [`negotiation`][1] event to the provided
/// [`DynPeerConnectionEventsHandler`] when it occurs in the attached
/// [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [1]: https://w3.org/TR/webrtc#event-negotiation
pub fn on_negotiation_needed_event(
    cb: &mut DynPeerConnectionEventsHandler,
    event_id: u32,
) {
    cb.on_negotiation_needed_event(event_id);
}

/// Forwards an [`icecandidateerror`][1] event's error information to the
/// provided [`DynPeerConnectionEventsHandler`] when it occurs in the attached
/// [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [1]: https://w3.org/TR/webrtc#event-icecandidateerror
pub fn on_ice_candidate_error(
    cb: &mut DynPeerConnectionEventsHandler,
    address: &CxxString,
    port: i32,
    url: &CxxString,
    error_code: i32,
    error_text: &CxxString,
) {
    cb.on_ice_candidate_error(address, port, url, error_code, error_text);
}

/// Forwards the new `receiving` status to the provided
/// [`DynPeerConnectionEventsHandler`] when an ICE connection receiving status
/// changes in the attached [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
pub fn on_ice_connection_receiving_change(
    cb: &mut DynPeerConnectionEventsHandler,
    receiving: bool,
) {
    cb.on_ice_connection_receiving_change(receiving);
}

/// Forwards the discovered [`IceCandidateInterface`] to the provided
/// [`DynPeerConnectionEventsHandler`] when an [`icecandidate`][1] event occurs
/// in the attached [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [`IceCandidateInterface`]: webrtc::IceCandidateInterface
/// [1]: https://w3.org/TR/webrtc#event-icecandidate
pub fn on_ice_candidate(
    cb: &mut DynPeerConnectionEventsHandler,
    candidate: UniquePtr<webrtc::IceCandidateInterface>,
) {
    cb.on_ice_candidate(IceCandidateInterface(candidate));
}

/// Forwards the removed [`Candidate`]s to the given
/// [`DynPeerConnectionEventsHandler`] when some ICE candidates have been
/// removed.
///
/// [`Candidate`]: webrtc::Candidate
pub fn on_ice_candidates_removed(
    cb: &mut DynPeerConnectionEventsHandler,
    candidates: &CxxVector<webrtc::Candidate>,
) {
    cb.on_ice_candidates_removed(candidates);
}

/// Called when a [`selectedcandidatepairchange`][1] event occurs in the
/// attached [`PeerConnectionInterface`]. Forwards the selected
/// [`CandidatePairChangeEvent`] to the given
/// [`DynPeerConnectionEventsHandler`].
///
/// Forwards the selected [`CandidatePairChangeEvent`] to the provided
/// [`DynPeerConnectionEventsHandler`] when a [`selectedcandidatepairchange`][1]
/// event occurs in the attached [`PeerConnectionInterface`].
///
/// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
/// [`CandidatePairChangeEvent`]: webrtc::CandidatePairChangeEvent
/// [1]: https://tinyurl.com/w3-selectedcandidatepairchange
pub fn on_ice_selected_candidate_pair_changed(
    cb: &mut DynPeerConnectionEventsHandler,
    event: &webrtc::CandidatePairChangeEvent,
) {
    cb.on_ice_selected_candidate_pair_changed(event);
}

/// Forwards the specified [`RtpTransceiverInterface`] to the provided
/// [`DynPeerConnectionEventsHandler`] when a [`track`][1] event occurs in the
/// attached [`PeerConnectionInterface`].
///
/// [1]: https://w3.org/TR/webrtc#event-track
pub fn on_track(
    cb: &mut DynPeerConnectionEventsHandler,
    transceiver: UniquePtr<webrtc::RtpTransceiverInterface>,
) {
    cb.on_track(RtpTransceiverInterface {
        media_type: webrtc::get_transceiver_media_type(&transceiver),
        inner: transceiver,
    });
}

/// Forwards the specified [`RtpTransceiverInterface`] to the provided
/// [`DynPeerConnectionEventsHandler`] when a track is removed.
///
/// This is a non-spec-compliant event.
pub fn on_remove_track(
    cb: &mut DynPeerConnectionEventsHandler,
    receiver: UniquePtr<webrtc::RtpReceiverInterface>,
) {
    cb.on_remove_track(RtpReceiverInterface(receiver));
}

/// Forwards the [`ended`][1] event to the given [`DynTrackEventCallback`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#event-mediastreamtrack-ended
pub fn on_ended(cb: &mut DynTrackEventCallback) {
    cb.on_ended();
}

/// Creates a new [`StringPair`].
fn new_string_pair(f: &CxxString, s: &CxxString) -> webrtc::StringPair {
    webrtc::StringPair {
        first: f.to_string(),
        second: s.to_string(),
    }
}

/// Calls the success [`DynAddIceCandidateCallback`].
#[allow(clippy::boxed_local)]
pub fn add_ice_candidate_success(mut cb: Box<DynAddIceCandidateCallback>) {
    cb.on_success();
}

/// Calls the fail [`DynAddIceCandidateCallback`].
#[allow(clippy::boxed_local)]
pub fn add_ice_candidate_fail(
    mut cb: Box<DynAddIceCandidateCallback>,
    error: &CxxString,
) {
    cb.on_fail(error);
}

impl TryFrom<&str> for webrtc::SdpType {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "offer" => Ok(Self::kOffer),
            "answer" => Ok(Self::kAnswer),
            "pranswer" => Ok(Self::kPrAnswer),
            "rollback" => Ok(Self::kRollback),
            v => Err(anyhow!("Invalid `SdpType`: {v}")),
        }
    }
}

impl TryFrom<&str> for webrtc::MediaType {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "audio" => Ok(Self::MEDIA_TYPE_AUDIO),
            "video" => Ok(Self::MEDIA_TYPE_VIDEO),
            "data" => Ok(Self::MEDIA_TYPE_DATA),
            "unsupported" => Ok(Self::MEDIA_TYPE_UNSUPPORTED),
            v => Err(anyhow!("Invalid `MediaType`: {v}")),
        }
    }
}

impl TryFrom<&str> for webrtc::RtpTransceiverDirection {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "sendrecv" => Ok(Self::kSendRecv),
            "sendonly" => Ok(Self::kSendOnly),
            "recvonly" => Ok(Self::kRecvOnly),
            "stopped" => Ok(Self::kStopped),
            "inactive" => Ok(Self::kInactive),
            v => Err(anyhow!("Invalid `RtpTransceiverDirection`: {v}")),
        }
    }
}

impl TryFrom<&str> for webrtc::IceTransportsType {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "none" => Ok(Self::kNone),
            "relay" => Ok(Self::kRelay),
            "nohost" => Ok(Self::kNoHost),
            "all" => Ok(Self::kAll),
            v => Err(anyhow!("Invalid `IceTransportsType`: {v}")),
        }
    }
}

impl TryFrom<&str> for webrtc::BundlePolicy {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "balanced" => Ok(Self::kBundlePolicyBalanced),
            "maxbundle" => Ok(Self::kBundlePolicyMaxBundle),
            "maxcompat" => Ok(Self::kBundlePolicyMaxCompat),
            v => Err(anyhow!("Invalid `BundlePolicy`: {v}")),
        }
    }
}

impl fmt::Display for webrtc::SdpType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::kOffer => write!(f, "offer"),
            Self::kAnswer => write!(f, "answer"),
            Self::kPrAnswer => write!(f, "pranswer"),
            Self::kRollback => write!(f, "rollback"),
            _ => unreachable!(),
        }
    }
}

impl fmt::Display for webrtc::RtpTransceiverDirection {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::kSendRecv => write!(f, "sendrecv"),
            Self::kSendOnly => write!(f, "sendonly"),
            Self::kRecvOnly => write!(f, "recvonly"),
            Self::kInactive => write!(f, "inactive"),
            Self::kStopped => write!(f, "stopped"),
            _ => unreachable!(),
        }
    }
}

impl fmt::Display for webrtc::SignalingState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::kStable => write!(f, "stable"),
            Self::kHaveLocalOffer => write!(f, "have-local-offer"),
            Self::kHaveLocalPrAnswer => write!(f, "have-local-pranswer"),
            Self::kHaveRemoteOffer => write!(f, "have-remote-offer"),
            Self::kHaveRemotePrAnswer => write!(f, "have-remote-pranswer"),
            Self::kClosed => write!(f, "closed"),
            _ => unreachable!(),
        }
    }
}

impl fmt::Display for webrtc::IceGatheringState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::kIceGatheringNew => write!(f, "new"),
            Self::kIceGatheringGathering => write!(f, "gathering"),
            Self::kIceGatheringComplete => write!(f, "complete"),
            _ => unreachable!(),
        }
    }
}

impl fmt::Display for webrtc::IceConnectionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::kIceConnectionNew => write!(f, "new"),
            Self::kIceConnectionChecking => write!(f, "checking"),
            Self::kIceConnectionConnected => write!(f, "connected"),
            Self::kIceConnectionCompleted => write!(f, "completed"),
            Self::kIceConnectionFailed => write!(f, "failed"),
            Self::kIceConnectionDisconnected => write!(f, "disconnected"),
            Self::kIceConnectionClosed => write!(f, "closed"),
            _ => unreachable!(),
        }
    }
}

impl fmt::Display for webrtc::TrackState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::kLive => write!(f, "live"),
            Self::kEnded => write!(f, "ended"),
            _ => unreachable!(),
        }
    }
}

impl fmt::Display for webrtc::MediaType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::MEDIA_TYPE_AUDIO => write!(f, "audio"),
            Self::MEDIA_TYPE_VIDEO => write!(f, "video"),
            Self::MEDIA_TYPE_DATA => write!(f, "data"),
            Self::MEDIA_TYPE_UNSUPPORTED => write!(f, "unsupported"),
            _ => unreachable!(),
        }
    }
}

impl fmt::Display for webrtc::PeerConnectionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            Self::kNew => write!(f, "new"),
            Self::kConnecting => write!(f, "connecting"),
            Self::kConnected => write!(f, "connected"),
            Self::kDisconnected => write!(f, "disconnected"),
            Self::kFailed => write!(f, "failed"),
            Self::kClosed => write!(f, "closed"),
            _ => unreachable!(),
        }
    }
}
