use std::sync::{Arc, Mutex};

use once_cell::sync::OnceCell;
use sys::PeerConnectionInterface;
use threadpool::ThreadPool;

use crate::{
    api,
    internal::{
        AddIceCandidateCallbackInterface, CreateSdpCallbackInterface,
        PeerConnectionObserverInterface, SetDescriptionCallbackInterface,
    },
    next_id, AudioTrack, AudioTrackId, VideoTrack, VideoTrackId, Webrtc,
};
use cxx::{let_cxx_string, CxxString, CxxVector, UniquePtr};
use dashmap::DashMap;
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;

impl Webrtc {
    /// Creates a new [`PeerConnection`] and returns its ID.
    ///
    /// Writes an error to the provided `err` if any.
    pub fn create_peer_connection(
        self: &mut Webrtc,
        obs: UniquePtr<PeerConnectionObserverInterface>,
        configuration: api::RtcConfiguration,
        error: &mut String,
    ) -> u64 {
        let peer = PeerConnection::new(
            &mut self.0.peer_connection_factory,
            Arc::clone(&self.0.video_tracks),
            Arc::clone(&self.0.audio_tracks),
            obs,
            configuration,
            self.0.callback_pool.clone(),
        );
        match peer {
            Ok(peer) => {
                let id = next_id();
                self.0.peer_connections.insert(id.into(), peer);
                id
            }
            Err(err) => {
                error.push_str(&err.to_string());
                0
            }
        }
    }

