use std::{
    mem, ptr,
    sync::{
        atomic::{AtomicPtr, Ordering},
        mpsc,
    },
    thread,
};

use anyhow::anyhow;
use libwebrtc_sys as sys;

use crate::{
    Webrtc, api,
    api::WEBRTC,
    frb_generated::StreamSink,
    user_media::{AudioDeviceId, MediaTrackSource, TrackOrigin, VideoDeviceId},
};

/// Returns a list of all available displays that can be used for screen
/// capturing.
pub fn enumerate_displays() -> Vec<api::MediaDisplayInfo> {
    sys::screen_capture_sources()
        .into_iter()
        .map(|s| api::MediaDisplayInfo {
            device_id: s.id().to_string(),
            title: s.title(),
        })
        .collect()
}

/// Sender to notify of media devices change.
static DEVICE_CHANGE_TX: AtomicPtr<mpsc::Sender<()>> =
    AtomicPtr::new(ptr::null_mut());

/// Initializes media devices change watcher.
///
/// # Panics
///
/// If fails to spawn the `dvc-chng-hndlr` [`Thread`] where the watcher should
/// run.
///
/// [`Thread`]: std::thread::Thread
pub fn init_on_device_change() {
    let (tx, rx) = mpsc::channel();

    let old =
        DEVICE_CHANGE_TX.swap(Box::into_raw(Box::new(tx)), Ordering::SeqCst);
    if old.is_null() {
        unsafe {
            #[cfg(target_os = "macos")]
            macos::init();
            #[cfg(target_os = "windows")]
            windows::init();
            #[cfg(target_os = "linux")]
            linux::init();
        }
    } else {
        unsafe {
            drop(Box::from_raw(old));
        }
    }

    thread::Builder::new()
        .name("dvc-chng-hndlr".into())
        .spawn(move || {
            while rx.recv().is_ok() {
                // Drain channel since this on_device_changed call will handle
                // all changes that happened to this moment
                while rx.try_recv().is_ok() {}
                WEBRTC.lock().unwrap().on_device_changed();
            }
        })
        .unwrap_or_else(|e| {
            panic!("failed to spawn `dvc-chng-hndlr` thread: {e}")
        });
}

impl Webrtc {
    /// Returns a list of all available media devices.
    pub fn enumerate_devices(
        &mut self,
    ) -> anyhow::Result<Vec<api::MediaDeviceInfo>> {
        let audio_inputs = self
            .enumerate_audio_input_devices()?
            .into_iter()
            .map(|(label, id)| api::MediaDeviceInfo {
                device_id: id.into(),
                kind: api::MediaDeviceKind::AudioInput,
                label,
            });

        let audio_outputs = self
            .enumerate_audio_output_devices()?
            .into_iter()
            .map(|(label, id)| api::MediaDeviceInfo {
                device_id: id.into(),
                kind: api::MediaDeviceKind::AudioOutput,
                label,
            });

        let video_inputs = self
            .enumerate_video_input_devices()?
            .into_iter()
            .map(|(label, id)| api::MediaDeviceInfo {
                device_id: id.into(),
                kind: api::MediaDeviceKind::VideoInput,
                label,
            });

        Ok(audio_inputs.chain(audio_outputs).chain(video_inputs).collect())
    }

    /// Returns a list of all available audio input devices.
    pub fn enumerate_audio_input_devices(
        &self,
    ) -> anyhow::Result<Vec<(String, AudioDeviceId)>> {
        let count_recording = self.audio_device_module.recording_devices();
        let mut result = Vec::with_capacity(count_recording as usize);

        for i in 0..i16::try_from(count_recording)? {
            let (label, device_id) =
                self.audio_device_module.recording_device_name(i)?;

            result.push((label, AudioDeviceId::from(device_id)));
        }

        Ok(result)
    }

