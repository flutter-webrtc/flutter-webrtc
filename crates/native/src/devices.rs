use std::{
    ptr,
    sync::atomic::{AtomicPtr, Ordering},
};

#[cfg(target_os = "windows")]
use std::{ffi::OsStr, mem, os::windows::prelude::OsStrExt, thread};

use anyhow::anyhow;
use libwebrtc_sys as sys;

#[cfg(target_os = "linux")]
use pulse::mainloop::standard::IterateResult;

#[cfg(target_os = "windows")]
use windows::{
    core::PCWSTR,
    Win32::{
        Foundation::{HMODULE, HWND, LPARAM, LRESULT, WPARAM},
        UI::WindowsAndMessaging::{
            CreateWindowExW, DefWindowProcW, DispatchMessageW, GetMessageW,
            RegisterClassExW, ShowWindow, TranslateMessage, CW_USEDEFAULT,
            DBT_DEVNODES_CHANGED, MSG, SW_HIDE, WINDOW_EX_STYLE,
            WM_DEVICECHANGE, WM_QUIT, WNDCLASSEXW, WS_ICONIC,
        },
    },
};

use crate::{
    api,
    stream_sink::StreamSink,
    user_media::{AudioDeviceId, VideoDeviceId},
    AudioDeviceModule, Webrtc,
};

/// Static instance of a [`DeviceState`].
static ON_DEVICE_CHANGE: AtomicPtr<DeviceState> =
    AtomicPtr::new(ptr::null_mut());

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

/// Struct containing the current number of media devices and some tools to
/// enumerate them (such as [`AudioDeviceModule`] and [`VideoDeviceInfo`]), and
/// generate event with [`OnDeviceChangeCallback`], if the last is needed.
pub struct DeviceState {
    cb: StreamSink<()>,
    adm: AudioDeviceModule,
    _thread: sys::Thread,
    vdi: sys::VideoDeviceInfo,
    audio_count: u32,
    video_count: u32,
}

impl DeviceState {
    /// Creates a new [`DeviceState`].
    pub fn new(
        cb: StreamSink<()>,
        tq: &mut sys::TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let mut thread = sys::Thread::create(false)?;
        thread.start()?;
        let adm = AudioDeviceModule::new(
            &mut thread,
            sys::AudioLayer::kPlatformDefaultAudio,
            tq,
            None,
        )?;

        let vdi = sys::VideoDeviceInfo::create()?;

        let mut ds = Self {
            adm,
            _thread: thread,
            vdi,
            audio_count: 0,
            video_count: 0,
            cb,
        };

        let audio_device_count = ds.count_audio_devices();
        ds.set_audio_count(audio_device_count);

        let video_device_count = ds.count_video_devices();
        ds.set_video_count(video_device_count);

        Ok(ds)
    }

    /// Counts current number of audio media devices.
    fn count_audio_devices(&mut self) -> u32 {
        self.adm.playout_devices() + self.adm.recording_devices()
    }

    /// Counts current number on video media devices.
    fn count_video_devices(&mut self) -> u32 {
        self.vdi.number_of_devices()
    }

    /// Fixes some audio media devices `count` in this [`DeviceState`].
    fn set_audio_count(&mut self, count: u32) {
        self.audio_count = count;
    }

    /// Fixes some video media devices `count` in this [`DeviceState`].
    fn set_video_count(&mut self, count: u32) {
        self.video_count = count;
    }

    /// Triggers the [`OnDeviceChangeCallback`].
    fn on_device_change(&mut self) {
        self.cb.add(());
    }
}

