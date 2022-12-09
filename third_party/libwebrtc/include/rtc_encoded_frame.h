#ifndef RTC_ENCODE_FRAME_HXX
#define RTC_ENCODE_FRAME_HXX

#include "media_manager_types.h"

namespace libwebrtc {

class RTCEncodedFrame : public RefCountInterface {
 public:
  virtual RTCMediaType media_type() = 0;

  virtual RTCVideoFrameType frame_type() = 0;

  virtual uint32_t timestamp() = 0;

  virtual uint32_t ssrc() = 0;

  virtual string mime_type() = 0;

  virtual const vector<uint8_t>& data() = 0;

  virtual void set_data(const vector<uint8_t>& data) = 0;
};

};  // namespace libwebrtc

#endif // RTC_ENCODE_FRAME_HXX