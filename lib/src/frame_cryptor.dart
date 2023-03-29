import 'dart:typed_data';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'native/frame_cryptor_impl.dart'
    if (dart.library.html) 'web/frame_cryptor_impl.dart';

/// Built-in Algorithm.
enum Algorithm {
  kAesGcm,
  kAesCbc,
}

class KeyProviderOptions {
  KeyProviderOptions({
    required this.sharedKey,
    required this.ratchetSalt,
    required this.ratchetWindowSize,
  });
  bool sharedKey;
  Uint8List ratchetSalt;
  int ratchetWindowSize;
  Map<String, dynamic> toJson() {
    return {
      'sharedKey': sharedKey,
      'ratchetSalt': ratchetSalt,
      'ratchetWindowSize': ratchetWindowSize,
    };
  }
}

/// Shared secret key for frame encryption.
abstract class KeyManager {
  /// The unique identifier of the key manager.
  String get id;

  /// Set the raw key at the given index.
  Future<bool> setKey({
    required String participantId,
    required int index,
    required Uint8List key,
  });

  /// ratchet the key at the given index.
  Future<Uint8List> ratchetKey({
    required String participantId,
    required int index,
  });

  /// Dispose the key manager.
  Future<void> dispose();
}

enum FrameCryptorState {
  FrameCryptorStateNew,
  FrameCryptorStateOk,
  FrameCryptorStateEncryptionFailed,
  FrameCryptorStateDecryptionFailed,
  FrameCryptorStateMissingKey,
  FrameCryptorStateKeyRatcheted,
  FrameCryptorStateInternalError,
}

/// Frame encryption/decryption.
///
abstract class FrameCryptor {
  FrameCryptor();

  Function(String participantId, FrameCryptorState state)?
      onFrameCryptorStateChanged;

  /// The unique identifier of the frame cryptor.
  String get participantId;

  /// Enable/Disable frame crypto for the sender or receiver.
  Future<bool> setEnabled(bool enabled);

  /// Get the enabled state for the sender or receiver.
  Future<bool> get enabled;

  /// Set the key index for the sender or receiver.
  /// If the key index is not set, the key index will be set to 0.
  Future<bool> setKeyIndex(int index);

  /// Get the key index for the sender or receiver.
  Future<int> get keyIndex;

  Future<void> updateCodec(String codec);

  /// Dispose the frame cryptor.
  Future<void> dispose();
}

/// Factory for creating frame Cryptors.
/// For End 2 End Encryption, you need to create a [KeyManager] for each peer.
/// And set your key in keyManager.
abstract class FrameCryptorFactory {
  /// Shared key manager.
  Future<KeyManager> createDefaultKeyManager(KeyProviderOptions options);

  /// Create a frame Cryptor from a [RTCRtpSender].
  Future<FrameCryptor> createFrameCryptorForRtpSender({
    required String participantId,
    required RTCRtpSender sender,
    required Algorithm algorithm,
    required KeyManager keyManager,
  });

  /// Create a frame Cryptor from a [RTCRtpReceiver].
  Future<FrameCryptor> createFrameCryptorForRtpReceiver({
    required String participantId,
    required RTCRtpReceiver receiver,
    required Algorithm algorithm,
    required KeyManager keyManager,
  });

  static final FrameCryptorFactory instance = FrameCryptorFactoryImpl.instance;
}
