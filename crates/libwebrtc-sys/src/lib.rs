#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]

mod bridge;

use anyhow::bail;
use cxx::{let_cxx_string, CxxString, CxxVector, UniquePtr};

use self::bridge::webrtc;

pub use crate::webrtc::{
    candidate_to_string, get_candidate_pair,
    get_estimated_disconnected_time_ms, get_last_data_received_ms, get_reason,
    ice_candidate_interface_to_string, video_frame_to_abgr, AudioLayer,
    Candidate, CandidatePairChangeEvent, IceCandidateInterface,
    IceConnectionState, IceGatheringState, PeerConnectionState, SdpType,
    SignalingState, VideoFrame, VideoRotation,
};

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
    /// [1]: https://www.w3.org/TR/webrtc/#event-icecandidateerror
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
    fn on_ice_candidate(
        &mut self,
        candidate: *const webrtc::IceCandidateInterface,
    );

    /// Called when some ICE candidates have been removed.
    fn on_ice_candidates_removed(&mut self, candidates: &CxxVector<Candidate>);

    /// Called when a [`selectedcandidatepairchange`][1] event occurs.
    ///
    /// [1]: https://tinyurl.com/w3-selectedcandidatepairchange
    fn on_ice_selected_candidate_pair_changed(
        &mut self,
        event: &CandidatePairChangeEvent,
    );
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

/// Available audio devices manager that is responsible for driving input
/// (microphone) and output (speaker) audio in WebRTC.
///
/// Backed by WebRTC's [Audio Device Module].
///
/// [Audio Device Module]: https://tinyurl.com/doc-adm
pub struct AudioDeviceModule(UniquePtr<webrtc::AudioDeviceModule>);

impl AudioDeviceModule {
    /// Creates a new [`AudioDeviceModule`] for the given [`AudioLayer`].
    pub fn create(
        audio_layer: AudioLayer,
        task_queue_factory: &mut TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_audio_device_module(
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
            bail!("`AudioDeviceModule::Init()` failed with `{}` code", result);
        }
        Ok(())
    }

    /// Returns count of available audio playout devices.
    pub fn playout_devices(&self) -> anyhow::Result<i16> {
        let count = webrtc::playout_devices(&self.0);

        if count < 0 {
            bail!(
                "`AudioDeviceModule::PlayoutDevices()` failed with `{}` code",
                count,
            );
        }

        Ok(count)
    }

    /// Returns count of available audio recording devices.
    pub fn recording_devices(&self) -> anyhow::Result<i16> {
        let count = webrtc::recording_devices(&self.0);

        if count < 0 {
            bail!(
                "`AudioDeviceModule::RecordingDevices()` failed with `{}` code",
                count
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
                "`AudioDeviceModule::PlayoutDeviceName()` failed with `{}` \
                 code",
                result,
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
                 `{}` code",
                result,
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
                 `{}` code.",
                result,
            );
        }

        Ok(())
    }
}

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
                "`AudioDeviceModule::GetDeviceName()` failed with `{}` code",
                result,
            );
        }

        Ok((name, guid))
    }
}

/// WebRTC [RTCConfiguration][1].
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration
pub struct RTCConfiguration(UniquePtr<webrtc::RTCConfiguration>);

impl Default for RTCConfiguration {
    fn default() -> Self {
        Self(webrtc::create_default_rtc_configuration())
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

/// [RTCPeerConnection][1] implementation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
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
}

/// Interface for using an RTC [`Thread`][1].
///
/// [1]: https://tinyurl.com/doc-threads
pub struct Thread(UniquePtr<webrtc::Thread>);

impl Thread {
    /// Creates a new [`Thread`].
    pub fn create() -> anyhow::Result<Self> {
        let ptr = webrtc::create_thread();

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
        configuration: &RTCConfiguration,
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
        let ptr = webrtc::create_video_track(&self.0, id, &video_src.0);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateVideoTrack()`",
            );
        }
        Ok(VideoTrackInterface(ptr))
    }

    /// Creates a new [`AudioTrackInterface`] sourced by the provided
    /// [`AudioSourceInterface`].
    pub fn create_audio_track(
        &self,
        id: String,
        audio_src: &AudioSourceInterface,
    ) -> anyhow::Result<AudioTrackInterface> {
        let ptr = webrtc::create_audio_track(&self.0, id, &audio_src.0);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateAudioTrack()`",
            );
        }
        Ok(AudioTrackInterface(ptr))
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

/// [`VideoTrackSourceInterface`] captures data from the specific audio input
/// device.
///
/// It can be later used to create a [`AudioTrackInterface`] with
/// [`PeerConnectionFactoryInterface::create_audio_track()`].
pub struct AudioSourceInterface(UniquePtr<webrtc::AudioSourceInterface>);

/// Video [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct VideoTrackInterface(UniquePtr<webrtc::VideoTrackInterface>);

impl VideoTrackInterface {
    /// Register the provided [`VideoSinkInterface`] for this
    /// [`VideoTrackInterface`].
    ///
    /// Used to connect this [`VideoTrackInterface`] to the underlying video
    /// engine.
    pub fn add_or_update_sink(&self, sink: &mut VideoSinkInterface) {
        webrtc::add_or_update_video_sink(&self.0, sink.0.pin_mut());
    }

    /// Detaches the provided [`VideoSinkInterface`] from this
    /// [`VideoTrackInterface`].
    pub fn remove_sink(&self, sink: &mut VideoSinkInterface) {
        webrtc::remove_video_sink(&self.0, sink.0.pin_mut());
    }

    /// Changes the [enabled][1] property of this [`VideoTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        webrtc::set_video_track_enabled(&self.0, enabled);
    }
}

/// Audio [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct AudioTrackInterface(UniquePtr<webrtc::AudioTrackInterface>);

impl AudioTrackInterface {
    /// Changes the [enabled][1] property of this [`AudioTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        webrtc::set_audio_track_enabled(&self.0, enabled);
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
        let result = webrtc::add_video_track(&self.0, &track.0);

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
        let result = webrtc::add_audio_track(&self.0, &track.0);

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
        let result = webrtc::remove_video_track(&self.0, &track.0);

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
        let result = webrtc::remove_audio_track(&self.0, &track.0);

        if !result {
            bail!("`webrtc::MediaStreamInterface::RemoveTrack()` failed");
        }
        Ok(())
    }
}

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
