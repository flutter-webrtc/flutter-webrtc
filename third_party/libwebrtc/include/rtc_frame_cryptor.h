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

struct KeyProviderOptions {
  bool shared_key;
  vector<uint8_t> ratchet_salt;
  vector<uint8_t> uncrypted_magic_bytes;
  int ratchet_window_size;
  KeyProviderOptions()
      : shared_key(false),
        ratchet_salt(vector<uint8_t>()),
        ratchet_window_size(0) {}
  KeyProviderOptions(KeyProviderOptions& copy)
      : shared_key(copy.shared_key),
        ratchet_salt(copy.ratchet_salt),
        ratchet_window_size(copy.ratchet_window_size) {}
};

/// Shared secret key for frame encryption.
class KeyProvider : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<KeyProvider> Create(KeyProviderOptions*);

  /// Set the key at the given index.
  virtual bool SetKey(const string participant_id,
                      int index,
                      vector<uint8_t> key) = 0;

  virtual vector<uint8_t> RatchetKey(const string participant_id,
                                     int key_index) = 0;

  virtual vector<uint8_t> ExportKey(const string participant_id,
                                    int key_index) = 0;

 protected:
  virtual ~KeyProvider() {}
};

enum RTCFrameCryptionState {
  kNew = 0,
  kOk,
  kEncryptionFailed,
  kDecryptionFailed,
  kMissingKey,
  kKeyRatcheted,
  kInternalError,
};

class RTCFrameCryptorObserver {
 public:
  virtual void OnFrameCryptionStateChanged(const string participant_id,
                                           RTCFrameCryptionState state) = 0;

 protected:
  virtual ~RTCFrameCryptorObserver() {}
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

  virtual const string participant_id() const = 0;

  virtual void RegisterRTCFrameCryptorObserver(
      RTCFrameCryptorObserver* observer) = 0;

  virtual void DeRegisterRTCFrameCryptorObserver() = 0;

 protected:
  virtual ~RTCFrameCryptor() {}
};

class FrameCryptorFactory {
 public:
  /// Create a frame cyrptor for [RTCRtpSender].
  LIB_WEBRTC_API static scoped_refptr<RTCFrameCryptor>
  frameCryptorFromRtpSender(const string participant_id,
                            scoped_refptr<RTCRtpSender> sender,
                            Algorithm algorithm,
                            scoped_refptr<KeyProvider> key_provider);

  /// Create a frame cyrptor for [RTCRtpReceiver].
  LIB_WEBRTC_API static scoped_refptr<RTCFrameCryptor>
  frameCryptorFromRtpReceiver(const string participant_id,
                              scoped_refptr<RTCRtpReceiver> receiver,
                              Algorithm algorithm,
                              scoped_refptr<KeyProvider> key_provider);
};

}  // namespace libwebrtc

#endif  // LIB_RTC_FRAME_CYRPTOR_H_