use std::{
    hash::Hash,
    mem,
    sync::{
        atomic::{AtomicBool, Ordering},
        mpsc, Arc, Mutex, Weak,
    },
};

use anyhow::anyhow;
use cxx::{CxxString, CxxVector};
use dashmap::DashMap;
use derive_more::{Display, From, Into};
use flutter_rust_bridge::RustOpaque;
use libwebrtc_sys as sys;
use once_cell::sync::OnceCell;
use threadpool::ThreadPool;

use crate::{
    api, next_id, stream_sink::StreamSink, user_media::TrackOrigin, AudioTrack,
    AudioTrackId, VideoTrack, VideoTrackId, Webrtc,
};

impl Webrtc {
    /// Creates a new [`PeerConnection`] and returns its ID.
    pub fn create_peer_connection(
        &mut self,
        obs: &StreamSink<api::PeerConnectionEvent>,
        configuration: api::RtcConfiguration,
    ) -> anyhow::Result<()> {
        let id = PeerConnectionId::from(next_id());
        let peer = PeerConnection::new(
            id,
            &mut self.peer_connection_factory,
            Arc::clone(&self.video_tracks),
            Arc::clone(&self.audio_tracks),
            obs.clone(),
            configuration,
            self.callback_pool.clone(),
        )?;
        let peer = RustOpaque::from(Arc::new(peer));
        obs.add(api::PeerConnectionEvent::PeerCreated { peer });

        Ok(())
    }

    /// Returns a sequence of [`api::RtcRtpTransceiver`] objects representing
    /// the RTP transceivers currently attached to specified [`PeerConnection`].
    pub fn get_transceivers(
        peer: &RustOpaque<Arc<PeerConnection>>,
    ) -> Vec<api::RtcRtpTransceiver> {
        let transceivers = peer.get_transceivers();
        let mut result = Vec::with_capacity(transceivers.len());

        for (index, transceiver) in transceivers.into_iter().enumerate() {
            let info = api::RtcRtpTransceiver {
                peer: peer.clone(),
                mid: transceiver.mid(),
                direction: transceiver.direction().into(),
                transceiver: RustOpaque::new(Arc::new(RtpTransceiver {
                    inner: Mutex::new(transceiver),
                    peer_id: peer.id,
                    index,
                })),
            };
            result.push(info);
        }

        result
    }

    /// Closes the provided [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn dispose_peer_connection(&mut self, this: &Arc<PeerConnection>) {
        // Remove all tracks from this `Peer`'s senders.
        for mut track in self.video_tracks.iter_mut() {
            track.senders.remove(this);
        }

        for mut track in self.audio_tracks.iter_mut() {
            track.senders.remove(this);
        }

        let peer = this.inner.lock().unwrap();

