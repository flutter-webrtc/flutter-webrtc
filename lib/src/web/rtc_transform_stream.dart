import 'dart:html';
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:js/js.dart';

@JS('WritableStream')
abstract class WritableStream {
  external void abort();
  external void close();
  external bool locked();
  external WritableStream clone();
}

@JS('ReadableStream')
abstract class ReadableStream {
  external void cancel();
  external bool locked();
  external ReadableStream pipeThrough(dynamic transformStream);
  external void pipeTo(WritableStream writableStream);
  external ReadableStream clone();
}

@JS('TransformStream')
class TransformStream {
  external TransformStream(dynamic);
  external ReadableStream get readable;
  external WritableStream get writable;
}

@anonymous
@JS()
abstract class TransformStreamDefaultController {
  external void enqueue(dynamic chunk);
  external void error(dynamic error);
  external void terminate();
}

@anonymous
@JS()
class EncodedStreams {
  external ReadableStream get readable;
  external WritableStream get writable;
}

@JS()
class RTCEncodedFrame {
  external int get timestamp;
  external ByteBuffer get data;
  external set data(ByteBuffer data);
  external RTCEncodedFrameMetadata getMetadata();
  external String? get type;
}

@JS()
class RTCEncodedAudioFrame {
  external int get timestamp;
  external ByteBuffer get data;
  external set data(ByteBuffer data);
  external int? get size;
  external RTCEncodedAudioFrameMetadata getMetadata();
}

@JS()
class RTCEncodedVideoFrame {
  external int get timestamp;
  external ByteBuffer get data;
  external set data(ByteBuffer data);
  external String get type;
  external RTCEncodedVideoFrameMetadata getMetadata();
}

@JS()
class RTCEncodedFrameMetadata {
  external int get payloadType;
  external int get synchronizationSource;
}

@JS()
class RTCEncodedAudioFrameMetadata {
  external int get payloadType;
  external int get synchronizationSource;
}

@JS()
class RTCEncodedVideoFrameMetadata {
  external int get frameId;
  external int get width;
  external int get height;
  external int get payloadType;
  external int get synchronizationSource;
}

@JS('RTCTransformEvent')
class RTCTransformEvent {
  external factory RTCTransformEvent();
}

extension PropsRTCTransformEvent on RTCTransformEvent {
  RTCRtpScriptTransformer get transformer =>
      js_util.getProperty(this, 'transformer');
}

@JS()
@staticInterop
class RTCRtpScriptTransformer {
  external factory RTCRtpScriptTransformer();
}

extension PropsRTCRtpScriptTransformer on RTCRtpScriptTransformer {
  ReadableStream get readable => js_util.getProperty(this, 'readable');
  WritableStream get writable => js_util.getProperty(this, 'writable');
  dynamic get options => js_util.getProperty(this, 'options');
  Future<int> generateKeyFrame([String? rid]) => js_util
      .promiseToFuture(js_util.callMethod(this, 'generateKeyFrame', [rid]));

  Future<void> sendKeyFrameRequest() => js_util
      .promiseToFuture(js_util.callMethod(this, 'sendKeyFrameRequest', []));

  set handled(bool value) {
    js_util.setProperty(this, 'handled', value);
  }
}

@JS('RTCRtpScriptTransform')
class RTCRtpScriptTransform {
  external factory RTCRtpScriptTransform(Worker worker,
      [dynamic options, Iterable<dynamic>? transfer]);
}
