#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]

mod bridge;

use std::{collections::HashMap, mem};

use anyhow::bail;
use cxx::{let_cxx_string, CxxString, CxxVector, UniquePtr};

use self::bridge::webrtc;

pub use crate::webrtc::{
    candidate_to_string, get_candidate_pair,
    get_estimated_disconnected_time_ms, get_last_data_received_ms, get_reason,
    video_frame_to_abgr, AudioLayer, BundlePolicy, Candidate,
    CandidatePairChangeEvent, IceConnectionState, IceGatheringState,
    IceTransportsType, MediaType, PeerConnectionState, RtpTransceiverDirection,
    SdpType, SignalingState, VideoFrame, VideoRotation,
};

/// Handler of events firing from a [`MediaStreamTrackInterface`].
pub trait TrackEventCallback {
    /// Called when an [`ended`][1] event occurs in the attached
    /// [`MediaStreamTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#event-mediastreamtrack-ended
    fn on_ended(&mut self);
}

/// Completion callback for a [`CreateSessionDescriptionObserver`], used to call
/// [`PeerConnectionInterface::create_offer()`] and
/// [`PeerConnectionInterface::create_answer()`].
pub trait CreateSdpCallback {
    /// Called when the related operation is successfully completed.
    fn success(&mut self, sdp: &CxxString, kind: webrtc::SdpType);

    /// Called when the related operation is completed with the `error`.
    fn fail(&mut self, error: &CxxString);
}

/// Completion callback for a [`SetLocalDescriptionObserver`] and
/// [`SetRemoteDescriptionObserver`], used to call
/// [`PeerConnectionInterface::set_local_description()`] and
/// [`PeerConnectionInterface::set_remote_description()`].
pub trait SetDescriptionCallback {
    /// Called when the related operation is successfully completed.
    fn success(&mut self);

    /// Called when the related operation is completed with the `error`.
    fn fail(&mut self, error: &CxxString);
}

/// Handler of [`VideoFrame`]s.
pub trait OnFrameCallback {
    /// Called when the attached [`VideoTrackInterface`] produces a new
    /// [`VideoFrame`].
    fn on_frame(&mut self, frame: UniquePtr<VideoFrame>);
}

/// Handler of events that fire from a [`PeerConnectionInterface`].
pub trait PeerConnectionEventsHandler {
    /// Called when a [`signalingstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-signalingstatechange
    fn on_signaling_change(&mut self, new_state: SignalingState);

    /// Called when an [`iceconnectionstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-iceconnectionstatechange
    fn on_standardized_ice_connection_change(
        &mut self,
        new_state: IceConnectionState,
    );

    /// Called when a [`connectionstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-connectionstatechange
    fn on_connection_change(&mut self, new_state: PeerConnectionState);

    /// Called when an [`icegatheringstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-icegatheringstatechange
    fn on_ice_gathering_change(&mut self, new_state: IceGatheringState);

    /// Called when a [`negotiation`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-negotiation
    fn on_negotiation_needed_event(&mut self, event_id: u32);

    /// Called when an [`icecandidateerror`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-icecandidateerror
    fn on_ice_candidate_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    );

    /// Called when the ICE connection receiving status changes.
    fn on_ice_connection_receiving_change(&mut self, receiving: bool);

    /// Called when an [`icecandidate`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-icecandidate
    fn on_ice_candidate(&mut self, candidate: IceCandidateInterface);

    /// Called when some ICE candidates have been removed.
    fn on_ice_candidates_removed(&mut self, candidates: &CxxVector<Candidate>);

    /// Called when a [`selectedcandidatepairchange`][1] event occurs.
    ///
    /// [1]: https://tinyurl.com/w3-selectedcandidatepairchange
    fn on_ice_selected_candidate_pair_changed(
        &mut self,
        event: &CandidatePairChangeEvent,
    );

    /// Called when a [`track`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-track
    fn on_track(&mut self, transceiver: RtpTransceiverInterface);

    /// Called when signaling indicates that media will no longer be received on
    /// a track.
    ///
    /// With "Unified Plan" semantics, the receiver will remain but the
    /// transceiver will have changed its direction to either `sendonly` or
    /// `inactive`.
    fn on_remove_track(&mut self, receiver: RtpReceiverInterface);
}

/// [MediaStreamTrack.kind][1] representation.
///
/// [1]: https://w3.org/TR/mediacapture-streams#dfn-kind
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub enum TrackKind {
    Audio,
    Video,
}

/// Completion callback for the [`PeerConnectionInterface::add_ice_candidate()`]
/// function.
pub trait AddIceCandidateCallback {
    /// Called when the operation is successfully completed.
    fn on_success(&mut self);

    /// Called when the operation fails with the `error`.
    fn on_fail(&mut self, error: &CxxString);
}

/// Thread safe task queue factory internally used in [`WebRTC`] that is capable
/// of creating [Task Queue]s.
///
/// [`WebRTC`]: https://webrtc.googlesource.com/src
/// [Task Queue]: https://tinyurl.com/doc-threads
pub struct TaskQueueFactory(UniquePtr<webrtc::TaskQueueFactory>);

impl TaskQueueFactory {
    /// Creates a default [`TaskQueueFactory`] based on the current platform.
    #[must_use]
    pub fn create_default_task_queue_factory() -> Self {
        Self(webrtc::create_default_task_queue_factory())
    }
}

unsafe impl Send for webrtc::TaskQueueFactory {}
unsafe impl Sync for webrtc::TaskQueueFactory {}

/// Available audio devices manager that is responsible for driving input
/// (microphone) and output (speaker) audio in WebRTC.
///
/// Backed by WebRTC's [Audio Device Module].
///
/// [Audio Device Module]: https://tinyurl.com/doc-adm
pub struct AudioDeviceModule(UniquePtr<webrtc::AudioDeviceModule>);

impl AudioDeviceModule {
    /// Creates a new [`AudioDeviceModule`] for the given [`AudioLayer`].
    ///
    /// All invocations will be proxied to the provided `worker_thred`, thus
    /// making it thread-safe.
    pub fn create_proxy(
        worker_thread: &mut Thread,
        audio_layer: AudioLayer,
        task_queue_factory: &mut TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_audio_device_module(
            worker_thread.0.pin_mut(),
            audio_layer,
            task_queue_factory.0.pin_mut(),
        );

        if ptr.is_null() {
            bail!("`null` pointer returned from `AudioDeviceModule::Create()`");
        }
        Ok(Self(ptr))
    }

