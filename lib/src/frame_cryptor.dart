import 'dart:typed_data';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'native/frame_cryptor_impl.dart';

/// Built-in Algorithm.
enum Algorithm {
  kAes128Gcm,
  kAes256Gcm,
  kAes128Cbc,
  kAes256Cbc,
}

/// Shared secret key for frame encryption.
abstract class KeyManager {
  /// The unique identifier of the key manager.
  String get id;

  /// Set the key at the given index.
  Future<bool> setKey(int index, Uint8List key);

  /// Set the keys.
  Future<bool> setKeys(List<Uint8List> keys);

  /// Get the keys.
  Future<List<Uint8List>> get keys;

  /// Dispose the key manager.
  Future<void> dispose();
}

/// Frame encryption/decryption.
///
abstract class FrameCyrptor {
  /// Enable/Disable frame crypto for the sender or receiver.
  Future<bool> setEnabled(bool enabled);

  /// Get the enabled state for the sender or receiver.
  Future<bool> get enabled;

  /// Set the key index for the sender or receiver.
  /// If the key index is not set, the key index will be set to 0.
  Future<bool> setKeyIndex(int index);

  /// Get the key index for the sender or receiver.
  Future<int> get keyIndex;

  /// Get the sender.
  RTCRtpSender? get sender => null;

  /// Get the receiver.
  RTCRtpReceiver? get receiver => null;
}

/// Factory for creating frame cyrptors.
/// For End 2 End Encryption, you need to create a [KeyManager] for each peer.
/// And set your key in keyManager.
abstract class FrameCyrptorFactory {
  /// Shared key manager.
  Future<KeyManager> createDefaultKeyManager();

  /// Create a frame cyrptor from a [RTCRtpSender].
  Future<FrameCyrptor> frameCyrptorFromRtpSender({
    required RTCRtpSender sender,
    required Algorithm algorithm,
    required KeyManager keyManager,
  });

  /// Create a frame cyrptor from a [RTCRtpReceiver].
  Future<FrameCyrptor> frameCyrptorFromRtpReceiver({
    required RTCRtpReceiver receiver,
    required Algorithm algorithm,
    required KeyManager keyManager,
  });

  static final FrameCyrptorFactory instance = FrameCyrptorFactoryImpl.instance;
}