impl Webrtc {
    /// Returns a list of all available audio input and output devices.
    ///
    /// # Panics
    ///
    /// On any error returned from `libWebRTC`.
    pub fn enumerate_devices(
        &mut self,
    ) -> anyhow::Result<Vec<api::MediaDeviceInfo>> {
        let mut audio = {
            let count_playout = self.audio_device_module.playout_devices();
            let count_recording = self.audio_device_module.recording_devices();

            #[allow(clippy::cast_sign_loss)]
            let mut result =
                Vec::with_capacity((count_playout + count_recording) as usize);

            for kind in [
                api::MediaDeviceKind::AudioOutput,
                api::MediaDeviceKind::AudioInput,
            ] {
                let count: i16 =
                    if let api::MediaDeviceKind::AudioOutput = kind {
                        count_playout
                    } else {
                        count_recording
                    }
                    .try_into()?;

                for i in 0..count {
                    let (label, device_id) =
                        if let api::MediaDeviceKind::AudioOutput = kind {
                            self.audio_device_module.playout_device_name(i)?
                        } else {
                            self.audio_device_module.recording_device_name(i)?
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
            let count = self.video_device_info.number_of_devices();
            let mut result = Vec::with_capacity(count as usize);

            for i in 0..count {
                let (label, device_id) =
                    self.video_device_info.device_name(i)?;

                result.push(api::MediaDeviceInfo {
                    device_id,
                    kind: api::MediaDeviceKind::VideoInput,
                    label,
                });
            }

            result
        };

        audio.append(&mut video);

        Ok(audio)
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
                #[allow(clippy::cast_sign_loss)]
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
                #[allow(clippy::cast_sign_loss)]
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

    /// Sets the provided [`OnDeviceChangeCallback`] as the callback to be
    /// called whenever the set of available media devices changes.
    ///
    /// Only one callback can be set at a time, so the previous one will be
    /// dropped, if any.
    pub fn set_on_device_changed(device_state: DeviceState) {
        let prev = ON_DEVICE_CHANGE
            .swap(Box::into_raw(Box::new(device_state)), Ordering::SeqCst);

        if prev.is_null() {
            unsafe {
                init();
            }
        } else {
            unsafe {
                drop(Box::from_raw(prev));
            }
        }
    }
}

#[cfg(target_os = "linux")]
/// Creates a detached [`Thread`] creating a devices monitor which polls for
/// events.
///
/// [`Thread`]: std::thread::Thread
pub unsafe fn init() {
    use std::thread;

    use crate::devices::linux_device_change::{
        pulse_audio::AudioMonitor, udev::monitoring,
    };

    // Video devices monitoring via `libudev`.
    thread::spawn(move || {
        let context = libudev::Context::new().unwrap();
        monitoring(&context).unwrap();
    });

    // Audio devices monitoring via PulseAudio.
    thread::spawn(move || {
        let mut m = AudioMonitor::new().unwrap();
        loop {
            match m.main_loop.iterate(true) {
                IterateResult::Success(_) => {}
                IterateResult::Quit(_) => {
                    break;
                }
                IterateResult::Err(e) => {
                    log::error!("pulse audio mainloop iterate error: {e}");
                }
            }
        }
    });
}

#[cfg(target_os = "linux")]
pub mod linux_device_change {
    //! Tools for monitoring devices on [Linux].
    //!
    //! [Linux]: https://linux.org

    pub mod udev {
        //! [libudev] tools for monitoring devices.
        //!
        //! [libudev]: https://freedesktop.org/software/systemd/man/libudev.html

        use std::{
            io,
            os::{fd::BorrowedFd, unix::prelude::AsRawFd},
            sync::atomic::Ordering,
        };

        use libudev::EventType;
        use nix::poll::{ppoll, PollFd, PollFlags};

        use crate::devices::ON_DEVICE_CHANGE;

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
                    let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);
                    if !state.is_null() {
                        let device_state = unsafe { &mut *state };
                        let new_count = device_state.count_video_devices();

                        if device_state.video_count != new_count {
                            device_state.set_video_count(new_count);
                            device_state.on_device_change();
                        }
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
                subscribe::{Facility, InterestMaskSet, Operation},
                Context, FlagSet, State,
            },
            mainloop::standard::{IterateResult, Mainloop},
        };

        use crate::devices::ON_DEVICE_CHANGE;

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

                context.set_subscribe_callback(Some(Box::new(
                    |facility, operation, _| {
                        if let Some(New | Removed | Changed) = operation {
                            if let Some(Sink | Source | Server) = facility {
                                let state =
                                    ON_DEVICE_CHANGE.load(Ordering::SeqCst);
                                if !state.is_null() {
                                    let device_state = unsafe { &mut *state };

                                    if facility == Some(Server) {
                                        device_state.on_device_change();
                                    } else {
                                        let new_count =
                                            device_state.count_audio_devices();

                                        if device_state.audio_count != new_count
                                        {
                                            device_state
                                                .set_audio_count(new_count);
                                            device_state.on_device_change();
                                        }
                                    }
                                }
                            }
                        }
                    },
                )));

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
                        IterateResult::Success(_) => {
                            continue;
                        }
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

                Ok(Self {
                    _context: context,
                    main_loop,
                })
            }
        }
    }
}