    /// Returns a list of all available audio output devices.
    pub fn enumerate_audio_output_devices(
        &self,
    ) -> anyhow::Result<Vec<(String, AudioDeviceId)>> {
        let count_playout = self.audio_device_module.playout_devices();
        let mut result = Vec::with_capacity(count_playout as usize);

        for i in 0..i16::try_from(count_playout)? {
            let (label, device_id) =
                self.audio_device_module.playout_device_name(i)?;

            result.push((label, AudioDeviceId::from(device_id)));
        }

        Ok(result)
    }

    /// Returns a list of all available video input devices.
    pub fn enumerate_video_input_devices(
        &mut self,
    ) -> anyhow::Result<Vec<(String, VideoDeviceId)>> {
        let count = self.video_device_info.number_of_devices();
        let mut result = Vec::with_capacity(count as usize);

        for i in 0..count {
            let (label, device_id) = self.video_device_info.device_name(i)?;

            result.push((label, VideoDeviceId::from(device_id)));
        }

        Ok(result)
    }

    /// Returns an index of the specific video device identified by the provided
    /// [`VideoDeviceId`].
    ///
    /// # Errors
    ///
    /// Whenever [`VideoDeviceInfo::device_name()`][1] returns an error.
    ///
    /// [1]: libwebrtc_sys::VideoDeviceInfo::device_name
    pub fn get_index_of_video_device(
        &mut self,
        device_id: &VideoDeviceId,
    ) -> anyhow::Result<Option<u32>> {
        let count = self.video_device_info.number_of_devices();
        for i in 0..count {
            let (_, id) = self.video_device_info.device_name(i)?;
            if id == device_id.to_string() {
                return Ok(Some(i));
            }
        }
        Ok(None)
    }

    /// Returns an index of the specific audio input device identified by the
    /// provided [`AudioDeviceId`].
    ///
    /// # Errors
    ///
    /// Whenever [`AudioDeviceModule::recording_devices()`][1] or
    /// [`AudioDeviceModule::recording_device_name()`][2] returns an error.
    ///
    /// [1]: libwebrtc_sys::AudioDeviceModule::recording_devices
    /// [2]: libwebrtc_sys::AudioDeviceModule::recording_device_name
    pub fn get_index_of_audio_recording_device(
        &mut self,
        device_id: &AudioDeviceId,
    ) -> anyhow::Result<Option<u16>> {
        let count: i16 =
            self.audio_device_module.recording_devices().try_into()?;
        for i in 0..count {
            let (_, id) = self.audio_device_module.recording_device_name(i)?;
            if id == device_id.to_string() {
                #[expect(clippy::cast_sign_loss, reason = "never negative")]
                return Ok(Some(i as u16));
            }
        }
        Ok(None)
    }

    /// Returns an index of the specific audio input device identified by the
    /// provided [`AudioDeviceId`].
    ///
    /// # Errors
    ///
    /// Whenever [`AudioDeviceModule::playout_devices()`][1] or
    /// [`AudioDeviceModule::playout_device_name()`][2] returns an error.
    ///
    /// [1]: libwebrtc_sys::AudioDeviceModule::playout_devices
    /// [2]: libwebrtc_sys::AudioDeviceModule::playout_device_name
    pub fn get_index_of_audio_playout_device(
        &mut self,
        device_id: &AudioDeviceId,
    ) -> anyhow::Result<Option<u16>> {
        let count: i16 =
            self.audio_device_module.playout_devices().try_into()?;
        for i in 0..count {
            let (_, id) = self.audio_device_module.playout_device_name(i)?;
            if id == device_id.to_string() {
                #[expect(clippy::cast_sign_loss, reason = "never negative")]
                return Ok(Some(i as u16));
            }
        }
        Ok(None)
    }

