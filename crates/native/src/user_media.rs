use std::{
    cmp,
    collections::{HashMap, HashSet},
    hash::Hash,
    mem,
    sync::{Arc, Mutex, OnceLock, RwLock, Weak},
};

use anyhow::{Context as _, anyhow, bail};
use derive_more::with_trait::{AsRef, Display, From, Into};
use libwebrtc_sys as sys;
use sys::AudioProcessing;
use xxhash::xxh3::xxh3_64;

use crate::{
    PeerConnection, VideoSink, VideoSinkId, Webrtc, api, devices,
    frb_generated::StreamSink,
    next_id,
    pc::{PeerConnectionId, RtpTransceiver},
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
                        self.video_sources.remove(&src.device_id);
                    }
                    return Err(err);
                }
                tracks.push(track?);
            }

            if let Some(audio) = constraints.audio {
                self.set_audio_processing_config(&audio);
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

        if let Err(err) = inner_get_media() {
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

            Err(err)
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
                    if let MediaTrackSource::Local(src) = &track.source {
                        if Arc::strong_count(src) <= 2 {
                            self.audio_sources.remove(&src.device_id);
                            self.audio_device_module
                                .dispose_audio_source(&src.device_id);
                        }
                    }
                    if notify_on_ended {
                        track.notify_on_ended();
                    }
                    mem::take(&mut track.senders)
                } else {
                    return;
                }
            }
            api::MediaType::Video => {
                if let Some((_, mut track)) = self
                    .video_tracks
                    .remove(&(VideoTrackId::from(track_id), track_origin))
                {
                    for id in track.sinks.clone() {
                        if let Some(sink) = self.video_sinks.remove(&id) {
                            track.remove_video_sink(sink);
                        }
                    }
                    if let MediaTrackSource::Local(src) = &track.source {
                        if Arc::strong_count(src) == 2 {
                            self.video_sources.remove(&src.device_id);
                        }
                    }
                    if notify_on_ended {
                        track.notify_on_ended();
                    }
                    track.senders.clone()
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

    /// Creates a new [`VideoTrack`] from the given [`VideoSource`].
    fn create_video_track(
        &self,
        source: Arc<VideoSource>,
    ) -> anyhow::Result<api::MediaStreamTrack> {
        let track =
            VideoTrack::create_local(&self.peer_connection_factory, source)?;

        let api_track = api::MediaStreamTrack::from(&track);

        self.video_tracks.insert((track.id.clone(), TrackOrigin::Local), track);

        Ok(api_track)
    }

    /// Creates a new [`VideoSource`] based on the given [`VideoConstraints`].
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
                VideoDeviceId(device_id)
            } else {
                let displays = devices::enumerate_displays();
                // No device ID is provided, so just pick the first available
                // device.
                if displays.is_empty() {
                    bail!("Cannot find any available video input displays");
                }

                VideoDeviceId(displays[0].device_id.clone())
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
            let (index, device_id) =
                if let Some(device_id) = caps.device_id.clone() {
                    let device_id = VideoDeviceId(device_id);
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
                    // No device ID is provided, so just pick the first
                    // available device.
                    if self.video_device_info.number_of_devices() < 1 {
                        bail!("Cannot find any available video input devices");
                    }

                    let device_id =
                        VideoDeviceId(self.video_device_info.device_name(0)?.1);
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

    /// Creates a new [`AudioTrack`] from the given
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

        self.audio_tracks.insert((track.id.clone(), TrackOrigin::Local), track);

        Ok(api_track)
    }

    /// Sets [`api::AudioConstraints`] for this [`Webrtc`] session.
    fn set_audio_processing_config(&self, caps: &api::AudioConstraints) {
        if let Some(auto_gain_control) = caps.auto_gain_control {
            let mut config = self.ap.config();
            config.set_gain_controller_enabled(auto_gain_control);
            self.ap.apply_config(&config);
        }
    }

    /// Creates a new [`sys::AudioSourceInterface`] based on the given
    /// [`AudioConstraints`].
    fn get_or_create_audio_source(
        &mut self,
        caps: &api::AudioConstraints,
    ) -> anyhow::Result<Arc<AudioSource>> {
        let device_id = if let Some(device_id) = caps.device_id.clone() {
            AudioDeviceId(device_id)
        } else {
            // `AudioDeviceModule` is not capturing anything at the moment,
            // so we will use first available device (with `0` index).
            if self.audio_device_module.recording_devices() < 1 {
                bail!("Cannot find any available audio input device");
            }

            AudioDeviceId(self.audio_device_module.recording_device_name(0)?.1)
        };

        let Some(device_index) =
            self.get_index_of_audio_recording_device(&device_id)?
        else {
            bail!(
                "Cannot find audio device with the specified ID `{device_id}`",
            );
        };

        let src = if let Some(src) = self.audio_sources.get(&device_id) {
            Arc::clone(src)
        } else {
            let src = Arc::new(AudioSource::new(
                device_id.clone(),
                Arc::new(
                    self.audio_device_module
                        .create_audio_source(device_index)?,
                ),
            ));
            self.audio_sources.insert(device_id, Arc::clone(&src));

            src
        };

        Ok(src)
    }

    /// Returns the [readyState][0] property of the media track by its ID and
    /// media type.
    ///
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
            .map(|t| *t.width.wait().read().unwrap())
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
            .map(|t| *t.height.wait().read().unwrap())
    }

    /// Changes the [enabled][1] property of the media track by its ID.
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

    /// Clones the specified [`api::MediaStreamTrack`].
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
                    |track| match &track.source {
                        MediaTrackSource::Local(source) => {
                            MediaTrackSource::Local(Arc::clone(source))
                        }
                        MediaTrackSource::Remote { mid, peer } => {
                            MediaTrackSource::Remote {
                                mid: mid.to_string(),
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
                    |track| match &track.source {
                        MediaTrackSource::Local(source) => {
                            MediaTrackSource::Local(Arc::clone(source))
                        }
                        MediaTrackSource::Remote { mid, peer } => {
                            MediaTrackSource::Remote {
                                mid: mid.to_string(),
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
    /// Returns error message if cannot find any [`AudioTrack`] by the provided
    /// `id`.
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
    /// Returns error message if cannot find any [`AudioTrack`] or
    /// [`VideoTrack`] by the specified `id`.
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
                    obs.set_audio_track(&track.inner);
                    track.set_track_events_tx(track_events_tx);
                    track.inner.register_observer(obs);
                }
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                let track = self.video_tracks.get_mut(&(id, track_origin));

                if let Some(mut track) = track {
                    obs.set_video_track(&track.inner);
                    track.set_track_events_tx(track_events_tx);
                    track.inner.register_observer(obs);
                }
            }
        }
    }
}

/// ID of a [MediaStream].
///
/// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, PartialEq)]
pub struct MediaStreamId(u64);

/// ID of an video input device that provides data to some [`VideoSource`].
#[derive(AsRef, Clone, Debug, Display, Eq, From, Hash, Into, PartialEq)]
#[as_ref(forward)]
pub struct VideoDeviceId(String);

/// ID of an `AudioDevice`.
#[derive(
    AsRef, Clone, Debug, Default, Display, Eq, From, Hash, Into, PartialEq,
)]
#[as_ref(forward)]
pub struct AudioDeviceId(String);

