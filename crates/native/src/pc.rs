use std::{
    mem,
    sync::{mpsc, Arc, Mutex},
};

use anyhow::{anyhow, bail};
use cxx::{CxxString, CxxVector};
use dashmap::DashMap;
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;
use once_cell::sync::OnceCell;
use threadpool::ThreadPool;

use crate::{
    api, next_id, stream_sink::StreamSink, AudioTrack, AudioTrackId,
    VideoTrack, VideoTrackId, Webrtc,
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
        self.peer_connections.insert(id, peer);

        obs.add(api::PeerConnectionEvent::PeerCreated { id: id.into() });

        Ok(())
    }

    /// Initiates the creation of a SDP offer for the purpose of starting a new
    /// WebRTC connection to a remote peer.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn create_offer(
        &self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        create_sdp_tx: mpsc::Sender<anyhow::Result<api::RtcSessionDescription>>,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

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
        peer.inner.lock().unwrap().create_offer(&options, obs);
        Ok(())
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
        &self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        create_sdp_tx: mpsc::Sender<anyhow::Result<api::RtcSessionDescription>>,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

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
        peer.inner.lock().unwrap().create_answer(&options, obs);
        Ok(())
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
        &self,
        peer_id: u64,
        kind: sys::SdpType,
        sdp: String,
        set_sdp_tx: mpsc::Sender<anyhow::Result<()>>,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let desc = sys::SessionDescriptionInterface::new(kind, &sdp);
        let obs = sys::SetLocalDescriptionObserver::new(Box::new(
            SetSdpCallback(set_sdp_tx),
        ));
        peer.inner.lock().unwrap().set_local_description(desc, obs);
        Ok(())
    }

    /// Returns [`RtcStats`] of the [`PeerConnection`] by its ID.
    pub fn get_stats(
        &self,
        peer_id: u64,
        report_tx: mpsc::Sender<sys::RtcStatsReport>,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let cb = GetStatsCallback(report_tx);
        peer.inner.lock().unwrap().get_stats(Box::new(cb));
        Ok(())
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
        kind: sys::SdpType,
        sdp: String,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer =
            self.peer_connections.get_mut(&peer_id).ok_or_else(|| {
                anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
            })?;

        let (set_sdp_tx, set_sdp_rx) = mpsc::channel();
        let desc = sys::SessionDescriptionInterface::new(kind, &sdp);
        let obs = sys::SetRemoteDescriptionObserver::new(Box::new(
            SetSdpCallback(set_sdp_tx),
        ));
        let mut inner = peer.inner.lock().unwrap();
        inner.set_remote_description(desc, obs);

        set_sdp_rx.recv_timeout(api::RX_TIMEOUT)??;
        peer.has_remote_description = true;

        let candidates = mem::take(&mut peer.candidates_buffer);
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
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn add_transceiver(
        &self,
        peer_id: u64,
        media_type: sys::MediaType,
        direction: sys::RtpTransceiverDirection,
    ) -> anyhow::Result<api::RtcRtpTransceiver> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;
        let mut peer_ref = peer.inner.lock().unwrap();

        let transceiver = peer_ref.add_transceiver(media_type, direction);
        let index = peer_ref.get_transceivers().len() - 1;

        Ok(api::RtcRtpTransceiver {
            peer_id: peer_id.into(),
            index: index as u64,
            mid: transceiver.mid(),
            direction: transceiver.direction().into(),
        })
    }

    /// Returns a sequence of [`api::RtcRtpTransceiver`] objects representing
    /// the RTP transceivers currently attached to specified [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn get_transceivers(
        &self,
        peer_id: u64,
    ) -> anyhow::Result<Vec<api::RtcRtpTransceiver>> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();
        let mut result = Vec::with_capacity(transceivers.len());

        for (index, transceiver) in transceivers.into_iter().enumerate() {
            let info = api::RtcRtpTransceiver {
                peer_id: peer_id.into(),
                index: index as u64,
                mid: transceiver.mid(),
                direction: transceiver.direction().into(),
            };
            result.push(info);
        }

        Ok(result)
    }

    /// Changes the preferred `direction` of the specified
    /// [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn set_transceiver_direction(
        &self,
        peer_id: u64,
        transceiver_index: u32,
        direction: api::RtpTransceiverDirection,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(transceiver_index as usize)
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_index}` doesn't exist");
        };

        transceiver.set_direction(direction.into())
    }

    /// Changes the receive direction of the specified [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn set_transceiver_recv(
        &self,
        peer_id: u64,
        transceiver_index: u32,
        recv: bool,
    ) -> anyhow::Result<()> {
        use sys::RtpTransceiverDirection as D;

        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();
        let transceiver = transceivers
            .get(transceiver_index as usize)
            .ok_or_else(|| {
                anyhow!(
                    "`Transceiver` with ID `{transceiver_index}` doesn't exist",
                )
            })?;

        let new_direction = match (transceiver.direction(), recv) {
            (D::kInactive | D::kRecvOnly, true) => D::kRecvOnly,
            (D::kSendOnly | D::kSendRecv, true) => D::kSendRecv,
            (D::kInactive | D::kRecvOnly, false) => D::kInactive,
            (D::kSendOnly | D::kSendRecv, false) => D::kSendOnly,
            _ => D::kStopped,
        };

        if new_direction == D::kStopped {
            Ok(())
        } else {
            transceiver.set_direction(new_direction)
        }
    }

    /// Changes the send direction of the specified [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn set_transceiver_send(
        &self,
        peer_id: u64,
        transceiver_index: u32,
        send: bool,
    ) -> anyhow::Result<()> {
        use sys::RtpTransceiverDirection as D;

        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();
        let transceiver = transceivers
            .get(transceiver_index as usize)
            .ok_or_else(|| {
                anyhow!(
                    "`Transceiver` with ID `{transceiver_index}` doesn't exist",
                )
            })?;

        let new_direction = match (transceiver.direction(), send) {
            (D::kInactive | D::kSendOnly, true) => D::kSendOnly,
            (D::kRecvOnly | D::kSendRecv, true) => D::kSendRecv,
            (D::kInactive | D::kSendOnly, false) => D::kInactive,
            (D::kSendRecv | D::kRecvOnly, false) => D::kRecvOnly,
            _ => D::kStopped,
        };

        if new_direction == D::kStopped {
            Ok(())
        } else {
            transceiver.set_direction(new_direction)
        }
    }

    /// Returns the [Negotiated media ID (mid)][1] of the specified
    /// [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub fn get_transceiver_mid(
        &self,
        peer_id: u64,
        transceiver_index: u32,
    ) -> anyhow::Result<Option<String>> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(transceiver_index as usize)
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_index}` doesn't exist");
        };

        Ok(transceiver.mid())
    }

    /// Returns the preferred direction of the specified [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn get_transceiver_direction(
        &self,
        peer_id: u64,
        transceiver_index: u32,
    ) -> anyhow::Result<sys::RtpTransceiverDirection> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(transceiver_index as usize)
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_index}` doesn't exist");
        };

        Ok(transceiver.direction())
    }

    /// Irreversibly marks the specified [`RtcRtpTransceiver`] as stopping,
    /// unless it's already stopped.
    ///
    /// This will immediately cause the transceiver's sender to no longer send,
    /// and its receiver to no longer receive.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn stop_transceiver(
        &self,
        peer_id: u64,
        transceiver_index: u32,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(transceiver_index as usize)
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_index}` doesn't exist");
        };

        transceiver.stop()
    }

    /// Replaces the specified [`AudioTrack`] (or [`crate::VideoTrack`]) on
    /// the [`sys::Transceiver`]'s `sender`.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    ///
    /// [`AudioTrack`]: crate::AudioTrack
    /// [`VideoTrack`]: crate::VideoTrack
    pub fn sender_replace_track(
        &self,
        peer_id: u64,
        transceiver_index: u32,
        track_id: Option<String>,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        let transceivers = peer.inner.lock().unwrap().get_transceivers();

        let transceiver = transceivers
            .get(transceiver_index as usize)
            .ok_or_else(|| {
                anyhow!(
                    "`Transceiver` with ID `{transceiver_index}` doesn't exist",
                )
            })?;

        match transceiver.media_type() {
            sys::MediaType::MEDIA_TYPE_VIDEO => {
                for mut track in self.video_tracks.iter_mut() {
                    let mut delete = false;
                    if let Some(trnscvrs) = track.senders.get_mut(&peer_id) {
                        trnscvrs.retain(|index| index != &transceiver_index);
                        delete = trnscvrs.is_empty();
                    }
                    if delete {
                        track.senders.remove(&peer_id);
                    }
                }
            }
            sys::MediaType::MEDIA_TYPE_AUDIO => {
                for mut track in self.audio_tracks.iter_mut() {
                    let mut delete = false;
                    if let Some(trnscvrs) = track.senders.get_mut(&peer_id) {
                        trnscvrs.retain(|index| index != &transceiver_index);
                        delete = trnscvrs.is_empty();
                    }
                    if delete {
                        track.senders.remove(&peer_id);
                    }
                }
            }
            _ => unreachable!(),
        }

        let sender = transceiver.sender();
        if let Some(track_id) = track_id {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    let track_id = VideoTrackId::from(track_id);
                    let mut track = self
                        .video_tracks
                        .get_mut(&track_id)
                        .ok_or_else(|| {
                            anyhow!("Cannot find track with ID `{track_id}`")
                        })?;

                    track
                        .value_mut()
                        .senders
                        .entry(peer_id)
                        .or_default()
                        .insert(transceiver_index);

                    sender.replace_video_track(Some(track.as_ref()))
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    let track_id = AudioTrackId::from(track_id);
                    let mut track = self
                        .audio_tracks
                        .get_mut(&track_id)
                        .ok_or_else(|| {
                            anyhow!("Cannot find track with ID `{track_id}`")
                        })?;

                    track
                        .value_mut()
                        .senders
                        .entry(peer_id)
                        .or_default()
                        .insert(transceiver_index);

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

    /// Adds a [`sys::IceCandidateInterface`] to the given [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn add_ice_candidate(
        &mut self,
        peer_id: u64,
        candidate: String,
        sdp_mid: String,
        sdp_mline_index: i32,
        add_candidate_tx: mpsc::Sender<anyhow::Result<()>>,
    ) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer =
            self.peer_connections.get_mut(&peer_id).ok_or_else(|| {
                anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
            })?;

        let candidate = IceCandidate {
            candidate,
            sdp_mid,
            sdp_mline_index,
        };

        if peer.has_remote_description {
            peer.inner.lock().unwrap().add_ice_candidate(
                candidate.try_into()?,
                Box::new(AddIceCandidateCallback(add_candidate_tx)),
            );
        } else {
            peer.candidates_buffer.push(candidate);
            add_candidate_tx.send(Ok(()))?;
        }

        Ok(())
    }

    /// Tells the [`PeerConnection`] that ICE should be restarted.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn restart_ice(&self, peer_id: u64) -> anyhow::Result<()> {
        let peer_id = PeerConnectionId::from(peer_id);
        let peer = self.peer_connections.get(&peer_id).ok_or_else(|| {
            anyhow!("`PeerConnection` with ID `{peer_id}` doesn't exist")
        })?;

        peer.inner.lock().unwrap().restart_ice();

        Ok(())
    }

    /// Closes the [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn dispose_peer_connection(&mut self, peer_id: u64) {
        let peer_id = PeerConnectionId::from(peer_id);
        if let Some(peer) = self.peer_connections.get(&peer_id) {
            // Remove all tracks from this `Peer`'s senders.
            for mut track in self.video_tracks.iter_mut() {
                track.senders.remove(&peer_id);
            }

            for mut track in self.audio_tracks.iter_mut() {
                track.senders.remove(&peer_id);
            }

            let peer = peer.inner.lock().unwrap();

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
    }
}

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

