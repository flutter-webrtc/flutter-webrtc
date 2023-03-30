import 'dart:async';
import 'dart:typed_data';
import 'dart:js_util' as jsutil;
import 'dart:html' as html;

import 'package:js/js.dart';

@JS('Promise')
class Promise<T> {
  external factory Promise._();
}

@JS('Algorithm')
class Algorithm {
  external String get name;
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
  ByteBuffer keyData,
  dynamic algorithm,
  bool extractable,
  List<String> keyUsages,
);

@JS('crypto.subtle.exportKey')
external Promise<ByteBuffer> exportKey(
  String format,
  html.CryptoKey key,
);

@JS('crypto.subtle.deriveKey')
external Promise<html.CryptoKey> deriveKey(
    dynamic algorithm,
    html.CryptoKey baseKey,
    dynamic derivedKeyAlgorithm,
    bool extractable,
    List<String> keyUsages);

@JS('crypto.subtle.deriveBits')
external Promise<ByteBuffer> deriveBits(
  dynamic algorithm,
  html.CryptoKey baseKey,
  int length,
);

Future<html.CryptoKey> impportKeyFromRawData(List<int> secretKeyData,
    {required String webCryptoAlgorithm,
    required List<String> keyUsages}) async {
  return jsutil.promiseToFuture<html.CryptoKey>(importKey(
    'raw',
    jsArrayBufferFrom(secretKeyData),
    jsutil.jsify({'name': webCryptoAlgorithm}),
    false,
    keyUsages,
  ));
}
