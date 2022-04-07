use std::{
    collections::{HashMap, HashSet},
    sync::Arc,
};

use anyhow::bail;
use dashmap::mapref::one::RefMut;
use derive_more::{AsRef, Display, From};
use flutter_rust_bridge::StreamSink;
use libwebrtc_sys as sys;
use sys::TrackEventObserver;

use crate::{
    api, api::TrackEvent, next_id, PeerConnectionId, VideoSink, VideoSinkId,
    Webrtc,
};

impl Webrtc {
    /// Creates a new [`VideoTrack`]s and/or [`AudioTrack`]s according to the
    /// provided accepted [`api::MediaStreamConstraints`].
    pub fn get_media(
        &mut self,
        constraints: api::MediaStreamConstraints,
    ) -> anyhow::Result<Vec<api::MediaStreamTrack>> {
        let mut result = Vec::new();

        if let Some(video) = constraints.video {
            let source = self.get_or_create_video_source(&video)?;
            let track = self.create_video_track(source)?;
            result.push(api::MediaStreamTrack::from(&*track));
        }

        if let Some(audio) = constraints.audio {
            let source = self.get_or_create_audio_source(&audio)?;
            let track = self.create_audio_track(source)?;
            result.push(api::MediaStreamTrack::from(&*track));
        }

        Ok(result)
    }

    /// Disposes a [`VideoTrack`] or [`AudioTrack`] by the provided `track_id`.
    pub fn dispose_track(&mut self, track_id: u64) {
        let senders = if let Some((_, track)) =
            self.video_tracks.remove(&VideoTrackId::from(track_id))
        {
            if let MediaTrackSource::Local(src) = track.source {
                if Arc::strong_count(&src) == 2 {
                    self.video_sources.remove(&src.device_id);
                };
            };
            track.senders
        } else if let Some((_, track)) =
            self.audio_tracks.remove(&AudioTrackId::from(track_id))
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
        };

        for (id, senders) in senders {
            for transceiver in senders {
                if let Err(e) =
                    self.sender_replace_track(id.into(), transceiver, None)
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
    ) -> anyhow::Result<RefMut<'_, VideoTrackId, VideoTrack>> {
        let track = if source.is_display {
            // TODO: Support screens enumeration.
            VideoTrack::create_local(
                &self.peer_connection_factory,
                source,
                VideoLabel::from("screen:0"),
            )?
        } else {
            let device_index = if let Some(index) =
                self.get_index_of_video_device(&source.device_id)?
            {
                index
            } else {
                bail!(
                    "Cannot find video device with the specified ID `{}`",
                    &source.device_id,
                );
            };

            VideoTrack::create_local(
                &self.peer_connection_factory,
                source,
                VideoLabel(self.video_device_info.device_name(device_index)?.0),
            )?
        };

        let track = self.video_tracks.entry(track.id).or_insert(track);

        Ok(track)
    }

    /// Creates a new [`VideoSource`] based on the given [`VideoConstraints`].
    fn get_or_create_video_source(
        &mut self,
        caps: &api::VideoConstraints,
    ) -> anyhow::Result<Arc<VideoSource>> {
        let (index, device_id) = if caps.is_display {
            // TODO: Support screens enumeration.
            (0, VideoDeviceId("screen:0".into()))
        } else if let Some(device_id) = caps.device_id.clone() {
            let device_id = VideoDeviceId(device_id);
            if let Some(index) = self.get_index_of_video_device(&device_id)? {
                (index, device_id)
            } else {
                bail!(
                    "Cannot find video device with the specified ID \
                     `{device_id}`",
                );
            }
        } else {
            // No device ID is provided so just pick the first available
            // device
            if self.video_device_info.number_of_devices() < 1 {
                bail!("Cannot find any available video input device");
            }

            let device_id =
                VideoDeviceId(self.video_device_info.device_name(0)?.1);
            (0, device_id)
        };

        if let Some(src) = self.video_sources.get(&device_id) {
            return Ok(Arc::clone(src));
        }

        let source = if caps.is_display {
            VideoSource::new_display_source(
                &mut self.worker_thread,
                &mut self.signaling_thread,
                caps,
                device_id,
            )?
        } else {
            VideoSource::new_device_source(
                &mut self.worker_thread,
                &mut self.signaling_thread,
                caps,
                index,
                device_id,
            )?
        };
        let source = self
            .video_sources
            .entry(source.device_id.clone())
            .or_insert_with(|| Arc::new(source));

        Ok(Arc::clone(source))
    }