/// ID of a [`VideoTrack`].
#[derive(Clone, Debug, Display, From, Eq, Hash, Into, PartialEq)]
pub struct VideoTrackId(String);

/// ID of an [`AudioTrack`].
#[derive(Clone, Debug, Display, From, Eq, Hash, Into, PartialEq)]
pub struct AudioTrackId(String);

/// Label identifying a video track source.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, From, Hash, PartialEq)]
#[as_ref(forward)]
#[from(forward)]
pub struct VideoLabel(String);

/// Label identifying an audio track source.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, From, Hash, PartialEq)]
#[as_ref(forward)]
#[from(forward)]
pub struct AudioLabel(String);

/// [`sys::VideoDeviceInfo`] wrapper.
pub struct VideoDeviceInfo(sys::VideoDeviceInfo);

impl VideoDeviceInfo {
    /// Creates a new [`VideoDeviceInfo`].
    ///
    /// # Errors
    ///
    /// If [`sys::VideoDeviceInfo::create()`] returns error.
    pub fn new() -> anyhow::Result<Self> {
        Ok(Self(sys::VideoDeviceInfo::create()?))
    }

    /// Returns count of a video recording devices.
    pub fn number_of_devices(&mut self) -> u32 {
        if api::is_fake_media() { 1 } else { self.0.number_of_devices() }
    }

    /// Returns the `(label, id)` tuple for the given video device `index`.
    ///
    /// # Errors
    ///
    /// If [`sys::VideoDeviceInfo::device_name()`] call returns error.
    pub fn device_name(
        &mut self,
        index: u32,
    ) -> anyhow::Result<(String, String)> {
        if api::is_fake_media() {
            Ok((String::from("fake camera"), String::from("fake camera id")))
        } else {
            self.0.device_name(index)
        }
    }
}

/// [`sys::AudioDeviceModule`] wrapper tracking the currently used audio input
/// device.
#[derive(AsRef)]
pub struct AudioDeviceModule {
    /// [`sys::AudioDeviceModule`] backing this [`AudioDeviceModule`].
    #[as_ref]
    inner: sys::AudioDeviceModule,
}