    /// Initiates the creation of a SDP offer for the purpose of starting a new
    /// WebRTC connection to a remote peer.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn create_offer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: UniquePtr<CreateSdpCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
            CreateSdpCallback(cb),
        ));
        peer.0.lock().unwrap().create_offer(&options, obs);

        String::new()
    }

    /// Creates a SDP answer to an offer received from a remote peer during an
    /// offer/answer negotiation of a WebRTC connection.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn create_answer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: UniquePtr<CreateSdpCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
            CreateSdpCallback(cb),
        ));
        peer.0.lock().unwrap().create_answer(&options, obs);

        String::new()
    }

    /// Changes the local description associated with the connection.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_local_description(
        &mut self,
        peer_id: u64,
        kind: String,
        sdp: String,
        cb: UniquePtr<SetDescriptionCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let sdp_kind = match sys::SdpType::try_from(kind.as_str()) {
            Ok(kind) => kind,
            Err(e) => {
                return e.to_string();
            }
        };

        let desc = sys::SessionDescriptionInterface::new(sdp_kind, &sdp);
        let obs =
            sys::SetLocalDescriptionObserver::new(Box::new(SetSdpCallback(cb)));
        peer.0.lock().unwrap().set_local_description(desc, obs);

        String::new()
    }

    /// Sets the specified session description as the remote peer's current
    /// offer or answer.
    ///
    /// Returns an empty [`String`] if operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_remote_description(
        &mut self,
        peer_id: u64,
        kind: String,
        sdp: String,
        cb: UniquePtr<SetDescriptionCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let sdp_kind = match sys::SdpType::try_from(kind.as_str()) {
            Ok(kind) => kind,
            Err(e) => {
                return e.to_string();
            }
        };

        let desc = sys::SessionDescriptionInterface::new(sdp_kind, &sdp);
        let obs = sys::SetRemoteDescriptionObserver::new(Box::new(
            SetSdpCallback(cb),
        ));
        peer.0.lock().unwrap().set_remote_description(desc, obs);

        String::new()
    }

    /// Creates a new [`api::RtcRtpTransceiver`] and adds it to the set of
    /// transceivers of the specified [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot parse the given `media_type` and `direction` to a valid
    ///   [`sys::MediaType`] and [`sys::RtpTransceiverDirection`].
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex that guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn add_transceiver(
        &mut self,
        peer_id: u64,
        media_type: &str,
        direction: &str,
    ) -> api::RtcRtpTransceiver {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();
        let mut peer_ref = peer.0.lock().unwrap();

        let transceiver = peer_ref.add_transceiver(
            media_type.try_into().unwrap(),
            direction.try_into().unwrap(),
        );

        let transceivers = peer_ref.get_transceivers();
        let mid = transceiver.mid().unwrap_or_default();
        let direction = transceiver.direction().to_string();
        let id = transceivers
            .iter()
            .enumerate()
            .find(|(_, t)| transceiver.mid() == t.mid())
            .map(|(id, _)| id)
            .unwrap();

        api::RtcRtpTransceiver {
            id: id as u64,
            mid,
            direction,
            sender: api::RtcRtpSender { id: id as u64 },
        }
    }

    /// Returns a sequence of [`api::RtcRtpTransceiver`] objects representing
    /// the RTP transceivers currently attached to specified [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn get_transceivers(
        &mut self,
        peer_id: u64,
    ) -> Vec<api::RtcRtpTransceiver> {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        let transceivers = peer.0.lock().unwrap().get_transceivers();
        let mut result = Vec::with_capacity(transceivers.len());

        for (index, transceiver) in transceivers.into_iter().enumerate() {
            let info = api::RtcRtpTransceiver {
                id: index as u64,
                mid: transceiver.mid().unwrap_or_default(),
                direction: transceiver.direction().to_string(),
                sender: api::RtcRtpSender { id: index as u64 },
            };
            result.push(info);
        }

        result
    }

    /// Changes the preferred `direction` of the specified
    /// [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If cannot parse the given `direction` as a valid
    ///   [`sys::RtpTransceiverDirection`].
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn set_transceiver_direction(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
        direction: &str,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.0
            .lock()
            .unwrap()
            .get_transceivers()
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .set_direction(direction.try_into().unwrap())
            .map_or_else(|err| err.to_string(), |_| String::new())
    }

    /// Returns the [Negotiated media ID (mid)][1] of the specified
    /// [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub fn get_transceiver_mid(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.0
            .lock()
            .unwrap()
            .get_transceivers()
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .mid()
            .unwrap_or_default()
    }

    /// Returns the preferred direction of the specified [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn get_transceiver_direction(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.0
            .lock()
            .unwrap()
            .get_transceivers()
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .direction()
            .to_string()
    }

    /// Irreversibly marks the specified [`RtcRtpTransceiver`] as stopping,
    /// unless it's already stopped.
    ///
    /// This will immediately cause the transceiver's sender to no longer send,
    /// and its receiver to no longer receive.
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn stop_transceiver(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.0
            .lock()
            .unwrap()
            .get_transceivers()
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .stop()
            .map_or_else(|err| err.to_string(), |_| String::new())
    }

    /// Replaces the specified [`AudioTrack`] (or [`crate::VideoTrack`]) on
    /// the [`sys::Transceiver`]'s `sender`.
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    ///
    /// [`AudioTrack`]: crate::AudioTrack
    /// [`VideoTrack`]: crate::VideoTrack
    pub fn sender_replace_track(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
        track_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();
        let transceivers = peer.0.lock().unwrap().get_transceivers();
        let transceiver = transceivers
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap();
        let sender = transceiver.sender();

        if track_id == 0 {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    sender.replace_video_track(None)
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    sender.replace_audio_track(None)
                }
                _ => unreachable!(),
            }
        } else {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    sender.replace_video_track(Some(
                        self.0
                            .video_tracks
                            .get(&VideoTrackId::from(track_id))
                            .unwrap()
                            .as_ref(),
                    ))
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    sender.replace_audio_track(Some(
                        self.0
                            .audio_tracks
                            .get(&AudioTrackId::from(track_id))
                            .unwrap()
                            .as_ref(),
                    ))
                }
                _ => unreachable!(),
            }
        }
        .map_or_else(|e| e.to_string(), |_| String::new())
    }

    /// Adds a [`sys::IceCandidateInterface`] to the given [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot add the given [`sys::IceCandidateInterface`].
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn add_ice_candidate(
        &mut self,
        peer_id: u64,
        candidate: &str,
        sdp_mid: &str,
        sdp_mline_index: i32,
        cb: UniquePtr<AddIceCandidateCallbackInterface>,
    ) {
        let candidate = sys::IceCandidateInterface::new(
            sdp_mid,
            sdp_mline_index,
            candidate,
        )
        .unwrap();
        self.0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap()
            .0
            .lock()
            .unwrap()
            .add_ice_candidate(
                candidate,
                Box::new(AddIceCandidateCallback(cb)),
            );
    }

    /// Tells the [`PeerConnection`] that ICE should be restarted.
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn restart_ice(&mut self, peer_id: u64) {
        self.0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap()
            .0
            .lock()
            .unwrap()
            .restart_ice();
    }

    /// Closes the [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn dispose_peer_connection(&mut self, peer_id: u64) {
        self.0
            .peer_connections
            .remove(&PeerConnectionId(peer_id))
            .unwrap()
            .0
            .lock()
            .unwrap()
            .close();
    }
}

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