    /// Creates a new [`AudioTrack`] from the given
    /// [`sys::AudioSourceInterface`].
    fn create_audio_track(
        &mut self,
        source: Arc<sys::AudioSourceInterface>,
    ) -> anyhow::Result<RefMut<'_, AudioTrackId, AudioTrack>> {
        // PANIC: If there is a `sys::AudioSourceInterface` then we are sure
        //        that `current_device_id` is set in the `AudioDeviceModule`.
        let device_id =
            self.audio_device_module.current_device_id.clone().unwrap();
        let device_index = if let Some(index) =
            self.get_index_of_audio_recording_device(&device_id)?
        {
            index
        } else {
            bail!(
                "Cannot find video device with the specified ID `{device_id}`",
            );
        };

        let track = AudioTrack::new(
            &self.peer_connection_factory,
            source,
            AudioLabel(
                #[allow(clippy::cast_possible_wrap)]
                self.audio_device_module
                    .inner
                    .recording_device_name(device_index as i16)?
                    .0,
            ),
        )?;

        let track = self.audio_tracks.entry(track.id).or_insert(track);

        Ok(track)
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
                if self.audio_device_module.inner.recording_devices()? < 1 {
                    bail!("Cannot find any available audio input device");
                }

                AudioDeviceId(
                    self.audio_device_module.inner.recording_device_name(0)?.1,
                )
            } else {
                // PANIC: If there is a `sys::AudioSourceInterface` then we are
                //        sure that `current_device_id` is set in the
                //        `AudioDeviceModule`.
                self.audio_device_module.current_device_id.clone().unwrap()
            }
        };

        let device_index = if let Some(index) =
            self.get_index_of_audio_recording_device(&device_id)?
        {
            index
        } else {
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

    /// Changes the [enabled][1] property of the media track by its ID.
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_track_enabled(
        &self,
        id: u64,
        enabled: bool,
    ) -> anyhow::Result<()> {
        if let Some(track) = self.video_tracks.get(&VideoTrackId(id)) {
            track.inner.set_enabled(enabled);
        } else if let Some(track) = self.audio_tracks.get(&AudioTrackId(id)) {
            track.set_enabled(enabled);
        } else {
            bail!("Cannot find track with `{id}` ID");
        }

        Ok(())
    }

    /// Clones the specified [`api::MediaStreamTrack`].
    pub fn clone_track(
        &mut self,
        id: u64,
    ) -> anyhow::Result<api::MediaStreamTrack> {
        if self.video_tracks.contains_key(&VideoTrackId(id)) {
            let source =
                match &self.video_tracks.get(&VideoTrackId(id)).unwrap().source
                {
                    MediaTrackSource::Local(source) => {
                        MediaTrackSource::Local(Arc::clone(source))
                    }
                    MediaTrackSource::Remote { mid, peer_id } => {
                        MediaTrackSource::Remote {
                            mid: mid.to_string(),
                            peer_id: *peer_id,
                        }
                    }
                };

            match source {
                MediaTrackSource::Local(source) => {
                    Ok(api::MediaStreamTrack::from(
                        self.create_video_track(source).unwrap().value(),
                    ))
                }
                MediaTrackSource::Remote { mid, peer_id } => {
                    let peer = self.peer_connections.get(&peer_id).unwrap();

                    let mut transceivers = peer.get_transceivers();

                    transceivers.retain(|transceiver| {
                        transceiver.mid().unwrap() == mid
                    });

                    if transceivers.is_empty() {
                        bail!(
                            "No `transceiver` has been found with mid `{mid}`",
                        );
                    }
                    let track = VideoTrack::wrap_remote(
                        transceivers.get(0).unwrap(),
                        peer_id,
                    );

                    Ok(api::MediaStreamTrack::from(&track))
                }
            }
        } else if self.audio_tracks.contains_key(&AudioTrackId(id)) {
            let source =
                match &self.audio_tracks.get(&AudioTrackId(id)).unwrap().source
                {
                    MediaTrackSource::Local(source) => {
                        MediaTrackSource::Local(Arc::clone(source))
                    }
                    MediaTrackSource::Remote { mid, peer_id } => {
                        MediaTrackSource::Remote {
                            mid: mid.to_string(),
                            peer_id: *peer_id,
                        }
                    }
                };

            match source {
                MediaTrackSource::Local(source) => {
                    Ok(api::MediaStreamTrack::from(
                        self.create_audio_track(source).unwrap().value(),
                    ))
                }
                MediaTrackSource::Remote { mid, peer_id } => {
                    let peer = self.peer_connections.get(&peer_id).unwrap();

                    let mut transceivers = peer.get_transceivers();

                    transceivers.retain(|transceiver| {
                        transceiver.mid().unwrap() == mid
                    });

                    if transceivers.is_empty() {
                        bail!(
                            "No `transceiver` has been found with mid `{mid}`",
                        );
                    }
                    let track = VideoTrack::wrap_remote(
                        transceivers.get(0).unwrap(),
                        peer_id,
                    );

                    Ok(api::MediaStreamTrack::from(&track))
                }
            }
        } else {
            bail!("Cannot find track with ID `{id}`")
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
        track_id: u64,
        cb: StreamSink<TrackEvent>,
    ) -> anyhow::Result<()> {
        let mut obs = TrackEventObserver::new(Box::new(TrackEventHandler(cb)));
        if let Some(mut track) =
            self.video_tracks.get_mut(&VideoTrackId::from(track_id))
        {
            obs.set_video_track(&track.inner);
            track.inner.register_observer(obs);
        } else if let Some(mut track) =
            self.audio_tracks.get_mut(&AudioTrackId::from(track_id))
        {
            obs.set_audio_track(&track.inner);
            track.inner.register_observer(obs);
        } else {
            bail!("Cannot find track with ID `{track_id}`")
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
pub struct AudioDeviceId(String);

/// ID of a [`VideoTrack`].
#[derive(Clone, Copy, Debug, Display, From, Eq, Hash, PartialEq)]
pub struct VideoTrackId(u64);

/// ID of an [`AudioTrack`].
#[derive(Clone, Copy, Debug, Display, From, Eq, Hash, PartialEq)]
pub struct AudioTrackId(u64);

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

/// [`sys::AudioDeviceModule`] wrapper tracking the currently used audio input
/// device.
pub struct AudioDeviceModule {
    /// [`sys::AudioDeviceModule`] backing this [`AudioDeviceModule`].
    pub(crate) inner: sys::AudioDeviceModule,

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

        Ok(Self {
            inner,
            current_device_id: None,
        })
    }

    /// Changes the recording device for this [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::set_recording_device()`] fails.
    pub fn set_recording_device(
        &mut self,
        id: AudioDeviceId,
        index: u16,
    ) -> anyhow::Result<()> {
        self.inner.set_recording_device(index)?;
        self.current_device_id.replace(id);

        Ok(())
    }

    /// Changes the playout device for this [`AudioDeviceModule`].
    ///
    /// # Errors
    ///
    /// If [`sys::AudioDeviceModule::set_playout_device()`] fails.
    pub fn set_playout_device(&self, index: u16) -> anyhow::Result<()> {
        self.inner.set_playout_device(index)?;

        Ok(())
    }
}

/// Possible kinds of media track's source.
enum MediaTrackSource<T> {
    Local(Arc<T>),
    Remote {
        mid: String,
        peer_id: PeerConnectionId,
    },
}

/// Representation of a [`sys::VideoTrackInterface`].
#[derive(AsRef)]
pub struct VideoTrack {
    /// ID of this [`VideoTrack`].
    id: VideoTrackId,

    /// Underlying [`sys::VideoTrackInterface`].
    #[as_ref]
    inner: sys::VideoTrackInterface,

    /// [`VideoSource`] that is used by this [`VideoTrack`].
    source: MediaTrackSource<VideoSource>,

    /// [`api::TrackKind::kVideo`].
    kind: api::MediaType,

    /// [`VideoLabel`] identifying the track source, as in "HD Webcam Analog
    /// Stereo".
    label: VideoLabel,

    /// List of the [`VideoSink`]s attached to this [`VideoTrack`].
    sinks: Vec<VideoSinkId>,

    /// Peers and transceivers sending this [`VideoTrack`].
    senders: HashMap<PeerConnectionId, HashSet<u32>>,
}

impl VideoTrack {
    /// Creates a new [`VideoTrack`].
    fn create_local(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Arc<VideoSource>,
        label: VideoLabel,
    ) -> anyhow::Result<Self> {
        let id = VideoTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_video_track(id.to_string(), &src.inner)?,
            source: MediaTrackSource::Local(src),
            kind: api::MediaType::Video,
            label,
            sinks: Vec::new(),
            senders: HashMap::new(),
        })
    }

    /// Wraps the track of the `transceiver.receiver.track()` into a
    /// [`VideoTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer_id: PeerConnectionId,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        Self {
            id: VideoTrackId(next_id()),
            inner: track.try_into().unwrap(),
            // Safe to unwrap since transceiver is guaranteed to be negotiated
            // at this point.
            source: MediaTrackSource::Remote {
                mid: transceiver.mid().unwrap(),
                peer_id,
            },
            kind: api::MediaType::Video,
            label: VideoLabel::from("remote"),
            sinks: Vec::new(),
            senders: HashMap::new(),
        }
    }

    /// Returns the [`VideoTrackId`] of this [`VideoTrack`].
    #[must_use]
    pub fn id(&self) -> VideoTrackId {
        self.id
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

    /// Returns peers and transceivers sending this [`VideoTrack`].
    pub fn senders(&mut self) -> &mut HashMap<PeerConnectionId, HashSet<u32>> {
        &mut self.senders
    }
}

