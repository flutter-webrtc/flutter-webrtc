#ifndef LIB_WEBRTC_RTC_ICE_CANDIDATE_HXX
#define LIB_WEBRTC_RTC_ICE_CANDIDATE_HXX

#include "rtc_types.h"

namespace libwebrtc {

class RTCIceCandidate : public RefCountInterface {
 public:
  virtual const char* candidate() const = 0;

  virtual const char* sdp_mid() const = 0;

  virtual int sdp_mline_index() const = 0;

  virtual bool ToString(char* buffer, int length) = 0;

 protected:
  virtual ~RTCIceCandidate() {}
};

LIB_WEBRTC_API scoped_refptr<RTCIceCandidate> CreateRTCIceCandidate(
    const char* sdp,
    const char* sdp_mid,
    int sdp_mline_index,
    SdpParseError* error);

};  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_ICE_CANDIDATE_HXX