        for trnscvr in peer.get_transceivers() {
            let sender = trnscvr.sender();
            match trnscvr.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    if let Err(e) = sender.replace_video_track(None) {
                        log::error!(
                            "Failed to remove video track from sender: {e}",
                        );
                    }
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    if let Err(e) = sender.replace_audio_track(None) {
                        log::error!(
                            "Failed to remove audio track from sender: {e}",
                        );
                    } else {
                        let is_sending = self
                            .audio_tracks
                            .iter()
                            .any(|t| !t.senders.is_empty());
                        self.ap.set_output_will_be_muted(!is_sending);
                    }
                }
                _ => unreachable!(),
            }
        }

        peer.close();
    }

    /// Replaces the specified [`AudioTrack`] (or [`VideoTrack`]) on the
    /// [`sys::Transceiver`]'s `sender`.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn sender_replace_track(
        &mut self,
        peer: &Arc<PeerConnection>,
        transceiver: &Arc<RtpTransceiver>,
        track_id: Option<String>,
    ) -> anyhow::Result<()> {
        let track_origin = TrackOrigin::Local;

        match transceiver.media_type() {
            sys::MediaType::MEDIA_TYPE_VIDEO => {
                for mut track in self.video_tracks.iter_mut() {
                    let mut delete = false;
                    if let Some(trnscvrs) = track.senders.get_mut(peer) {
                        trnscvrs.retain(|tr| tr != transceiver);
                        delete = trnscvrs.is_empty();
                    }
                    if delete {
                        track.senders.remove(peer);
                    }
                }
            }
            sys::MediaType::MEDIA_TYPE_AUDIO => {
                for mut track in self.audio_tracks.iter_mut() {
                    let mut delete = false;
                    if let Some(trnscvrs) = track.senders.get_mut(peer) {
                        trnscvrs.retain(|tr| tr != transceiver);
                        delete = trnscvrs.is_empty();
                    }
                    if delete {
                        track.senders.remove(peer);
                    }
                }
            }
            _ => unreachable!(),
        }

        let sender = transceiver.inner.lock().unwrap().sender();
        if let Some(track_id) = track_id {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    let track_id = VideoTrackId::from(track_id);
                    let mut track = self
                        .video_tracks
                        .get_mut(&(track_id.clone(), track_origin))
                        .ok_or_else(|| {
                            anyhow!("Cannot find track with ID `{track_id}`")
                        })?;

                    track
                        .value_mut()
                        .senders
                        .entry(Arc::clone(peer))
                        .or_default()
                        .insert(Arc::clone(transceiver));

                    sender.replace_video_track(Some(track.as_ref()))
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    let track_id = AudioTrackId::from(track_id);
                    let mut track = self
                        .audio_tracks
                        .get_mut(&(track_id.clone(), track_origin))
                        .ok_or_else(|| {
                            anyhow!("Cannot find track with ID `{track_id}`")
                        })?;

                    track
                        .value_mut()
                        .senders
                        .entry(Arc::clone(peer))
                        .or_default()
                        .insert(Arc::clone(transceiver));

                    sender.replace_audio_track(Some(track.as_ref()))
                }
                _ => unreachable!(),
            }
        } else {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    sender.replace_video_track(None)
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    let result = sender.replace_audio_track(None);

                    if result.is_ok() {
                        let is_sending = self
                            .audio_tracks
                            .iter()
                            .any(|t| !t.senders.is_empty());
                        self.ap.set_output_will_be_muted(!is_sending);
                    }

                    result
                }
                _ => unreachable!(),
            }
        }
    }
}

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

/// Wrapper around a [`sys::PeerConnectionInterface`] with a unique ID.
pub struct PeerConnection {
    /// ID of this [`PeerConnection`].
    id: PeerConnectionId,

    /// Underlying [`sys::PeerConnectionInterface`].
    inner: Arc<Mutex<sys::PeerConnectionInterface>>,

    /// Indicates whether the
    /// [`sys::PeerConnectionInterface::set_remote_description()`] was called
    /// on the underlying peer.
    has_remote_description: AtomicBool,

    /// Candidates, added before a remote description has been set on the
    /// underlying peer.
    candidates_buffer: Mutex<Vec<IceCandidate>>,
}

impl Hash for PeerConnection {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl PartialEq for PeerConnection {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

impl Eq for PeerConnection {}

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        id: PeerConnectionId,
        factory: &mut sys::PeerConnectionFactoryInterface,
        video_tracks: Arc<DashMap<(VideoTrackId, TrackOrigin), VideoTrack>>,
        audio_tracks: Arc<DashMap<(AudioTrackId, TrackOrigin), AudioTrack>>,
        observer: StreamSink<api::PeerConnectionEvent>,
        configuration: api::RtcConfiguration,
        pool: ThreadPool,
    ) -> anyhow::Result<Arc<Self>> {
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

        sys_configuration
            .set_ice_transport_type(configuration.ice_transport_policy.into());

        sys_configuration.set_bundle_policy(configuration.bundle_policy.into());

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

        let res = Arc::new(Self {
            inner: Arc::new(Mutex::new(inner)),
            has_remote_description: AtomicBool::new(false),
            candidates_buffer: Mutex::new(vec![]),
            id,
        });

        obs_peer.set(Arc::downgrade(&res)).unwrap_or_default();

        Ok(res)
    }

    /// Returns ID of this [`PeerConnection`].
    pub fn id(&self) -> PeerConnectionId {
        self.id
    }

    /// Returns a sequence of [`RtpTransceiverInterface`] objects representing
    /// the RTP transceivers currently attached to this [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// If the underlying [`Mutex`] is poisoned.
    #[must_use]
    pub fn get_transceivers(&self) -> Vec<sys::RtpTransceiverInterface> {
        self.inner.lock().unwrap().get_transceivers()
    }

