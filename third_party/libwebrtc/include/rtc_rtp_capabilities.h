#ifndef LIB_WBBRTC_RTC_RTP_CAPABILITIES_HXX
#define LIB_WBBRTC_RTC_RTP_CAPABILITIES_HXX

#include "base/refcount.h"
#include "base/scoped_ref_ptr.h"

#include "rtc_rtp_parameters.h"
#include "rtc_types.h"


namespace libwebrtc {

class RTCRtpCodecCapability : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<RTCRtpCodecCapability> Create();

  virtual void set_mime_type(const string& mime_type) = 0;
  virtual void set_clock_rate(int clock_rate) = 0;
  virtual void set_channels(int channels) = 0;
  virtual void set_sdp_fmtp_line(const string& sdp_fmtp_line) = 0;

  virtual string mime_type() const = 0;
  virtual int clock_rate() const = 0;
  virtual int channels() const = 0;
  virtual string sdp_fmtp_line() const = 0;

 protected:
  virtual ~RTCRtpCodecCapability() {}
};

class RTCRtpHeaderExtensionCapability : public RefCountInterface {
public:
  virtual const string uri() = 0;
  virtual void set_uri(const string uri) = 0;

  virtual int preferred_id() = 0;
  virtual void set_preferred_id(int value) = 0;

  virtual bool preferred_encrypt() = 0;
  virtual void set_preferred_encrypt(bool value) = 0;
};

class RTCRtpCapabilities : public RefCountInterface {
public:
  virtual const vector<scoped_refptr<RTCRtpCodecCapability>> codecs() = 0;
  virtual void set_codecs(
      const vector<scoped_refptr<RTCRtpCodecCapability>> codecs) = 0;

  virtual const vector<scoped_refptr<RTCRtpHeaderExtensionCapability>>
  header_extensions() = 0;

  virtual void set_header_extensions(
      const vector<scoped_refptr<RTCRtpHeaderExtensionCapability>>
          header_extensions) = 0;

  //virtual const vector<scoped_refptr<RTCFecMechanism>> fec() = 0;
  //virtual void set_fec(const vector<scoped_refptr<RTCFecMechanism>> fec) = 0;
};

}  // namespace libwebrtc

#endif  // LIB_WBBRTC_RTC_RTP_CAPABILITIES_HXX