    /// Initializes the current [`AudioDeviceModule`].
    pub fn init(&self) -> anyhow::Result<()> {
        let result = webrtc::init_audio_device_module(&self.0);
        if result != 0 {
            bail!("`AudioDeviceModule::Init()` failed with `{result}` code");
        }
        Ok(())
    }

    /// Returns count of available audio playout devices.
    pub fn playout_devices(&self) -> anyhow::Result<i16> {
        let count = webrtc::playout_devices(&self.0);

        if count < 0 {
            bail!(
                "`AudioDeviceModule::PlayoutDevices()` failed with `{count}` \
                 code",
            );
        }

        Ok(count)
    }

    /// Returns count of available audio recording devices.
    pub fn recording_devices(&self) -> anyhow::Result<i16> {
        let count = webrtc::recording_devices(&self.0);

        if count < 0 {
            bail!(
                "`AudioDeviceModule::RecordingDevices()` failed with `{count}` \
                 code",
            );
        }

        Ok(count)
    }

    /// Returns the `(label, id)` tuple for the given audio playout device
    /// `index`.
    pub fn playout_device_name(
        &self,
        index: i16,
    ) -> anyhow::Result<(String, String)> {
        let mut name = String::new();
        let mut guid = String::new();

        let result =
            webrtc::playout_device_name(&self.0, index, &mut name, &mut guid);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::PlayoutDeviceName()` failed with \
                 `{result}` code",
            );
        }

        Ok((name, guid))
    }

    /// Returns the `(label, id)` tuple for the given audio recording device
    /// `index`.
    pub fn recording_device_name(
        &self,
        index: i16,
    ) -> anyhow::Result<(String, String)> {
        let mut name = String::new();
        let mut guid = String::new();

        let result =
            webrtc::recording_device_name(&self.0, index, &mut name, &mut guid);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::RecordingDeviceName()` failed with \
                 `{result}` code",
            );
        }

        Ok((name, guid))
    }

    /// Sets the recording audio device according to the given `index`.
    pub fn set_recording_device(&self, index: u16) -> anyhow::Result<()> {
        let result = webrtc::set_audio_recording_device(&self.0, index);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::SetRecordingDevice()` failed with \
                 `{result}` code",
            );
        }

        Ok(())
    }

    /// Sets the playout audio device according to the given `index`.
    pub fn set_playout_device(&self, index: u16) -> anyhow::Result<()> {
        let result = webrtc::set_audio_playout_device(&self.0, index);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::SetPlayoutDevice()` failed with \
                 `{result}` code",
            );
        }

        Ok(())
    }
}

unsafe impl Send for webrtc::AudioDeviceModule {}
unsafe impl Sync for webrtc::AudioDeviceModule {}

/// Interface for receiving information about available camera devices.
pub struct VideoDeviceInfo(UniquePtr<webrtc::VideoDeviceInfo>);

impl VideoDeviceInfo {
    /// Creates a new [`VideoDeviceInfo`].
    pub fn create() -> anyhow::Result<Self> {
        let ptr = webrtc::create_video_device_info();

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `VideoCaptureFactory::CreateDeviceInfo()`",
            );
        }
        Ok(Self(ptr))
    }

    /// Returns count of a video recording devices.
    pub fn number_of_devices(&mut self) -> u32 {
        self.0.pin_mut().number_of_video_devices()
    }

    /// Returns the `(label, id)` tuple for the given video device `index`.
    pub fn device_name(
        &mut self,
        index: u32,
    ) -> anyhow::Result<(String, String)> {
        let mut name = String::new();
        let mut guid = String::new();

        let result = webrtc::video_device_name(
            self.0.pin_mut(),
            index,
            &mut name,
            &mut guid,
        );

        if result != 0 {
            bail!(
                "`AudioDeviceModule::GetDeviceName()` failed with `{result}` \
                 code",
            );
        }

        Ok((name, guid))
    }
}

unsafe impl Send for webrtc::VideoDeviceInfo {}
unsafe impl Sync for webrtc::VideoDeviceInfo {}

/// [RTCConfiguration][1] wrapper.
///
/// Defines a set of parameters to configure how the peer-to-peer communication
/// via a [`PeerConnectionInterface`] is established or re-established.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration
pub struct RtcConfiguration(UniquePtr<webrtc::RTCConfiguration>);

impl RtcConfiguration {
    /// Sets the specified [`IceTransportsType`] configuration for this
    /// [`RtcConfiguration`].
    pub fn set_ice_transport_type(
        &mut self,
        transport_type: webrtc::IceTransportsType,
    ) {
        webrtc::set_rtc_configuration_ice_transport_type(
            self.0.pin_mut(),
            transport_type,
        );
    }

    /// Sets the specified [`BundlePolicy`] configuration for this
    /// [`RtcConfiguration`].
    pub fn set_bundle_policy(&mut self, bundle_policy: webrtc::BundlePolicy) {
        webrtc::set_rtc_configuration_bundle_policy(
            self.0.pin_mut(),
            bundle_policy,
        );
    }

    /// Adds the specified [`IceServer`] to the list of servers of this
    /// [`RtcConfiguration`].
    pub fn add_server(&mut self, mut server: IceServer) {
        webrtc::add_rtc_configuration_server(
            self.0.pin_mut(),
            server.0.pin_mut(),
        );
    }
}

impl Default for RtcConfiguration {
    fn default() -> Self {
        Self(webrtc::create_default_rtc_configuration())
    }
}

/// [RTCIceServer][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtciceserver
pub struct IceServer(UniquePtr<webrtc::IceServer>);

impl IceServer {
    /// Adds a new `url` to the list of [urls][1] of this [`IceServer`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-urls
    pub fn add_url(&mut self, url: String) {
        webrtc::add_ice_server_url(self.0.pin_mut(), url);
    }

    /// Sets the [username][1] and [credential][2] of this [`IceServer`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-username
    /// [2]: https://w3.org/TR/webrtc#dom-rtciceserver-credential
    pub fn set_credentials(&mut self, username: String, credential: String) {
        webrtc::set_ice_server_credentials(
            self.0.pin_mut(),
            username,
            credential,
        );
    }
}

impl Default for IceServer {
    fn default() -> Self {
        Self(webrtc::create_ice_server())
    }
}

/// Member of [`PeerConnectionDependencies`] containing functions called on
/// events in a [`PeerConnectionInterface`]
pub struct PeerConnectionObserver(UniquePtr<webrtc::PeerConnectionObserver>);

impl PeerConnectionObserver {
    /// Creates a new [`PeerConnectionObserver`] backed by the provided
    /// [`PeerConnectionEventsHandler`]
    #[must_use]
    pub fn new(cb: Box<dyn PeerConnectionEventsHandler>) -> Self {
        Self(webrtc::create_peer_connection_observer(Box::new(cb)))
    }
}

