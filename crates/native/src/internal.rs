pub use cpp_api_bindings::*;

#[allow(clippy::items_after_statements)]
#[cxx::bridge]
mod cpp_api_bindings {
    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");
        include!("flutter-webrtc-native/src/lib.rs.h");

        pub type CreateSdpCallbackInterface;
        pub type SetDescriptionCallbackInterface;
        pub type OnFrameCallbackInterface;

        type VideoFrame = crate::api::VideoFrame;

        /// Calls C++ side `CreateSdpCallbackInterface->OnSuccess`.
        #[cxx_name = "OnSuccess"]
        pub fn on_create_sdp_success(
            self: Pin<&mut CreateSdpCallbackInterface>,
            sdp: &CxxString,
            kind: &CxxString,
        );

        /// Calls C++ side `CreateSdpCallbackInterface->OnFail`.
        #[cxx_name = "OnFail"]
        pub fn on_create_sdp_fail(
            self: Pin<&mut CreateSdpCallbackInterface>,
            error: &CxxString,
        );

        /// Calls C++ side `SetDescriptionCallbackInterface->OnSuccess`.
        #[cxx_name = "OnSuccess"]
        pub fn on_set_description_sucess(
            self: Pin<&mut SetDescriptionCallbackInterface>,
        );

        /// Calls C++ side `SetDescriptionCallbackInterface->OnFail`.
        #[cxx_name = "OnFail"]
        pub fn on_set_description_fail(
            self: Pin<&mut SetDescriptionCallbackInterface>,
            error: &CxxString,
        );

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
        fn _touch_create_sdp_callback(i: UniquePtr<CreateSdpCallbackInterface>);
        fn _touch_set_description_callback(
            i: UniquePtr<SetDescriptionCallbackInterface>,
        );
        fn _touch_unique_ptr_on_frame_handler(
            i: UniquePtr<OnFrameCallbackInterface>,
        );
    }
}

fn _touch_create_sdp_callback(_: cxx::UniquePtr<CreateSdpCallbackInterface>) {}

fn _touch_set_description_callback(
    _: cxx::UniquePtr<SetDescriptionCallbackInterface>,
) {
}

fn _touch_unique_ptr_on_frame_handler(
    _: cxx::UniquePtr<OnFrameCallbackInterface>,
) {
}