impl AudioDeviceModule {
    /// Creates a new [`AudioDeviceModule`] according to the passed
    /// [`sys::AudioLayer`].
    ///
    /// # Errors
    ///
    /// If could not find any available recording device.
    pub fn new(
        worker_thread: &mut sys::Thread,
        audio_layer: sys::AudioLayer,
        task_queue_factory: &mut sys::TaskQueueFactory,
        ap: Option<&AudioProcessing>,
    ) -> anyhow::Result<Self> {
        let inner = sys::AudioDeviceModule::create_proxy(
            worker_thread,
            audio_layer,
            task_queue_factory,
            ap,
        )?;
        inner.init()?;

        Ok(Self { inner })
    }

    /// Returns the `(label, id)` tuple for the given audio playout device
    /// `index`.
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::playout_device_name()`] call fails.
    pub fn playout_device_name(
        &self,
        index: i16,
    ) -> anyhow::Result<(String, String)> {
        if api::is_fake_media() {
            return Ok((
                String::from("fake headset"),
                String::from("fake headset id"),
            ));
        }

        let (label, mut device_id) = self.inner.playout_device_name(index)?;

        if device_id.is_empty() {
            let hash = xxh3_64(
                [label.as_bytes(), &[api::MediaDeviceKind::AudioOutput as u8]]
                    .concat()
                    .as_slice(),
            );
            device_id = hash.to_string();
        }

        Ok((label, device_id))
    }

    /// Returns the `(label, id)` tuple for the given audio recording device
    /// `index`.
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::recording_device_name()`] call fails.
    pub fn recording_device_name(
        &self,
        index: i16,
    ) -> anyhow::Result<(String, String)> {
        if api::is_fake_media() {
            return Ok((String::from("fake mic"), String::from("fake mic id")));
        }

        let (label, mut device_id) = self.inner.recording_device_name(index)?;

        if device_id.is_empty() {
            let hash = xxh3_64(
                [label.as_bytes(), &[api::MediaDeviceKind::AudioOutput as u8]]
                    .concat()
                    .as_slice(),
            );
            device_id = hash.to_string();
        }

        Ok((label, device_id))
    }

    /// Returns count of available audio playout devices.
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::playout_devices()`] call fails.
    #[must_use]
    pub fn playout_devices(&self) -> u32 {
        self.inner.playout_devices()
    }

    /// Returns count of available audio recording devices.
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::recording_devices()`] call fails.
    #[must_use]
    pub fn recording_devices(&self) -> u32 {
        if api::is_fake_media() { 1 } else { self.inner.recording_devices() }
    }

    /// Creates a new [`sys::AudioSourceInterface`] based on the provided
    /// `device_index`.
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::recording_devices()`] call fails.
    pub fn create_audio_source(
        &mut self,
        device_index: u16,
    ) -> anyhow::Result<sys::AudioSourceInterface> {
        if api::is_fake_media() {
            self.inner.create_fake_audio_source()
        } else {
            self.inner.create_audio_source(device_index)
        }
    }

    /// Disposes a [`sys::AudioSourceInterface`] by the provided
    /// [`AudioDeviceId`].
    pub fn dispose_audio_source(&mut self, device_id: &AudioDeviceId) {
        self.inner.dispose_audio_source(device_id.to_string());
    }

    /// Sets the microphone system volume according to the given level in
    /// percents.
    ///
    /// # Errors
    ///
    /// Errors if any of the following calls fail:
    ///     - [`sys::AudioDeviceModule::microphone_volume_is_available()`];
    ///     - [`sys::AudioDeviceModule::min_microphone_volume()`];
    ///     - [`sys::AudioDeviceModule::max_microphone_volume()`];
    ///     - [`sys::AudioDeviceModule::set_microphone_volume()`].
    pub fn set_microphone_volume(&self, mut level: u8) -> anyhow::Result<()> {
        if !self.microphone_volume_is_available()? {
            bail!("The microphone volume is unavailable.")
        }

        if level > 100 {
            level = 100;
        }

        let min_volume = self.inner.min_microphone_volume()?;
        let max_volume = self.inner.max_microphone_volume()?;

        let volume = f64::from(max_volume - min_volume)
            .mul_add(f64::from(level) / 100.0, f64::from(min_volume));

        #[expect( // intentional
            clippy::cast_possible_truncation,
            clippy::cast_sign_loss,
            reason = "size fits and non-negative"
        )]
        self.inner.set_microphone_volume(volume as u32)
    }

    /// Indicates if the microphone is available to set volume.
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::microphone_volume_is_available()`] call
    /// fails.
    pub fn microphone_volume_is_available(&self) -> anyhow::Result<bool> {
        Ok(self.inner.microphone_volume_is_available().unwrap_or(false))
    }

    /// Returns the current level of the microphone volume in percents.
    ///
    /// # Errors
    ///
    /// If fails on:
    ///     - [`sys::AudioDeviceModule::microphone_volume()`] call
    ///     - [`sys::AudioDeviceModule::min_microphone_volume()`] call
    ///     - [`sys::AudioDeviceModule::max_microphone_volume()`] call
    pub fn microphone_volume(&self) -> anyhow::Result<u32> {
        let volume = self.inner.microphone_volume()?;
        let min_volume = self.inner.min_microphone_volume()?;
        let max_volume = self.inner.max_microphone_volume()?;

        #[expect( // intentional
            clippy::cast_possible_truncation,
            clippy::cast_sign_loss,
            reason = "size fits and non-negative"
        )]
        let level = (f64::from(volume - min_volume)
            / f64::from(max_volume - min_volume)
            * 100.0) as u32;

        Ok(level)
    }

    /// Changes the playout device for this [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::set_playout_device()`] call fails.
    pub fn set_playout_device(&self, index: u16) -> anyhow::Result<()> {
        self.inner.set_playout_device(index)?;

        Ok(())
    }

    /// Stops playout of audio on this [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::stop_playout()`] call fails.
    pub fn stop_playout(&self) -> anyhow::Result<()> {
        self.inner.stop_playout()
    }

    /// Indicates whether stereo is available in this playout
    /// [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::stereo_playout_is_available()`] call fails.
    pub fn stereo_playout_is_available(&self) -> anyhow::Result<bool> {
        self.inner.stereo_playout_is_available()
    }

    /// Initializes this playout [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::init_playout()`] call fails.
    pub fn init_playout(&self) -> anyhow::Result<()> {
        self.inner.init_playout()
    }

    /// Starts playout of audio on this [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::start_playout()`] call fails.
    pub fn start_playout(&self) -> anyhow::Result<()> {
        self.inner.start_playout()
    }
}

