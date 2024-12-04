#ifndef LIB_RTC_FRAME_CYRPTOR_H_
#define LIB_RTC_FRAME_CYRPTOR_H_

#include "base/refcount.h"
#include "rtc_peerconnection_factory.h"
#include "rtc_rtp_receiver.h"
#include "rtc_rtp_sender.h"
#include "rtc_types.h"

namespace libwebrtc {

enum class Algorithm {
  kAesGcm = 0,
  kAesCbc,
};

#define DEFAULT_KEYRING_SIZE 16
#define MAX_KEYRING_SIZE 255

struct KeyProviderOptions {
  bool shared_key;
  vector<uint8_t> ratchet_salt;
  vector<uint8_t> uncrypted_magic_bytes;
  int ratchet_window_size;
  int failure_tolerance;
  // The size of the key ring. between 1 and 255.
  int key_ring_size;
  bool discard_frame_when_cryptor_not_ready;
  KeyProviderOptions()
      : shared_key(false),
        ratchet_salt(vector<uint8_t>()),
        ratchet_window_size(0),
        failure_tolerance(-1),
        key_ring_size(DEFAULT_KEYRING_SIZE),
        discard_frame_when_cryptor_not_ready(false) {}
  KeyProviderOptions(KeyProviderOptions& copy)
      : shared_key(copy.shared_key),
        ratchet_salt(copy.ratchet_salt),
        ratchet_window_size(copy.ratchet_window_size),
        failure_tolerance(copy.failure_tolerance),
        key_ring_size(copy.key_ring_size) {}
};

/// Shared secret key for frame encryption.
class KeyProvider : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<KeyProvider> Create(KeyProviderOptions*);

  virtual bool SetSharedKey(int index, vector<uint8_t> key) = 0;

  virtual vector<uint8_t> RatchetSharedKey(int key_index) = 0;

  virtual vector<uint8_t> ExportSharedKey(int key_index) = 0;

  /// Set the key at the given index.
  virtual bool SetKey(const string participant_id, int index,
                      vector<uint8_t> key) = 0;

  virtual vector<uint8_t> RatchetKey(const string participant_id,
                                     int key_index) = 0;

  virtual vector<uint8_t> ExportKey(const string participant_id,
                                    int key_index) = 0;

  virtual void SetSifTrailer(vector<uint8_t> trailer) = 0;

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

class RTCFrameCryptorObserver : public RefCountInterface {
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
      scoped_refptr<RTCFrameCryptorObserver> observer) = 0;

  virtual void DeRegisterRTCFrameCryptorObserver() = 0;

 protected:
  virtual ~RTCFrameCryptor() {}
};

class FrameCryptorFactory {
 public:
  /// Create a frame cyrptor for [RTCRtpSender].
  LIB_WEBRTC_API static scoped_refptr<RTCFrameCryptor>
  frameCryptorFromRtpSender(scoped_refptr<RTCPeerConnectionFactory> factory,
                            const string participant_id,
                            scoped_refptr<RTCRtpSender> sender,
                            Algorithm algorithm,
                            scoped_refptr<KeyProvider> key_provider);

  /// Create a frame cyrptor for [RTCRtpReceiver].
  LIB_WEBRTC_API static scoped_refptr<RTCFrameCryptor>
  frameCryptorFromRtpReceiver(scoped_refptr<RTCPeerConnectionFactory> factory,
                              const string participant_id,
                              scoped_refptr<RTCRtpReceiver> receiver,
                              Algorithm algorithm,
                              scoped_refptr<KeyProvider> key_provider);
};

}  // namespace libwebrtc

#endif  // LIB_RTC_FRAME_CYRPTOR_H_