    /// Sets the specified `audio playout` device.
    pub fn set_audio_playout_device(
        &mut self,
        device_id: String,
    ) -> anyhow::Result<()> {
        let device_id = AudioDeviceId::from(device_id);
        let index = self.get_index_of_audio_playout_device(&device_id)?;

        if let Some(index) = index {
            let adm = &self.audio_device_module;
            adm.stop_playout()?;
            adm.set_playout_device(index)?;
            adm.init_playout()?;
            adm.start_playout()?;
            Ok(())
        } else {
            Err(anyhow!("Cannot find playout device with ID `{device_id}`"))
        }
    }

    /// Sets the microphone system volume according to the specified `level` in
    /// percents.
    pub fn set_microphone_volume(&mut self, level: u8) -> anyhow::Result<()> {
        self.audio_device_module.set_microphone_volume(level)
    }

    /// Indicates if the microphone is available to set volume.
    pub fn microphone_volume_is_available(&mut self) -> anyhow::Result<bool> {
        self.audio_device_module.microphone_volume_is_available()
    }

    /// Returns the current level of the microphone volume in percents.
    pub fn microphone_volume(&mut self) -> anyhow::Result<u32> {
        self.audio_device_module.microphone_volume()
    }

    /// Sets the provided `StreamSink` as the callback to be called whenever the
    /// set of available media devices changes.
    ///
    /// Only one callback can be set at a time, so the previous one will be
    /// dropped, if any.
    pub fn set_on_device_changed(&mut self, cb: StreamSink<()>) {
        self.devices_state.on_device_change = Some(cb);
    }

    /// Triggers the device change event.
    fn on_device_changed(&mut self) {
        let new_audio_ins = match self.enumerate_audio_input_devices() {
            Ok(ais) => ais,
            Err(e) => {
                log::error!("Failed to enumerate audio inputs: {e}");
                return;
            }
        };
        let new_audio_outs = match self.enumerate_audio_output_devices() {
            Ok(ais) => ais,
            Err(e) => {
                log::error!("Failed to enumerate audio outputs: {e}");
                return;
            }
        };
        let new_video_ins = match self.enumerate_video_input_devices() {
            Ok(ais) => ais,
            Err(e) => {
                log::error!("Failed to enumerate video inputs: {e}");
                return;
            }
        };

        let audio_ins_changed =
            self.devices_state.audio_inputs != new_audio_ins;
        let audio_outs_changed =
            self.devices_state.audio_outputs != new_audio_outs;
        let video_ins_changed =
            self.devices_state.video_inputs != new_video_ins;

        if !audio_ins_changed && !audio_outs_changed && !video_ins_changed {
            // No media devices changed
            return;
        }

        let mut old_audio_ins = mem::take(&mut self.devices_state.audio_inputs);
        let mut old_video_ins = mem::take(&mut self.devices_state.video_inputs);

        // If some audio or video inputs wre disconnected we drop corresponding
        // audio/video sources and tracks sourced from these sources.
        let mut tracks_to_remove: Vec<(String, api::MediaType)> = Vec::new();
        if audio_ins_changed && old_audio_ins.len() > new_audio_ins.len() {
            old_audio_ins.retain(|e| !new_audio_ins.contains(e));

            for (_, delete_ai) in old_audio_ins {
                for track in self.audio_tracks.iter() {
                    if let MediaTrackSource::Local(s) = &track.source {
                        if s.device_id == delete_ai {
                            tracks_to_remove.push((
                                track.id.clone().into(),
                                api::MediaType::Audio,
                            ));
                        }
                    }
                }
            }
        }
        if video_ins_changed && old_video_ins.len() > new_video_ins.len() {
            old_video_ins.retain(|e| !new_video_ins.contains(e));

            for (_, delete_vi) in old_video_ins {
                for track in self.video_tracks.iter() {
                    if let MediaTrackSource::Local(s) = &track.source {
                        if s.device_id == delete_vi {
                            tracks_to_remove.push((
                                track.id.clone().into(),
                                api::MediaType::Video,
                            ));
                        }
                    }
                }
            }
        }

        for (id, kind) in tracks_to_remove {
            self.dispose_track(TrackOrigin::Local, id, kind, true);
        }

        self.devices_state.audio_inputs = new_audio_ins;
        self.devices_state.audio_outputs = new_audio_outs;
        self.devices_state.video_inputs = new_video_ins;

        if let Some(cb) = &self.devices_state.on_device_change {
            _ = cb.add(());
        }
    }
}

