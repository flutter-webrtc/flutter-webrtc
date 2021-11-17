mod bridge;

use self::bridge::rtc;

#[must_use]
pub fn system_time_millis() -> i64 {
    rtc::SystemTimeMillis()
}

#[cfg(test)]
mod test {
    use super::system_time_millis;

    #[test]
    fn it_works() {
        let a = system_time_millis();
        let b = system_time_millis();

        assert!((a - b).abs() < 5);
    }
}