unsafe impl Send for webrtc::PeerConnectionObserver {}
unsafe impl Sync for webrtc::PeerConnectionObserver {}

/// Contains all the [`PeerConnectionInterface`] dependencies.
pub struct PeerConnectionDependencies {
    /// Pointer to the C++ side `PeerConnectionDependencies` object.
    inner: UniquePtr<webrtc::PeerConnectionDependencies>,

    /// [`PeerConnectionObserver`] that these [`PeerConnectionDependencies`]
    /// depend on.
    ///
    /// It's stored here since it must outlive the dependencies object.
    observer: PeerConnectionObserver,
}

impl PeerConnectionDependencies {
    /// Creates a new [`PeerConnectionDependencies`] backed by the provided
    /// [`PeerConnectionObserver`].
    #[must_use]
    pub fn new(observer: PeerConnectionObserver) -> Self {
        Self {
            inner: webrtc::create_peer_connection_dependencies(&observer.0),
            observer,
        }
    }
}

/// Description of the options used to control an offer/answer creation process.
pub struct RTCOfferAnswerOptions(pub UniquePtr<webrtc::RTCOfferAnswerOptions>);

impl Default for RTCOfferAnswerOptions {
    fn default() -> Self {
        Self(webrtc::create_default_rtc_offer_answer_options())
    }
}

impl RTCOfferAnswerOptions {
    /// Creates a new [`RTCOfferAnswerOptions`].
    #[must_use]
    pub fn new(
        offer_to_receive_video: Option<bool>,
        offer_to_receive_audio: Option<bool>,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
    ) -> Self {
        Self(webrtc::create_rtc_offer_answer_options(
            offer_to_receive_video.map_or(-1, |f| if f { 1 } else { 0 }),
            offer_to_receive_audio.map_or(-1, |f| if f { 1 } else { 0 }),
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        ))
    }
}

/// [`SessionDescriptionInterface`] class, used by a [`PeerConnectionInterface`]
/// to expose local and remote session descriptions.
pub struct SessionDescriptionInterface(
    UniquePtr<webrtc::SessionDescriptionInterface>,
);

impl SessionDescriptionInterface {
    /// Creates a new [`SessionDescriptionInterface`].
    #[must_use]
    pub fn new(kind: webrtc::SdpType, sdp: &str) -> Self {
        let_cxx_string!(cxx_sdp = sdp);
        Self(webrtc::create_session_description(kind, &cxx_sdp))
    }
}

/// [`PeerConnectionInterface::create_answer()`] and
/// [`PeerConnectionInterface::create_offer()`] completion callback.
pub struct CreateSessionDescriptionObserver(
    UniquePtr<webrtc::CreateSessionDescriptionObserver>,
);

impl CreateSessionDescriptionObserver {
    /// Creates a new [`CreateSessionDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn CreateSdpCallback>) -> Self {
        Self(webrtc::create_create_session_observer(Box::new(cb)))
    }
}

/// [`PeerConnectionInterface::set_local_description()`] completion callback.
pub struct SetLocalDescriptionObserver(
    UniquePtr<webrtc::SetLocalDescriptionObserver>,
);

impl SetLocalDescriptionObserver {
    /// Creates a new [`SetLocalDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn SetDescriptionCallback>) -> Self {
        Self(webrtc::create_set_local_description_observer(Box::new(cb)))
    }
}

/// [`PeerConnectionInterface::set_remote_description()`] completion callback.
pub struct SetRemoteDescriptionObserver(
    UniquePtr<webrtc::SetRemoteDescriptionObserver>,
);

impl SetRemoteDescriptionObserver {
    /// Creates a new [`SetRemoteDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn SetDescriptionCallback>) -> Self {
        Self(webrtc::create_set_remote_description_observer(Box::new(cb)))
    }
}

/// Representation of a combination of an [`RtpSenderInterface`] and an
/// [`RtpReceiverInterface`] sharing a common
/// [media stream "identification-tag"][1].
///
/// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
pub struct RtpTransceiverInterface {
    /// Pointer to the C++ side [`RtpTransceiverInterface`] object.
    ///
    /// [`RtpTransceiverInterface`]: webrtc::PeerConnectionInterface
    inner: UniquePtr<webrtc::RtpTransceiverInterface>,

    /// Configured [`MediaType`] of this [`RtpTransceiverInterface`].
    ///
    /// It cannot be changed, so it's fetched from the C++ side once and cached
    /// here.
    media_type: MediaType,
}

impl RtpTransceiverInterface {
    /// Returns a [`mid`][0] of this [`RtpTransceiverInterface`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtptransceiver-mid
    #[must_use]
    pub fn mid(&self) -> Option<String> {
        let mid = webrtc::get_transceiver_mid(&self.inner);
        (!mid.is_empty()).then(|| mid)
    }

    /// Returns a [`direction`][0] of this [`RtpTransceiverInterface`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver-direction
    #[must_use]
    pub fn direction(&self) -> webrtc::RtpTransceiverDirection {
        webrtc::get_transceiver_direction(&self.inner)
    }

    /// Returns a [`MediaType`] of this [`RtpTransceiverInterface`].
    #[must_use]
    pub fn media_type(&self) -> MediaType {
        self.media_type
    }

    /// Changes the preferred `direction` of this [`RtpTransceiverInterface`].
    pub fn set_direction(
        &self,
        direction: webrtc::RtpTransceiverDirection,
    ) -> anyhow::Result<()> {
        let err = webrtc::set_transceiver_direction(&self.inner, direction);
        if !err.is_empty() {
            bail!(
                "`RtpTransceiverInterface->SetDirectionWithError()` call \
                 failed: {err}",
            );
        }
        Ok(())
    }

    /// Returns the [`RtpSenderInterface`] object responsible for encoding and
    /// sending data to the remote peer.
    #[must_use]
    pub fn sender(&self) -> RtpSenderInterface {
        RtpSenderInterface(webrtc::transceiver_sender(&self.inner))
    }

    /// Returns the [`RtpReceiverInterface`] responsible for receiving and
    /// decoding incoming media data for the transceiver's stream.
    #[must_use]
    pub fn receiver(&self) -> RtpReceiverInterface {
        RtpReceiverInterface(webrtc::transceiver_receiver(&self.inner))
    }

    /// Irreversibly marks this [`RtpTransceiverInterface`] as stopping, unless
    /// it's already stopped.
    ///
    /// This will immediately cause this [`RtpTransceiverInterface`]'s sender to
    /// no longer send, and its receiver to no longer receive.
    pub fn stop(&self) -> anyhow::Result<()> {
        let err = webrtc::stop_transceiver(&self.inner);
        if !err.is_empty() {
            bail!(
                "`RtpTransceiverInterface->StopStandard()` call failed: {err}",
            );
        }
        Ok(())
    }
}