impl From<&VideoTrack> for api::MediaStreamTrack {
    fn from(track: &VideoTrack) -> Self {
        Self {
            id: track.id.0,
            device_id: track.label.0.clone(),
            kind: track.kind,
            enabled: true,
        }
    }
}

/// Representation of a [`sys::AudioSourceInterface`].
#[derive(AsRef)]
pub struct AudioTrack {
    /// ID of this [`AudioTrack`].
    id: AudioTrackId,

    /// Underlying [`sys::AudioTrackInterface`].
    #[as_ref]
    inner: sys::AudioTrackInterface,

    /// [`sys::AudioSourceInterface`] that is used by this [`AudioTrack`].
    source: MediaTrackSource<sys::AudioSourceInterface>,

    /// [`api::TrackKind::kAudio`].
    kind: api::MediaType,

    /// [`AudioLabel`] identifying the track source, as in "internal
    /// microphone".
    label: AudioLabel,

    /// Peers and transceivers sending this [`VideoTrack`].
    senders: HashMap<PeerConnectionId, HashSet<u32>>,
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
        label: AudioLabel,
    ) -> anyhow::Result<Self> {
        let id = AudioTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_audio_track(id.to_string(), &src)?,
            source: MediaTrackSource::Local(src),
            kind: api::MediaType::Audio,
            label,
            senders: HashMap::new(),
        })
    }

    /// Wraps the track of the `transceiver.receiver.track()` into an
    /// [`AudioTrack`].
    pub(crate) fn wrap_remote(
        transceiver: &sys::RtpTransceiverInterface,
        peer_id: PeerConnectionId,
    ) -> Self {
        let receiver = transceiver.receiver();
        let track = receiver.track();
        Self {
            id: AudioTrackId(next_id()),
            inner: track.try_into().unwrap(),
            // Safe to unwrap since transceiver is guaranteed to be negotiated
            // at this point.
            source: MediaTrackSource::Remote {
                mid: transceiver.mid().unwrap(),
                peer_id,
            },
            kind: api::MediaType::Audio,
            label: AudioLabel::from("remote"),
            senders: HashMap::new(),
        }
    }

    /// Returns the [`AudioTrackId`] of this [`AudioTrack`].
    #[must_use]
    pub fn id(&self) -> AudioTrackId {
        self.id
    }

    /// Changes the [enabled][1] property of the underlying
    /// [`sys::AudioTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        self.inner.set_enabled(enabled);
    }

    /// Returns peers and transceivers sending this [`VideoTrack`].
    pub fn senders(&mut self) -> &mut HashMap<PeerConnectionId, HashSet<u32>> {
        &mut self.senders
    }
}

