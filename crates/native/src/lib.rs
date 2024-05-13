#![warn(clippy::pedantic)]

mod api;
#[allow(
    clippy::default_trait_access,
    clippy::let_underscore_untyped,
    clippy::ptr_as_ptr,
    clippy::semicolon_if_nothing_returned,
    clippy::too_many_lines,
    clippy::wildcard_imports,
    let_underscore_drop
)]
#[rustfmt::skip]
mod bridge_generated;
mod devices;
mod pc;
mod renderer;
mod stream_sink;
mod user_media;
mod video_sink;

use std::{
    collections::HashMap,
    sync::{
        atomic::{AtomicU64, Ordering},
        Arc,
    },
};

use dashmap::DashMap;
use libwebrtc_sys as sys;
use threadpool::ThreadPool;

use crate::{user_media::TrackOrigin, video_sink::Id as VideoSinkId};

#[doc(inline)]
pub use crate::{
    pc::{
        PeerConnection, RtpEncodingParameters, RtpParameters, RtpTransceiver,
    },
    user_media::{
        AudioDeviceId, AudioDeviceModule, AudioSource, AudioTrack,
        AudioTrackId, MediaStreamId, VideoDeviceId, VideoDeviceInfo,
        VideoSource, VideoTrack, VideoTrackId,
    },
    video_sink::VideoSink,
};

/// Counter used to generate unique IDs.
static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

/// Returns a next unique ID.
pub(crate) fn next_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

/// Global context for an application.
struct Webrtc {
    video_device_info: VideoDeviceInfo,
    video_sources: HashMap<VideoDeviceId, Arc<VideoSource>>,
    video_tracks: Arc<DashMap<(VideoTrackId, TrackOrigin), VideoTrack>>,
    audio_sources: HashMap<AudioDeviceId, Arc<AudioSource>>,
    audio_tracks: Arc<DashMap<(AudioTrackId, TrackOrigin), AudioTrack>>,
    video_sinks: HashMap<VideoSinkId, VideoSink>,
    ap: sys::AudioProcessing,

    /// `peer_connection_factory` must be dropped before [`Thread`]s.
    peer_connection_factory: sys::PeerConnectionFactoryInterface,
    task_queue_factory: sys::TaskQueueFactory,
    audio_device_module: AudioDeviceModule,
    worker_thread: sys::Thread,
    signaling_thread: sys::Thread,

    /// [`ThreadPool`] used to offload blocking or CPU-intensive tasks, so they
    /// won't block Flutter WebRTC threads.
    callback_pool: ThreadPool,
}

impl Webrtc {
    /// Creates a new [`Webrtc`] context.
    fn new() -> anyhow::Result<Self> {
        let mut task_queue_factory =
            sys::TaskQueueFactory::create_default_task_queue_factory();

        let mut worker_thread = sys::Thread::create(false)?;
        worker_thread.start()?;

        let mut signaling_thread = sys::Thread::create(false)?;
        signaling_thread.start()?;

        let ap = sys::AudioProcessing::new()?;
        let mut config = ap.config();
        config.set_gain_controller_enabled(true);
        ap.apply_config(&config);

        let audio_device_module = AudioDeviceModule::new(
            &mut worker_thread,
            sys::AudioLayer::kPlatformDefaultAudio,
            &mut task_queue_factory,
            Some(&ap),
        )?;

        let peer_connection_factory =
            sys::PeerConnectionFactoryInterface::create(
                None,
                Some(&worker_thread),
                Some(&signaling_thread),
                Some(audio_device_module.as_ref()),
                Some(&ap),
            )?;

        Ok(Self {
            task_queue_factory,
            worker_thread,
            signaling_thread,
            ap,
            audio_device_module,
            video_device_info: VideoDeviceInfo::new()?,
            peer_connection_factory,
            video_sources: HashMap::new(),
            video_tracks: Arc::new(DashMap::new()),
            audio_sources: HashMap::new(),
            audio_tracks: Arc::new(DashMap::new()),
            video_sinks: HashMap::new(),
            callback_pool: ThreadPool::new(4),
        })
    }
}