    /// Adds a [`sys::IceCandidateInterface`] to this [`PeerConnection`].
    ///
    /// # Errors
    ///
    /// If the underlying engine errors.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn add_ice_candidate(
        &self,
        candidate: String,
        sdp_mid: String,
        sdp_mline_index: i32,
        add_candidate_tx: mpsc::Sender<anyhow::Result<()>>,
    ) -> anyhow::Result<()> {
        let candidate = IceCandidate {
            candidate,
            sdp_mid,
            sdp_mline_index,
        };

        if self.has_remote_description.load(Ordering::SeqCst) {
            self.inner.lock().unwrap().add_ice_candidate(
                candidate.try_into()?,
                Box::new(AddIceCandidateCallback(add_candidate_tx)),
            );
        } else {
            self.candidates_buffer.lock().unwrap().push(candidate);
            add_candidate_tx.send(Ok(()))?;
        }

        Ok(())
    }

    /// Sets the specified session description as the remote peer's current
    /// offer or answer.
    ///
    /// Returns an empty [`String`] if this operation succeeds, or an error
    /// otherwise.
    ///
    /// # Errors
    ///
    /// If the underlying engine errors.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn set_remote_description(
        &self,
        kind: sys::SdpType,
        sdp: &str,
    ) -> anyhow::Result<()> {
        let (set_sdp_tx, set_sdp_rx) = mpsc::channel();
        let desc = sys::SessionDescriptionInterface::new(kind, sdp);
        let obs = sys::SetRemoteDescriptionObserver::new(Box::new(
            SetSdpCallback(set_sdp_tx),
        ));
        let mut inner = self.inner.lock().unwrap();
        inner.set_remote_description(desc, obs);

        set_sdp_rx.recv_timeout(api::RX_TIMEOUT)??;
        self.has_remote_description.store(true, Ordering::SeqCst);

        let candidates: Vec<_> =
            mem::take(self.candidates_buffer.lock().unwrap().as_mut());
        for candidate in candidates {
            let (add_candidate_tx, add_candidate_rx) = mpsc::channel();
            inner.add_ice_candidate(
                candidate.try_into()?,
                Box::new(AddIceCandidateCallback(add_candidate_tx)),
            );
            add_candidate_rx.recv_timeout(api::RX_TIMEOUT)??;
        }

        Ok(())
    }

    /// Creates a new [`api::RtcRtpTransceiver`] and adds it to the set of
    /// transceivers of the specified [`PeerConnection`].
    ///
    /// # Errors
    ///
    /// If underlying engine returns error.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn add_transceiver(
        this: RustOpaque<Arc<Self>>,
        media_type: sys::MediaType,
        init: &RustOpaque<Arc<RtpTransceiverInit>>,
    ) -> anyhow::Result<api::RtcRtpTransceiver> {
        let (mid, direction, transceiver) = {
            let mut peer = this.inner.lock().unwrap();

            let transceiver = {
                let init = init.0.lock().unwrap();

                peer.add_transceiver(media_type, &init)
            };
            let index = peer.get_transceivers().len() - 1;

            (
                transceiver.mid(),
                transceiver.direction().into(),
                RustOpaque::new(Arc::new(RtpTransceiver {
                    inner: Mutex::new(transceiver),
                    peer_id: this.id,
                    index,
                })),
            )
        };

        Ok(api::RtcRtpTransceiver {
            peer: this,
            transceiver,
            mid,
            direction,
        })
    }

    /// Initiates the creation of an SDP offer for the purpose of starting a new
    /// WebRTC connection to a remote peer.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn create_offer(
        &self,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        create_sdp_tx: mpsc::Sender<anyhow::Result<api::RtcSessionDescription>>,
    ) {
        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
            CreateSdpCallback(create_sdp_tx),
        ));
        self.inner.lock().unwrap().create_offer(&options, obs);
    }

    /// Creates an SDP answer to the offer received from a remote peer during an
    /// offer/answer negotiation of a WebRTC connection.
    ///
    /// Returns an empty [`String`] if this operation succeeds, or an error
    /// otherwise.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn create_answer(
        &self,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        create_sdp_tx: mpsc::Sender<anyhow::Result<api::RtcSessionDescription>>,
    ) {
        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
            CreateSdpCallback(create_sdp_tx),
        ));
        self.inner.lock().unwrap().create_answer(&options, obs);
    }

    /// Changes the local description associated with this [`PeerConnection`].
    ///
    /// Returns an empty [`String`] if this operation succeeds, or an error
    /// otherwise.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn set_local_description(
        &self,
        kind: sys::SdpType,
        sdp: &str,
        set_sdp_tx: mpsc::Sender<anyhow::Result<()>>,
    ) {
        let desc = sys::SessionDescriptionInterface::new(kind, sdp);
        let obs = sys::SetLocalDescriptionObserver::new(Box::new(
            SetSdpCallback(set_sdp_tx),
        ));
        self.inner.lock().unwrap().set_local_description(desc, obs);
    }

    /// Returns [`RtcStats`] of this [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn get_stats(&self, report_tx: mpsc::Sender<sys::RtcStatsReport>) {
        let cb = GetStatsCallback(report_tx);
        self.inner.lock().unwrap().get_stats(Box::new(cb));
    }

    /// Tells the [`PeerConnection`] that ICE should be restarted.
    ///
    /// # Errors
    ///
    /// If the underlying engine errors.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::PeerConnectionInterface`] is
    /// poisoned.
    pub fn restart_ice(&self) {
        self.inner.lock().unwrap().restart_ice();
    }
}

