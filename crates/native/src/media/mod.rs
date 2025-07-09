mod device;
mod source;
mod track;

use std::{
    hash::Hash,
    sync::{Arc, Weak},
};

use anyhow::{anyhow, bail};
use derive_more::with_trait::{Display, From, Into as _};
use libwebrtc_sys as sys;

use self::track::TrackEventHandler;
pub use self::{
    device::{
        AudioDeviceId, AudioDeviceModule, VideoDeviceId, VideoDeviceInfo,
    },
    source::{
        AudioLevelObserverId, AudioSource, MediaTrackSource, VideoSource,
    },
    track::{
        AudioTrack, AudioTrackId, Track, TrackOrigin, VideoTrack, VideoTrackId,
    },
};
use crate::{
    Webrtc, api, api::NoiseSuppressionLevel, devices,
    frb_generated::StreamSink, pc::PeerConnectionId,
};

impl Webrtc {
    /// Creates a new [`VideoTrack`]s and/or [`AudioTrack`]s according to the
    /// provided accepted [`api::MediaStreamConstraints`].
    pub fn get_media(
        &mut self,
        constraints: api::MediaStreamConstraints,
    ) -> Result<Vec<api::MediaStreamTrack>, api::GetMediaError> {
        let mut tracks = Vec::new();

        let inner_get_media = || -> Result<(), api::GetMediaError> {
            if let Some(video) = constraints.video {
                let src =
                    self.get_or_create_video_source(&video).map_err(|err| {
                        api::GetMediaError::Video(err.to_string())
                    })?;
                let track = self
                    .create_video_track(Arc::clone(&src))
                    .map_err(|err| api::GetMediaError::Video(err.to_string()));
                if let Err(err) = track {
                    if Arc::strong_count(&src) == 2 {
                        self.video_sources.remove(src.device_id());
                    }
                    return Err(err);
                }
                tracks.push(track?);
            }

            if let Some(audio) = constraints.audio {
                let src = self
                    .get_or_create_audio_source(&audio)
                    .map_err(|e| api::GetMediaError::Audio(e.to_string()))?;
                let track = self
                    .create_audio_track(Arc::clone(&src))
                    .map_err(|e| api::GetMediaError::Audio(e.to_string()))?;
                tracks.push(track);
            }

            Ok(())
        };

        if let Err(e) = inner_get_media() {
            for track in tracks {
                self.dispose_track(
                    TrackOrigin::from(
                        track.peer_id.map(PeerConnectionId::from),
                    ),
                    track.id,
                    track.kind,
                    true,
                );
            }

            Err(e)
        } else {
            Ok(tracks)
        }
    }

    /// Disposes a [`VideoTrack`] or [`AudioTrack`] by the provided `track_id`.
    pub fn dispose_track(
        &mut self,
        track_origin: TrackOrigin,
        track_id: String,
        kind: api::MediaType,
        notify_on_ended: bool,
    ) {
        #[expect(clippy::mutable_key_type, reason = "false positive")]
        let senders = match kind {
            api::MediaType::Audio => {
                if let Some((_, mut track)) = self
                    .audio_tracks
                    .remove(&(AudioTrackId::from(track_id), track_origin))
                {
                    if let MediaTrackSource::Local(src) = track.source() {
                        if Arc::strong_count(src) <= 2 {
                            self.audio_sources.remove(src.device_id());
                            self.audio_device_module
                                .dispose_audio_source(src.device_id());
                        }
                    }
                    if notify_on_ended {
                        track.notify_on_ended();
                    }
                    track.take_senders()
                } else {
                    return;
                }
            }
            api::MediaType::Video => {
                if let Some((_, mut track)) = self
                    .video_tracks
                    .remove(&(VideoTrackId::from(track_id), track_origin))
                {
                    for id in track.sinks().clone() {
                        if let Some(sink) = self.video_sinks.remove(&id) {
                            track.remove_video_sink(sink);
                        }
                    }
                    if let MediaTrackSource::Local(src) = track.source() {
                        if Arc::strong_count(src) == 2 {
                            self.video_sources.remove(src.device_id());
                        }
                    }
                    if notify_on_ended {
                        track.notify_on_ended();
                    }
                    track.senders().clone()
                } else {
                    return;
                }
            }
        };

        #[expect(clippy::iter_over_hash_type, reason = "doesn't matter")]
        for (peer, tranceivers) in senders {
            for transceiver in tranceivers {
                if let Err(e) =
                    self.sender_replace_track(&peer, &transceiver, None)
                {
                    log::error!("Failed to remove track for the sender: {e}");
                }
            }
        }
    }