/// Wrapper around a [`sys::PeerConnectionInterface`] with a unique ID.
pub struct PeerConnection {
    /// Underlying [`sys::PeerConnectionInterface`].
    inner: Arc<Mutex<sys::PeerConnectionInterface>>,

    /// Indicates whether the
    /// [`sys::PeerConnectionInterface::set_remote_description()`] was called
    /// on the underlying peer.
    has_remote_description: bool,

    /// Candidates, added before a remote description has been set on the
    /// underlying peer.
    candidates_buffer: Vec<IceCandidate>,
}

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        id: PeerConnectionId,
        factory: &mut sys::PeerConnectionFactoryInterface,
        video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,
        audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,
        observer: StreamSink<api::PeerConnectionEvent>,
        configuration: api::RtcConfiguration,
        pool: ThreadPool,
    ) -> anyhow::Result<Self> {
        let obs_peer = Arc::new(OnceCell::new());
        let observer = sys::PeerConnectionObserver::new(Box::new(
            PeerConnectionObserver {
                peer_id: id,
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

        let inner = Arc::new(Mutex::new(inner));
        obs_peer.set(Arc::clone(&inner)).unwrap_or_default();

        Ok(Self {
            inner,
            has_remote_description: false,
            candidates_buffer: Vec::new(),
        })
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
}

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
    /// ID of the observed [`PeerConnection`].
    peer_id: PeerConnectionId,

    /// [`PeerConnectionObserverInterface`] to forward the events to.
    observer: Arc<Mutex<StreamSink<api::PeerConnectionEvent>>>,

    /// [`InnerPeer`] of the [`PeerConnection`] internally used in
    /// [`sys::PeerConnectionObserver::on_track()`][1]
    ///
    /// Tasks with [`InnerPeer`] must be offloaded to a separate [`ThreadPool`],
    /// so the signalling thread wouldn't be blocked.
    peer: Arc<OnceCell<Arc<Mutex<sys::PeerConnectionInterface>>>>,

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
        let track_id = transceiver.receiver().track().id();
        let track_id = VideoTrackId::from(track_id);
        if self.video_tracks.contains_key(&track_id) {
            return;
        }
        let track_id = AudioTrackId::from(String::from(track_id));
        if self.audio_tracks.contains_key(&track_id) {
            return;
        }

        let track = match transceiver.media_type() {
            sys::MediaType::MEDIA_TYPE_AUDIO => {
                let track = AudioTrack::wrap_remote(&transceiver, self.peer_id);
                let result = api::MediaStreamTrack::from(&track);
                self.audio_tracks.insert(track.id.clone(), track);

                result
            }
            sys::MediaType::MEDIA_TYPE_VIDEO => {
                let track = VideoTrack::wrap_remote(&transceiver, self.peer_id);
                let result = api::MediaStreamTrack::from(&track);
                self.video_tracks.insert(track.id.clone(), track);

                result
            }
            _ => unreachable!(),
        };

        self.pool.execute({
            // PANIC: Unwrapping is OK, since the transceiver is guaranteed
            //        to be negotiated at this point.
            let mid = transceiver.mid().unwrap();
            let direction = transceiver.direction();
            let peer = Arc::clone(&self.peer);
            let observer = Arc::clone(&self.observer);
            let peer_id = self.peer_id;

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
                        index: index as u64,
                        mid: Some(mid),
                        direction: direction.into(),
                        peer_id: peer_id.into(),
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
