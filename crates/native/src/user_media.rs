use std::rc::Rc;

use anyhow::bail;
use derive_more::{AsRef, Display, From};
use libwebrtc_sys as sys;

use crate::{
    api::{self, AudioConstraints, VideoConstraints},
    next_id, VideoSink, VideoSinkId, Webrtc,
};

impl Webrtc {
    /// Creates a new local [`MediaStream`] with [`VideoTrack`]s and/or
    /// [`AudioTrack`]s according to the provided accepted
    /// [`api::MediaStreamConstraints`].
    #[allow(clippy::too_many_lines, clippy::missing_panics_doc)]
    pub fn get_users_media(
        self: &mut Webrtc,
        constraints: &api::MediaStreamConstraints,
    ) -> api::MediaStream {
        let mut stream =
            MediaStream::new(&self.0.peer_connection_factory).unwrap();

        let mut result = api::MediaStream {
            stream_id: stream.id.0,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        };

        if constraints.video.required {
            let source =
                self.get_or_create_video_source(&constraints.video).unwrap();
            let track = self.create_video_track(source).unwrap();

            stream.add_video_track(track).unwrap();
            result.video_tracks.push(api::MediaStreamTrack {
                id: track.id.0,
                label: track.label.0.clone(),
                kind: track.kind,
                enabled: true,
            });
        }

        if constraints.audio.required {
            let source =
                self.get_or_create_audio_source(&constraints.audio).unwrap();
            let track = self.create_audio_track(source).unwrap();

            stream.add_audio_track(track).unwrap();
            result.audio_tracks.push(api::MediaStreamTrack {
                id: track.id.0,
                label: track.label.0.clone(),
                kind: track.kind,
                enabled: true,
            });
        };

        self.0
            .local_media_streams
            .entry(stream.id)
            .or_insert(stream);

        result
    }

    /// Disposes the [`MediaStream`] and all the contained tracks in it.
    ///
    /// # Panics
    ///
    /// Panics if tracks from the provided [`MediaStream`] are not found in the
    /// context, as it's an invariant violation.
    pub fn dispose_stream(self: &mut Webrtc, id: u64) {
        if let Some(stream) =
            self.0.local_media_streams.remove(&MediaStreamId(id))
        {
            let video_tracks = stream.video_tracks;
            let audio_tracks = stream.audio_tracks;

            for track in video_tracks {
                let src = self.0.video_tracks.remove(&track).unwrap().src;

                if Rc::strong_count(&src) == 2 {
                    self.0.video_sources.remove(&src.device_id);
                };
            }

            for track in audio_tracks {
                let src = self.0.audio_tracks.remove(&track).unwrap().src;

                if Rc::strong_count(&src) == 2 {
                    self.0.audio_source.take();
                    // TODO: We should make `AudioDeviceModule` to stop
                    //       recording.
                };
            }
        }
    }

    /// Creates a new [`VideoTrack`] from the given [`VideoSource`].
    fn create_video_track(
        &mut self,
        source: Rc<VideoSource>,
    ) -> anyhow::Result<&mut VideoTrack> {
        let device_index = if let Some(index) =
            self.get_index_of_video_device(&source.device_id)?
        {
            index
        } else {
            bail!(
                "Could not find video device with the specified ID `{}`",
                &source.device_id,
            );
        };

        let track = VideoTrack::new(
            &self.0.peer_connection_factory,
            source,
            VideoLabel(self.0.video_device_info.device_name(device_index)?.0),
        )?;

        let track = self.0.video_tracks.entry(track.id).or_insert(track);

        Ok(track)
    }

    /// Creates a new [`VideoSource`] based on the given [`VideoConstraints`].
    fn get_or_create_video_source(
        &mut self,
        caps: &VideoConstraints,
    ) -> anyhow::Result<Rc<VideoSource>> {
        let (index, device_id) = if caps.device_id.is_empty() {
            // No device ID is provided so just pick the first available device
            if self.0.video_device_info.number_of_devices() < 1 {
                bail!("Could not find any available video input device");
            }

            let device_id =
                VideoDeviceId(self.0.video_device_info.device_name(0)?.1);
            (0, device_id)
        } else {
            let device_id = VideoDeviceId(caps.device_id.clone());
            if let Some(index) = self.get_index_of_video_device(&device_id)? {
                (index, device_id)
            } else {
                bail!(
                    "Could not find video device with the specified ID `{}`",
                    device_id,
                );
            }
        };

        if let Some(src) = self.0.video_sources.get(&device_id) {
            return Ok(Rc::clone(src));
        }

        let source = Rc::new(VideoSource::new(
            &mut self.0.worker_thread,
            &mut self.0.signaling_thread,
            caps,
            index,
            device_id,
        )?);
        self.0
            .video_sources
            .insert(source.device_id.clone(), Rc::clone(&source));

        Ok(source)
    }