unsafe impl Send for webrtc::RtpTransceiverInterface {}
unsafe impl Sync for webrtc::RtpTransceiverInterface {}

/// [RTCRtpSender] allowing to control how a [MediaStreamTrack][1] is encoded
/// and transmitted to a remote peer.
///
/// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct RtpSenderInterface(UniquePtr<webrtc::RtpSenderInterface>);

impl RtpSenderInterface {
    /// Replaces the track currently being used as the sender's source with a
    /// new [`VideoTrackInterface`].
    pub fn replace_video_track(
        &self,
        track: Option<&VideoTrackInterface>,
    ) -> anyhow::Result<()> {
        let success = webrtc::replace_sender_video_track(
            &self.0,
            track.map_or(&UniquePtr::null(), |t| &t.inner),
        );

        if !success {
            bail!("`RtpSenderInterface::SetTrack` failed");
        }

        Ok(())
    }

    /// Replaces the track currently being used as the sender's source with a
    /// new [`AudioTrackInterface`].
    pub fn replace_audio_track(
        &self,
        track: Option<&AudioTrackInterface>,
    ) -> anyhow::Result<()> {
        let success = webrtc::replace_sender_audio_track(
            &self.0,
            track.map_or(&UniquePtr::null(), |t| &t.inner),
        );

        if !success {
            bail!("`RtpSenderInterface::SetTrack` failed");
        }

        Ok(())
    }
}

unsafe impl Send for webrtc::RtpSenderInterface {}
unsafe impl Sync for webrtc::RtpSenderInterface {}

/// [RTCRtpReceiver][0] allowing to inspect the receipt of a
/// [MediaStreamTrack][1].
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct RtpReceiverInterface(UniquePtr<webrtc::RtpReceiverInterface>);

impl RtpReceiverInterface {
    /// Returns the [`MediaStreamTrackInterface`] attribute, representing the
    /// track associated with this [`RtpReceiverInterface`] object receiver.
    #[must_use]
    pub fn track(&self) -> MediaStreamTrackInterface {
        MediaStreamTrackInterface(webrtc::rtp_receiver_track(&self.0))
    }

    /// Returns the [`RtpParameters`] object describing the current
    /// configuration for the encoding and transmission of media on the
    /// receiver's track.
    #[must_use]
    pub fn get_parameters(&self) -> RtpParameters {
        RtpParameters(webrtc::rtp_receiver_parameters(&self.0))
    }
}

unsafe impl Send for webrtc::RtpReceiverInterface {}
unsafe impl Sync for webrtc::RtpReceiverInterface {}

/// [RTCRtpCodecParameters][0] representation.
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters
pub struct RtpCodecParameters(webrtc::RtpCodecParametersContainer);

impl RtpCodecParameters {
    /// Returns the `name` of these [`RtpCodecParameters`].
    #[must_use]
    pub fn name(&self) -> String {
        webrtc::rtp_codec_parameters_name(&self.0.ptr).to_string()
    }

    /// Returns the [`payloadType`][0] of these [`RtpCodecParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters-payloadtype
    #[must_use]
    pub fn payload_type(&self) -> i32 {
        webrtc::rtp_codec_parameters_payload_type(&self.0.ptr)
    }

    /// Returns the [`clockRate`][0] of these [`RtpCodecParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters-clockrate
    #[must_use]
    pub fn clock_rate(&self) -> Option<i32> {
        webrtc::rtp_codec_parameters_clock_rate(&self.0.ptr).ok()
    }

    /// Returns the [`channels`][0] of these [`RtpCodecParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters-channels
    #[must_use]
    pub fn num_channels(&self) -> Option<i32> {
        webrtc::rtp_codec_parameters_num_channels(&self.0.ptr).ok()
    }

    /// Returns the `parameters` of these [`RtpCodecParameters`].
    #[must_use]
    pub fn parameters(&self) -> HashMap<String, String> {
        let mut result = HashMap::new();
        let mut params = webrtc::rtp_codec_parameters_parameters(&self.0.ptr);
        while let Some(pair) = params.pin_mut().pop() {
            result.insert(pair.first, pair.second);
        }
        result
    }

    /// Returns the [`MediaType`] of these [`RtpCodecParameters`].
    #[must_use]
    pub fn kind(&self) -> MediaType {
        webrtc::rtp_codec_parameters_kind(&self.0.ptr)
    }
}

/// [RTCRtpHeaderExtensionParameters][0] representation.
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpheaderextensionparameters
pub struct RtpExtension(webrtc::RtpExtensionContainer);

impl RtpExtension {
    /// Returns the [`uri`][0] of this [`RtpExtension`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpheaderextensionparameters-uri
    #[must_use]
    pub fn uri(&self) -> String {
        webrtc::rtp_extension_uri(&self.0.ptr).to_string()
    }

    /// Returns the [`id`][0] of this [`RtpExtension`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpheaderextensionparameters-id
    #[must_use]
    pub fn id(&self) -> i32 {
        webrtc::rtp_extension_id(&self.0.ptr)
    }

    /// Returns the [`encrypted`][0] property of this [`RtpExtension`].
    ///
    /// [0]: https://tinyurl.com/headerparameters-encrypted
    #[must_use]
    pub fn encrypt(&self) -> bool {
        webrtc::rtp_extension_encrypt(&self.0.ptr)
    }
}

/// [RTCRtpEncodingParameters][0] representation.
///
/// [0]: https://w3.org/TR/webrtc/#dom-rtcrtpencodingparameters
pub struct RtpEncodingParameters(webrtc::RtpEncodingParametersContainer);

impl RtpEncodingParameters {
    /// Returns the [`active`][0] property of these [`RtpEncodingParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpencodingparameters-active
    #[must_use]
    pub fn active(&self) -> bool {
        webrtc::rtp_encoding_parameters_active(&self.0.ptr)
    }

    /// Returns the [`maxBitrate`][0] of these [`RtpEncodingParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpencodingparameters-maxbitrate
    #[must_use]
    pub fn max_bitrate(&self) -> Option<i32> {
        webrtc::rtp_encoding_parameters_maxBitrate(&self.0.ptr).ok()
    }

    /// Returns the `minBitrate` of these [`RtpEncodingParameters`].
    #[must_use]
    pub fn min_bitrate(&self) -> Option<i32> {
        webrtc::rtp_encoding_parameters_minBitrate(&self.0.ptr).ok()
    }