/// Indicates whether some track is a local track obtained via
/// [getUserMedia()][1]/[getDisplayMedia()][2] call or a remote received in a
/// [ontrack][3] callback.
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediadevices-getusermedia
/// [2]: https://w3.org/TR/screen-capture/#dom-mediadevices-getdisplaymedia
/// [3]: https://w3.org/TR/webrtc/#dom-rtcpeerconnection-ontrack
#[derive(Clone, Copy, Debug, Eq, From, Hash, PartialEq)]
pub enum TrackOrigin {
    Local,
    Remote(PeerConnectionId),
}

impl From<Option<PeerConnectionId>> for TrackOrigin {
    fn from(value: Option<PeerConnectionId>) -> Self {
        value.map_or(Self::Local, Self::Remote)
    }
}

/// Possible kinds of media track's source.
pub enum MediaTrackSource<T> {
    Local(Arc<T>),
    Remote { mid: String, peer: Weak<PeerConnection> },
}

/// Representation of a [`sys::VideoTrackInterface`].
#[derive(AsRef)]
pub struct VideoTrack {
    /// ID of this [`VideoTrack`].
    pub id: VideoTrackId,

    /// Indicator whether this is a remote or a local track.
    track_origin: TrackOrigin,

    /// Underlying [`sys::VideoTrackInterface`].
    #[as_ref]
    inner: sys::VideoTrackInterface,

    /// [`VideoSource`] that is used by this [`VideoTrack`].
    pub source: MediaTrackSource<VideoSource>,

    /// [`api::TrackKind::kVideo`].
    kind: api::MediaType,

    /// List of the [`VideoSink`]s attached to this [`VideoTrack`].
    sinks: Vec<VideoSinkId>,

    /// `StreamSink` which can be used by this [`VideoTrack`] to emit
    /// [`api::TrackEvent`]s to Flutter side.
    pub track_events_tx: Option<StreamSink<api::TrackEvent>>,

    /// Peers and transceivers sending this [`VideoTrack`].
    pub senders: HashMap<Arc<PeerConnection>, HashSet<Arc<RtpTransceiver>>>,

    /// Tracks changes in video `height` and `width`.
    sink: Option<VideoSink>,

    /// Video width.
    width: Arc<OnceLock<RwLock<i32>>>,

    /// Video height.
    height: Arc<OnceLock<RwLock<i32>>>,
}

/// Tracks changes in video `height` and `width`.
struct VideoFormatSink {
    /// Video width.
    width: Arc<OnceLock<RwLock<i32>>>,

