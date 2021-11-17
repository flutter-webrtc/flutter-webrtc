#[cxx::bridge(namespace = "RTC")]
pub mod rtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        pub fn SystemTimeMillis() -> i64;
    }
}