/// Wrapper around a [`sys::RtpTransceiverInit`].
pub struct RtpTransceiverInit(Arc<Mutex<sys::RtpTransceiverInit>>);

impl RtpTransceiverInit {
    /// Creates a new [`RtpTransceiverInit`].
    #[must_use]
    pub fn new() -> Self {
        Self(Arc::new(Mutex::new(sys::RtpTransceiverInit::new())))
    }

    /// Sets a provided [`api::RtpTransceiverDirection`] to this
    /// [`RtpTransceiverInit`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInit`] is poisoned.
    pub fn set_direction(&self, direction: api::RtpTransceiverDirection) {
        self.0.lock().unwrap().set_direction(direction.into());
    }

    /// Adds a provided [`RtpEncodingParameters`] to this
    /// [`RtpTransceiverInit`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInit`] or the
    /// [`sys::RtpEncodingParameters`] is poisoned.
    pub fn add_encoding(
        &self,
        encoding: &RustOpaque<Arc<RtpEncodingParameters>>,
    ) {
        self.0
            .lock()
            .unwrap()
            .add_encoding(&encoding.0.lock().unwrap());
    }
}

impl Default for RtpTransceiverInit {
    fn default() -> Self {
        Self::new()
    }
}

/// Wrapper around a [`sys::RtpEncodingParameters`].
pub struct RtpEncodingParameters(Arc<Mutex<sys::RtpEncodingParameters>>);

impl RtpEncodingParameters {
    /// Creates a new [`RtpEncodingParameters`].
    #[must_use]
    pub fn new() -> Self {
        Self(Arc::new(Mutex::new(sys::RtpEncodingParameters::new())))
    }

    /// Sets a provided `rid` to this [`RtpEncodingParameters`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpEncodingParameters`] is
    /// poisoned.
    pub fn set_rid(&self, rid: String) {
        self.0.lock().unwrap().set_rid(rid);
    }

    /// Sets `active` to this [`RtpEncodingParameters`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpEncodingParameters`] is
    /// poisoned.
    pub fn set_active(&self, active: bool) {
        self.0.lock().unwrap().set_active(active);
    }

    /// Sets a provided `max_bitrate` to this [`RtpEncodingParameters`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpEncodingParameters`] is
    /// poisoned.
    pub fn set_max_bitrate(&self, max_bitrate: i32) {
        self.0.lock().unwrap().set_max_bitrate(max_bitrate);
    }

    /// Sets a provided `max_framerate` to this [`RtpEncodingParameters`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpEncodingParameters`] is
    /// poisoned.
    pub fn set_max_framerate(&self, max_framerate: f64) {
        self.0.lock().unwrap().set_max_framerate(max_framerate);
    }

    /// Sets a provided `scale_resolution_down_by` to this
    /// [`RtpEncodingParameters`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpEncodingParameters`] is
    /// poisoned.
    pub fn set_scale_resolution_down_by(&self, scale_resolution_down_by: f64) {
        self.0
            .lock()
            .unwrap()
            .set_scale_resolution_down_by(scale_resolution_down_by);
    }

    /// Sets a provided `scalability_mode` to this [`RtpEncodingParameters`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpEncodingParameters`] is
    /// poisoned.
    pub fn set_scalability_mode(&self, scalability_mode: String) {
        self.0
            .lock()
            .unwrap()
            .set_scalability_mode(scalability_mode);
    }
}