/// Wrapper around a [`sys::PeerConnectionInterface`] with a unique ID.
pub struct PeerConnection(Arc<Mutex<sys::PeerConnectionInterface>>);

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        factory: &mut sys::PeerConnectionFactoryInterface,
        video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,
        audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,
        observer: UniquePtr<PeerConnectionObserverInterface>,
        configuration: api::RtcConfiguration,
        pool: ThreadPool,
    ) -> anyhow::Result<Self> {
        let obs_peer = Arc::new(OnceCell::new());
        let observer = sys::PeerConnectionObserver::new(Box::new(
            PeerConnectionObserver {
                observer: Arc::new(Mutex::new(observer)),
                peer: Arc::clone(&obs_peer),
                video_tracks,
                audio_tracks,
                pool,
            },
        ));

        let mut sys_configuration = sys::RtcConfiguration::default();

        if !configuration.ice_transport_policy.is_empty() {
            sys_configuration.set_ice_transport_type(
                configuration.ice_transport_policy.as_str().try_into()?,
            );
        }

        if !configuration.bundle_policy.is_empty() {
            sys_configuration.set_bundle_policy(
                configuration.bundle_policy.as_str().try_into()?,
            );
        }

        for server in configuration.ice_servers {
            let mut ice_server = sys::IceServer::default();
            let mut have_ice_servers = false;

            for url in server.urls {
                if !url.is_empty() {
                    ice_server.add_url(url);
                    have_ice_servers = true;
                }
            }

            if have_ice_servers {
                if !server.username.is_empty() || !server.credential.is_empty()
                {
                    ice_server
                        .set_credentials(server.username, server.credential);
                }

                sys_configuration.add_server(ice_server);
            }
        }

        let inner = factory.create_peer_connection_or_error(
            &sys_configuration,
            sys::PeerConnectionDependencies::new(observer),
        )?;

        let inner_peer = Arc::new(Mutex::new(inner));
        obs_peer.set(Arc::clone(&inner_peer)).unwrap_or_default();

        Ok(Self(inner_peer))
    }
}

/// [`CreateSdpCallbackInterface`] wrapper.
struct CreateSdpCallback(UniquePtr<CreateSdpCallbackInterface>);

impl sys::CreateSdpCallback for CreateSdpCallback {
    fn success(&mut self, sdp: &CxxString, kind: sys::SdpType) {
        let_cxx_string!(kind = kind.to_string());
        self.0.pin_mut().on_create_sdp_success(sdp, &kind.as_ref());
    }

    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_create_sdp_fail(error);
    }
}

/// [`SetDescriptionCallbackInterface`] wrapper.
struct SetSdpCallback(UniquePtr<SetDescriptionCallbackInterface>);

impl sys::SetDescriptionCallback for SetSdpCallback {
    fn success(&mut self) {
        self.0.pin_mut().on_set_description_sucess();
    }

    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_set_description_fail(error);
    }
}

/// [`PeerConnectionObserverInterface`] wrapper.
struct PeerConnectionObserver {
    /// [`PeerConnectionObserverInterface`] to forward the events to.
    observer: Arc<Mutex<UniquePtr<PeerConnectionObserverInterface>>>,

    /// [`InnerPeer`] of the [`PeerConnection`] internally used in
    /// [`sys::PeerConnectionObserver::on_track()`][1]
    ///
    /// Tasks with [`InnerPeer`] must be offloaded to a separate [`ThreadPool`],
    /// so the signalling thread wouldn't be blocked.
    peer: Arc<OnceCell<Arc<Mutex<PeerConnectionInterface>>>>,

    /// Map of the remote [`VideoTrack`]s shared with the [`crate::Webrtc`].
    video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,

    /// Map of the remote [`AudioTrack`]s shared with the [`crate::Webrtc`].
    audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,

    /// [`ThreadPool`] executing blocking tasks from the
    /// [`PeerConnectionObserver`] callbacks.
    pool: ThreadPool,
}

