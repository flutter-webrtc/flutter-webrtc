#include <memory>
#include <string>
#include <cstdint>

#include "libwebrtc-sys/include/bridge.h"
#include "rtc_base/time_utils.h"

namespace RTC {
  int64_t SystemTimeMillis() {
    return rtc::SystemTimeMillis();
  }
}  // namespace RTC