    /// Creates a new [`AudioTrack`] from the given
    /// [`sys::AudioSourceInterface`].
    fn create_audio_track(
        &mut self,
        source: Rc<sys::AudioSourceInterface>,
    ) -> anyhow::Result<&mut AudioTrack> {
        // PANIC: If there is a `sys::AudioSourceInterface` then we are sure
        //        that `current_device_id` is set in the `AudioDeviceModule`.
        let device_id = self
            .0
            .audio_device_module
            .current_device_id
            .clone()
            .unwrap();
        let device_index = if let Some(index) =
            self.get_index_of_audio_recording_device(&device_id)?
        {
            index
        } else {
            bail!(
                "Could not find video device with the specified ID `{}`",
                device_id,
            )
        };

        let track = AudioTrack::new(
            &self.0.peer_connection_factory,
            source,
            AudioLabel(
                #[allow(clippy::cast_possible_wrap)]
                self.0
                    .audio_device_module
                    .inner
                    .recording_device_name(device_index as i16)?
                    .0,
            ),
        )?;

        let track = self.0.audio_tracks.entry(track.id).or_insert(track);

        Ok(track)
    }

    /// Creates a new [`sys::AudioSourceInterface`] based on the given
    /// [`AudioConstraints`].
    fn get_or_create_audio_source(
        &mut self,
        caps: &AudioConstraints,
    ) -> anyhow::Result<Rc<sys::AudioSourceInterface>> {
        let device_id = if caps.device_id.is_empty() {
            // No device ID is provided so just pick the currently used.
            if self.0.audio_device_module.current_device_id.is_none() {
                // `AudioDeviceModule` is not capturing anything at the moment,
                // so we will use first available device (with `0` index).
                if self.0.audio_device_module.inner.recording_devices()? < 1 {
                    bail!("Could not find any available audio input device");
                }

                AudioDeviceId(
                    self.0
                        .audio_device_module
                        .inner
                        .recording_device_name(0)?
                        .1,
                )
            } else {
                self.0
                    .audio_device_module
                    .current_device_id
                    .clone()
                    .unwrap()
            }
        } else {
            AudioDeviceId(caps.device_id.clone())
        };

        let device_index = if let Some(index) =
            self.get_index_of_audio_recording_device(&device_id)?
        {
            index
        } else {
            bail!(
                "Could not find audio device with the specified ID `{}`",
                device_id,
            );
        };

        if Some(&device_id)
            != self.0.audio_device_module.current_device_id.as_ref()
        {
            self.0
                .audio_device_module
                .set_recording_device(device_id, device_index)?;
        }

        let src = if let Some(src) = self.0.audio_source.as_ref() {
            Rc::clone(src)
        } else {
            let src =
                Rc::new(self.0.peer_connection_factory.create_audio_source()?);
            self.0.audio_source.replace(Rc::clone(&src));

            src
        };

        Ok(src)
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
#[derive(AsRef, Clone, Debug, Default, Display, Eq, Hash, PartialEq)]
#[as_ref(forward)]
pub struct AudioDeviceId(String);

/// ID of a [`VideoTrack`].
#[derive(Clone, Copy, Debug, Display, Eq, Hash, PartialEq)]
pub struct VideoTrackId(u64);

/// ID of an [`AudioTrack`].
#[derive(Clone, Copy, Debug, Display, Eq, Hash, PartialEq)]
pub struct AudioTrackId(u64);

/// Label identifying a video track source.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, Hash, PartialEq)]
#[as_ref(forward)]
pub struct VideoLabel(String);

/// Label identifying an audio track source.
#[derive(AsRef, Clone, Debug, Default, Display, Eq, Hash, PartialEq)]
#[as_ref(forward)]
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
        audio_layer: sys::AudioLayer,
        task_queue_factory: &mut sys::TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let inner =
            sys::AudioDeviceModule::create(audio_layer, task_queue_factory)?;
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
}

/// [`sys::MediaStreamInterface`] tracking all the added [`VideoTrack`]s and
/// [`AudioTrack`]s.
pub struct MediaStream {
    /// ID of this [`MediaStream`].
    id: MediaStreamId,

