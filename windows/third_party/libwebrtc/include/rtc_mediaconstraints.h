#ifndef LIB_WEBRTC_RTC_MEDIA_CONSTRAINTS_HXX
#define LIB_WEBRTC_RTC_MEDIA_CONSTRAINTS_HXX

#include "rtc_types.h"

namespace libwebrtc {

class RTCMediaConstraints : public RefCountInterface {
 public:
  /** Constraint keys for media sources. */
  LIB_WEBRTC_API static const char* kMinAspectRatio;
  LIB_WEBRTC_API static const char* kMaxAspectRatio;
  LIB_WEBRTC_API static const char* kMaxWidth;
  LIB_WEBRTC_API static const char* kMinWidth;
  LIB_WEBRTC_API static const char* kMaxHeight;
  LIB_WEBRTC_API static const char* kMinHeight;
  LIB_WEBRTC_API static const char* kMaxFrameRate;
  LIB_WEBRTC_API static const char* kMinFrameRate;
  /** The value for this key should be a base64 encoded string containing
   *  the data from the serialized configuration proto.
   */
  LIB_WEBRTC_API static const char* kAudioNetworkAdaptorConfig;

  /** Constraint keys for generating offers and answers. */
  LIB_WEBRTC_API static const char* kIceRestart;
  LIB_WEBRTC_API static const char* kOfferToReceiveAudio;
  LIB_WEBRTC_API static const char* kOfferToReceiveVideo;
  LIB_WEBRTC_API static const char* kVoiceActivityDetection;

  /** Constraint values for Boolean parameters. */
  LIB_WEBRTC_API static const char* kValueTrue;
  LIB_WEBRTC_API static const char* kValueFalse;

 public:
  LIB_WEBRTC_API static scoped_refptr<RTCMediaConstraints> Create();

  virtual void AddMandatoryConstraint(const char* key, const char* value) = 0;

  virtual void AddOptionalConstraint(const char* key, const char* value) = 0;

 protected:
  virtual ~RTCMediaConstraints() {}
};

};  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_MEDIA_CONSTRAINTS_HXX