    /// Returns the `maxFramerate` of these [`RtpEncodingParameters`].
    #[must_use]
    pub fn max_framerate(&self) -> Option<f64> {
        webrtc::rtp_encoding_parameters_maxFramerate(&self.0.ptr).ok()
    }

    /// Returns the `ssrc` of these [`RtpEncodingParameters`].
    #[must_use]
    pub fn ssrc(&self) -> Option<i64> {
        webrtc::rtp_encoding_parameters_ssrc(&self.0.ptr).ok()
    }

    /// Returns the [`scaleResolutionDownBy`][0] of these
    /// [`RtpEncodingParameters`].
    ///
    /// [0]: https://tinyurl.com/scaleresolutiondownby
    #[must_use]
    pub fn scale_resolution_down_by(&self) -> Option<f64> {
        webrtc::rtp_encoding_parameters_scale_resolution_down_by(&self.0.ptr)
            .ok()
    }
}

/// [RTCRtcpParameters][0] representation.
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtcpparameters
pub struct RtcpParameters(UniquePtr<webrtc::RtcpParameters>);

impl RtcpParameters {
    /// Returns the [`cname`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtcpparameters-cname
    #[must_use]
    pub fn cname(&self) -> String {
        webrtc::rtcp_parameters_cname(&self.0).to_string()
    }

    /// Returns the [`reducedSize`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtcpparameters-reducedsize
    #[must_use]
    pub fn reduced_size(&self) -> bool {
        webrtc::rtcp_parameters_reduced_size(&self.0)
    }
}

/// Parameters being used by an [`RtpReceiverInterface`]'s RTP
/// connection with a remote peer.
pub struct RtpParameters(UniquePtr<webrtc::RtpParameters>);

impl RtpParameters {
    /// Returns the `parameters` of these [`RtpParameters`].
    #[must_use]
    pub fn transaction_id(&self) -> String {
        webrtc::rtp_parameters_transaction_id(&self.0).to_string()
    }

    /// Returns the `mid` of these [`RtpParameters`].
    #[must_use]
    pub fn mid(&self) -> String {
        webrtc::rtp_parameters_mid(&self.0).to_string()
    }

    /// Returns the [`codecs`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpparameters-codecs
    #[must_use]
    pub fn codecs(&self) -> Vec<RtpCodecParameters> {
        webrtc::rtp_parameters_codecs(&self.0)
            .into_iter()
            .map(RtpCodecParameters)
            .collect()
    }

    /// Returns the [`headerExtensions`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpparameters-headerextensions
    #[must_use]
    pub fn header_extensions(&self) -> Vec<RtpExtension> {
        webrtc::rtp_parameters_header_extensions(&self.0)
            .into_iter()
            .map(RtpExtension)
            .collect()
    }

    /// Returns the `encodings` of these [`RtpParameters`].
    #[must_use]
    pub fn encodings(&self) -> Vec<RtpEncodingParameters> {
        webrtc::rtp_parameters_encodings(&self.0)
            .into_iter()
            .map(RtpEncodingParameters)
            .collect()
    }

    /// Returns the [`rtcp`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpparameters-rtcp
    #[must_use]
    pub fn rtcp(&self) -> RtcpParameters {
        RtcpParameters(webrtc::rtp_parameters_rtcp(&self.0))
    }
}
/// This interface describes an ICE candidate, described in
/// [RFC 5245 Section 2][1].
///
/// [1]: https://datatracker.ietf.org/doc/html/rfc5245#section-2
pub struct IceCandidateInterface(UniquePtr<webrtc::IceCandidateInterface>);

impl IceCandidateInterface {
    /// Creates a new [`IceCandidateInterface`].
    pub fn new(
        sdp_mid: &str,
        sdp_mline_index: i32,
        candidate: &str,
    ) -> anyhow::Result<Self> {
        let mut error = String::new();
        let inner = webrtc::create_ice_candidate(
            sdp_mid,
            sdp_mline_index,
            candidate,
            &mut error,
        );

        if !error.is_empty() {
            bail!(error);
        }

        Ok(Self(inner))
    }

    /// Returns this [`IceCandidateInterface`]'s [`sdpMid`][1].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-sdpmid
    #[must_use]
    pub fn mid(&self) -> String {
        webrtc::sdp_mid_of_ice_candidate(&self.0).to_string()
    }

    /// Returns this [`IceCandidateInterface`] in a [string format][1].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-candidate
    #[must_use]
    pub fn candidate(&self) -> String {
        webrtc::ice_candidate_interface_to_string(&self.0).to_string()
    }

    /// Returns this [`IceCandidateInterface`]'s [`sdpMLineIndex`][1].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-sdpmlineindex
    #[must_use]
    pub fn mline_index(&self) -> i32 {
        webrtc::sdp_mline_index_of_ice_candidate(&self.0)
    }
}

/// [RTCPeerConnection][1] implementation.
///
/// Calls to a [`PeerConnectionInterface`] APIs are proxied to the signaling
/// thread, meaning that an application can call those APIs from whatever
/// thread. See the "Threading Model" section in the
/// [Native APIs documentation][2].
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
/// [2]: https://webrtc.github.io/webrtc-org/native-code/native-apis
pub struct PeerConnectionInterface {
    /// Pointer to the C++ side [`PeerConnectionInterface`] object.
    ///
    /// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
    inner: UniquePtr<webrtc::PeerConnectionInterface>,

    /// [`PeerConnectionObserver`] that this [`PeerConnectionInterface`]
    /// uses internally.
    ///
    /// It's stored here since it must outlive the peer connection object.
    _observer: PeerConnectionObserver,
}

unsafe impl Sync for webrtc::PeerConnectionInterface {}
unsafe impl Send for webrtc::PeerConnectionInterface {}

impl PeerConnectionInterface {
    /// [RTCPeerConnection.createOffer()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection-createoffer
    pub fn create_offer(
        &mut self,
        options: &RTCOfferAnswerOptions,
        obs: CreateSessionDescriptionObserver,
    ) {
        webrtc::create_offer(self.inner.pin_mut(), &options.0, obs.0);
    }

    /// [RTCPeerConnection.createAnswer()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection-createanswer
    pub fn create_answer(
        &mut self,
        options: &RTCOfferAnswerOptions,
        obs: CreateSessionDescriptionObserver,
    ) {
        webrtc::create_answer(self.inner.pin_mut(), &options.0, obs.0);
    }

    /// [RTCPeerConnection.setLocalDescription()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-peerconnection-setlocaldescription
    pub fn set_local_description(
        &mut self,
        desc: SessionDescriptionInterface,
        obs: SetLocalDescriptionObserver,
    ) {
        webrtc::set_local_description(self.inner.pin_mut(), desc.0, obs.0);
    }