impl Default for RtpEncodingParameters {
    fn default() -> Self {
        Self::new()
    }
}

/// Wrapper around a [`sys::RtpTransceiverInterface`] with a unique ID.
pub struct RtpTransceiver {
    /// Native-side transceiver.
    inner: Mutex<sys::RtpTransceiverInterface>,

    /// ID of a [`PeerConnection`] that this [`RtpTransceiver`] belongs to.
    peer_id: PeerConnectionId,

    /// Index of this [`RtpTransceiver`] in it's [`PeerConnection`]s
    /// transceivers list.
    index: usize,
}

impl RtpTransceiver {
    /// Changes the preferred `direction` of this [`RtpTransceiver`].
    ///
    /// # Errors
    ///
    /// If the underlying engine errors.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInterface`] is
    /// poisoned.
    pub fn set_direction(
        &self,
        direction: api::RtpTransceiverDirection,
    ) -> anyhow::Result<()> {
        self.inner.lock().unwrap().set_direction(direction.into())
    }

    /// Changes the receive direction of this [`RtpTransceiver`].
    ///
    /// # Errors
    ///
    /// If the underlying engine errors.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInterface`] is
    /// poisoned.
    pub fn set_recv(&self, recv: bool) -> anyhow::Result<()> {
        use sys::RtpTransceiverDirection as D;

        let inner = self.inner.lock().unwrap();

        let new_direction = match (inner.direction(), recv) {
            (D::kInactive | D::kRecvOnly, true) => D::kRecvOnly,
            (D::kSendOnly | D::kSendRecv, true) => D::kSendRecv,
            (D::kInactive | D::kRecvOnly, false) => D::kInactive,
            (D::kSendOnly | D::kSendRecv, false) => D::kSendOnly,
            _ => D::kStopped,
        };

        if new_direction == D::kStopped {
            Ok(())
        } else {
            inner.set_direction(new_direction)
        }
    }

    /// Changes the send direction of this [`RtpTransceiver`].
    ///
    /// # Errors
    ///
    /// If the underlying engine errors.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInterface`] is
    /// poisoned.
    pub fn set_send(&self, send: bool) -> anyhow::Result<()> {
        use sys::RtpTransceiverDirection as D;

        let inner = self.inner.lock().unwrap();

        let new_direction = match (inner.direction(), send) {
            (D::kInactive | D::kSendOnly, true) => D::kSendOnly,
            (D::kRecvOnly | D::kSendRecv, true) => D::kSendRecv,
            (D::kInactive | D::kSendOnly, false) => D::kInactive,
            (D::kSendRecv | D::kRecvOnly, false) => D::kRecvOnly,
            _ => D::kStopped,
        };

        if new_direction == D::kStopped {
            Ok(())
        } else {
            inner.set_direction(new_direction)
        }
    }

    /// Returns the [Negotiated media ID (mid)][1] of this [`RtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInterface`] is
    /// poisoned.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    #[must_use]
    pub fn mid(&self) -> Option<String> {
        self.inner.lock().unwrap().mid()
    }

    /// Returns the preferred direction of this [`RtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInterface`] is
    /// poisoned.
    #[must_use]
    pub fn direction(&self) -> sys::RtpTransceiverDirection {
        self.inner.lock().unwrap().direction()
    }

    /// Returns the [`MediaType`] of this [`RtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInterface`] is
    /// poisoned.
    #[must_use]
    pub fn media_type(&self) -> sys::MediaType {
        self.inner.lock().unwrap().media_type()
    }

    /// Irreversibly marks this [`RtpTransceiver`] as stopping, unless it's
    /// already stopped.
    ///
    /// This will immediately cause this [`RtpTransceiver`]'s sender to no
    /// longer send, and its receiver to no longer receive.
    ///
    /// # Errors
    ///
    /// If the underlying engine errors.
    ///
    /// # Panics
    ///
    /// If the [`Mutex`] guarding the [`sys::RtpTransceiverInterface`] is
    /// poisoned.
    pub fn stop(&self) -> anyhow::Result<()> {
        self.inner.lock().unwrap().stop()
    }
}

impl PartialEq for RtpTransceiver {
    fn eq(&self, other: &Self) -> bool {
        self.peer_id == other.peer_id && self.index == other.index
    }
}

impl Hash for RtpTransceiver {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.peer_id.hash(state);
        self.index.hash(state);
    }
}

impl Eq for RtpTransceiver {}

