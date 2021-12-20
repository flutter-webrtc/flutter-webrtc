use libwebrtc_sys::system_time_millis;

/// Module describing a bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
    extern "Rust" {
        #[cxx_name = "SystemTimeMillis"]
        fn system_time_millis() -> i64;

        #[cxx_name = "ReturnRustVec"]
        fn return_rust_vec() -> Vec<u64>;
    }
}

// TODO: For demonstration purposes only, will be remove in the next PR.
fn return_rust_vec() -> Vec<u64> {
    vec![1, 2, 3]
}
