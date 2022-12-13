#ifndef LIB_RTC_FRAME_CYRPTOR_H_
#define LIB_RTC_FRAME_CYRPTOR_H_

#include "base/refcount.h"
#include "rtc_rtp_receiver.h"
#include "rtc_rtp_sender.h"
#include "rtc_types.h"

namespace libwebrtc {

enum class Algorithm {
  kAesGcm = 0,
  kAesCbc,
};

/// Shared secret key for frame encryption.
class KeyManager : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<KeyManager> Create();

  /// Set the key at the given index.
  virtual bool SetKey(int index, vector<uint8_t> key) = 0;

  /// Set the keys.
  virtual bool SetKeys(vector<vector<uint8_t>> keys) = 0;

  /// Get the keys.
  virtual const vector<vector<uint8_t>> GetKeys() const = 0;

 protected:
  virtual ~KeyManager() {}
};

/// Frame encryption/decryption.
///
class RTCFrameCryptor : public RefCountInterface {
 public:
  /// Enable/Disable frame crypto for the sender or receiver.
  virtual bool SetEnabled(bool enabled) = 0;

  /// Get the enabled state for the sender or receiver.
  virtual bool enabled() const = 0;

  /// Set the key index for the sender or receiver.
  /// If the key index is not set, the key index will be set to 0.
  virtual bool SetKeyIndex(int index) = 0;

  /// Get the key index for the sender or receiver.
  virtual int key_index() const = 0;

 protected:
  virtual ~RTCFrameCryptor() {}
};

class FrameCryptorFactory {
public:
  /// Create a frame cyrptor from a [RTCRtpSender].
  LIB_WEBRTC_API static scoped_refptr<RTCFrameCryptor>
  frameCryptorFromRtpSender(scoped_refptr<RTCRtpSender> sender,
                            Algorithm algorithm,
                            scoped_refptr<KeyManager> keyManager);

  /// Create a frame cyrptor from a [RTCRtpReceiver].
  LIB_WEBRTC_API static scoped_refptr<RTCFrameCryptor>
  frameCryptorFromRtpReceiver(scoped_refptr<RTCRtpReceiver> receiver,
                              Algorithm algorithm,
                              scoped_refptr<KeyManager> keyManager);
};

}  // namespace libwebrtc

#endif  // LIB_RTC_FRAME_CYRPTOR_H_