/// [RTCIceCandidate][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
struct IceCandidate {
    /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
    ///
    /// If this [RTCIceCandidate][1] represents an end-of-candidates indication
    /// or a peer reflexive remote candidate, candidate is an empty string.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
    /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
    pub candidate: String,

    /// Media stream "identification-tag" defined in [RFC 5888] for the media
    /// component this [RTCIceCandidate][1] is associated with.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
    /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
    pub sdp_mid: String,

    /// Index (starting at zero) of the media description in the SDP this
    /// [RTCIceCandidate][1] is associated with.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
    pub sdp_mline_index: i32,
}

impl TryFrom<IceCandidate> for sys::IceCandidateInterface {
    type Error = anyhow::Error;

    fn try_from(value: IceCandidate) -> anyhow::Result<Self> {
        Self::new(&value.sdp_mid, value.sdp_mline_index, &value.candidate)
    }
}

/// [`CreateSdpCallbackInterface`] wrapper.
struct CreateSdpCallback(
    mpsc::Sender<anyhow::Result<api::RtcSessionDescription>>,
);

impl sys::CreateSdpCallback for CreateSdpCallback {
    fn success(&mut self, sdp: &CxxString, kind: sys::SdpType) {
        if let Err(e) = self.0.send(Ok(api::RtcSessionDescription {
            sdp: sdp.to_string(),
            kind: kind.into(),
        })) {
            log::warn!("Failed to send SDP in `CreateSdpCallback`: {e}");
        }
    }

    fn fail(&mut self, error: &CxxString) {
        if let Err(e) = self.0.send(Err(anyhow!("{error}"))) {
            log::warn!("Failed to send SDP error in `CreateSdpCallback`: {e}");
        }
    }
}

/// [`SetDescriptionCallbackInterface`] wrapper.
struct SetSdpCallback(mpsc::Sender<anyhow::Result<()>>);

impl sys::SetDescriptionCallback for SetSdpCallback {
    fn success(&mut self) {
        if let Err(e) = self.0.send(Ok(())) {
            log::warn!("Failed to complete `SetSdpCallback`: {e}");
        }
    }

    fn fail(&mut self, error: &CxxString) {
        if let Err(e) = self.0.send(Err(anyhow!("{error}"))) {
            log::warn!("Failed to send SDP error in `SetSdpCallback`: {e}");
        }
    }
}

/// [`sys::RTCStatsCollectorCallback`] wrapper.
struct GetStatsCallback(mpsc::Sender<sys::RtcStatsReport>);

impl sys::RTCStatsCollectorCallback for GetStatsCallback {
    fn on_stats_delivered(&mut self, report: sys::RtcStatsReport) {
        if let Err(e) = self.0.send(report) {
            log::warn!("Failed to complete `GetStatsCallback`: {e}");
        }
    }
}

/// [`PeerConnectionObserverInterface`] wrapper.
struct PeerConnectionObserver {
    /// [`PeerConnectionObserverInterface`] to forward the events to.
    observer: Arc<Mutex<StreamSink<api::PeerConnectionEvent>>>,

    /// [`InnerPeer`] of the [`PeerConnection`] internally used in
    /// [`sys::PeerConnectionObserver::on_track()`][1]
    ///
    /// Tasks with [`InnerPeer`] must be offloaded to a separate [`ThreadPool`],
    /// so the signalling thread wouldn't be blocked.
    peer: Arc<OnceCell<Weak<PeerConnection>>>,

    /// Map of the remote [`VideoTrack`]s shared with the [`crate::Webrtc`].
    video_tracks: Arc<DashMap<(VideoTrackId, TrackOrigin), VideoTrack>>,

    /// Map of the remote [`AudioTrack`]s shared with the [`crate::Webrtc`].
    audio_tracks: Arc<DashMap<(AudioTrackId, TrackOrigin), AudioTrack>>,

    /// [`ThreadPool`] executing blocking tasks from the
    /// [`PeerConnectionObserver`] callbacks.
    pool: ThreadPool,
}

impl sys::PeerConnectionEventsHandler for PeerConnectionObserver {
    fn on_signaling_change(&mut self, new_state: sys::SignalingState) {
        self.observer
            .lock()
            .unwrap()
            .add(api::PeerConnectionEvent::SignallingChange(new_state.into()));
    }