impl From<&AudioTrack> for api::MediaStreamTrack {
    fn from(track: &AudioTrack) -> Self {
        Self {
            id: track.id.0,
            device_id: track.label.0.clone(),
            kind: track.kind,
            enabled: true,
        }
    }
}

/// [`sys::VideoTrackSourceInterface`] wrapper.
pub struct VideoSource {
    /// Underlying [`sys::VideoTrackSourceInterface`].
    inner: sys::VideoTrackSourceInterface,

    /// ID of an video input device that provides data to this [`VideoSource`].
    device_id: VideoDeviceId,

    /// Indicates whether this [`VideoSource`] is backed by screen capturing.
    is_display: bool,
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
        Ok(Self {
            inner: sys::VideoTrackSourceInterface::create_proxy_from_device(
                worker_thread,
                signaling_thread,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
                device_index,
            )?,
            device_id,
            is_display: false,
        })
    }

    /// Starts screen capturing and creates a new [`VideoTrackSourceInterface`]
    /// with the specified constraints.
    fn new_display_source(
        worker_thread: &mut sys::Thread,
        signaling_thread: &mut sys::Thread,
        caps: &api::VideoConstraints,
        device_id: VideoDeviceId,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            inner: sys::VideoTrackSourceInterface::create_proxy_from_display(
                worker_thread,
                signaling_thread,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
            )?,
            device_id,
            is_display: true,
        })
    }
}

/// Wrapper around [`TrackObserverInterface`] implementing
/// [`sys::TrackEventCallback`].
struct TrackEventHandler(StreamSink<TrackEvent>);

impl sys::TrackEventCallback for TrackEventHandler {
    fn on_ended(&mut self) {
        self.0.add(TrackEvent::Ended);
    }
}
