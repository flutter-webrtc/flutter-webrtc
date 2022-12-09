
#ifndef LIB_RTC_FRAME_ENCRYPTOR_HXX
#define LIB_RTC_FRAME_ENCRYPTOR_HXX

#include "base/refcount.h"
#include "rtc_types.h"

namespace libwebrtc {

typedef fixed_size_function<int(RTCMediaType media_type,
                                uint32_t ssrc,
                                portable::vector<const uint8_t> additional_data,
                                portable::vector<const uint8_t> frame,
                                portable::vector<uint8_t> encrypted_frame,
                                size_t* bytes_written)>
    EncryptCallback;

typedef fixed_size_function<size_t(RTCMediaType media_type, size_t frame_size)>
    GetMaxCiphertextByteSizeCallback;

class RTCFrameEncryptor : public RefCountInterface {
 public:
 static scoped_refptr<RTCFrameEncryptor> Create(
      EncryptCallback encrypt,
      GetMaxCiphertextByteSizeCallback get_max_ciphertext_byte_size);
};

}  // namespace libwebrtc

#endif  // LIB_RTC_FRAME_ENCRYPTOR_HXX
