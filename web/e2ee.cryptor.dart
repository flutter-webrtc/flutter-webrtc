import 'dart:html';
import 'dart:js';
import 'dart:js_util';
import 'dart:math';
import 'dart:typed_data';

import 'crypto.dart';
import 'package:flutter_webrtc/src/web/rtc_transform_stream.dart';

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
  kInternalError,
  kDisposed,
}

class Cryptor {
  Cryptor(
      {required this.worker,
      required this.participantId,
      required this.trackId,
      required this.sharedKey});
  Map<int, int> sendCounts = {};
  String? participantId;
  String? trackId;
  String? codec;
  final bool sharedKey;
  late String kind;
  CryptoKey? secretKey;
  int keyIndex = 0;
  bool enabled = false;
  CryptorError lastError = CryptorError.kNew;
  final DedicatedWorkerGlobalScope worker;

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
    this.keyIndex = keyIndex;
  }

  void setEnabled(bool enabled) {
    if (lastError != CryptorError.kOk) {
      print(
          'setEnabled[$enabled]: lastError != CryptorError.kOk, reset state to kNew');
      lastError = CryptorError.kNew;
    }
    this.enabled = enabled;
  }

  Future<void> setKey(Uint8List key) async {
    if (lastError != CryptorError.kOk) {
      print('setKey: lastError != CryptorError.kOk, reset state to kNew');
      lastError = CryptorError.kNew;
    }
    secretKey =
        await cryptoKeyFromAesSecretKey(key, webCryptoAlgorithm: 'AES-GCM');
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
    var transformer = TransformStream(jsify({
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
          case SPS:
          case PPS:
          case AUD:
          case SEI:
          case PREFIX_NALU:
            // skipping
            // workerLogger.debug(`skipping NALU of type ${NALUType[type]}`);
            break;
          default:
            return index + 2;
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

      var cipherText = await promiseToFuture<ByteBuffer>(encrypt(
        AesGcmParams(
          name: 'AES-GCM',
          iv: jsArrayBufferFrom(iv),
          additionalData: jsArrayBufferFrom(buffer.sublist(0, headerLength)),
        ),
        secretKey!,
        jsArrayBufferFrom(buffer.sublist(headerLength, buffer.length)),
      ));

      //print(
      //    'buffer: ${buffer.length}, cipherText: ${cipherText.asUint8List().length}');
      var finalBuffer = BytesBuilder();

      finalBuffer.add(Uint8List.fromList(buffer.sublist(0, headerLength)));
      finalBuffer.add(cipherText.asUint8List());
      finalBuffer.add(iv);
      finalBuffer.add(frameTrailer.buffer.asUint8List());
      frame.data = jsArrayBufferFrom(finalBuffer.toBytes());

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
    var buffer = frame.data.asUint8List();

    if (!enabled ||
        // skip for encryption for empty dtx frames
        buffer.isEmpty) {
      controller.enqueue(frame);
      return;
    }

    if (secretKey == null) {
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
    }

    try {
      var headerLength =
          kind == 'video' ? getUnencryptedBytes(frame, codec) : 1;
      var metaData = frame.getMetadata();

      var frameTrailer = buffer.sublist(buffer.length - 2);
      var ivLength = frameTrailer[0];
      var keyIndex = frameTrailer[1];
      var iv = buffer.sublist(buffer.length - ivLength - 2, buffer.length - 2);

      var decrypted = await promiseToFuture<ByteBuffer>(decrypt(
        AesGcmParams(
          name: 'AES-GCM',
          iv: jsArrayBufferFrom(iv),
          additionalData: jsArrayBufferFrom(buffer.sublist(0, headerLength)),
        ),
        secretKey!,
        jsArrayBufferFrom(
            buffer.sublist(headerLength, buffer.length - ivLength - 2)),
      ));
      //print(
      //    'buffer: ${buffer.length}, decrypted: ${decrypted.asUint8List().length}');
      var finalBuffer = BytesBuilder();

      finalBuffer.add(Uint8List.fromList(buffer.sublist(0, headerLength)));
      finalBuffer.add(decrypted.asUint8List());
      frame.data = jsArrayBufferFrom(finalBuffer.toBytes());
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
      //print('derypto: e ${e.toString()}');
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