    /// [RTCPeerConnection.setRemoteDescription()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-peerconnection-setremotedescription
    pub fn set_remote_description(
        &mut self,
        desc: SessionDescriptionInterface,
        obs: SetRemoteDescriptionObserver,
    ) {
        webrtc::set_remote_description(self.inner.pin_mut(), desc.0, obs.0);
    }

    /// Creates a new [`RtpTransceiverInterface`] and adds it to the set of
    /// transceivers of this [`PeerConnectionInterface`].
    pub fn add_transceiver(
        &mut self,
        media_type: MediaType,
        direction: RtpTransceiverDirection,
    ) -> RtpTransceiverInterface {
        let inner = webrtc::add_transceiver(
            self.inner.pin_mut(),
            media_type,
            direction,
        );

        RtpTransceiverInterface { inner, media_type }
    }

    /// Returns a sequence of [`RtpTransceiverInterface`] objects representing
    /// the RTP transceivers currently attached to this
    /// [`PeerConnectionInterface`].
    #[must_use]
    pub fn get_transceivers(&self) -> Vec<RtpTransceiverInterface> {
        webrtc::get_transceivers(&self.inner)
            .into_iter()
            .map(|t| RtpTransceiverInterface {
                media_type: webrtc::get_transceiver_media_type(&t.ptr),
                inner: t.ptr,
            })
            .collect()
    }

    /// Adds an [`IceCandidateInterface`] to the [`PeerConnectionInterface`].
    pub fn add_ice_candidate(
        &self,
        candidate: IceCandidateInterface,
        cb: Box<dyn AddIceCandidateCallback>,
    ) {
        webrtc::add_ice_candidate(&self.inner, candidate.0, Box::new(cb));
    }

    /// Tells the [`PeerConnectionInterface`] that ICE should be restarted.
    pub fn restart_ice(&self) {
        webrtc::restart_ice(&self.inner);
    }

    /// Closes the [`PeerConnectionInterface`].
    pub fn close(&self) {
        webrtc::close_peer_connection(&self.inner);
    }
}

/// Interface for using an RTC [`Thread`][1].
///
/// [1]: https://tinyurl.com/doc-threads
pub struct Thread(UniquePtr<webrtc::Thread>);

impl Thread {
    /// Creates a new [`Thread`].
    ///
    /// If `with_socket_server` is `true`, then the created thread will have a
    /// socket server attached, thus it will be capable of serving as a network
    /// thread.
    pub fn create(with_socket_server: bool) -> anyhow::Result<Self> {
        let ptr = if with_socket_server {
            webrtc::create_thread_with_socket_server()
        } else {
            webrtc::create_thread()
        };

        if ptr.is_null() {
            bail!("`null` pointer returned from `rtc::Thread::Create()`");
        }
        Ok(Self(ptr))
    }

    /// Starts the [`Thread`].
    pub fn start(&mut self) -> anyhow::Result<()> {
        if !self.0.pin_mut().start_thread() {
            bail!("`rtc::Thread::Start()` failed");
        }
        Ok(())
    }
}

unsafe impl Send for webrtc::Thread {}
unsafe impl Sync for webrtc::Thread {}

/// [`PeerConnectionFactoryInterface`] is the main entry point to the
/// `PeerConnection API` for clients it is responsible for creating
/// [`AudioSourceInterface`], tracks ([`VideoTrackInterface`],
/// [`AudioTrackInterface`]), [`MediaStreamInterface`] and the
/// `PeerConnection`s.
pub struct PeerConnectionFactoryInterface(
    UniquePtr<webrtc::PeerConnectionFactoryInterface>,
);

impl PeerConnectionFactoryInterface {
    /// Creates a new [`PeerConnectionFactoryInterface`].
    pub fn create(
        network_thread: Option<&Thread>,
        worker_thread: Option<&Thread>,
        signaling_thread: Option<&Thread>,
        default_adm: Option<&AudioDeviceModule>,
    ) -> anyhow::Result<Self> {
        let inner = webrtc::create_peer_connection_factory(
            network_thread.map_or(&UniquePtr::null(), |t| &t.0),
            worker_thread.map_or(&UniquePtr::null(), |t| &t.0),
            signaling_thread.map_or(&UniquePtr::null(), |t| &t.0),
            default_adm.map_or(&UniquePtr::null(), |t| &t.0),
        );

        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::CreatePeerConnectionFactory()`",
            );
        }
        Ok(Self(inner))
    }

    /// Creates a new [`PeerConnectionInterface`].
    pub fn create_peer_connection_or_error(
        &mut self,
        configuration: &RtcConfiguration,
        dependencies: PeerConnectionDependencies,
    ) -> anyhow::Result<PeerConnectionInterface> {
        let mut error = String::new();
        let inner = webrtc::create_peer_connection_or_error(
            self.0.pin_mut(),
            &configuration.0,
            dependencies.inner,
            &mut error,
        );

        if !error.is_empty() {
            bail!(error);
        }
        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::\
                 CreatePeerConnectionOrError()`",
            );
        }
        Ok(PeerConnectionInterface {
            inner,
            _observer: dependencies.observer,
        })
    }

    /// Creates a new [`AudioSourceInterface`], which provides sound recording
    /// from native platform.
    pub fn create_audio_source(&self) -> anyhow::Result<AudioSourceInterface> {
        let ptr = webrtc::create_audio_source(&self.0);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateAudioSource()`",
            );
        }
        Ok(AudioSourceInterface(ptr))
    }

    /// Creates a new [`VideoTrackInterface`] sourced by the provided
    /// [`VideoTrackSourceInterface`].
    pub fn create_video_track(
        &self,
        id: String,
        video_src: &VideoTrackSourceInterface,
    ) -> anyhow::Result<VideoTrackInterface> {
        let inner = webrtc::create_video_track(&self.0, id, &video_src.0);

        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateVideoTrack()`",
            );
        }
        Ok(VideoTrackInterface {
            inner,
            observers: Vec::new(),
        })
    }

    /// Creates a new [`AudioTrackInterface`] sourced by the provided
    /// [`AudioSourceInterface`].
    pub fn create_audio_track(
        &self,
        id: String,
        audio_src: &AudioSourceInterface,
    ) -> anyhow::Result<AudioTrackInterface> {
        let inner = webrtc::create_audio_track(&self.0, id, &audio_src.0);

        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateAudioTrack()`",
            );
        }
        Ok(AudioTrackInterface {
            inner,
            observers: Vec::new(),
        })
    }

    /// Creates a new empty [`MediaStreamInterface`].
    pub fn create_local_media_stream(
        &self,
        id: String,
    ) -> anyhow::Result<MediaStreamInterface> {
        let ptr = webrtc::create_local_media_stream(&self.0, id);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::\
                 CreateLocalMediaStream()`",
            );
        }
        Ok(MediaStreamInterface(ptr))
    }
}

