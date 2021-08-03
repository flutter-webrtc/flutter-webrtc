#ifndef LIB_WEBRTC_RTP_RECEIVER_HXX
#define LIB_WEBRTC_RTP_RECEIVER_HXX

#include "base/refcount.h"
#include "base/scoped_ref_ptr.h"

#include "rtc_rtp_parameters.h"
#include "rtc_types.h"
#include "rtc_media_stream.h"

//#include "rtc_frame_decryptor.h"
//#include "rtc_frame_encryptor.h"

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

  virtual scoped_refptr<RTCStreamIds> stream_ids() const = 0;

  virtual scoped_refptr<RTCMediaStreams> streams() const = 0;

  virtual RTCMediaType media_type() const = 0;

  virtual const string id() const = 0;

  virtual scoped_refptr<RTCRtpParameters> parameters() const = 0;

  virtual bool set_parameters(scoped_refptr<RTCRtpParameters> parameters) = 0;

  virtual void SetObserver(RTCRtpReceiverObserver* observer) = 0;

  virtual void SetJitterBufferMinimumDelay(double delay_seconds) = 0;

  // virtual Vector<RtpSource> GetSources() const = 0;

  // virtual void SetFrameDecryptor(
  //    scoped_refptr<FrameDecryptor> frame_decryptor);

  // virtual scoped_refptr<FrameDecryptor> GetFrameDecryptor() const = 0;

  // virtual void SetDepacketizerToDecoderFrameTransformer(
  //    scoped_refptr<FrameTransformerInterface> frame_transformer) = 0;
};

class RTCRtpReceivers : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<RTCRtpReceivers> Create();
  virtual void Add(scoped_refptr<RTCRtpReceiver> value) = 0;
  virtual scoped_refptr<RTCRtpReceiver> Get(int index) = 0;
  virtual int Size() = 0;
  virtual void Remove(int index) = 0;
  virtual void Clean() = 0;
};
}  // namespace libwebrtc

#endif  // !LIB_WEBRTC_RTP_RECEIVER_H_