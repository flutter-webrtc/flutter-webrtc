import 'dart:html';
import 'dart:js';
import 'dart:js_util' as jsutil;
import 'dart:math';
import 'dart:typed_data';
import 'dart:collection';

import 'package:flutter_webrtc/src/web/rtc_transform_stream.dart';

import 'crypto.dart' as crypto;
import 'e2ee.utils.dart';

class KeyOptions {
  KeyOptions({
    required this.sharedKey,
    required this.ratchetSalt,
    required this.ratchetWindowSize,
  });
  bool sharedKey;
  Uint8List ratchetSalt;
  int ratchetWindowSize;

  @override
  String toString() {
    return 'KeyOptions{sharedKey: $sharedKey, ratchetWindowSize: $ratchetWindowSize}';
  }
}

const IV_LENGTH = 12;

const kNaluTypeMask = 0x1f;

/// Coded slice of a non-IDR picture
const SLICE_NON_IDR = 1;

/// Coded slice data partition A
const SLICE_PARTITION_A = 2;

/// Coded slice data partition B
const SLICE_PARTITION_B = 3;

/// Coded slice data partition C
const SLICE_PARTITION_C = 4;

/// Coded slice of an IDR picture
const SLICE_IDR = 5;

/// Supplemental enhancement information
const SEI = 6;

/// Sequence parameter set
const SPS = 7;

/// Picture parameter set
const PPS = 8;

/// Access unit delimiter
const AUD = 9;

/// End of sequence
const END_SEQ = 10;

/// End of stream
const END_STREAM = 11;

/// Filler data
const FILLER_DATA = 12;

/// Sequence parameter set extension
const SPS_EXT = 13;

/// Prefix NAL unit
const PREFIX_NALU = 14;

/// Subset sequence parameter set
const SUBSET_SPS = 15;

/// Depth parameter set
const DPS = 16;

// 17, 18 reserved

/// Coded slice of an auxiliary coded picture without partitioning
const SLICE_AUX = 19;

/// Coded slice extension
const SLICE_EXT = 20;

/// Coded slice extension for a depth view component or a 3D-AVC texture view component
const SLICE_LAYER_EXT = 21;

// 22, 23 reserved

List<int> findNALUIndices(Uint8List stream) {
  var result = <int>[];
  var start = 0, pos = 0, searchLength = stream.length - 2;
  while (pos < searchLength) {
    // skip until end of current NALU
    while (pos < searchLength &&
        !(stream[pos] == 0 && stream[pos + 1] == 0 && stream[pos + 2] == 1)) {
      pos++;
    }
    if (pos >= searchLength) pos = stream.length;
    // remove trailing zeros from current NALU
    var end = pos;
    while (end > start && stream[end - 1] == 0) {
      end--;
    }
    // save current NALU
    if (start == 0) {
      if (end != start) throw Exception('byte stream contains leading data');
    } else {
      result.add(start);
    }
    // begin new NALU
    start = pos = pos + 3;
  }
  return result;
}

int parseNALUType(int startByte) {
  return startByte & kNaluTypeMask;
}

enum CryptorError {
  kNew,
  kOk,
  kDecryptError,
  kEncryptError,
  kUnsupportedCodec,
  kMissingKey,
  kKeyRatcheted,
  kInternalError,
  kDisposed,
}

const KEYRING_SIZE = 16;

class KeySet {
  KeySet(this.material, this.encryptionKey);
  CryptoKey material;
  CryptoKey encryptionKey;
}

class Cryptor {
  Cryptor(
      {required this.worker,
      required this.participantId,
      required this.trackId,
      required this.keyOptions});
  Map<int, int> sendCounts = {};
  String? participantId;
  String? trackId;
  String? codec;
  final KeyOptions keyOptions;
  late String kind;
  bool enabled = false;
  CryptorError lastError = CryptorError.kNew;
  final DedicatedWorkerGlobalScope worker;
  int currentKeyIndex = 0;