impl sys::PeerConnectionEventsHandler for PeerConnectionObserver {
    fn on_signaling_change(&mut self, new_state: sys::SignalingState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.observer
            .lock()
            .unwrap()
            .pin_mut()
            .on_signaling_change(&new_state);
    }

    fn on_standardized_ice_connection_change(
        &mut self,
        new_state: sys::IceConnectionState,
    ) {
        let_cxx_string!(new_state = new_state.to_string());
        self.observer
            .lock()
            .unwrap()
            .pin_mut()
            .on_ice_connection_state_change(&new_state);
    }

    fn on_connection_change(&mut self, new_state: sys::PeerConnectionState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.observer
            .lock()
            .unwrap()
            .pin_mut()
            .on_connection_state_change(&new_state);
    }

    fn on_ice_gathering_change(&mut self, new_state: sys::IceGatheringState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.observer
            .lock()
            .unwrap()
            .pin_mut()
            .on_ice_gathering_change(&new_state);
    }

    fn on_negotiation_needed_event(&mut self, _: u32) {
        self.observer
            .lock()
            .unwrap()
            .pin_mut()
            .on_negotiation_needed();
    }

    fn on_ice_candidate_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    ) {
        self.observer
            .lock()
            .unwrap()
            .pin_mut()
            .on_ice_candidate_error(address, port, url, error_code, error_text);
    }

    fn on_ice_connection_receiving_change(&mut self, _: bool) {
        // This is a non-spec-compliant event.
    }

    fn on_track(&mut self, transceiver: sys::RtpTransceiverInterface) {
        let track = match transceiver.media_type() {
            sys::MediaType::MEDIA_TYPE_AUDIO => {
                let track = AudioTrack::wrap_remote(&transceiver);
                let result = api::MediaStreamTrack::from(&track);
                self.audio_tracks.insert(track.id(), track);

                result
            }
            sys::MediaType::MEDIA_TYPE_VIDEO => {
                let track = VideoTrack::wrap_remote(&transceiver);
                let result = api::MediaStreamTrack::from(&track);
                self.video_tracks.insert(track.id(), track);

                result
            }
            _ => unreachable!(),
        };

        self.pool.execute({
            // PANIC: Unwrapping is OK, since the transceiver is guaranteed to
            //        be negotiated at this point.
            let mid = transceiver.mid().unwrap();
            let direction = transceiver.direction();
            let peer = Arc::clone(&self.peer);
            let observer = Arc::clone(&self.observer);

            move || {
                let peer = peer.get().unwrap().lock().unwrap();
                let index = peer
                    .get_transceivers()
                    .iter()
                    .enumerate()
                    .find(|(_, t)| t.mid().as_ref() == Some(&mid))
                    .map(|(id, _)| id)
                    .unwrap();

                let result = api::RtcTrackEvent {
                    track,
                    transceiver: api::RtcRtpTransceiver {
                        id: index as u64,
                        mid,
                        direction: direction.to_string(),
                        sender: api::RtcRtpSender { id: index as u64 },
                    },
                };

                observer.lock().unwrap().pin_mut().on_track(result);
            }
        });
    }

    fn on_ice_candidate(&mut self, candidate: sys::IceCandidateInterface) {
        self.observer.lock().unwrap().pin_mut().on_ice_candidate(
            candidate.candidate(),
            candidate.mid(),
            candidate.mline_index(),
        );
    }

    fn on_ice_candidates_removed(&mut self, _: &CxxVector<sys::Candidate>) {
        // This is a non-spec-compliant event.
    }

    fn on_ice_selected_candidate_pair_changed(
        &mut self,
        _: &sys::CandidatePairChangeEvent,
    ) {
        // This is a non-spec-compliant event.
    }

    fn on_remove_track(&mut self, _: sys::RtpReceiverInterface) {
        // This is a non-spec-compliant event.
    }
}

/// [`sys::AddIceCandidateCallback`] wrapper.
pub struct AddIceCandidateCallback(UniquePtr<AddIceCandidateCallbackInterface>);

impl sys::AddIceCandidateCallback for AddIceCandidateCallback {
    fn on_success(&mut self) {
        self.0.pin_mut().on_add_ice_candidate_success();
    }

    fn on_fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_add_ice_candidate_fail(error);
    }
}
