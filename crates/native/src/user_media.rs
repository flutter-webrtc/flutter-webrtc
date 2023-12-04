use std::{
    collections::{HashMap, HashSet},
    hash::Hash,
    sync::{Arc, RwLock, Weak},
};

use anyhow::{anyhow, bail, Context};
use derive_more::{AsRef, Display, From, Into};
use libwebrtc_sys::{self as sys, OnFrameCallback, TrackEventObserver};
// TODO: Use `std::sync::OnceLock` instead, once it support `.wait()` API.
use once_cell::sync::OnceCell;
use xxhash::xxh3::xxh3_64;

use crate::{
    api, devices, next_id,
    pc::{PeerConnectionId, RtpTransceiver},
    stream_sink::StreamSink,
    PeerConnection, VideoSink, VideoSinkId, Webrtc,
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
                    };
                    return Err(err);
                }
                tracks.push(track?);
            }

            if let Some(audio) = constraints.audio {
                let src =
                    self.get_or_create_audio_source(&audio).map_err(|err| {
                        api::GetMediaError::Audio(err.to_string())
                    })?;
                let track = self
                    .create_audio_track(src)
                    .map_err(|err| api::GetMediaError::Audio(err.to_string()));
                if let Err(err) = track {
                    if Arc::get_mut(self.audio_source.as_mut().unwrap())
                        .is_some()
                    {
                        self.audio_source.take();
                    }
                    return Err(err);
                }
                tracks.push(track?);
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
    ) {
        #[allow(clippy::mutable_key_type)] // false positive
        let senders = match kind {
            api::MediaType::Audio => {
                if let Some((_, track)) = self
                    .audio_tracks
                    .remove(&(AudioTrackId::from(track_id), track_origin))
                {
                    if let MediaTrackSource::Local(src) = track.source {
                        if Arc::strong_count(&src) == 2 {
                            self.audio_source.take();
                            // TODO: We should make `AudioDeviceModule` to stop
                            //       recording.
                        };
                    }
                    track.senders
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
                        };
                    }
                    track.senders.clone()
                } else {
                    return;
                }
            }
        };

        for (peer, senders) in senders {
            for transceiver in senders {
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
        &mut self,
        source: Arc<VideoSource>,
    ) -> anyhow::Result<api::MediaStreamTrack> {
        let track =
            VideoTrack::create_local(&self.peer_connection_factory, source)?;

        let api_track = api::MediaStreamTrack::from(&track);

        self.video_tracks
            .insert((track.id.clone(), TrackOrigin::Local), track);

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
        &mut self,
        source: Arc<sys::AudioSourceInterface>,
    ) -> anyhow::Result<api::MediaStreamTrack> {
        // PANIC: If there is a `sys::AudioSourceInterface` then we are sure
        //        that `current_device_id` is set in the `AudioDeviceModule`.
        let device_id =
            self.audio_device_module.current_device_id.clone().unwrap();

        let track = AudioTrack::new(
            &self.peer_connection_factory,
            source,
            device_id,
            TrackOrigin::Local,
        )?;

        let api_track = api::MediaStreamTrack::from(&track);

        self.audio_tracks
            .insert((track.id.clone(), TrackOrigin::Local), track);

        Ok(api_track)
    }

    /// Creates a new [`sys::AudioSourceInterface`] based on the given
    /// [`AudioConstraints`].
    fn get_or_create_audio_source(
        &mut self,
        caps: &api::AudioConstraints,
    ) -> anyhow::Result<Arc<sys::AudioSourceInterface>> {
        let device_id = if let Some(device_id) = caps.device_id.clone() {
            AudioDeviceId(device_id)
        } else {
            // No device ID is provided so just pick the currently used.
            if self.audio_device_module.current_device_id.is_none() {
                // `AudioDeviceModule` is not capturing anything at the moment,
                // so we will use first available device (with `0` index).
                if self.audio_device_module.recording_devices() < 1 {
                    bail!("Cannot find any available audio input device");
                }

                AudioDeviceId(
                    self.audio_device_module.recording_device_name(0)?.1,
                )
            } else {
                // PANIC: If there is a `sys::AudioSourceInterface` then we are
                //        sure that `current_device_id` is set in the
                //        `AudioDeviceModule`.
                self.audio_device_module.current_device_id.clone().unwrap()
            }
        };

        let Some(device_index) =
            self.get_index_of_audio_recording_device(&device_id)?
        else {
            bail!(
                "Cannot find audio device with the specified ID `{device_id}`",
            );
        };

        if Some(&device_id)
            != self.audio_device_module.current_device_id.as_ref()
        {
            self.audio_device_module
                .set_recording_device(device_id, device_index)?;
        }

        let src = if let Some(src) = self.audio_source.as_ref() {
            Arc::clone(src)
        } else {
            let src =
                Arc::new(self.peer_connection_factory.create_audio_source()?);
            self.audio_source.replace(Arc::clone(&src));

            src
        };

        Ok(src)
    }

    /// Returns the [readyState][0] property of the media track by its ID and
    /// media type.
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    pub fn track_state(
        &self,
        id: String,
        track_origin: TrackOrigin,
        kind: api::MediaType,
    ) -> anyhow::Result<api::TrackState> {
        Ok(match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                self.audio_tracks
                    .get(&(id.clone(), track_origin))
                    .ok_or_else(|| {
                        anyhow!("Cannot find audio track with ID `{id}`")
                    })?
                    .state()
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                self.video_tracks
                    .get(&(id.clone(), track_origin))
                    .ok_or_else(|| {
                        anyhow!("Cannot find video track with ID `{id}`")
                    })?
                    .state()
            }
        })
    }

    /// Returns the [width] property of the media track by its ID and origin.
    ///
    /// Blocks until the [width] is initialized.
    ///
    /// [width]: https://w3.org/TR/mediacapture-streams#dfn-width
    pub fn track_width(
        &self,
        id: String,
        track_origin: TrackOrigin,
    ) -> anyhow::Result<i32> {
        let id = VideoTrackId::from(id);

        Ok(*self
            .video_tracks
            .get(&(id.clone(), track_origin))
            .ok_or_else(|| anyhow!("Cannot find video track with ID `{id}`"))?
            .width
            .wait()
            .read()
            .unwrap())
    }

    /// Returns the [height] property of the media track by its ID and origin.
    ///
    /// Blocks until the [height] is initialized.
    ///
    /// [height]: https://w3.org/TR/mediacapture-streams#dfn-height
    pub fn track_height(
        &self,
        id: String,
        track_origin: TrackOrigin,
    ) -> anyhow::Result<i32> {
        let id = VideoTrackId::from(id);

        Ok(*self
            .video_tracks
            .get(&(id.clone(), track_origin))
            .ok_or_else(|| anyhow!("Cannot find video track with ID `{id}`"))?
            .height
            .wait()
            .read()
            .unwrap())
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
    ) -> anyhow::Result<()> {
        match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                let track = self
                    .audio_tracks
                    .get(&(id.clone(), track_origin))
                    .ok_or_else(|| {
                        anyhow!("Cannot find track with ID `{id}`")
                    })?;

                track.set_enabled(enabled);
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                let track = self
                    .video_tracks
                    .get(&(id.clone(), track_origin))
                    .ok_or_else(|| {
                        anyhow!("Cannot find track with ID `{id}`")
                    })?;

                track.set_enabled(enabled);
            }
        }

        Ok(())
    }

    /// Clones the specified [`api::MediaStreamTrack`].
    #[allow(clippy::too_many_lines)]
    pub fn clone_track(
        &mut self,
        id: String,
        track_origin: TrackOrigin,
        kind: api::MediaType,
    ) -> anyhow::Result<api::MediaStreamTrack> {
        match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                let source = self
                    .audio_tracks
                    .get(&(id.clone(), track_origin))
                    .map(|track| match &track.source {
                        MediaTrackSource::Local(source) => {
                            MediaTrackSource::Local(Arc::clone(source))
                        }
                        MediaTrackSource::Remote { mid, peer } => {
                            MediaTrackSource::Remote {
                                mid: mid.to_string(),
                                peer: peer.clone(),
                            }
                        }
                    })
                    .ok_or_else(|| {
                        anyhow!("Cannot find track with ID `{id}`")
                    })?;

                match source {
                    MediaTrackSource::Local(source) => {
                        Ok(self.create_audio_track(source)?)
                    }
                    MediaTrackSource::Remote { mid, peer } => {
                        let peer = peer.upgrade().ok_or_else(|| {
                            anyhow!("`PeerConnection` has been disposed")
                        })?;
                        let mut transceivers = peer.get_transceivers();

                        transceivers.retain(|transceiver| {
                            transceiver.mid().unwrap() == mid
                        });

                        if transceivers.is_empty() {
                            bail!(
                                "No `transceiver` has been found with mid \
                                 `{mid}`",
                            );
                        }

                        let track = AudioTrack::wrap_remote(
                            transceivers.get(0).unwrap(),
                            &peer,
                        );

                        Ok(api::MediaStreamTrack::from(&track))
                    }
                }
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                let source = self
                    .video_tracks
                    .get(&(id.clone(), track_origin))
                    .map(|track| match &track.source {
                        MediaTrackSource::Local(source) => {
                            MediaTrackSource::Local(Arc::clone(source))
                        }
                        MediaTrackSource::Remote { mid, peer } => {
                            MediaTrackSource::Remote {
                                mid: mid.to_string(),
                                peer: peer.clone(),
                            }
                        }
                    })
                    .ok_or_else(|| {
                        anyhow!("Cannot find track with ID `{id}`")
                    })?;

                match source {
                    MediaTrackSource::Local(source) => {
                        Ok(self.create_video_track(source)?)
                    }
                    MediaTrackSource::Remote { mid, peer } => {
                        let peer = peer.upgrade().ok_or_else(|| {
                            anyhow!("`PeerConnection` has been disposed")
                        })?;
                        let mut transceivers = peer.get_transceivers();
                        transceivers.retain(|transceiver| {
                            transceiver.mid().unwrap() == mid
                        });

                        if transceivers.is_empty() {
                            bail!(
                                "No `transceiver` has been found with mid \
                                 `{mid}`",
                            );
                        }

                        let track = VideoTrack::wrap_remote(
                            transceivers.get(0).unwrap(),
                            &peer,
                        );

                        Ok(api::MediaStreamTrack::from(&track))
                    }
                }
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
        cb: StreamSink<api::TrackEvent>,
    ) -> anyhow::Result<()> {
        let mut obs = TrackEventObserver::new(Box::new(TrackEventHandler(cb)));
        match kind {
            api::MediaType::Audio => {
                let id = AudioTrackId::from(id);
                let mut track = self
                    .audio_tracks
                    .get_mut(&(id.clone(), track_origin))
                    .ok_or_else(|| {
                        anyhow!("Cannot find track with ID `{id}`")
                    })?;

                obs.set_audio_track(&track.inner);
                track.inner.register_observer(obs);
            }
            api::MediaType::Video => {
                let id = VideoTrackId::from(id);
                let mut track = self
                    .video_tracks
                    .get_mut(&(id.clone(), track_origin))
                    .ok_or_else(|| {
                        anyhow!("Cannot find track with ID `{id}`")
                    })?;

                obs.set_video_track(&track.inner);
                track.inner.register_observer(obs);
            }
        }

        Ok(())
    }
}