  final queue = Queue<RTCEncodedFrame>();
  bool ratchetInProgress = false;

  List<KeySet?> cryptoKeyRing = List.filled(KEYRING_SIZE, null);

  Future<void> ratchetKey(int? keyIndex) async {
    var currentMaterial = getKeySet(keyIndex)?.material;
    if (currentMaterial == null) {
      return;
    }
    var newMaterial = await ratchetMaterial(currentMaterial);
    var newKeySet = await deriveKeys(newMaterial, keyOptions.ratchetSalt);
    await setKeySetFromMaterial(newKeySet, keyIndex ?? currentKeyIndex);
  }

  Future<CryptoKey> ratchetMaterial(CryptoKey currentMaterial) async {
    var newMaterial = await jsutil.promiseToFuture(crypto.importKey(
      'raw',
      crypto.jsArrayBufferFrom(
          await ratchet(currentMaterial, keyOptions.ratchetSalt)),
      (currentMaterial.algorithm as crypto.Algorithm).name,
      false,
      ['deriveBits', 'deriveKey'],
    ));
    return newMaterial;
  }

  KeySet? getKeySet(int? keyIndex) {
    return cryptoKeyRing[keyIndex ?? currentKeyIndex];
  }

  void setParticipantId(String participantId) {
    if (lastError != CryptorError.kOk) {
      print(
          'setParticipantId: lastError != CryptorError.kOk, reset state to kNew');
      lastError = CryptorError.kNew;
    }
    this.participantId = participantId;
  }

  void setKeyIndex(int keyIndex) {
    if (lastError != CryptorError.kOk) {
      print('setKeyIndex: lastError != CryptorError.kOk, reset state to kNew');
      lastError = CryptorError.kNew;
    }
    currentKeyIndex = keyIndex;
  }

  void setEnabled(bool enabled) {
    if (lastError != CryptorError.kOk) {
      print(
          'setEnabled[$enabled]: lastError != CryptorError.kOk, reset state to kNew');
      lastError = CryptorError.kNew;
    }
    this.enabled = enabled;
  }

  Future<void> setKey(int keyIndex, Uint8List key) async {
    if (lastError != CryptorError.kOk) {
      print('setKey: lastError != CryptorError.kOk, reset state to kNew');
      lastError = CryptorError.kNew;
    }
    var keyMaterial = await crypto.impportKeyFromRawData(key,
        webCryptoAlgorithm: 'PBKDF2', keyUsages: ['deriveBits', 'deriveKey']);
    var keySet = await deriveKeys(
      keyMaterial,
      keyOptions.ratchetSalt,
    );
    await setKeySetFromMaterial(keySet, keyIndex);
  }

  Future<void> setKeySetFromMaterial(KeySet keySet, int keyIndex) async {
    print('setting new key');
    if (keyIndex >= 0) {
      currentKeyIndex = keyIndex % cryptoKeyRing.length;
    }
    cryptoKeyRing[currentKeyIndex] = keySet;
  }

  /// Derives a set of keys from the master key.
  /// See https://tools.ietf.org/html/draft-omara-sframe-00#section-4.3.1
  Future<KeySet> deriveKeys(CryptoKey material, Uint8List salt) async {
    var algorithmOptions =
        getAlgoOptions((material.algorithm as crypto.Algorithm).name, salt);

    // https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/deriveKey#HKDF
    // https://developer.mozilla.org/en-US/docs/Web/API/HkdfParams
    var encryptionKey =
        await jsutil.promiseToFuture<CryptoKey>(crypto.deriveKey(
      jsutil.jsify(algorithmOptions),
      material,
      jsutil.jsify({'name': 'AES-GCM', 'length': 128}),
      false,
      ['encrypt', 'decrypt'],
    ));

    return KeySet(material, encryptionKey);
  }

  /// Ratchets a key. See
  /// https://tools.ietf.org/html/draft-omara-sframe-00#section-4.3.5.1