    /// Video height.
    height: Arc<OnceLock<RwLock<i32>>>,
}

impl sys::OnFrameCallback for VideoFormatSink {
    fn on_frame(&mut self, frame: cxx::UniquePtr<sys::VideoFrame>) {
        if self.width.get().is_none() {
            self.width.set(RwLock::from(frame.width())).unwrap();
            self.height.set(RwLock::from(frame.height())).unwrap();
        } else {
            *self.width.get().unwrap().write().unwrap() = frame.width();
            *self.height.get().unwrap().write().unwrap() = frame.height();
        }
    }
}

impl VideoTrack {
    /// Creates a new [`VideoTrack`].
    fn create_local(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Arc<VideoSource>,
    ) -> anyhow::Result<Self> {
        let id = VideoTrackId(next_id().to_string());
        let track_origin = TrackOrigin::Local;

        let width = Arc::new(OnceLock::new());
        let height = Arc::new(OnceLock::new());
        let mut sink = VideoSink::new(
            i64::from(next_id()),
            sys::VideoSinkInterface::create_forwarding(Box::new(
                VideoFormatSink {
                    width: Arc::clone(&width),
                    height: Arc::clone(&height),
                },
            )),
            id.clone(),
            track_origin,
        );

        let mut res = Self {
            id: id.clone(),
            inner: pc.create_video_track(id.into(), &src.inner)?,
            source: MediaTrackSource::Local(src),
            kind: api::MediaType::Video,
            sinks: Vec::new(),
            senders: HashMap::new(),
            track_events_tx: None,
            width,
            height,
            sink: None,
            track_origin,
        };

        res.add_video_sink(&mut sink);
        res.sink = Some(sink);

        Ok(res)
    }

    /// Sets the provided `StreamSink` for this [`VideoTrack`] to use for
    /// [`api::TrackEvent`]s emitting.
    pub fn set_track_events_tx(&mut self, sink: StreamSink<api::TrackEvent>) {
        drop(self.track_events_tx.replace(sink));
    }

    /// Wraps the track of the `transceiver.receiver.track()` into a
    /// [`VideoTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer: &Arc<PeerConnection>,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        let track_origin = TrackOrigin::Remote(peer.id());

        let width = Arc::new(OnceLock::new());
        width.set(RwLock::from(0)).unwrap();
        let height = Arc::new(OnceLock::new());
        height.set(RwLock::from(0)).unwrap();
        let mut sink = VideoSink::new(
            i64::from(next_id()),
            sys::VideoSinkInterface::create_forwarding(Box::new(
                VideoFormatSink {
                    width: Arc::clone(&width),
                    height: Arc::clone(&height),
                },
            )),
            VideoTrackId(track.id()),
            track_origin,
        );

        let mut res = Self {
            id: VideoTrackId(track.id()),
            inner: track.try_into().unwrap(),
            // Safe to unwrap since transceiver is guaranteed to be negotiated
            // at this point.
            source: MediaTrackSource::Remote {
                mid: transceiver.mid().unwrap(),
                peer: Arc::downgrade(peer),
            },
            kind: api::MediaType::Video,
            sinks: Vec::new(),
            senders: HashMap::new(),
            track_events_tx: None,
            width,
            height,
            sink: None,
            track_origin,
        };

        res.add_video_sink(&mut sink);
        res.sink = Some(sink);

        res
    }

    /// Adds the provided [`VideoSink`] to this [`VideoTrack`].
    pub fn add_video_sink(&mut self, video_sink: &mut VideoSink) {
        self.inner.add_or_update_sink(video_sink.as_mut());
        self.sinks.push(video_sink.id());
    }

    /// Detaches the provided [`VideoSink`] from this [`VideoTrack`].
    pub fn remove_video_sink(&mut self, mut video_sink: VideoSink) {
        self.sinks.retain(|&sink| sink != video_sink.id());
        self.inner.remove_sink(video_sink.as_mut());
    }

    /// Changes the [enabled][1] property of the underlying
    /// [`sys::VideoTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        self.inner.set_enabled(enabled);
    }

    /// Returns the [readyState][0] property of the underlying
    /// [`sys::VideoTrackInterface`].
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    #[must_use]
    pub fn state(&self) -> api::TrackState {
        self.inner.state().into()
    }

    /// Emits [`api::TrackEvent::Ended`] to the Flutter side.
    pub fn notify_on_ended(&mut self) {
        if let Some(sink) = self.track_events_tx.take() {
            _ = sink.add(api::TrackEvent::Ended);
        }
    }
}

impl Drop for VideoTrack {
    fn drop(&mut self) {
        let sink = self.sink.take().unwrap();
        self.remove_video_sink(sink);
    }
}

