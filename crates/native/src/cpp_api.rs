use crate::Frame;

pub use self::cpp_api_bindings::*;

#[allow(
    clippy::items_after_statements,
    clippy::let_underscore_drop,
    clippy::trait_duplication_in_bounds
)]
#[cxx::bridge]
mod cpp_api_bindings {
    /// Single video frame.
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

        /// Converts this [`api::VideoFrame`] pixel data to `ABGR` scheme and
        /// outputs the result to the provided `buffer`.
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