/// Available media devices snapshot.
#[derive(Default)]
pub struct DevicesState {
    /// `StreamSink` to notify Dart side about a device change event.
    pub on_device_change: Option<StreamSink<()>>,

    /// List of all available audio input devices.
    pub audio_inputs: Vec<(String, AudioDeviceId)>,

    /// List of all available audio output devices.
    pub audio_outputs: Vec<(String, AudioDeviceId)>,

    /// List of all available video input devices.
    pub video_inputs: Vec<(String, VideoDeviceId)>,
}

#[cfg(target_os = "linux")]
mod linux {
    //! Tools for monitoring devices on [Linux].
    //!
    //! [Linux]: https://linux.org

    use pulse::mainloop::standard::IterateResult;

    /// Creates a detached [`Thread`] creating a devices monitor which polls for
    /// events.
    ///
    /// # Panics
    ///
    /// If fails to spawn the `udev-dvc-lstnr` or `pulse-dvc-lstnr` [`Thread`].
    ///
    /// [`Thread`]: std::thread::Thread
    pub unsafe fn init() {
        use std::thread;

        // Video devices monitoring via `libudev`.
        thread::Builder::new()
            .name("udev-dvc-lstnr".into())
            .spawn(move || {
                let context = libudev::Context::new().unwrap();
                udev::monitoring(&context).unwrap();
            })
            .unwrap_or_else(|e| {
                panic!("failed to spawn `udev-dvc-lstnr` thread: {e}")
            });

        // Audio devices monitoring via PulseAudio.
        thread::Builder::new()
            .name("pulse-dvc-lstnr".to_owned())
            .spawn(move || {
                let mut m = pulse_audio::AudioMonitor::new().unwrap();
                loop {
                    match m.main_loop.iterate(true) {
                        IterateResult::Success(_) => {}
                        IterateResult::Quit(_) => {
                            break;
                        }
                        IterateResult::Err(e) => {
                            log::error!(
                                "pulse audio mainloop iterate error: {e}",
                            );
                        }
                    }
                }
            })
            .unwrap_or_else(|e| {
                panic!("failed to spawn `pulse-dvc-lstnr` thread: {e}")
            });
    }

    pub mod udev {
        //! [libudev] tools for monitoring devices.
        //!
        //! [libudev]: https://freedesktop.org/software/systemd/man/libudev.html

        use std::{
            io,
            os::{fd::BorrowedFd, unix::prelude::AsRawFd as _},
            sync::atomic::Ordering,
        };

        use libudev::EventType;
        use nix::poll::{PollFd, PollFlags, ppoll};

        use crate::devices::DEVICE_CHANGE_TX;

        /// Monitors video devices via [libudev].
        ///
        /// [libudev]: https://freedesktop.org/software/systemd/man/libudev.html
        pub fn monitoring(context: &libudev::Context) -> io::Result<()> {
            let mut monitor = libudev::Monitor::new(context)?;
            monitor.match_subsystem("video4linux")?;
            let mut socket = monitor.listen()?;

            // SAFETY: This this safe, because `fd` doesn't outlive the
            //         `socket`.
            let socket_fd =
                unsafe { BorrowedFd::borrow_raw(socket.as_raw_fd()) };
            let fds = PollFd::new(socket_fd, PollFlags::POLLIN);
            loop {
                ppoll(&mut [fds], None, None)?;

                let Some(event) = socket.receive_event() else {
                    continue;
                };

                if matches!(
                    event.event_type(),
                    EventType::Add | EventType::Remove,
                ) {
                    let tx = DEVICE_CHANGE_TX.load(Ordering::SeqCst);
                    if !tx.is_null() {
                        _ = unsafe { &*tx }.send(());
                    }
                }
            }
        }
    }