impl From<&VideoTrack> for api::MediaStreamTrack {
    fn from(track: &VideoTrack) -> Self {
        Self {
            id: track.id.0.clone(),
            device_id: match &track.source {
                MediaTrackSource::Local(src) => src.device_id.to_string(),
                MediaTrackSource::Remote { .. } => "remote".into(),
            },
            kind: track.kind,
            enabled: true,
            peer_id: match track.track_origin {
                TrackOrigin::Local => None,
                TrackOrigin::Remote(peer_id) => Some(peer_id.into()),
            },
        }
    }
}

// TODO: Refactor tracks to Track<Audio|Video> to avoid duplication.
/// Representation of a [`sys::AudioSourceInterface`].
#[derive(AsRef)]
pub struct AudioTrack {
    /// ID of this [`AudioTrack`].
    pub id: AudioTrackId,

    /// Indicator whether this is a remote or a local track.
    track_origin: TrackOrigin,

    /// Underlying [`sys::AudioTrackInterface`].
    #[as_ref]
    inner: sys::AudioTrackInterface,

    /// [`sys::AudioSourceInterface`] that is used by this [`AudioTrack`].
    pub source: MediaTrackSource<AudioSource>,

    /// [`api::TrackKind::kAudio`].
    kind: api::MediaType,

    /// `StreamSink` which can be used by this [`AudioTrack`] to emit
    /// [`api::TrackEvent`]s to Flutter side.
    pub track_events_tx: Option<StreamSink<api::TrackEvent>>,

    /// Peers and transceivers sending this [`VideoTrack`].
    pub senders: HashMap<Arc<PeerConnection>, HashSet<Arc<RtpTransceiver>>>,

    /// [`AudioLevelObserverId`] related to this [`AudioTrack`].
    ///
    /// This ID can be used when this [`AudioTrack`] needs to dispose its
    /// observer.
    volume_observer_id: Option<AudioLevelObserverId>,
}

impl AudioTrack {
    /// Creates a new [`AudioTrack`].
    ///
    /// # Errors
    ///
    /// Whenever [`sys::PeerConnectionFactoryInterface::create_audio_track()`]
    /// returns an error.
    pub fn new(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Arc<AudioSource>,
        track_origin: TrackOrigin,
    ) -> anyhow::Result<Self> {
        let id = AudioTrackId(next_id().to_string());
        Ok(Self {
            id: id.clone(),
            inner: pc.create_audio_track(id.into(), &src.src)?,
            source: MediaTrackSource::Local(src),
            kind: api::MediaType::Audio,
            senders: HashMap::new(),
            track_origin,
            track_events_tx: None,
            volume_observer_id: None,
        })
    }

    /// Subscribes this [`AudioTrack`] to audio level updates.
    ///
    /// Volume updates will be passed to the `stream_sink` of this
    /// [`AudioTrack`].
    pub fn subscribe_to_audio_level(&mut self) {
        if let Some(sink) = self.track_events_tx.clone() {
            match &self.source {
                MediaTrackSource::Local(src) => {
                    let observer = src.subscribe_on_audio_level(
                        AudioSourceAudioLevelHandler(sink),
                    );
                    self.volume_observer_id = Some(observer);
                }
                MediaTrackSource::Remote { mid: _, peer: _ } => (),
            }
        }
    }

    /// Unsubscribes this [`AudioTrack`] from audio level updates.
    pub fn unsubscribe_from_audio_level(&self) {
        match &self.source {
            MediaTrackSource::Local(src) => {
                if let Some(id) = self.volume_observer_id {
                    src.unsubscribe_audio_level(id);
                }
            }
            MediaTrackSource::Remote { mid: _, peer: _ } => (),
        }
    }

    /// Sets the provided `stream_sink` for this [`AudioTrack`] to use for
    /// [`api::TrackEvent`]s emitting.
    pub fn set_track_events_tx(&mut self, sink: StreamSink<api::TrackEvent>) {
        drop(self.track_events_tx.replace(sink));
    }

    /// Wraps the track of the `transceiver.receiver.track()` into an
    /// [`AudioTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer: &Arc<PeerConnection>,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        Self {
            id: AudioTrackId(track.id()),
            inner: track.try_into().unwrap(),
            // Safe to unwrap since transceiver is guaranteed to be negotiated
            // at this point.
            source: MediaTrackSource::Remote {
                mid: transceiver.mid().unwrap(),
                peer: Arc::downgrade(peer),
            },
            kind: api::MediaType::Audio,
            senders: HashMap::new(),
            track_origin: TrackOrigin::Remote(peer.id()),
            track_events_tx: None,
            volume_observer_id: None,
        }
    }

    /// Returns the [readyState][0] property of the underlying
    /// [`sys::AudioTrackInterface`].
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    #[must_use]
    pub fn state(&self) -> api::TrackState {
        self.inner.state().into()
    }

    /// Changes the [enabled][1] property of the underlying
    /// [`sys::AudioTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        self.inner.set_enabled(enabled);
    }

    /// Emits [`api::TrackEvent::Ended`] to the Flutter side.
    pub fn notify_on_ended(&mut self) {
        if let Some(sink) = self.track_events_tx.take() {
            _ = sink.add(api::TrackEvent::Ended);
        }
    }
}