unsafe impl Send for webrtc::PeerConnectionFactoryInterface {}
unsafe impl Sync for webrtc::PeerConnectionFactoryInterface {}

/// [`VideoTrackSourceInterface`] captures data from the specific video input
/// device.
///
/// It can be later used to create a [`VideoTrackInterface`] with
/// [`PeerConnectionFactoryInterface::create_video_track()`].
pub struct VideoTrackSourceInterface(
    UniquePtr<webrtc::VideoTrackSourceInterface>,
);

impl VideoTrackSourceInterface {
    /// Creates a new [`VideoTrackSourceInterface`] from the video input device
    /// with the specified constraints.
    ///
    /// The created capturer is wrapped in the `VideoTrackSourceProxy` that
    /// makes sure the real [`VideoTrackSourceInterface`] implementation is
    /// destroyed on the signaling thread and marshals all method calls to the
    /// signaling thread.
    pub fn create_proxy_from_device(
        worker_thread: &mut Thread,
        signaling_thread: &mut Thread,
        width: usize,
        height: usize,
        fps: usize,
        device_index: u32,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_device_video_source(
            worker_thread.0.pin_mut(),
            signaling_thread.0.pin_mut(),
            width,
            height,
            fps,
            device_index,
        );

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::CreateVideoTrackSourceProxy()`",
            );
        }
        Ok(VideoTrackSourceInterface(ptr))
    }

    // TODO: Support screens enumeration.
    /// Starts screen capturing and creates a new [`VideoTrackSourceInterface`]
    /// with the specified constraints.
    ///
    /// The created capturer is wrapped in the `VideoTrackSourceProxy` that
    /// makes sure the real [`VideoTrackSourceInterface`] implementation is
    /// destroyed on the signaling thread and marshals all method calls to the
    /// signaling thread.
    pub fn create_proxy_from_display(
        worker_thread: &mut Thread,
        signaling_thread: &mut Thread,
        width: usize,
        height: usize,
        fps: usize,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_display_video_source(
            worker_thread.0.pin_mut(),
            signaling_thread.0.pin_mut(),
            width,
            height,
            fps,
        );

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::CreateVideoTrackSourceProxy()`",
            );
        }
        Ok(VideoTrackSourceInterface(ptr))
    }
}

unsafe impl Send for webrtc::VideoTrackSourceInterface {}
unsafe impl Sync for webrtc::VideoTrackSourceInterface {}

/// [`VideoTrackSourceInterface`] captures data from the specific audio input
/// device.
///
/// It can be later used to create a [`AudioTrackInterface`] with
/// [`PeerConnectionFactoryInterface::create_audio_track()`].
pub struct AudioSourceInterface(UniquePtr<webrtc::AudioSourceInterface>);

unsafe impl Send for webrtc::AudioSourceInterface {}
unsafe impl Sync for webrtc::AudioSourceInterface {}

/// [MediaStreamTrack] object representing a media source in an User Agent.
///
/// An example source is a device connected to the User Agent.
///
/// [MediaStreamTrack]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
pub struct MediaStreamTrackInterface(
    UniquePtr<webrtc::MediaStreamTrackInterface>,
);

impl MediaStreamTrackInterface {
    /// Returns the [`String`] containing the unique identifier (GUID) of this
    /// track.
    #[must_use]
    pub fn id(&self) -> String {
        webrtc::media_stream_track_id(&self.0).to_string()
    }

    /// Returns the [`TrackState`] of this [`MediaStreamTrackInterface`].
    #[must_use]
    pub fn state(&self) -> webrtc::TrackState {
        webrtc::media_stream_track_state(&self.0)
    }

    /// Returns the `enabled` property of this [`MediaStreamTrackInterface`],
    /// which is a [`bool`] indicating `true` if this track is allowed to render
    /// the source stream, or `false` otherwise.
    #[must_use]
    pub fn enabled(&self) -> bool {
        webrtc::media_stream_track_enabled(&self.0)
    }

    /// Returns the [`TrackKind`] of this [`MediaStreamTrackInterface`].
    #[must_use]
    pub fn kind(&self) -> TrackKind {
        let kind = webrtc::media_stream_track_kind(&self.0).to_string();
        match kind.as_str() {
            "audio" => TrackKind::Audio,
            "video" => TrackKind::Video,
            _ => unreachable!(),
        }
    }
}

/// C++ side [`TrackEventCallback`] handling [`MediaStreamTrackInterface`]
/// events.
pub struct TrackEventObserver(UniquePtr<webrtc::TrackEventObserver>);

impl TrackEventObserver {
    /// Creates a new [`TrackEventObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn TrackEventCallback>) -> Self {
        TrackEventObserver(webrtc::create_track_event_observer(Box::new(cb)))
    }

    /// Sets the observable track to the specified [`VideoTrackInterface`].
    pub fn set_video_track(&mut self, track: &VideoTrackInterface) {
        webrtc::set_track_observer_video_track(self.0.pin_mut(), &track.inner);
    }

    /// Sets the observable track to the specified [`AudioTrackInterface`].
    pub fn set_audio_track(&mut self, track: &AudioTrackInterface) {
        webrtc::set_track_observer_audio_track(self.0.pin_mut(), &track.inner);
    }
}

unsafe impl Send for webrtc::TrackEventObserver {}
unsafe impl Sync for webrtc::TrackEventObserver {}

/// Video [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct VideoTrackInterface {
    /// Pointer to the C++ side `VideoTrackInterface` object.
    inner: UniquePtr<webrtc::VideoTrackInterface>,

    /// [`TrackEventObserver`]s subscribed to this [`VideoTrackInterface`] state
    /// changes.
    observers: Vec<TrackEventObserver>,
}

impl VideoTrackInterface {
    /// Register the provided [`VideoSinkInterface`] for this
    /// [`VideoTrackInterface`].
    ///
    /// Used to connect this [`VideoTrackInterface`] to the underlying video
    /// engine.
    pub fn add_or_update_sink(&self, sink: &mut VideoSinkInterface) {
        webrtc::add_or_update_video_sink(&self.inner, sink.0.pin_mut());
    }