    /// Creates a new [`VideoTrack`] from the provided [`VideoSource`].
    fn create_video_track(
        &self,
        source: Arc<VideoSource>,
    ) -> anyhow::Result<api::MediaStreamTrack> {
        let track =
            VideoTrack::create_local(&self.peer_connection_factory, source)?;

        let api_track = api::MediaStreamTrack::from(&track);

        self.video_tracks.insert((track.id(), TrackOrigin::Local), track);

        Ok(api_track)
    }

    /// Creates a new [`VideoSource`] based on the provided
    /// [`VideoConstraints`].
    ///
    /// [`VideoConstraints`]: api::VideoConstraints
    fn get_or_create_video_source(
        &mut self,
        caps: &api::VideoConstraints,
    ) -> anyhow::Result<Arc<VideoSource>> {
        let (source, device_id) = if caps.is_display {
            let device_id = if let Some(device_id) = caps.device_id.clone() {
                sys::screen_capture_sources()
                    .into_iter()
                    .find(|d| d.id().to_string() == device_id)
                    .ok_or_else(|| {
                        anyhow!(
                            "Cannot find video display with the specified ID: \
                             {device_id}",
                        )
                    })?;
                device_id.into()
            } else {
                let displays = devices::enumerate_displays();
                // No device ID is provided, so pick the first available device.
                if displays.is_empty() {
                    bail!("Cannot find any available video input displays");
                }

                displays[0].device_id.clone().into()
            };
            if let Some(src) = self.video_sources.get(&device_id) {
                return Ok(Arc::clone(src));
            }

            (
                VideoSource::new_display_source(
                    &mut self.worker_thread,
                    &mut self.signaling_thread,
                    caps,
                    device_id.clone(),
                )?,
                device_id,
            )
        } else {
            let (index, device_id) = if let Some(device_id) =
                caps.device_id.clone()
            {
                let device_id = device_id.into();
                if let Some(index) =
                    self.get_index_of_video_device(&device_id)?
                {
                    (index, device_id)
                } else {
                    bail!(
                        "Cannot find video device with the specified ID: \
                         {device_id}",
                    );
                }
            } else {
                // No device ID is provided, so pick the first available device.
                if self.video_device_info.number_of_devices() < 1 {
                    bail!("Cannot find any available video input devices");
                }

                let device_id = self.video_device_info.device_name(0)?.1.into();
                (0, device_id)
            };
            if let Some(src) = self.video_sources.get(&device_id) {
                return Ok(Arc::clone(src));
            }

            (
                VideoSource::new_device_source(
                    &mut self.worker_thread,
                    &mut self.signaling_thread,
                    caps,
                    index,
                    device_id.clone(),
                )?,
                device_id,
            )
        };

        let source = self
            .video_sources
            .entry(device_id)
            .or_insert_with(|| Arc::new(source));

        Ok(Arc::clone(source))
    }

    /// Creates a new [`AudioTrack`] from the provided
    /// [`sys::AudioSourceInterface`].
    fn create_audio_track(
        &self,
        source: Arc<AudioSource>,
    ) -> anyhow::Result<api::MediaStreamTrack> {
        let track = AudioTrack::new(
            &self.peer_connection_factory,
            source,
            TrackOrigin::Local,
        )?;

        let api_track = api::MediaStreamTrack::from(&track);

        self.audio_tracks.insert((track.id(), TrackOrigin::Local), track);

        Ok(api_track)
    }

    /// Creates a new [`sys::AudioSourceInterface`] based on the provided
    /// [`AudioConstraints`].
    ///
    /// [`AudioConstraints`]: api::AudioConstraints
    fn get_or_create_audio_source(
        &mut self,
        caps: &api::AudioConstraints,
    ) -> anyhow::Result<Arc<AudioSource>> {
        let device_id = if let Some(device_id) = caps.device_id.clone() {
            device_id.into()
        } else {
            // `AudioDeviceModule` is not capturing anything at the moment, so
            // the first available device (with `0` index) will be used.
            if self.audio_device_module.recording_devices() < 1 {
                bail!("Cannot find any available audio input device");
            }

            self.audio_device_module.recording_device_name(0)?.1.into()
        };

        let Some(device_index) =
            self.get_index_of_audio_recording_device(&device_id)?
        else {
            bail!(
                "Cannot find audio device with the specified ID: `{device_id}`",
            );
        };

        let src = if let Some(src) = self.audio_sources.get(&device_id) {
            src.update_audio_processing(&caps.processing);
            Arc::clone(src)
        } else {
            let processing =
                sys::AudioProcessing::new((&caps.processing).into())?;

            let src = Arc::new(AudioSource::new(
                device_id.clone(),
                self.audio_device_module
                    .create_audio_source(device_index, &processing)?,
                processing,
            ));
            self.audio_sources.insert(device_id, Arc::clone(&src));

            src
        };

        Ok(src)
    }

