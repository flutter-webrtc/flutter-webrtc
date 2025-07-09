use std::{
    cmp,
    collections::HashMap,
    hash::Hash,
    sync::{Arc, Mutex, RwLock, Weak},
};

use anyhow::Context as _;
use derive_more::{AsRef, with_trait::Into as _};
use libwebrtc_sys as sys;

#[cfg(doc)]
use super::Track;
use crate::{
    AudioDeviceId, PeerConnection, VideoDeviceId, api,
    frb_generated::StreamSink,
};

/// Possible kinds of media [`Track`]'s source.
pub enum MediaTrackSource<T> {
    /// Local source.
    Local(Arc<T>),

    /// Remote sources.
    Remote {
        /// [mid] of the source.
        ///
        /// [mid]: https://w3.org/TR/webrtc#dom-rtptransceiver-mid
        mid: String,

        /// [`PeerConnection`] of the source.
        peer: Weak<PeerConnection>,
    },
}

/// [`sys::AudioSourceOnAudioLevelChangeCallback`] unique (per
/// [`AudioSourceInterface`]) ID.
#[derive(Clone, Copy, Debug, Default, Eq, Hash, PartialEq)]
pub struct AudioLevelObserverId(u64);

/// [`sys::AudioSourceInterface`] wrapper.
#[derive(AsRef)]
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
    device_id: AudioDeviceId,

    /// Underlying FFI wrapper for the `LocalAudioSource`.
    #[as_ref]
    src: sys::AudioSourceInterface,

    /// [`sys::AudioProcessing`] used by this [`AudioSource`].
    ap: sys::AudioProcessing,
}

impl AudioSource {
    /// Creates a new [`AudioSource`] with the provided parameters.
    #[must_use]
    pub fn new(
        device_id: AudioDeviceId,
        src: sys::AudioSourceInterface,
        ap: sys::AudioProcessing,
    ) -> Self {
        Self {
            device_id,
            observers: Arc::default(),
            last_observer_id: Mutex::default(),
            src,
            ap,
        }
    }

    /// Returns [`AudioDeviceId`] of the device this [`AudioSource`] is
    /// related to.
    #[must_use]
    pub const fn device_id(&self) -> &AudioDeviceId {
        &self.device_id
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
    pub(super) fn subscribe_on_audio_level(
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
    pub(super) fn unsubscribe_audio_level(&self, id: AudioLevelObserverId) {
        let mut observers = self.observers.write().unwrap();

        observers.remove(&id);
        if observers.is_empty() {
            self.src.unsubscribe();
        }
    }

    /// Applies the provided [`api::AudioProcessingConstraints`] to the
    /// [`sys::AudioProcessing`] of this [`AudioSource`].
    pub(super) fn update_audio_processing(
        &self,
        new_conf: &api::AudioProcessingConstraints,
    ) {
        let mut conf = self.ap.config();
        if let Some(aec) = new_conf.echo_cancellation {
            conf.set_echo_cancellation_enabled(aec);
        }
        if let Some(hpf) = new_conf.high_pass_filter {
            conf.set_high_pass_filter_enabled(hpf);
        }
        if let Some(agc) = new_conf.auto_gain_control {
            conf.set_gain_controller_enabled(agc);
        }
        if let Some(ns) = new_conf.noise_suppression {
            conf.set_noise_suppression_enabled(ns);
        }
        if let Some(nsl) = new_conf.noise_suppression_level {
            conf.set_noise_suppression_level(nsl.into());
        }
        self.ap.apply_config(&conf);
    }

    /// [`sys::AudioProcessingConfig`] used by this [`AudioSource`].
    pub(super) fn ap_config(&self) -> sys::AudioProcessingConfig {
        self.ap.config()
    }
}

/// [`sys::VideoTrackSourceInterface`] wrapper.
#[derive(AsRef)]
pub struct VideoSource {
    /// Underlying [`sys::VideoTrackSourceInterface`].
    #[as_ref]
    inner: sys::VideoTrackSourceInterface,

    /// ID of an video input device that provides data to this [`VideoSource`].
    device_id: VideoDeviceId,
}

impl VideoSource {
    /// Returns [`VideoDeviceId`] of the device this [`VideoSource`] is
    /// related to.
    #[must_use]
    pub const fn device_id(&self) -> &VideoDeviceId {
        &self.device_id
    }

    /// Creates a new [`VideoTrackSourceInterface`] from the video input device
    /// with the specified constraints.
    pub(super) fn new_device_source(
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
    pub(super) fn new_display_source(
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
            let device_id: &str = device_id.as_ref();

            sys::VideoTrackSourceInterface::create_proxy_from_display(
                worker_thread,
                signaling_thread,
                device_id.parse::<i64>()?,
                caps.width as usize,
                caps.height as usize,
                caps.frame_rate as usize,
            )?
        };
        Ok(Self { inner, device_id })
    }
}

/// Wrapper around a [`StreamSink`] which emits [`AudioLevelUpdated`] events to
/// the Flutter side.
///
/// This handler also will multiply volume by `1000` and cast it to [`u32`], for
/// more convenient usage.
///
/// [`AudioLevelUpdated`]: api::TrackEvent::AudioLevelUpdated
pub(super) struct AudioSourceAudioLevelHandler(StreamSink<api::TrackEvent>);

impl AudioSourceAudioLevelHandler {
    /// Creates a new [`AudioSourceAudioLevelHandler`] with
    /// the provided [`StreamSink`].
    pub const fn new(sink: StreamSink<api::TrackEvent>) -> Self {
        Self(sink)
    }

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

impl From<&api::AudioProcessingConstraints> for sys::AudioProcessingConfig {
    fn from(caps: &api::AudioProcessingConstraints) -> Self {
        let mut conf = Self::default();

        conf.set_high_pass_filter_enabled(
            caps.high_pass_filter.unwrap_or(true),
        );
        conf.set_echo_cancellation_enabled(
            caps.echo_cancellation.unwrap_or(true),
        );
        conf.set_gain_controller_enabled(
            caps.auto_gain_control.unwrap_or(true),
        );

        conf.set_noise_suppression_enabled(
            caps.noise_suppression.unwrap_or(true),
        );
        conf.set_noise_suppression_level(
            caps.noise_suppression_level
                .unwrap_or(api::NoiseSuppressionLevel::VeryHigh)
                .into(),
        );

        conf
    }
}

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
