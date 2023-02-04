import 'dart:async';
import 'dart:typed_data';
import 'dart:js_util' as jsutil;
import 'dart:html' as html;

import 'package:js/js.dart';

@JS('Promise')
class Promise<T> {
  external factory Promise._();
}

@JS('crypto.subtle.encrypt')
external Promise<ByteBuffer> encrypt(
  dynamic algorithm,
  html.CryptoKey key,
  ByteBuffer data,
);

@JS('crypto.subtle.decrypt')
external Promise<ByteBuffer> decrypt(
  dynamic algorithm,
  html.CryptoKey key,
  ByteBuffer data,
);

@JS()
@anonymous
class AesGcmParams {
  external factory AesGcmParams({
    required String name,
    required ByteBuffer iv,
    ByteBuffer? additionalData,
    int tagLength = 128,
  });
}

ByteBuffer jsArrayBufferFrom(List<int> data) {
  // Avoid copying if possible
  if (data is Uint8List &&
      data.offsetInBytes == 0 &&
      data.lengthInBytes == data.buffer.lengthInBytes) {
    return data.buffer;
  }
  // Copy
  return Uint8List.fromList(data).buffer;
}

@JS('crypto.subtle.importKey')
external Promise<html.CryptoKey> importKey(
  String format,
  dynamic keyData,
  dynamic algorithm,
  bool extractable,
  List<String> keyUsages,
);

FutureOr<html.CryptoKey> cryptoKeyFromAesSecretKey(
  List<int> secretKeyData, {
  required String webCryptoAlgorithm,
}) async {
  return jsutil.promiseToFuture(importKey(
    'raw',
    jsArrayBufferFrom(secretKeyData),
    webCryptoAlgorithm,
    false,
    ['encrypt', 'decrypt'],
  ));
}
