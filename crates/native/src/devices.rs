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
use winapi::{
    shared::{
        minwindef::{HINSTANCE, LPARAM, LRESULT, UINT, WPARAM},
        windef::HWND,
    },
    um::{
        dbt::DBT_DEVNODES_CHANGED,
        winuser::{
            CreateWindowExW, DefWindowProcW, DispatchMessageW, GetMessageW,
            RegisterClassExW, ShowWindow, TranslateMessage, CW_USEDEFAULT, MSG,
            SW_HIDE, WM_DEVICECHANGE, WM_QUIT, WNDCLASSEXW, WS_ICONIC,
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

/// Struct containing the current number of media devices and some tools to
/// enumerate them (such as [`AudioDeviceModule`] and [`VideoDeviceInfo`]), and
/// generate event with [`OnDeviceChangeCallback`], if the last is needed.
struct DeviceState {
    cb: StreamSink<()>,
    adm: AudioDeviceModule,
    _thread: sys::Thread,
    vdi: sys::VideoDeviceInfo,
    audio_count: u32,
    video_count: u32,
}

impl DeviceState {
    /// Creates a new [`DeviceState`].
    fn new(
        cb: StreamSink<()>,
        tq: &mut sys::TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let mut thread = sys::Thread::create(false)?;
        thread.start()?;
        let adm = AudioDeviceModule::new(
            &mut thread,
            sys::AudioLayer::kPlatformDefaultAudio,
            tq,
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
            self.audio_device_module.set_playout_device(index)
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
    pub fn set_on_device_changed(
        &mut self,
        cb: StreamSink<()>,
    ) -> anyhow::Result<()> {
        let prev = ON_DEVICE_CHANGE.swap(
            Box::into_raw(Box::new(DeviceState::new(
                cb,
                &mut self.task_queue_factory,
            )?)),
            Ordering::SeqCst,
        );

        if prev.is_null() {
            unsafe {
                init();
            }
        } else {
            unsafe {
                drop(Box::from_raw(prev));
            }
        }

        Ok(())
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

        use std::{io, os::unix::prelude::AsRawFd, sync::atomic::Ordering};

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

            let fds = PollFd::new(socket.as_raw_fd(), PollFlags::POLLIN);
            loop {
                ppoll(&mut [fds], None, None)?;

                let event = match socket.receive_event() {
                    Some(evt) => evt,
                    None => continue,
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
            pub context: Context,

            /// [PulseAudio] main loop.
            ///
            /// [PulseAudio]: https://freedesktop.org/wiki/Software/PulseAudio
            pub main_loop: Mainloop,
        }

        impl AudioMonitor {
            /// Creates a new [`AudioMonitor`].
            pub fn new() -> anyhow::Result<Self> {
                use Facility::{Sink, Source};
                use Operation::{New, Removed};

                let mut main_loop = Mainloop::new()
                    .ok_or_else(|| anyhow!("PulseAudio mainloop is `null`"))?;
                let mut context =
                    Context::new(&main_loop, "flutter-audio-monitor")
                        .ok_or_else(|| {
                            anyhow!("PulseAudio context failed to start")
                        })?;

                context.set_subscribe_callback(Some(Box::new(
                    |facility, operation, _| {
                        if let Some(New | Removed) = operation {
                            if let Some(Sink | Source) = facility {
                                let state =
                                    ON_DEVICE_CHANGE.load(Ordering::SeqCst);
                                if !state.is_null() {
                                    let device_state = unsafe { &mut *state };
                                    let new_count =
                                        device_state.count_audio_devices();

                                    if device_state.audio_count != new_count {
                                        device_state.set_audio_count(new_count);
                                        device_state.on_device_change();
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

                let mask = InterestMaskSet::SOURCE | InterestMaskSet::SINK;
                context.subscribe(mask, |_| {});

                Ok(Self { context, main_loop })
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
/// Creates a detached [`Thread`] creating and registering a system message
/// window - [`HWND`].
///
/// [`Thread`]: thread::Thread
pub unsafe fn init() {
    /// Message handler for an [`HWND`].
    unsafe extern "system" fn wndproc(
        hwnd: HWND,
        msg: UINT,
        wp: WPARAM,
        lp: LPARAM,
    ) -> LRESULT {
        let mut result: LRESULT = 0;

        // The message that notifies an application of a change to the hardware
        // configuration of a device or the computer.
        if msg == WM_DEVICECHANGE {
            // The device event when a device has been added to or removed from
            // the system.
            if DBT_DEVNODES_CHANGED == wp {
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

    thread::spawn(|| {
        let lpsz_class_name = OsStr::new("EventWatcher")
            .encode_wide()
            .chain(Some(0).into_iter())
            .collect::<Vec<u16>>()
            .as_ptr();

        #[allow(clippy::cast_possible_truncation)]
        let class = WNDCLASSEXW {
            cbSize: mem::size_of::<WNDCLASSEXW>() as u32,
            lpfnWndProc: Some(wndproc),
            lpszClassName: lpsz_class_name,
            ..WNDCLASSEXW::default()
        };
        RegisterClassExW(&class);

        let hwnd = CreateWindowExW(
            0,
            class.lpszClassName,
            OsStr::new("Notifier")
                .encode_wide()
                .chain(Some(0).into_iter())
                .collect::<Vec<u16>>()
                .as_ptr(),
            WS_ICONIC,
            0,
            0,
            CW_USEDEFAULT,
            0,
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            0 as HINSTANCE,
            std::ptr::null_mut(),
        );

        ShowWindow(hwnd, SW_HIDE);

        let mut msg: MSG = mem::zeroed();

        while GetMessageW(&mut msg, hwnd, 0, 0) > 0 {
            if msg.message == WM_QUIT {
                break;
            }

            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    });
}