    /// Detaches the provided [`VideoSinkInterface`] from this
    /// [`VideoTrackInterface`].
    pub fn remove_sink(&self, sink: &mut VideoSinkInterface) {
        webrtc::remove_video_sink(&self.inner, sink.0.pin_mut());
    }

    /// Changes the [enabled][1] property of this [`VideoTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        webrtc::set_video_track_enabled(&self.inner, enabled);
    }

    /// Registers the given [`TrackEventCallback`] as an observer of this
    /// [`MediaStreamTrackInterface`] events.
    pub fn register_observer(&mut self, mut obs: TrackEventObserver) {
        webrtc::video_track_register_observer(
            self.inner.pin_mut(),
            obs.0.pin_mut(),
        );
        self.observers.push(obs);
    }

    /// Returns the [`VideoTrackSourceInterface`] attached to this
    /// [`VideoTrackInterface`].
    #[must_use]
    pub fn source(&self) -> VideoTrackSourceInterface {
        VideoTrackSourceInterface(webrtc::get_video_track_source(&self.inner))
    }
}

impl Drop for VideoTrackInterface {
    fn drop(&mut self) {
        let observers = mem::take(&mut self.observers);

        for mut obs in observers {
            webrtc::video_track_unregister_observer(
                self.inner.pin_mut(),
                obs.0.pin_mut(),
            );
        }
    }
}

unsafe impl Send for webrtc::VideoTrackInterface {}
unsafe impl Sync for webrtc::VideoTrackInterface {}

impl TryFrom<MediaStreamTrackInterface> for VideoTrackInterface {
    type Error = anyhow::Error;

    fn try_from(track: MediaStreamTrackInterface) -> anyhow::Result<Self> {
        if track.kind() == TrackKind::Video {
            let inner =
                webrtc::media_stream_track_interface_downcast_video_track(
                    track.0,
                );
            Ok(VideoTrackInterface {
                inner,
                observers: Vec::new(),
            })
        } else {
            bail!(
                "The provided `MediaStreamTrackInterface` is not an instance \
                 of `VideoTrackInterface`"
            );
        }
    }
}

/// Audio [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct AudioTrackInterface {
    /// Pointer to the C++ side `AudioTrackInterface` object.
    inner: UniquePtr<webrtc::AudioTrackInterface>,

    /// [`TrackEventObserver`]s subscribed to this [`AudioTrackInterface`] state
    /// changes.
    observers: Vec<TrackEventObserver>,
}

impl AudioTrackInterface {
    /// Changes the [enabled][1] property of this [`AudioTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        webrtc::set_audio_track_enabled(&self.inner, enabled);
    }

    /// Registers the provided [`TrackEventCallback`] as an observer of this
    /// [`MediaStreamTrackInterface`] events.
    pub fn register_observer(&mut self, mut obs: TrackEventObserver) {
        webrtc::audio_track_register_observer(
            self.inner.pin_mut(),
            obs.0.pin_mut(),
        );
        self.observers.push(obs);
    }

    /// Returns the [`AudioSourceInterface`] attached to this
    /// [`AudioTrackInterface`].
    #[must_use]
    pub fn source(&self) -> AudioSourceInterface {
        AudioSourceInterface(webrtc::get_audio_track_source(&self.inner))
    }
}

impl Drop for AudioTrackInterface {
    fn drop(&mut self) {
        let observers = mem::take(&mut self.observers);

        for mut obs in observers {
            webrtc::audio_track_unregister_observer(
                self.inner.pin_mut(),
                obs.0.pin_mut(),
            );
        }
    }
}

unsafe impl Send for webrtc::AudioTrackInterface {}
unsafe impl Sync for webrtc::AudioTrackInterface {}

impl TryFrom<MediaStreamTrackInterface> for AudioTrackInterface {
    type Error = anyhow::Error;

    fn try_from(track: MediaStreamTrackInterface) -> anyhow::Result<Self> {
        if track.kind() == TrackKind::Audio {
            let inner =
                webrtc::media_stream_track_interface_downcast_audio_track(
                    track.0,
                );
            Ok(AudioTrackInterface {
                inner,
                observers: Vec::new(),
            })
        } else {
            bail!(
                "The provided `MediaStreamTrackInterface` is not an instance \
                 of `AudioTrackInterface`"
            );
        }
    }
}

/// [`MediaStreamInterface`][1] representation.
///
/// [1]: https://w3.org/TR/mediacapture-streams#mediastream
pub struct MediaStreamInterface(UniquePtr<webrtc::MediaStreamInterface>);

impl MediaStreamInterface {
    /// Adds the provided [`VideoTrackInterface`] to this
    /// [`MediaStreamInterface`].
    pub fn add_video_track(
        &self,
        track: &VideoTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::add_video_track(&self.0, &track.inner);

        if !result {
            bail!("`webrtc::MediaStreamInterface::AddTrack()` failed");
        }
        Ok(())
    }

    /// Adds the provided  [`AudioTrackInterface`] to this
    /// [`MediaStreamInterface`].
    pub fn add_audio_track(
        &self,
        track: &AudioTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::add_audio_track(&self.0, &track.inner);

        if !result {
            bail!("`webrtc::MediaStreamInterface::AddTrack()` failed");
        }
        Ok(())
    }

    /// Removes the provided [`VideoTrackInterface`] from this
    /// [`MediaStreamInterface`].
    pub fn remove_video_track(
        &self,
        track: &VideoTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::remove_video_track(&self.0, &track.inner);

        if !result {
            bail!("`webrtc::MediaStreamInterface::RemoveTrack()` failed");
        }
        Ok(())
    }

    /// Removes the provided [`AudioTrackInterface`] from this
    /// [`MediaStreamInterface`].
    pub fn remove_audio_track(
        &self,
        track: &AudioTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::remove_audio_track(&self.0, &track.inner);

        if !result {
            bail!("`webrtc::MediaStreamInterface::RemoveTrack()` failed");
        }
        Ok(())
    }
}

unsafe impl Send for webrtc::MediaStreamInterface {}
unsafe impl Sync for webrtc::MediaStreamInterface {}

/// End point of a video pipeline.
pub struct VideoSinkInterface(UniquePtr<webrtc::VideoSinkInterface>);

impl VideoSinkInterface {
    /// Creates a new [`VideoSinkInterface`] forwarding [`VideoFrame`]s to
    /// the provided [`OnFrameCallback`].
    #[must_use]
    pub fn create_forwarding(cb: Box<dyn OnFrameCallback>) -> Self {
        Self(webrtc::create_forwarding_video_sink(Box::new(cb)))
    }
}

unsafe impl Send for webrtc::VideoSinkInterface {}
unsafe impl Sync for webrtc::VideoSinkInterface {}