  Future<Uint8List> ratchet(CryptoKey material, Uint8List salt) async {
    var algorithmOptions = getAlgoOptions('PBKDF2', salt);

    // https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/deriveBits
    var newKey = await jsutil.promiseToFuture<ByteBuffer>(
        crypto.deriveBits(jsutil.jsify(algorithmOptions), material, 256));
    return newKey.asUint8List();
  }

  void updateCodec(String codec) {
    if (lastError != CryptorError.kOk) {
      print(
          'updateCodec[$codec]: lastError != CryptorError.kOk, reset state to kNew');
      lastError = CryptorError.kNew;
    }
    this.codec = codec;
  }

  Uint8List makeIv(
      {required int synchronizationSource, required int timestamp}) {
    var iv = ByteData(IV_LENGTH);

    // having to keep our own send count (similar to a picture id) is not ideal.
    if (sendCounts[synchronizationSource] == null) {
      // Initialize with a random offset, similar to the RTP sequence number.
      sendCounts[synchronizationSource] = Random.secure().nextInt(0xffff);
    }

    var sendCount = sendCounts[synchronizationSource] ?? 0;

    iv.setUint32(0, synchronizationSource);
    iv.setUint32(4, timestamp);
    iv.setUint32(8, timestamp - (sendCount % 0xffff));

    sendCounts[synchronizationSource] = sendCount + 1;

    return iv.buffer.asUint8List();
  }

  void postMessage(Object message) {
    worker.postMessage(message);
  }

  Future<void> setupTransform({
    required String operation,
    required ReadableStream readable,
    required WritableStream writable,
    required String trackId,
    required String kind,
    String? codec,
  }) async {
    print('setupTransform $operation');
    this.kind = kind;
    if (codec != null) {
      print('setting codec on cryptor to $codec');
      this.codec = codec;
    }
    var transformer = TransformStream(jsutil.jsify({
      'transform':
          allowInterop(operation == 'encode' ? encodeFunction : decodeFunction)
    }));
    try {
      readable.pipeThrough(transformer).pipeTo(writable);
    } catch (e) {
      print('e ${e.toString()}');
      if (lastError != CryptorError.kInternalError) {
        lastError = CryptorError.kInternalError;
        postMessage({
          'type': 'cryptorState',
          'participantId': participantId,
          'state': 'internalError',
          'error': 'Internal error: ${e.toString()}'
        });
      }
    }
    this.trackId = trackId;
  }

  int getUnencryptedBytes(RTCEncodedFrame frame, String? codec) {
    if (codec != null && codec.toLowerCase() == 'h264') {
      var data = frame.data.asUint8List();
      var naluIndices = findNALUIndices(data);
      for (var index in naluIndices) {
        var type = parseNALUType(data[index]);
        switch (type) {
          case SLICE_IDR:
          case SLICE_NON_IDR:
            // skipping
            //print('unEncryptedBytes NALU of type $type, offset ${index + 2}');
            return index + 2;
          default:
            //print('skipping NALU of type $type');
            break;
        }
      }
      throw Exception('Could not find NALU');
    }
    switch (frame.type) {
      case 'key':
        return 10;
      case 'delta':
        return 3;
      case 'audio':
        return 1; // frame.type is not set on audio, so this is set manually
      default:
        return 0;
    }
  }