impl From<&AudioTrack> for api::MediaStreamTrack {
    fn from(track: &AudioTrack) -> Self {
        Self {
            id: track.id.0.clone(),
            device_id: match &track.source {
                MediaTrackSource::Local(local) => local.device_id.to_string(),
                MediaTrackSource::Remote { mid: _, peer: _ } => "remote".into(),
            },
            kind: track.kind,
            enabled: true,
            peer_id: match track.track_origin {
                TrackOrigin::Local => None,
                TrackOrigin::Remote(peer_id) => Some(peer_id.into()),
            },
        }
    }
}

impl Drop for AudioTrack {
    fn drop(&mut self) {
        self.unsubscribe_from_audio_level();
    }
}

/// [`sys::AudioSourceOnAudioLevelChangeCallback`] unique (per
/// [`AudioSourceInterface`]) ID.
#[derive(Clone, Copy, Debug, Default, Eq, Hash, PartialEq)]
pub struct AudioLevelObserverId(u64);

/// Storage for a [`sys::AudioSourceOnAudioLevelChangeCallback`].
type ObserverStorage =
    Arc<RwLock<HashMap<AudioLevelObserverId, AudioSourceAudioLevelHandler>>>;

/// [`sys::AudioSourceOnAudioLevelChangeCallback`] implementation which
/// broadcasts all audio level updates to all the underlying
/// [`sys::AudioSourceOnAudioLevelChangeCallback`]s.
struct BroadcasterObserver(ObserverStorage);

impl BroadcasterObserver {
    /// Creates a new [`BroadcasterObserver`] with the provided
    /// [`ObserverStorage`] as a sink for audio level broadcasts.
    pub const fn new(observers: ObserverStorage) -> Self {
        Self(observers)
    }
}

impl sys::AudioSourceOnAudioLevelChangeCallback for BroadcasterObserver {
    /// Propagates audio level change to all the underlying
    /// [`sys::AudioSourceOnAudioLevelChangeCallback`]s.
    fn on_audio_level_change(&self, volume: f32) {
        let observers = self.0.read().unwrap();

        observers.values().for_each(|observer| {
            observer.on_audio_level_change(volume);
        });
    }
}

/// [`sys::AudioSourceInterface`] wrapper.
pub struct AudioSource {
    /// Storage for the all the [`sys::AudioSourceOnAudioLevelChangeCallback`]
    /// related to this [`AudioSourceInterface`].
    ///
    /// This [`ObserverStorage`] is shared with the [`BroadcasterObserver`] and
    /// needed for a [`sys::AudioSourceOnAudioLevelChangeCallback`] disposing
    /// without calling the C++ side.
    observers: ObserverStorage,

    /// Last ID used for the [`AudioLevelObserverId`].
    last_observer_id: Mutex<AudioLevelObserverId>,

    /// [`AudioDeviceId`] of the device this [`AudioSource`] is related to.
    pub device_id: AudioDeviceId,

    /// Underlying FFI wrapper for the `LocalAudioSource`.
    src: Arc<sys::AudioSourceInterface>,
}

impl AudioSource {
    /// Creates a new [`AudioSource`] with the provided parameters.
    #[must_use]
    pub fn new(
        device_id: AudioDeviceId,
        src: Arc<sys::AudioSourceInterface>,
    ) -> Self {
        Self {
            device_id,
            observers: Arc::default(),
            last_observer_id: Mutex::default(),
            src,
        }
    }

    /// Subscribes the provided [`sys::AudioSourceOnAudioLevelChangeCallback`]
    /// to audio level updates.
    ///
    /// This method will initialize new [`BroadcasterObserver`] if it wasn't
    /// initialized before.
    ///
    /// Returns [`AudioLevelObserverId`] which can be used to unsubscribe the
    /// provided here [`sys::AudioSourceOnAudioLevelChangeCallback`].
    ///
    /// # Panics
    ///
    /// On [`Mutex`] poisoning.
    fn subscribe_on_audio_level(
        &self,
        cb: AudioSourceAudioLevelHandler,
    ) -> AudioLevelObserverId {
        let mut observers = self.observers.write().unwrap();

        if observers.is_empty() {
            self.src.subscribe(Box::new(BroadcasterObserver::new(Arc::clone(
                &self.observers,
            ))));
        }

        let observer_id = {
            let mut last_observer_id = self.last_observer_id.lock().unwrap();
            let next_id = AudioLevelObserverId(last_observer_id.0 + 1);
            *last_observer_id = next_id;
            next_id
        };
        observers.insert(observer_id, cb);

        observer_id
    }