    fn on_standardized_ice_connection_change(
        &mut self,
        new_state: sys::IceConnectionState,
    ) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::IceConnectionStateChange(
                new_state.into(),
            ),
        );
    }

    fn on_connection_change(&mut self, new_state: sys::PeerConnectionState) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::ConnectionStateChange(new_state.into()),
        );
    }

    fn on_ice_gathering_change(&mut self, new_state: sys::IceGatheringState) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::IceGatheringStateChange(new_state.into()),
        );
    }

    fn on_negotiation_needed_event(&mut self, _: u32) {
        self.observer
            .lock()
            .unwrap()
            .add(api::PeerConnectionEvent::NegotiationNeeded);
    }

    fn on_ice_candidate_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    ) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::IceCandidateError {
                address: address.to_string(),
                port,
                url: url.to_string(),
                error_code,
                error_text: error_text.to_string(),
            },
        );
    }

    fn on_ice_connection_receiving_change(&mut self, _: bool) {
        // This is a non-spec-compliant event.
    }

    fn on_ice_candidate(&mut self, candidate: sys::IceCandidateInterface) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::IceCandidate {
                sdp_mid: candidate.mid(),
                sdp_mline_index: candidate.mline_index(),
                candidate: candidate.candidate(),
            },
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

    fn on_track(&mut self, transceiver: sys::RtpTransceiverInterface) {
        self.pool.execute({
            // PANIC: Unwrapping is OK, since the transceiver is guaranteed
            //        to be negotiated at this point.
            let mid = transceiver.mid().unwrap();
            let direction = transceiver.direction();
            let peer = Arc::clone(&self.peer);
            let observer = Arc::clone(&self.observer);
            let track_id = transceiver.receiver().track().id();
            let video_tracks = Arc::clone(&self.video_tracks);
            let audio_tracks = Arc::clone(&self.audio_tracks);

            move || {
                let peer = if let Some(peer) = peer.get().unwrap().upgrade() {
                    peer
                } else {
                    // `peer` is already dropped on the Rust side, so just don't
                    // do anything.
                    return;
                };
                let track_origin = TrackOrigin::Remote(peer.id());

                let track = match transceiver.media_type() {
                    sys::MediaType::MEDIA_TYPE_AUDIO => {
                        let track_id = AudioTrackId::from(track_id);
                        if audio_tracks.contains_key(&(
                            track_id.clone(),
                            track_origin.clone(),
                        )) {
                            return;
                        }

                        let track =
                            AudioTrack::wrap_remote(&transceiver, &peer);
                        let result = api::MediaStreamTrack::from(&track);
                        audio_tracks.insert((track_id, track_origin), track);

                        result
                    }
                    sys::MediaType::MEDIA_TYPE_VIDEO => {
                        let track_id = VideoTrackId::from(track_id);
                        if video_tracks.contains_key(&(
                            track_id.clone(),
                            track_origin.clone(),
                        )) {
                            return;
                        }

                        let track =
                            VideoTrack::wrap_remote(&transceiver, &peer);
                        let result = api::MediaStreamTrack::from(&track);
                        video_tracks
                            .insert((track.id.clone(), track_origin), track);

                        result
                    }
                    _ => unreachable!(),
                };

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
                        transceiver: RustOpaque::new(Arc::new(
                            RtpTransceiver {
                                inner: Mutex::new(transceiver),
                                peer_id: peer.id,
                                index,
                            },
                        )),
                        mid: Some(mid),
                        direction: direction.into(),
                        peer: RustOpaque::new(peer),
                    },
                };

                observer
                    .lock()
                    .unwrap()
                    .add(api::PeerConnectionEvent::Track(result));
            }
        });
    }

    fn on_remove_track(&mut self, _: sys::RtpReceiverInterface) {
        // This is a non-spec-compliant event.
    }
}

/// [`sys::AddIceCandidateCallback`] wrapper.
pub struct AddIceCandidateCallback(mpsc::Sender<anyhow::Result<()>>);

impl sys::AddIceCandidateCallback for AddIceCandidateCallback {
    fn on_success(&mut self) {
        if let Err(e) = self.0.send(Ok(())) {
            log::warn!(
                "Failed to send success in `AddIceCandidateCallback`: {e}",
            );
        }
    }

    fn on_fail(&mut self, error: &CxxString) {
        if let Err(e) = self.0.send(Err(anyhow!("{error}"))) {
            log::warn!(
                "Failed to send error in `AddIceCandidateCallback`: {e}",
            );
        }
    }
}