  Future<void> encodeFunction(
    RTCEncodedFrame frame,
    TransformStreamDefaultController controller,
  ) async {
    var buffer = frame.data.asUint8List();

    if (!enabled ||
        // skip for encryption for empty dtx frames
        buffer.isEmpty) {
      controller.enqueue(frame);
      return;
    }

    var secretKey = getKeySet(currentKeyIndex)?.encryptionKey;
    var keyIndex = currentKeyIndex;

    if (secretKey == null) {
      if (lastError != CryptorError.kMissingKey) {
        lastError = CryptorError.kMissingKey;
        postMessage({
          'type': 'cryptorState',
          'participantId': participantId,
          'trackId': trackId,
          'kind': kind,
          'state': 'missingKey',
          'error': 'Missing key for track $trackId',
        });
      }
      return;
    }

    try {
      var headerLength =
          kind == 'video' ? getUnencryptedBytes(frame, codec) : 1;
      var metaData = frame.getMetadata();
      var iv = makeIv(
          synchronizationSource: metaData.synchronizationSource,
          timestamp: frame.timestamp);

      var frameTrailer = ByteData(2);
      frameTrailer.setInt8(0, IV_LENGTH);
      frameTrailer.setInt8(1, keyIndex);

      var cipherText = await jsutil.promiseToFuture<ByteBuffer>(crypto.encrypt(
        crypto.AesGcmParams(
          name: 'AES-GCM',
          iv: crypto.jsArrayBufferFrom(iv),
          additionalData:
              crypto.jsArrayBufferFrom(buffer.sublist(0, headerLength)),
        ),
        secretKey,
        crypto.jsArrayBufferFrom(buffer.sublist(headerLength, buffer.length)),
      ));

      //print(
      //    'buffer: ${buffer.length}, cipherText: ${cipherText.asUint8List().length}');
      var finalBuffer = BytesBuilder();

      finalBuffer.add(Uint8List.fromList(buffer.sublist(0, headerLength)));
      finalBuffer.add(cipherText.asUint8List());
      finalBuffer.add(iv);
      finalBuffer.add(frameTrailer.buffer.asUint8List());
      frame.data = crypto.jsArrayBufferFrom(finalBuffer.toBytes());

      controller.enqueue(frame);

      if (lastError != CryptorError.kOk) {
        lastError = CryptorError.kOk;
        postMessage({
          'type': 'cryptorState',
          'participantId': participantId,
          'trackId': trackId,
          'kind': kind,
          'state': 'ok',
          'error': 'encryption ok'
        });
      }

      //print(
      //    'encrypto kind $kind,codec $codec headerLength: $headerLength,  timestamp: ${frame.timestamp}, ssrc: ${metaData.synchronizationSource}, data length: ${buffer.length}, encrypted length: ${finalBuffer.toBytes().length}, key ${secretKey.toString()} , iv $iv');
    } catch (e) {
      //print('encrypt: e ${e.toString()}');
      if (lastError != CryptorError.kEncryptError) {
        lastError = CryptorError.kEncryptError;
        postMessage({
          'type': 'cryptorState',
          'participantId': participantId,
          'trackId': trackId,
          'kind': kind,
          'state': 'encryptError',
          'error': e.toString()
        });
      }
    }
  }