    pub mod pulse_audio {
        //! [PulseAudio] tools for monitoring devices.
        //!
        //! [PulseAudio]: https://freedesktop.org/wiki/Software/PulseAudio

        use std::sync::atomic::Ordering;

        use anyhow::anyhow;
        use pulse::{
            context::{
                Context, FlagSet, State,
                subscribe::{Facility, InterestMaskSet, Operation},
            },
            mainloop::standard::{IterateResult, Mainloop},
        };

        use crate::devices::DEVICE_CHANGE_TX;

        /// Monitor of audio devices via [PulseAudio].
        ///
        /// [PulseAudio]: https://freedesktop.org/wiki/Software/PulseAudio
        pub struct AudioMonitor {
            /// [PulseAudio] context.
            ///
            /// [PulseAudio]: https://freedesktop.org/wiki/Software/PulseAudio
            pub _context: Context,

            /// [PulseAudio] main loop.
            ///
            /// [PulseAudio]: https://freedesktop.org/wiki/Software/PulseAudio
            pub main_loop: Mainloop,
        }

        impl AudioMonitor {
            /// Creates a new [`AudioMonitor`].
            pub fn new() -> anyhow::Result<Self> {
                use Facility::{Server, Sink, Source};
                use Operation::{Changed, New, Removed};

                let mut main_loop = Mainloop::new()
                    .ok_or_else(|| anyhow!("PulseAudio mainloop is `null`"))?;
                let mut context =
                    Context::new(&main_loop, "flutter-audio-monitor")
                        .ok_or_else(|| {
                            anyhow!("PulseAudio context failed to start")
                        })?;

                context.set_subscribe_callback(Some(Box::new(|f, op, _| {
                    let (Some(f), Some(op)) = (f, op) else {
                        return;
                    };

                    if matches!(f, Sink | Source) && matches!(op, New | Removed)
                        || f == Server && op == Changed
                    {
                        let tx = DEVICE_CHANGE_TX.load(Ordering::SeqCst);
                        if !tx.is_null() {
                            _ = unsafe { &*tx }.send(());
                        }
                    }
                })));

                context.connect(None, FlagSet::empty(), None)?;
                loop {
                    let state = context.get_state();

                    if !state.is_good() {
                        anyhow::bail!("PulseAudio context connection failed");
                    }

                    if state == State::Ready {
                        break;
                    }

                    match main_loop.iterate(true) {
                        IterateResult::Success(_) => {}
                        IterateResult::Quit(c) => {
                            anyhow::bail!("PulseAudio quit with code: {}", c.0);
                        }
                        IterateResult::Err(e) => {
                            anyhow::bail!("PulseAudio errored: {e}");
                        }
                    }
                }

                let mask = InterestMaskSet::SOURCE
                    | InterestMaskSet::SINK
                    | InterestMaskSet::SERVER;
                context.subscribe(mask, |_| {});

                Ok(Self { _context: context, main_loop })
            }
        }
    }
}

#[cfg(target_os = "macos")]
mod macos {
    use std::sync::atomic::Ordering;

    use crate::devices::DEVICE_CHANGE_TX;

    /// Sets native side callback for devices monitoring.
    pub unsafe fn init() {
        unsafe extern "C" {
            /// Passes the callback to the native side.
            pub fn set_on_device_change_mac(cb: unsafe extern "C" fn());
        }

        extern "C" fn on_device_change() {
            let tx = DEVICE_CHANGE_TX.load(Ordering::SeqCst);
            if !tx.is_null() {
                _ = unsafe { &*tx }.send(());
            }
        }

        unsafe {
            set_on_device_change_mac(on_device_change);
        }
    }
}

