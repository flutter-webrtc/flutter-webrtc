use crate::{
    api,
    user_media::{AudioDeviceId, VideoDeviceId},
    Webrtc,
};

impl Webrtc {
    /// Returns a list of all available audio input and output devices.
    ///
    /// # Panics
    ///
    /// Panics on any error returned from the `libWebRTC`.
    #[must_use]
    pub fn enumerate_devices(self: &mut Webrtc) -> Vec<api::MediaDeviceInfo> {
        // TODO: Dont panic but propagate errors to API users.
        // Returns a list of all available audio devices.
        let mut audio = {
            let count_playout =
                self.0.audio_device_module.inner.playout_devices().unwrap();
            let count_recording = self
                .0
                .audio_device_module
                .inner
                .recording_devices()
                .unwrap();

            #[allow(clippy::cast_sign_loss)]
            let mut result =
                Vec::with_capacity((count_playout + count_recording) as usize);

            for kind in [
                api::MediaDeviceKind::kAudioOutput,
                api::MediaDeviceKind::kAudioInput,
            ] {
                let count = if let api::MediaDeviceKind::kAudioOutput = kind {
                    count_playout
                } else {
                    count_recording
                };

                for i in 0..count {
                    let (label, device_id) =
                        if let api::MediaDeviceKind::kAudioOutput = kind {
                            self.0
                                .audio_device_module
                                .inner
                                .playout_device_name(i)
                                .unwrap()
                        } else {
                            self.0
                                .audio_device_module
                                .inner
                                .recording_device_name(i)
                                .unwrap()
                        };

                    result.push(api::MediaDeviceInfo {
                        device_id,
                        kind,
                        label,
                    });
                }
            }

            result
        };

        // Returns a list of all available video input devices.
        let mut video = {
            let count = self.0.video_device_info.number_of_devices();
            let mut result = Vec::with_capacity(count as usize);

            for i in 0..count {
                let (label, device_id) =
                    self.0.video_device_info.device_name(i).unwrap();

                result.push(api::MediaDeviceInfo {
                    device_id,
                    kind: api::MediaDeviceKind::kVideoInput,
                    label,
                });
            }

            result
        };

        audio.append(&mut video);

        audio
    }

    /// Returns an index of a specific video device identified by the provided
    /// [`VideoDeviceId`].
    ///
    /// # Errors
    ///
    /// Errors if [`VideoDeviceInfo::device_name()`][1] returns error.
    ///
    /// [1]: [`libwebrtc_sys::VideoDeviceInfo::device_name()`]
    pub fn get_index_of_video_device(
        &mut self,
        device_id: &VideoDeviceId,
    ) -> anyhow::Result<Option<u32>> {
        let count = self.0.video_device_info.number_of_devices();
        for i in 0..count {
            let (_, id) = self.0.video_device_info.device_name(i)?;
            if id == device_id.as_ref() {
                return Ok(Some(i));
            }
        }
        Ok(None)
    }

    /// Returns an index of a specific audio input device identified by the
    /// provided [`AudioDeviceId`].
    ///
    /// # Errors
    ///
    /// Errors if [`AudioDeviceModule::recording_devices()`][1] or
    /// [`AudioDeviceModule::recording_device_name()`][2]
    /// returns error.
    ///
    /// [1]: libwebrtc_sys::AudioDeviceModule::recording_devices
    /// [2]: libwebrtc_sys::AudioDeviceModule::recording_device_name
    pub fn get_index_of_audio_recording_device(
        &mut self,
        device_id: &AudioDeviceId,
    ) -> anyhow::Result<Option<u16>> {
        let count = self.0.audio_device_module.inner.recording_devices()?;
        for i in 0..count {
            let (_, id) =
                self.0.audio_device_module.inner.recording_device_name(i)?;
            if id == device_id.as_ref() {
                #[allow(clippy::cast_sign_loss)]
                return Ok(Some(i as u16));
            }
        }
        Ok(None)
    }
}