  Future<void> decodeFunction(
    RTCEncodedFrame frame,
    TransformStreamDefaultController controller,
  ) async {
    var ratchetCount = 0;
    var buffer = frame.data.asUint8List();
    ByteBuffer? decrypted;

    if (ratchetInProgress) {
      print('ratchet in progress, add the frame to the queue');
      queue.add(frame);
      return;
    }

    if (!enabled ||
        // skip for encryption for empty dtx frames
        buffer.isEmpty) {
      controller.enqueue(frame);
      return;
    }

    try {
      var headerLength =
          kind == 'video' ? getUnencryptedBytes(frame, codec) : 1;
      var metaData = frame.getMetadata();

      var frameTrailer = buffer.sublist(buffer.length - 2);
      var ivLength = frameTrailer[0];
      var keyIndex = frameTrailer[1];
      var iv = buffer.sublist(buffer.length - ivLength - 2, buffer.length - 2);

      var keySet = getKeySet(keyIndex);
      var initialKeySet = getKeySet(keyIndex);

      if (keySet == null) {
        if (lastError != CryptorError.kMissingKey) {
          lastError = CryptorError.kMissingKey;
          postMessage({
            'type': 'cryptorState',
            'participantId': participantId,
            'trackId': trackId,
            'kind': kind,
            'state': 'missingKey',
            'error': 'Missing key for track $trackId'
          });
        }
        controller.enqueue(frame);
        return;
      }
      bool endDecLoop = false;

      while (!endDecLoop) {
        try {
          decrypted = await jsutil.promiseToFuture<ByteBuffer>(crypto.decrypt(
            crypto.AesGcmParams(
              name: 'AES-GCM',
              iv: crypto.jsArrayBufferFrom(iv),
              additionalData:
                  crypto.jsArrayBufferFrom(buffer.sublist(0, headerLength)),
            ),
            keySet!.encryptionKey,
            crypto.jsArrayBufferFrom(
                buffer.sublist(headerLength, buffer.length - ivLength - 2)),
          ));
          endDecLoop = true;

          if (keySet != initialKeySet) {
            // decrypt ok, update keyset.
            await setKeySetFromMaterial(keySet, keyIndex);
          }

          if (lastError != CryptorError.kKeyRatcheted && ratchetCount > 0) {
            print(
                'ratchetKey: lastError != CryptorError.kKeyRatcheted, reset state to kKeyRatcheted');
            lastError = CryptorError.kKeyRatcheted;
            postMessage({
              'type': 'cryptorState',
              'participantId': participantId,
              'trackId': trackId,
              'kind': kind,
              'state': 'keyRatcheted',
              'error': 'Key ratcheted ok'
            });
          }

          ratchetInProgress = false;

          if (queue.isNotEmpty) {
            print('Ratchet done, process the queue of frames ${queue.length}}');
            var q = queue;
            queue.clear();
            for (var f in q) {
              await decodeFunction(f, controller);
            }
          }
        } catch (e) {
          ratchetInProgress = true;
          print(
              'decrypt e ${e.toString()}: ssrc ${metaData.synchronizationSource} timestamp ${frame.timestamp} ratchetCount $ratchetCount  participantId: $participantId');
          endDecLoop = ratchetCount >= keyOptions.ratchetWindowSize ||
              keyOptions.ratchetWindowSize <= 0;
          if (endDecLoop) {
            /// Since the key it is first send and only afterwards actually used for encrypting, there were
            /// situations when the decrypting failed due to the fact that the received frame was not encrypted
            /// yet and ratcheting, of course, did not solve the problem. So if we fail RATCHET_WINDOW_SIZE times,
            ///  we come back to the initial key.
            if (initialKeySet != null) {
              await setKeySetFromMaterial(initialKeySet, keyIndex);
            }
            ratchetInProgress = false;
            if (queue.isNotEmpty) {
              queue.clear();
            }
            rethrow;
          }
          ratchetCount++;
          var newMaterial = await ratchetMaterial(keySet!.material);
          keySet = await deriveKeys(newMaterial, keyOptions.ratchetSalt);
        }
      }

      //print(
      //    'buffer: ${buffer.length}, decrypted: ${decrypted.asUint8List().length}');
      var finalBuffer = BytesBuilder();

      finalBuffer.add(Uint8List.fromList(buffer.sublist(0, headerLength)));
      finalBuffer.add(decrypted!.asUint8List());
      frame.data = crypto.jsArrayBufferFrom(finalBuffer.toBytes());
      controller.enqueue(frame);

      if (lastError != CryptorError.kOk) {
        lastError = CryptorError.kOk;
        postMessage({
          'type': 'cryptorState',
          'participantId': participantId,
          'trackId': trackId,
          'kind': kind,
          'state': 'ok',
          'error': 'decryption ok'
        });
      }

      //print(
      //    'decrypto kind $kind,codec $codec headerLength: $headerLength, timestamp: ${frame.timestamp}, ssrc: ${metaData.synchronizationSource}, data length: ${buffer.length}, decrypted length: ${finalBuffer.toBytes().length}, key ${secretKey.toString()}, keyindex $keyIndex iv $iv');
    } catch (e) {
      if (lastError != CryptorError.kDecryptError) {
        lastError = CryptorError.kDecryptError;
        postMessage({
          'type': 'cryptorState',
          'participantId': participantId,
          'trackId': trackId,
          'kind': kind,
          'state': 'decryptError',
          'error': e.toString()
        });
      }
    }
  }
}
