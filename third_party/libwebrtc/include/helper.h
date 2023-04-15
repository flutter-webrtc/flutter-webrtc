#ifndef HELPER_HXX
#define HELPER_HXX

#include "rtc_types.h"

namespace libwebrtc {
/**
 * @brief A helper class with static methods for generating random UUIDs.
 *
 */
class Helper {
 public:
  /**
   * @brief Generates a random UUID string.
   *
   * @return The generated UUID string.
   */
  LIB_WEBRTC_API static string CreateRandomUuid();
};
}  // namespace libwebrtc

#endif  // HELPER_HXX
