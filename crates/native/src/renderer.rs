//! Implementations and definitions of the renderers API for C and C++ APIs.

pub use frame_handler::FrameHandler;

#[cfg(not(target_os = "macos"))]
/// Definitions and implementation of a handler for C++ API [`sys::VideoFrame`]s
/// renderer.
mod frame_handler {
    use cxx::UniquePtr;
    use derive_more::From;
    use libwebrtc_sys as sys;

    pub use cpp_api_bindings::{OnFrameCallbackInterface, VideoFrame};

    /// Handler for a [`sys::VideoFrame`]s renderer.
    pub struct FrameHandler(UniquePtr<OnFrameCallbackInterface>);

    impl FrameHandler {
        /// Returns new [`FrameHandler`] with the provided [`sys::VideoFrame`]s
        /// receiver.
        pub fn new(handler: *mut OnFrameCallbackInterface) -> Self {
            unsafe { Self(UniquePtr::from_raw(handler)) }
        }

        /// Passes provided [`sys::VideoFrame`] to the C++ side listener.
        pub fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
            self.0.pin_mut().on_frame(VideoFrame::from(frame));
        }
    }

    impl From<UniquePtr<sys::VideoFrame>> for VideoFrame {
        #[allow(clippy::cast_sign_loss)]
        fn from(frame: UniquePtr<sys::VideoFrame>) -> Self {
            let height = frame.height();
            let width = frame.width();

            assert!(height >= 0, "VideoFrame has a negative height");
            assert!(width >= 0, "VideoFrame has a negative width");

            let buffer_size = width * height * 4;

            Self {
                height: height as usize,
                width: width as usize,
                buffer_size: buffer_size as usize,
                rotation: frame.rotation().repr,
                frame: Box::new(Frame::from(Box::new(frame))),
            }
        }
    }

    /// Wrapper around a [`sys::VideoFrame`] transferable via FFI.
    #[derive(From)]
    pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

    #[allow(
        clippy::items_after_statements,
        clippy::trait_duplication_in_bounds,
        let_underscore_drop
    )]
    #[cxx::bridge]
    mod cpp_api_bindings {
        /// Single video `frame`.
        pub struct VideoFrame {
            /// Vertical count of pixels in this [`VideoFrame`].
            pub height: usize,

            /// Horizontal count of pixels in this [`VideoFrame`].
            pub width: usize,

            /// Rotation of this [`VideoFrame`] in degrees.
            pub rotation: i32,

            /// Size of the bytes buffer required for allocation of the
            /// [`VideoFrame::get_abgr_bytes()`] call.
            pub buffer_size: usize,

            /// Underlying Rust side frame.
            pub frame: Box<Frame>,
        }

        extern "Rust" {
            type Frame;

            /// Converts this [`api::VideoFrame`] pixel data to `ABGR` scheme
            /// and outputs the result to the provided `buffer`.
            #[cxx_name = "GetABGRBytes"]
            unsafe fn get_abgr_bytes(self: &VideoFrame, buffer: *mut u8);
        }

        unsafe extern "C++" {
            include!("flutter-webrtc-native/include/api.h");

            pub type OnFrameCallbackInterface;

            /// Calls C++ side `OnFrameCallbackInterface->OnFrame`.
            #[cxx_name = "OnFrame"]
            pub fn on_frame(
                self: Pin<&mut OnFrameCallbackInterface>,
                frame: VideoFrame,
            );
        }

        // This will trigger `cxx` to generate `UniquePtrTarget` trait for the
        // mentioned types.
        extern "Rust" {
            fn _touch_unique_ptr_on_frame_handler(
                i: UniquePtr<OnFrameCallbackInterface>,
            );
        }
    }

    fn _touch_unique_ptr_on_frame_handler(
        _: cxx::UniquePtr<OnFrameCallbackInterface>,
    ) {
    }

    impl cpp_api_bindings::VideoFrame {
        /// Converts this [`api::VideoFrame`] pixel data to the `ABGR` scheme
        /// and outputs the result to the provided `buffer`.
        ///
        /// # Safety
        ///
        /// The provided `buffer` must be a valid pointer.
        pub unsafe fn get_abgr_bytes(&self, buffer: *mut u8) {
            libwebrtc_sys::video_frame_to_abgr(self.frame.0.as_ref(), buffer);
        }
    }
}

#[cfg(target_os = "macos")]
/// Definitions and implementation of a handler for C API [`sys::VideoFrame`]s
/// renderer.
///
/// cbindgen:ignore
mod frame_handler {
    use cxx::UniquePtr;
    use libwebrtc_sys as sys;

    /// Handler for a [`sys::VideoFrame`]s renderer.
    pub struct FrameHandler(*const ());

    impl Drop for FrameHandler {
        fn drop(&mut self) {
            unsafe { drop_handler(self.0) };
        }
    }

    /// [`sys::VideoFrame`] and metadata which will be passed to the C API
    /// renderer.
    #[repr(C)]
    pub struct Frame {
        /// Height of the [`Frame`].
        pub height: usize,

        /// Width of the [`Frame`].
        pub width: usize,

        /// Rotation of the [`Frame`].
        pub rotation: i32,

        /// Size of the [`Frame`] buffer.
        pub buffer_size: usize,

        /// Actual [`sys::VideoFrame`].
        pub frame: *mut sys::VideoFrame,
    }

    impl FrameHandler {
        /// Returns new [`FrameHandler`] with the provided [`sys::VideoFrame`]s
        /// receiver.
        pub fn new(handler: *const ()) -> Self {
            Self(handler)
        }

        /// Passes the provided [`sys::VideoFrame`] to the C side listener.
        #[allow(clippy::cast_sign_loss)]
        pub fn on_frame(&self, frame: UniquePtr<sys::VideoFrame>) {
            let height = frame.height();
            let width = frame.width();

            assert!(height >= 0, "VideoFrame has a negative height");
            assert!(width >= 0, "VideoFrame has a negative width");

            let buffer_size = width * height * 4;
            unsafe {
                on_frame_caller(
                    self.0,
                    Frame {
                        height: height as usize,
                        width: width as usize,
                        buffer_size: buffer_size as usize,
                        rotation: frame.rotation().repr,
                        frame: UniquePtr::into_raw(frame),
                    },
                );
            }
        }
    }

    extern "C" {
        /// C side function into which [`Frame`]s will be passed.
        pub fn on_frame_caller(handler: *const (), frame: Frame);

        /// Destructor for the C side renderer.
        pub fn drop_handler(handler: *const ());
    }

    /// Converts the provided [`sys::VideoFrame`] pixel data to `ARGB` scheme
    /// and outputs the result to the provided `buffer`.
    ///
    /// # Safety
    ///
    /// The provided `buffer` must be a valid pointer.
    #[no_mangle]
    unsafe extern "C" fn get_argb_bytes(
        frame: *mut sys::VideoFrame,
        argb_stride: i32,
        buffer: *mut u8,
    ) {
        libwebrtc_sys::video_frame_to_argb(
            frame.as_ref().unwrap(),
            argb_stride,
            buffer,
        );
    }

    /// Drops the provided [`sys::VideoFrame`].
    #[no_mangle]
    unsafe extern "C" fn drop_frame(frame: *mut sys::VideoFrame) {
        UniquePtr::from_raw(frame);
    }
}