/// ID of a [`MediaStream`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, PartialEq)]
pub struct MediaStreamId(u64);

/// ID of an video input device that provides data to some [`VideoSource`].
#[derive(AsRef, Clone, Debug, Display, Eq, Hash, PartialEq)]
#[as_ref(forward)]
pub struct VideoDeviceId(String);

/// ID of an `AudioDevice`.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, From, Hash, PartialEq)]
#[as_ref(forward)]
#[from(forward)]
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
        Ok(VideoDeviceInfo(sys::VideoDeviceInfo::create()?))
    }

    /// Returns count of a video recording devices.
    pub fn number_of_devices(&mut self) -> u32 {
        if api::is_fake_media() {
            1
        } else {
            self.0.number_of_devices()
        }
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

    /// ID of the audio input device currently used by this
    /// [`sys::AudioDeviceModule`].
    ///
    /// [`None`] if the [`AudioDeviceModule`] was not used yet to record data
    /// from the audio input device.
    current_device_id: Option<AudioDeviceId>,
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
    ) -> anyhow::Result<Self> {
        let inner = sys::AudioDeviceModule::create_proxy(
            worker_thread,
            audio_layer,
            task_queue_factory,
        )?;
        inner.init()?;

        let mut adm = Self {
            inner,
            current_device_id: None,
        };
        if adm.recording_devices() > 0 {
            adm.set_recording_device(
                AudioDeviceId(adm.recording_device_name(0)?.1),
                0,
            )?;
        }
        Ok(adm)
    }

    /// Creates a new [`AudioDeviceModule`] according to the passed
    /// [`sys::AudioLayer`].
    ///
    /// # Errors
    ///
    /// If could not find any available recording device.
    pub fn new_fake(task_queue_factory: &mut sys::TaskQueueFactory) -> Self {
        let inner = sys::AudioDeviceModule::create_fake(task_queue_factory);
        drop(inner.init());

        Self {
            inner,
            current_device_id: None,
        }
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
        if api::is_fake_media() {
            1
        } else {
            self.inner.recording_devices()
        }
    }

    /// Changes the recording device for this [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::set_recording_device()`] call fails.
    pub fn set_recording_device(
        &mut self,
        id: AudioDeviceId,
        index: u16,
    ) -> anyhow::Result<()> {
        self.inner.set_recording_device(index)?;
        self.current_device_id.replace(id);

        if !self.inner.microphone_is_initialized() {
            self.inner.init_microphone()?;
        }

        Ok(())
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

        let volume = f64::from(min_volume)
            + (f64::from(max_volume - min_volume) * (f64::from(level) / 100.0));

        #[allow(clippy::cast_possible_truncation, clippy::cast_sign_loss)]
        self.inner.set_microphone_volume(volume as u32)
    }

    /// Indicates if the microphone is available to set volume.
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::microphone_volume_is_available()`] call
    /// fails.
    pub fn microphone_volume_is_available(&self) -> anyhow::Result<bool> {
        Ok(
            if let Ok(is_available) =
                self.inner.microphone_volume_is_available()
            {
                is_available
            } else {
                false
            },
        )
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

        #[allow(clippy::cast_possible_truncation, clippy::cast_sign_loss)]
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

    /// Sets stereo availability of this playout [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::stereo_playout_is_available()`] call fails.
    pub fn stereo_playout_is_available(
        &self,
        available: bool,
    ) -> anyhow::Result<()> {
        self.inner.stereo_playout_is_available(available)
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
enum MediaTrackSource<T> {
    Local(Arc<T>),
    Remote {
        mid: String,
        peer: Weak<PeerConnection>,
    },
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
    source: MediaTrackSource<VideoSource>,

    /// [`api::TrackKind::kVideo`].
    kind: api::MediaType,

    /// List of the [`VideoSink`]s attached to this [`VideoTrack`].
    sinks: Vec<VideoSinkId>,

    /// Peers and transceivers sending this [`VideoTrack`].
    pub senders: HashMap<Arc<PeerConnection>, HashSet<Arc<RtpTransceiver>>>,

    /// Tracks changes in video `height` and `width`.
    sink: Option<VideoSink>,

    /// Video width.
    width: Arc<OnceCell<RwLock<i32>>>,

    /// Video height.
    height: Arc<OnceCell<RwLock<i32>>>,
}

/// Tracks changes in video `height` and `width`.
struct VideoFormatSink {
    /// Video width.
    width: Arc<OnceCell<RwLock<i32>>>,

    /// Video height.
    height: Arc<OnceCell<RwLock<i32>>>,
}

impl OnFrameCallback for VideoFormatSink {
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

        let width = Arc::new(OnceCell::new());
        let height = Arc::new(OnceCell::new());
        let mut sink = VideoSink::new(
            i64::try_from(next_id()).unwrap(),
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
            width,
            height,
            sink: None,
            track_origin,
        };

        res.add_video_sink(&mut sink);
        res.sink = Some(sink);

        Ok(res)
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

        let width = Arc::new(OnceCell::new());
        width.set(RwLock::from(0)).unwrap();
        let height = Arc::new(OnceCell::new());
        height.set(RwLock::from(0)).unwrap();
        let mut sink = VideoSink::new(
            i64::try_from(next_id()).unwrap(),
            sys::VideoSinkInterface::create_forwarding(Box::new(
                VideoFormatSink {
                    width: Arc::clone(&width),
                    height: Arc::clone(&height),
                },
            )),
            VideoTrackId(track.id().clone()),
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
    source: MediaTrackSource<sys::AudioSourceInterface>,

    /// [`api::TrackKind::kAudio`].
    kind: api::MediaType,

    /// Device ID of the [`AudioTrack`]'s [`sys::AudioSourceInterface`].
    device_id: AudioDeviceId,

    /// Peers and transceivers sending this [`VideoTrack`].
    pub senders: HashMap<Arc<PeerConnection>, HashSet<Arc<RtpTransceiver>>>,
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
        src: Arc<sys::AudioSourceInterface>,
        device_id: AudioDeviceId,
        track_origin: TrackOrigin,
    ) -> anyhow::Result<Self> {
        let id = AudioTrackId(next_id().to_string());
        Ok(Self {
            id: id.clone(),
            inner: pc.create_audio_track(id.into(), &src)?,
            source: MediaTrackSource::Local(src),
            kind: api::MediaType::Audio,
            device_id,
            senders: HashMap::new(),
            track_origin,
        })
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
            device_id: AudioDeviceId::from("remote"),
            senders: HashMap::new(),
            track_origin: TrackOrigin::Remote(peer.id()),
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
}

impl From<&AudioTrack> for api::MediaStreamTrack {
    fn from(track: &AudioTrack) -> Self {
        Self {
            id: track.id.0.clone(),
            device_id: track.device_id.to_string(),
            kind: track.kind,
            enabled: true,
            peer_id: match track.track_origin {
                TrackOrigin::Local => None,
                TrackOrigin::Remote(peer_id) => Some(peer_id.into()),
            },
        }
    }
}

/// [`sys::VideoTrackSourceInterface`] wrapper.
pub struct VideoSource {
    /// Underlying [`sys::VideoTrackSourceInterface`].
    inner: sys::VideoTrackSourceInterface,

    /// ID of an video input device that provides data to this [`VideoSource`].
    device_id: VideoDeviceId,
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

impl sys::TrackEventCallback for TrackEventHandler {
    fn on_ended(&mut self) {
        self.0.add(api::TrackEvent::Ended);
    }
}