    /// Underlying [`sys::MediaStreamInterface`].
    inner: sys::MediaStreamInterface,

    /// List of [`VideoTrack`] IDs contained in this [`MediaStream`].
    video_tracks: Vec<VideoTrackId>,

    /// List of [`AudioTrack`] IDs contained in this [`MediaStream`].
    audio_tracks: Vec<AudioTrackId>,
}

impl MediaStream {
    /// Creates a new [`MediaStream`].
    fn new(pc: &sys::PeerConnectionFactoryInterface) -> anyhow::Result<Self> {
        let id = MediaStreamId(next_id());
        Ok(Self {
            id,
            inner: pc.create_local_media_stream(id.to_string())?,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        })
    }

    /// Adds the provided [`VideoTrack`] to this [`MediaStream`].
    fn add_video_track(&mut self, track: &VideoTrack) -> anyhow::Result<()> {
        self.inner.add_video_track(&track.inner)?;
        self.video_tracks.push(track.id);

        Ok(())
    }

    /// Adds the provided [`AudioTrack`] to this [`MediaStream`].
    fn add_audio_track(&mut self, track: &AudioTrack) -> anyhow::Result<()> {
        self.inner.add_audio_track(&track.inner)?;
        self.audio_tracks.push(track.id);

        Ok(())
    }

    /// Returns an [`Iterator`] over all the [`VideoTrackId`]s belonging to the
    /// [`VideoTrack`]s that were added to this [`MediaStream`].
    pub fn video_tracks(&self) -> impl Iterator<Item = &'_ VideoTrackId> {
        self.video_tracks.iter()
    }
}

/// Representation of a [`sys::VideoTrackInterface`].
pub struct VideoTrack {
    /// ID of this [`VideoTrack`].
    id: VideoTrackId,

    /// Underlying [`sys::VideoTrackInterface`].
    inner: sys::VideoTrackInterface,

    /// [`VideoSource`] that is used by this [`VideoTrack`].
    src: Rc<VideoSource>,

    /// [`api::TrackKind::kVideo`].
    kind: api::TrackKind,

    /// [`VideoLabel`] identifying the track source, as in "HD Webcam Analog
    /// Stereo".
    label: VideoLabel,

    /// List of the [`VideoSink`]s attached to this [`VideoTrack`].
    sinks: Vec<VideoSinkId>,
}

impl VideoTrack {
    /// Creates a new [`VideoTrack`].
    fn new(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Rc<VideoSource>,
        label: VideoLabel,
    ) -> anyhow::Result<Self> {
        let id = VideoTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_video_track(id.to_string(), &src.inner)?,
            src,
            kind: api::TrackKind::kVideo,
            label,
            sinks: Vec::new(),
        })
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
}

/// Representation of a [`sys::AudioSourceInterface`].
pub struct AudioTrack {
    /// ID of this [`AudioTrack`].
    id: AudioTrackId,

    /// Underlying [`sys::AudioTrackInterface`].
    inner: sys::AudioTrackInterface,

    /// [`sys::AudioSourceInterface`] that is used by this [`AudioTrack`].
    src: Rc<sys::AudioSourceInterface>,

    /// [`api::TrackKind::kAudio`].
    kind: api::TrackKind,

    /// [`AudioLabel`] identifying the track source, as in "internal
    /// microphone".
    label: AudioLabel,
}

impl AudioTrack {
    /// Creates a new [`AudioTrack`].
    fn new(
        pc: &sys::PeerConnectionFactoryInterface,
        src: Rc<sys::AudioSourceInterface>,
        label: AudioLabel,
    ) -> anyhow::Result<Self> {
        let id = AudioTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_audio_track(id.to_string(), &src)?,
            src,
            kind: api::TrackKind::kAudio,
            label,
        })
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
    /// Creates a new [`VideoSource`].
    fn new(
        worker_thread: &mut sys::Thread,
        signaling_thread: &mut sys::Thread,
        caps: &api::VideoConstraints,
        device_index: u32,
        device_id: VideoDeviceId,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            inner: sys::VideoTrackSourceInterface::create_proxy(
                worker_thread,
                signaling_thread,
                caps.width,
                caps.height,
                caps.frame_rate,
                device_index,
            )?,
            device_id,
        })
    }
}