#[cfg(target_os = "windows")]
mod windows {
    //! Implementation of the default audio output device changes detector for
    //! Windows.

    // TODO: Remove once macro expands with `#[automatically_derived]`:
    //       https://github.com/microsoft/windows-rs/issues/3566
    #![expect( // `#[windows::core::implement]` macro expansion
        clippy::as_pointer_underscore,
        clippy::borrow_as_ptr,
        clippy::inline_always,
        clippy::multiple_unsafe_ops_per_block,
        clippy::ptr_as_ptr,
        trivial_casts,
        reason = "`#[windows::core::implement]` macro expansion"
    )]

    use std::{
        ffi::OsStr,
        mem,
        os::windows::prelude::OsStrExt as _,
        ptr,
        sync::atomic::{AtomicPtr, Ordering},
        thread,
    };

    use windows::{
        Win32::{
            Foundation::{HWND, LPARAM, LRESULT, PROPERTYKEY, WPARAM},
            Media::Audio::{
                DEVICE_STATE, EDataFlow, ERole, IMMDeviceEnumerator,
                IMMNotificationClient, IMMNotificationClient_Impl,
                MMDeviceEnumerator,
            },
            System::Com::{CLSCTX_ALL, CoCreateInstance},
            UI::WindowsAndMessaging::{
                CW_USEDEFAULT, CreateWindowExW, DBT_DEVNODES_CHANGED,
                DefWindowProcW, DispatchMessageW, GetMessageW, MSG,
                RegisterClassExW, SW_HIDE, ShowWindow, TranslateMessage,
                WINDOW_EX_STYLE, WM_DEVICECHANGE, WM_QUIT, WNDCLASSEXW,
                WS_ICONIC,
            },
        },
        core::{PCWSTR, Result},
    };

    use crate::devices::DEVICE_CHANGE_TX;

    /// Storage for an [`IMMDeviceEnumerator`] used for detecting default audio
    /// device changes.
    static AUDIO_ENDPOINT_ENUMERATOR: AtomicPtr<IMMDeviceEnumerator> =
        AtomicPtr::new(ptr::null_mut());

    /// Storage for an [`EMMNotificationClient`] used for detecting default
    /// audio device changes.
    static AUDIO_ENDPOINT_CALLBACK: AtomicPtr<IMMNotificationClient> =
        AtomicPtr::new(ptr::null_mut());

    /// Implementation of an [`IMMNotificationClient`] used for detecting
    /// default audio output device changes.
    #[windows::core::implement(IMMNotificationClient)]
    struct AudioEndpointCallback;

    impl IMMNotificationClient_Impl for AudioEndpointCallback_Impl {
        fn OnDeviceStateChanged(
            &self,
            _: &PCWSTR,
            _: DEVICE_STATE,
        ) -> Result<()> {
            Ok(())
        }

        fn OnDeviceAdded(&self, _: &PCWSTR) -> Result<()> {
            Ok(())
        }

        fn OnDeviceRemoved(&self, _: &PCWSTR) -> Result<()> {
            Ok(())
        }

        fn OnDefaultDeviceChanged(
            &self,
            _: EDataFlow,
            role: ERole,
            _: &PCWSTR,
        ) -> Result<()> {
            if role == ERole(0) {
                let tx = DEVICE_CHANGE_TX.load(Ordering::SeqCst);
                if !tx.is_null() {
                    _ = unsafe { &*tx }.send(());
                }
            }

            Ok(())
        }

        fn OnPropertyValueChanged(
            &self,
            _pwstrdeviceid: &PCWSTR,
            _key: &PROPERTYKEY,
        ) -> Result<()> {
            Ok(())
        }
    }

    /// Registers default audio output callback for Windows.
    ///
    /// Will call [`DeviceState::on_device_change`] callback whenever a default
    /// audio output is changed.
    pub fn register() {
        let audio_endpoint_enumerator: IMMDeviceEnumerator =
            unsafe { CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL) }
                .unwrap();

        let audio_endpoint_callback: IMMNotificationClient =
            AudioEndpointCallback.into();
        unsafe {
            audio_endpoint_enumerator
                .RegisterEndpointNotificationCallback(&audio_endpoint_callback)
        }
        .unwrap();

        AUDIO_ENDPOINT_ENUMERATOR.swap(
            Box::into_raw(Box::new(audio_endpoint_enumerator)),
            Ordering::SeqCst,
        );
        AUDIO_ENDPOINT_CALLBACK.swap(
            Box::into_raw(Box::new(audio_endpoint_callback)),
            Ordering::SeqCst,
        );
    }

    /// Creates a detached [`Thread`] creating and registering a system message
    /// window - [`HWND`].
    ///
    /// # Panics
    ///
    /// If fails to spawn the `dvc-chng-lstnr` [`Thread`].
    ///
    /// [`Thread`]: thread::Thread
    pub unsafe fn init() {
        /// Message handler for an [`HWND`].
        unsafe extern "system" fn wndproc(
            hwnd: HWND,
            msg: u32,
            wp: WPARAM,
            lp: LPARAM,
        ) -> LRESULT {
            let mut result = LRESULT(0);

            // The message that notifies an application of a change to the
            // hardware configuration of a device or the computer.
            if msg == WM_DEVICECHANGE {
                // The device event when a device has been added to or removed
                // from the system.
                if DBT_DEVNODES_CHANGED as usize == wp.0 {
                    let tx = DEVICE_CHANGE_TX.load(Ordering::SeqCst);
                    if !tx.is_null() {
                        _ = unsafe { &*tx }.send(());
                    }
                }
            } else {
                result = unsafe { DefWindowProcW(hwnd, msg, wp, lp) };
            }

            result
        }

        register();

        thread::Builder::new().name("dvc-chng-lstnr".into()).spawn(move || {
            let lpsz_class_name = OsStr::new("EventWatcher")
                .encode_wide()
                .chain(Some(0))
                .collect::<Vec<u16>>();
            let lpsz_class_name_ptr = lpsz_class_name.as_ptr();

            #[expect(clippy::cast_possible_truncation, reason = "size fits")]
            let class = WNDCLASSEXW {
                cbSize: mem::size_of::<WNDCLASSEXW>() as u32,
                lpfnWndProc: Some(wndproc),
                lpszClassName: PCWSTR(lpsz_class_name_ptr),
                ..WNDCLASSEXW::default()
            };
            unsafe {
                RegisterClassExW(&class);
            }

            let lp_window_name = OsStr::new("Notifier")
                .encode_wide()
                .chain(Some(0))
                .collect::<Vec<u16>>();
            let lp_window_name_ptr = lp_window_name.as_ptr();

            let hwnd = unsafe {
                CreateWindowExW(
                    WINDOW_EX_STYLE(0),
                    class.lpszClassName,
                    PCWSTR::from_raw(lp_window_name_ptr),
                    WS_ICONIC,
                    0,
                    0,
                    CW_USEDEFAULT,
                    0,
                    None,
                    None,
                    None,
                    None,
                )
            };

            let Ok(hwnd) = hwnd else {
                log::error!(
                    "Failed to create window so on device change listener is \
                    disabled",
                );
                return;
            };

            _ = unsafe { ShowWindow(hwnd, SW_HIDE) };

            let mut msg: MSG = unsafe { mem::zeroed() };

            while unsafe { GetMessageW(&mut msg, Some(hwnd), 0, 0).into() } {
                if msg.message == WM_QUIT {
                    break;
                }

                _ = unsafe { TranslateMessage(&msg) };
                unsafe {
                    DispatchMessageW(&msg);
                }
            }
        }).unwrap_or_else(|e| {
            panic!("failed to spawn `dvc-chng-lstnr` thread: {e}")
        });
    }
}