    /// Returns the [readyState][0] property of the media track by its ID and
    /// [`MediaType`].
    ///
    /// [`MediaType`]: api::MediaType
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    #[must_use]
    pub fn track_state(
        &self,
        id: String,
        track_origin: TrackOrigin,
        kind: api::MediaType,
    ) -> api::TrackState {
        match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                self.audio_tracks
                    .get(&(id, track_origin))
                    .map_or_else(|| api::TrackState::Ended, |t| t.state())
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                self.video_tracks
                    .get(&(id, track_origin))
                    .map_or_else(|| api::TrackState::Ended, |t| t.state())
            }
        }
    }

    /// Returns the [width] property of the media track by its ID and origin.
    ///
    /// Blocks until the [width] is initialized.
    ///
    /// [width]: https://w3.org/TR/mediacapture-streams#dfn-width
    #[must_use]
    pub fn track_width(
        &self,
        id: String,
        track_origin: TrackOrigin,
    ) -> Option<i32> {
        let id = VideoTrackId::from(id);

        self.video_tracks
            .get(&(id, track_origin))
            .map(|t| t.dimensions().width())
    }

    /// Returns the [height] property of the media track by its ID and origin.
    ///
    /// Blocks until the [height] is initialized.
    ///
    /// [height]: https://w3.org/TR/mediacapture-streams#dfn-height
    #[must_use]
    pub fn track_height(
        &self,
        id: String,
        track_origin: TrackOrigin,
    ) -> Option<i32> {
        let id = VideoTrackId::from(id);

        self.video_tracks
            .get(&(id, track_origin))
            .map(|t| t.dimensions().height())
    }

    /// Changes the [enabled][1] property of the media track by its ID and
    /// origin.
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_track_enabled(
        &self,
        id: String,
        track_origin: TrackOrigin,
        kind: api::MediaType,
        enabled: bool,
    ) {
        match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                let track = self.audio_tracks.get(&(id, track_origin));
                if let Some(track) = track {
                    track.set_enabled(enabled);
                }
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                let track = self.video_tracks.get(&(id, track_origin));
                if let Some(track) = track {
                    track.set_enabled(enabled);
                }
            }
        }
    }

    /// Clones a [`MediaStreamTrack`] by its ID and origin.
    ///
    /// [`MediaStreamTrack`]: api::MediaStreamTrack
    #[must_use]
    pub fn clone_track(
        &self,
        id: String,
        track_origin: TrackOrigin,
        kind: api::MediaType,
    ) -> Option<api::MediaStreamTrack> {
        match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                let source = self.audio_tracks.get(&(id, track_origin)).map(
                    |track| match track.source() {
                        MediaTrackSource::Local(source) => {
                            MediaTrackSource::Local(Arc::clone(source))
                        }
                        MediaTrackSource::Remote { mid, peer } => {
                            MediaTrackSource::Remote {
                                mid: mid.clone(),
                                peer: Weak::clone(peer),
                            }
                        }
                    },
                )?;

                match source {
                    MediaTrackSource::Local(source) => Some(
                        self.create_audio_track(Arc::clone(&source)).ok()?,
                    ),
                    MediaTrackSource::Remote { mid, peer } => {
                        let peer = peer.upgrade()?;
                        let mut transceivers = peer.get_transceivers();

                        transceivers.retain(|transceiver| {
                            transceiver.mid().unwrap() == mid
                        });

                        if transceivers.is_empty() {
                            return None;
                        }

                        let track = AudioTrack::wrap_remote(
                            transceivers.first().unwrap(),
                            &peer,
                        );

                        Some(api::MediaStreamTrack::from(&track))
                    }
                }
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                let source = self.video_tracks.get(&(id, track_origin)).map(
                    |track| match track.source() {
                        MediaTrackSource::Local(source) => {
                            MediaTrackSource::Local(Arc::clone(source))
                        }
                        MediaTrackSource::Remote { mid, peer } => {
                            MediaTrackSource::Remote {
                                mid: mid.clone(),
                                peer: Weak::clone(peer),
                            }
                        }
                    },
                )?;

                match source {
                    MediaTrackSource::Local(source) => {
                        Some(self.create_video_track(source).ok()?)
                    }
                    MediaTrackSource::Remote { mid, peer } => {
                        let peer = peer.upgrade()?;
                        let mut transceivers = peer.get_transceivers();
                        transceivers.retain(|transceiver| {
                            transceiver.mid().unwrap() == mid
                        });

                        if transceivers.is_empty() {
                            return None;
                        }

                        let track = VideoTrack::wrap_remote(
                            transceivers.first().unwrap(),
                            &peer,
                        );

                        Some(api::MediaStreamTrack::from(&track))
                    }
                }
            }
        }
    }

    /// Enables or disables audio level observing of the [`AudioTrack`] with the
    /// provided `id`.
    ///
    /// # Warning
    ///
    /// Returns an error message if cannot find any [`AudioTrack`] by the
    /// provided `id`.
    pub fn set_audio_level_observer_enabled(
        &self,
        id: String,
        track_origin: TrackOrigin,
        enabled: bool,
    ) {
        let id = AudioTrackId::from(id);
        let track = self.audio_tracks.get_mut(&(id, track_origin));
        if let Some(mut track) = track {
            if enabled {
                track.subscribe_to_audio_level();
            } else {
                track.unsubscribe_from_audio_level();
            }
        }
    }

    /// Registers an events observer for an [`AudioTrack`] or a [`VideoTrack`].
    ///
    /// # Warning
    ///
    /// Returns an error message if cannot find any [`AudioTrack`] or
    /// [`VideoTrack`] by the provided `id`.
    pub fn register_track_observer(
        &self,
        id: String,
        track_origin: TrackOrigin,
        kind: api::MediaType,
        track_events_tx: StreamSink<api::TrackEvent>,
    ) {
        let mut obs = sys::TrackEventObserver::new(Box::new(
            TrackEventHandler::new(track_events_tx.clone()),
        ));
        match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                let track = self.audio_tracks.get_mut(&(id, track_origin));

                if let Some(mut track) = track {
                    obs.set_audio_track(&track);
                    track.set_track_events_tx(track_events_tx);
                    track.register_observer(obs);
                }
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                let track = self.video_tracks.get_mut(&(id, track_origin));

                if let Some(mut track) = track {
                    obs.set_video_track(&track);
                    track.set_track_events_tx(track_events_tx);
                    track.register_observer(obs);
                }
            }
        }
    }

    /// Applies the provided [`api::AudioProcessingConstraints`] to the
    /// [`sys::AudioSourceInterface`] of the referred local [`AudioTrack`].
    ///
    /// # Errors
    ///
    /// If the provided [`AudioTrackId`] refers to a remote [`AudioTrack`].
    pub fn apply_audio_processing_config(
        &self,
        id: String,
        conf: &api::AudioProcessingConstraints,
    ) -> anyhow::Result<()> {
        let id = AudioTrackId::from(id);
        let Some(track) = self.audio_tracks.get_mut(&(id, TrackOrigin::Local))
        else {
            return Ok(());
        };

        let MediaTrackSource::Local(src) = track.source() else {
            bail!("Cannot change audio processing of remote `AudioTrack`");
        };

        src.update_audio_processing(conf);

        Ok(())
    }

    /// Returns the [`api::AudioProcessingConstraints`] of the
    /// [`sys::AudioSourceInterface`] of the referred local [`AudioTrack`].
    ///
    /// # Errors
    ///
    /// If the provided [`AudioTrackId`] refers to a remote [`AudioTrack`].
    pub fn get_audio_processing_config(
        &self,
        id: String,
    ) -> anyhow::Result<api::AudioProcessingConfig> {
        let id = AudioTrackId::from(id);
        let Some(track) = self.audio_tracks.get_mut(&(id, TrackOrigin::Local))
        else {
            // This means that the `AudioTrack` was already removed, so to omit
            // erroring something should be returned. It shouldn't really matter
            // what is returned, so default values are just okay.
            return Ok(api::AudioProcessingConfig {
                auto_gain_control: true,
                high_pass_filter: true,
                noise_suppression: true,
                noise_suppression_level: NoiseSuppressionLevel::VeryHigh,
                echo_cancellation: true,
            });
        };

        let MediaTrackSource::Local(src) = track.source() else {
            bail!("Cannot get audio processing of remote `AudioTrack`");
        };

        let mut conf = src.ap_config();

        Ok(api::AudioProcessingConfig {
            auto_gain_control: conf.get_gain_controller_enabled(),
            high_pass_filter: conf.get_high_pass_filter_enabled(),
            noise_suppression: conf.get_noise_suppression_enabled(),
            noise_suppression_level: conf.get_noise_suppression_level().into(),
            echo_cancellation: conf.get_echo_cancellation_enabled(),
        })
    }
}

/// ID of a [MediaStream].
///
/// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, PartialEq)]
pub struct MediaStreamId(u64);