#[cfg(target_os = "macos")]
/// Sets native side callback for devices monitoring.
pub unsafe fn init() {
    extern "C" {
        /// Passes the callback to the native side.
        pub fn set_on_device_change_mac(cb: unsafe extern "C" fn());
    }

    extern "C" fn on_device_change() {
        let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);
        if !state.is_null() {
            let device_state = unsafe { &mut *state };
            device_state.on_device_change();
        }
    }

    set_on_device_change_mac(on_device_change);
}

#[cfg(target_os = "windows")]
#[allow(unused_must_use)]
mod win_default_device_callback {
    //! Implementation of the default audio output device changes detector for
    //! Windows.

    use std::{
        ptr,
        sync::atomic::{AtomicPtr, Ordering},
    };

    use windows::{
        core::{Result, PCWSTR},
        Win32::{
            Media::Audio::{
                EDataFlow, ERole, IMMDeviceEnumerator, IMMNotificationClient,
                IMMNotificationClient_Impl, MMDeviceEnumerator, DEVICE_STATE,
            },
            System::Com::{CoCreateInstance, CLSCTX_ALL},
            UI::Shell::PropertiesSystem::PROPERTYKEY,
        },
    };

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

    #[allow(non_snake_case)]
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
                unsafe {
                    let state = super::ON_DEVICE_CHANGE.load(Ordering::SeqCst);

                    if !state.is_null() {
                        let device_state = &mut *state;
                        device_state.on_device_change();
                    }
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
        unsafe {
            let audio_endpoint_enumerator: IMMDeviceEnumerator =
                CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)
                    .unwrap();
            let audio_endpoint_callback: IMMNotificationClient =
                AudioEndpointCallback.into();
            audio_endpoint_enumerator
                .RegisterEndpointNotificationCallback(&audio_endpoint_callback)
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
    }
}

#[cfg(target_os = "windows")]
/// Creates a detached [`Thread`] creating and registering a system message
/// window - [`HWND`].
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
        let mut result: LRESULT = LRESULT(0);

        // The message that notifies an application of a change to the hardware
        // configuration of a device or the computer.
        if msg == WM_DEVICECHANGE {
            // The device event when a device has been added to or removed from
            // the system.
            if DBT_DEVNODES_CHANGED as usize == wp.0 {
                let state = ON_DEVICE_CHANGE.load(Ordering::SeqCst);

                if !state.is_null() {
                    let device_state = &mut *state;
                    let new_video_count = device_state.count_video_devices();
                    let new_audio_count = device_state.count_audio_devices();

                    if device_state.video_count != new_video_count
                        || device_state.audio_count != new_audio_count
                    {
                        device_state.set_video_count(new_video_count);
                        device_state.set_audio_count(new_audio_count);
                        device_state.on_device_change();
                    }
                }
            }
        } else {
            result = DefWindowProcW(hwnd, msg, wp, lp);
        }

        result
    }

    win_default_device_callback::register();

    thread::spawn(|| {
        let lpsz_class_name = OsStr::new("EventWatcher")
            .encode_wide()
            .chain(Some(0))
            .collect::<Vec<u16>>();
        let lpsz_class_name_ptr = lpsz_class_name.as_ptr();

        #[allow(clippy::cast_possible_truncation)]
        let class = WNDCLASSEXW {
            cbSize: mem::size_of::<WNDCLASSEXW>() as u32,
            lpfnWndProc: Some(wndproc),
            lpszClassName: PCWSTR(lpsz_class_name_ptr),
            ..WNDCLASSEXW::default()
        };
        RegisterClassExW(&class);

        let lp_window_name = OsStr::new("Notifier")
            .encode_wide()
            .chain(Some(0))
            .collect::<Vec<u16>>();
        let lp_window_name_ptr = lp_window_name.as_ptr();

        let hwnd = CreateWindowExW(
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
            HMODULE(ptr::null_mut()),
            None,
        );

        let Ok(hwnd) = hwnd else {
            log::error!(
                "Failed to create window so on device change listener is \
                 disabled",
            );
            return;
        };

        _ = ShowWindow(hwnd, SW_HIDE);

        let mut msg: MSG = mem::zeroed();

        while GetMessageW(&mut msg, hwnd, 0, 0).into() {
            if msg.message == WM_QUIT {
                break;
            }

            _ = TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    });
}
