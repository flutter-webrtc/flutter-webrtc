#ifndef LIB_WEBRTC_RTC_SESSION_DESCRIPTION_HXX
#define LIB_WEBRTC_RTC_SESSION_DESCRIPTION_HXX

#include "rtc_types.h"

namespace libwebrtc {

class RTCSessionDescription : public RefCountInterface {
 public:
  enum SdpType { kOffer = 0, kPrAnswer, kAnswer };

 public:
  virtual const char* sdp() const = 0;

  virtual SdpType GetType() = 0;

  virtual const char* type() = 0;

  virtual bool ToString(char* buffer, int length) = 0;

 protected:
  virtual ~RTCSessionDescription() {}
};

LIB_WEBRTC_API scoped_refptr<RTCSessionDescription> CreateRTCSessionDescription(
    const char* type,
    const char* sdp,
    SdpParseError* error);

};  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_SESSION_DESCRIPTION_HXX