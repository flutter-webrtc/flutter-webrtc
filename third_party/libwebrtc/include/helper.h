#ifndef HELPER_HXX
#define HELPER_HXX

#include "rtc_types.h"

namespace libwebrtc {
class Helper {
 public:
  LIB_WEBRTC_API static string CreateRandomUuid();
};
}  // namespace libwebrtc

#endif  // HELPER_HXX