    /// Unsubscribes the current [`sys::AudioSourceOnAudioLevelChangeCallback`]
    /// from audio level updates.
    ///
    /// After unsubscribing this callback will be disposed.
    ///
    /// If [`AudioSourceInterface`] detects that this was the last callback, it
    /// will stop any audio level calculations to save system resources.
    ///
    /// # Panics
    ///
    /// On [`Mutex`] poisoning.
    fn unsubscribe_audio_level(&self, id: AudioLevelObserverId) {
        let mut observers = self.observers.write().unwrap();

        observers.remove(&id);
        if observers.is_empty() {
            self.src.unsubscribe();
        }
    }
}

/// [`sys::VideoTrackSourceInterface`] wrapper.
pub struct VideoSource {
    /// Underlying [`sys::VideoTrackSourceInterface`].
    inner: sys::VideoTrackSourceInterface,

    /// ID of an video input device that provides data to this [`VideoSource`].
    pub device_id: VideoDeviceId,
}

impl VideoSource {
    /// Creates a new [`VideoTrackSourceInterface`] from the video input device
    /// with the specified constraints.
    fn new_device_source(
        worker_thread: &mut sys::Thread,
        signaling_thread: &mut sys::Thread,
        caps: &api::VideoConstraints,
        device_index: u32,
        device_id: VideoDeviceId,
    ) -> anyhow::Result<Self> {
        let inner = if api::is_fake_media() {
            sys::VideoTrackSourceInterface::create_fake(
                worker_thread,
                signaling_thread,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
            )
        } else {
            sys::VideoTrackSourceInterface::create_proxy_from_device(
                worker_thread,
                signaling_thread,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
                device_index,
            )
        }
        .with_context(|| {
            format!("Failed to acquire device with ID `{device_id}`")
        })?;

        Ok(Self { inner, device_id })
    }

    /// Starts screen capturing and creates a new [`VideoTrackSourceInterface`]
    /// with the specified constraints.
    fn new_display_source(
        worker_thread: &mut sys::Thread,
        signaling_thread: &mut sys::Thread,
        caps: &api::VideoConstraints,
        device_id: VideoDeviceId,
    ) -> anyhow::Result<Self> {
        let inner = if api::is_fake_media() {
            sys::VideoTrackSourceInterface::create_fake(
                worker_thread,
                signaling_thread,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
            )?
        } else {
            sys::VideoTrackSourceInterface::create_proxy_from_display(
                worker_thread,
                signaling_thread,
                device_id.0.parse::<i64>()?,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
            )?
        };
        Ok(Self { inner, device_id })
    }
}

/// Wrapper around [`TrackObserverInterface`] implementing
/// [`sys::TrackEventCallback`].
struct TrackEventHandler(StreamSink<api::TrackEvent>);

impl TrackEventHandler {
    /// Creates a new [`TrackEventHandler`] with the provided [`StreamSink`].
    ///
    /// Sends an [`api::TrackEvent::TrackCreated`] to the provided
    /// [`StreamSink`].
    pub fn new(cb: StreamSink<api::TrackEvent>) -> Self {
        _ = cb.add(api::TrackEvent::TrackCreated);
        Self(cb)
    }
}

impl sys::TrackEventCallback for TrackEventHandler {
    fn on_ended(&mut self) {
        _ = self.0.add(api::TrackEvent::Ended);
    }
}

/// Wrapper around a [`StreamSink`] which emits [`AudioLevelUpdated`] events to
/// the Flutter side.
///
/// This handler also will multiply volume by `1000` and cast it to [`u32`], for
/// more convenient usage.
///
/// [`AudioLevelUpdated`]: api::TrackEvent::AudioLevelUpdated
struct AudioSourceAudioLevelHandler(StreamSink<api::TrackEvent>);

impl AudioSourceAudioLevelHandler {
    #[expect( // intentional
        clippy::cast_possible_truncation,
        clippy::cast_sign_loss,
        reason = "size fits and non-negative"
    )]
    fn on_audio_level_change(&self, level: f32) {
        _ = self.0.add(api::TrackEvent::AudioLevelUpdated(cmp::min(
            (level * 1000.0).round() as u32,
            100,
        )));
    }
}
