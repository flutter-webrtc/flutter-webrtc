use libwebrtc_sys::system_time_millis;

#[no_mangle]
pub extern "C" fn SystemTimeMillis() -> i64 {
    system_time_millis()
}
