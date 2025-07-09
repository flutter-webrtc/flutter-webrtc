use std::hash::Hash;

use anyhow::bail;
use derive_more::with_trait::{AsRef, Display, From, Into};
use libwebrtc_sys as sys;
use sys::AudioProcessing;
use xxhash::xxh3::xxh3_64;

use crate::api;

/// ID of a video input device that provides data to some [`VideoSource`].
///
/// [`VideoSource`]: crate::media::VideoSource
#[derive(AsRef, Clone, Debug, Display, Eq, From, Hash, Into, PartialEq)]
#[as_ref(forward)]
pub struct VideoDeviceId(String);

/// ID of an `AudioDevice`.
#[derive(
    AsRef, Clone, Debug, Default, Display, Eq, From, Hash, Into, PartialEq,
)]
#[as_ref(forward)]
pub struct AudioDeviceId(String);

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
    ) -> anyhow::Result<Self> {
        let inner = sys::AudioDeviceModule::create_proxy(
            worker_thread,
            audio_layer,
            task_queue_factory,
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
        ap: &AudioProcessing,
    ) -> anyhow::Result<sys::AudioSourceInterface> {
        if api::is_fake_media() {
            self.inner.create_fake_audio_source()
        } else {
            self.inner.create_audio_source(device_index, ap)
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
