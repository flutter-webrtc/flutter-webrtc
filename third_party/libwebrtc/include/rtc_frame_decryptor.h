
#ifndef LIB_RTC_FRAME_DECRYPTOR_HXX
#define LIB_RTC_FRAME_DECRYPTOR_HXX

#include "base/refcount.h"
#include "rtc_types.h"

namespace libwebrtc {

enum class DecryptResultStatus { kOk, kRecoverable, kFailedToDecrypt, kUnknown };

struct DecryptResult {
  DecryptResult(DecryptResultStatus status, size_t bytes_written)
      : status(status), bytes_written(bytes_written) {}

  bool IsOk() const { return status == DecryptResultStatus::kOk; }

  const DecryptResultStatus status;
  const size_t bytes_written;
};

typedef fixed_size_function<DecryptResult(
    RTCMediaType media_type,
    const portable::vector<uint32_t>& csrcs,
    portable::vector<const uint8_t> additional_data,
    portable::vector<const uint8_t> encrypted_frame,
    portable::vector<uint8_t> frame)>
    DecryptCallback;

typedef fixed_size_function<size_t(RTCMediaType media_type,
                                   size_t encrypted_frame_size)>
    GetMaxPlaintextByteSizeCallback;

class RTCFrameDecryptor : public RefCountInterface {
 public:
  static scoped_refptr<RTCFrameDecryptor> Create(
      DecryptCallback decrypt,
      GetMaxPlaintextByteSizeCallback get_max_plaintext_byte_size);
};

}  // namespace libwebrtc

#endif  // LIB_RTC_FRAME_DECRYPTOR_HXX
