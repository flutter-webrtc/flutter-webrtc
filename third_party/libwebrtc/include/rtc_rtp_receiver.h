#ifndef LIB_WEBRTC_RTP_RECEIVER_HXX
#define LIB_WEBRTC_RTP_RECEIVER_HXX

#include "base/refcount.h"
#include "base/scoped_ref_ptr.h"

#include "rtc_rtp_parameters.h"
#include "rtc_types.h"

namespace libwebrtc {

class RTCMediaTrack;
class RTCMediaStream;
class RTCDtlsTransport;

class RTCRtpReceiverObserver {
 public:
  virtual void OnFirstPacketReceived(RTCMediaType media_type) = 0;

 protected:
  virtual ~RTCRtpReceiverObserver() {}
};

class RTCRtpReceiver : public RefCountInterface {
 public:
  virtual scoped_refptr<RTCMediaTrack> track() const = 0;

  virtual scoped_refptr<RTCDtlsTransport> dtls_transport() const = 0;

  virtual const vector<string> stream_ids() const = 0;

  virtual vector<scoped_refptr<RTCMediaStream>> streams() const = 0;

  virtual RTCMediaType media_type() const = 0;

  virtual const string id() const = 0;

  virtual scoped_refptr<RTCRtpParameters> parameters() const = 0;

  virtual bool set_parameters(scoped_refptr<RTCRtpParameters> parameters) = 0;

  virtual void SetObserver(RTCRtpReceiverObserver* observer) = 0;

  virtual void SetJitterBufferMinimumDelay(double delay_seconds) = 0;

};

}  // namespace libwebrtc

#endif  // !LIB_WEBRTC_RTP_RECEIVER_H_