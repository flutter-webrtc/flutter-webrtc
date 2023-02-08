import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;

import 'package:flutter/services.dart';
import 'package:webrtc_interface/webrtc_interface.dart';
// ignore: implementation_imports
import 'package:dart_webrtc/src/rtc_rtp_receiver_impl.dart';
// ignore: implementation_imports
import 'package:dart_webrtc/src/rtc_rtp_sender_impl.dart';

import '../frame_cryptor.dart';
import 'rtc_transform_stream.dart';

extension RtcRtpReceiverExt on html.RtcRtpReceiver {
  static Map<int, ReadableStream> readableStreams_ = {};
  static Map<int, WritableStream> writableStreams_ = {};

  ReadableStream? get readable {
    if (readableStreams_.containsKey(hashCode)) {
      return readableStreams_[hashCode]!;
    }
    return null;
  }

  WritableStream? get writable {
    if (writableStreams_.containsKey(hashCode)) {
      return writableStreams_[hashCode]!;
    }
    return null;
  }

  set readableStream(ReadableStream stream) {
    readableStreams_[hashCode] = stream;
  }

  set writableStream(WritableStream stream) {
    writableStreams_[hashCode] = stream;
  }

  void closeStreams() {
    readableStreams_.remove(hashCode);
    writableStreams_.remove(hashCode);
  }
}

extension RtcRtpSenderExt on html.RtcRtpSender {
  static Map<int, ReadableStream> readableStreams_ = {};
  static Map<int, WritableStream> writableStreams_ = {};

  ReadableStream? get readable {
    if (readableStreams_.containsKey(hashCode)) {
      return readableStreams_[hashCode]!;
    }
    return null;
  }

  WritableStream? get writable {
    if (writableStreams_.containsKey(hashCode)) {
      return writableStreams_[hashCode]!;
    }
    return null;
  }

  set readableStream(ReadableStream stream) {
    readableStreams_[hashCode] = stream;
  }

  set writableStream(WritableStream stream) {
    writableStreams_[hashCode] = stream;
  }

  void closeStreams() {
    readableStreams_.remove(hashCode);
    writableStreams_.remove(hashCode);
  }
}

class FrameCryptorImpl extends FrameCryptor {
  FrameCryptorImpl(
      this._factory, this.worker, this._participantId, this._trackId,
      {this.jsSender, this.jsReceiver});
  html.Worker worker;
  bool _enabled = false;
  int _keyIndex = 0;
  final String _participantId;
  final String _trackId;
  final html.RtcRtpSender? jsSender;
  final html.RtcRtpReceiver? jsReceiver;
  final FrameCryptorFactoryImpl _factory;

  @override
  Future<void> dispose() async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'dispose',
        'participantId': participantId,
      })
    ]);
    _factory.removeFrameCryptor(_trackId);
    return;
  }

  @override
  Future<bool> get enabled => Future(() => _enabled);

  @override
  Future<int> get keyIndex => Future(() => _keyIndex);

  @override
  String get participantId => _participantId;

  @override
  Future<bool> setEnabled(bool enabled) async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'enable',
        'participantId': participantId,
        'enabled': enabled
      })
    ]);
    _enabled = enabled;
    return true;
  }

  @override
  Future<bool> setKeyIndex(int index) async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'setKeyIndex',
        'participantId': participantId,
        'index': index,
      })
    ]);
    _keyIndex = index;
    return true;
  }

  @override
  Future<void> updateCodec(String codec) async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'updateCodec',
        'trackId': _trackId,
        'codec': codec,
      })
    ]);
  }
}

class KeyManagerImpl implements KeyManager {
  KeyManagerImpl(this._id, this.worker);
  final String _id;
  final html.Worker worker;

  final Map<String, List<Uint8List>> _keys = {};

  @override
  String get id => _id;

  @override
  Future<void> dispose() {
    return Future.value();
  }

  @override
  Future<List<Uint8List>> getKeys({required String participantId}) async {
    return _keys[participantId] ?? [];
  }

  @override
  Future<bool> setKey(
      {required String participantId,
      required int index,
      required Uint8List key}) async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'setKey',
        'participantId': participantId,
        'index': index,
        'key': base64Encode(key),
      })
    ]);
    _keys[participantId] ??= [];
    if (_keys[participantId]!.length <= index) {
      _keys[participantId]!.add(key);
    } else {
      _keys[participantId]![index] = key;
    }
    return true;
  }

  @override
  Future<bool> setKeys(
      {required String participantId, required List<Uint8List> keys}) async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'setKey',
        'participantId': participantId,
        'keys': keys,
      })
    ]);
    _keys[participantId] = keys;
    return true;
  }
}

class FrameCryptorFactoryImpl implements FrameCryptorFactory {
  FrameCryptorFactoryImpl._internal() {
    worker = html.Worker('e2ee.worker.dart.js');
    worker.onMessage.listen((msg) {
      print('master got ${msg.data}');
    });
    worker.onError.listen((err) {
      print('worker error: $err');
    });
  }

  static final FrameCryptorFactoryImpl instance =
      FrameCryptorFactoryImpl._internal();

  late html.Worker worker;
  final Map<String, FrameCryptor> _frameCryptors = {};

  @override
  Future<KeyManager> createDefaultKeyManager() async {
    return KeyManagerImpl('default', worker);
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpReceiver(
      {required String participantId,
      required RTCRtpReceiver receiver,
      required Algorithm algorithm,
      required KeyManager keyManager}) {
    html.RtcRtpReceiver jsReceiver =
        (receiver as RTCRtpReceiverWeb).jsRtpReceiver;

    var trackId = jsReceiver.track!.id!;
    var kind = jsReceiver.track!.kind!;

    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
      var options = {
        'msgType': 'decode',
        'kind': kind,
        'participantId': participantId,
        'trackId': trackId,
      };
      jsutil.setProperty(jsReceiver, 'transform',
          RTCRtpScriptTransform(worker, jsutil.jsify(options)));
    } else {
      var writable = jsReceiver.writable;
      var readable = jsReceiver.readable;
      if (writable == null || readable == null) {
        EncodedStreams streams =
            jsutil.callMethod(jsReceiver, 'createEncodedStreams', []);
        readable = streams.readable;
        jsReceiver.readableStream = readable;
        writable = streams.writable;
        jsReceiver.writableStream = writable;
      }

      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'decode',
          'kind': kind,
          'participantId': participantId,
          'trackId': trackId,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    FrameCryptor cryptor = FrameCryptorImpl(
        this, worker, participantId, trackId,
        jsReceiver: jsReceiver);
    _frameCryptors[trackId] = cryptor;
    return Future.value(cryptor);
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpSender(
      {required String participantId,
      required RTCRtpSender sender,
      required Algorithm algorithm,
      required KeyManager keyManager}) {
    html.RtcRtpSender jsSender = (sender as RTCRtpSenderWeb).jsRtpSender;
    var trackId = jsSender.track!.id!;
    var kind = jsSender.track!.kind!;

    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
      var options = {
        'msgType': 'encode',
        'kind': kind,
        'participantId': participantId,
        'trackId': trackId,
      };
      jsutil.setProperty(jsSender, 'transform',
          RTCRtpScriptTransform(worker, jsutil.jsify(options)));
    } else {
      var writable = jsSender.writable;
      var readable = jsSender.readable;
      if (writable == null || readable == null) {
        EncodedStreams streams =
            jsutil.callMethod(jsSender, 'createEncodedStreams', []);
        readable = streams.readable;
        jsSender.readableStream = readable;
        writable = streams.writable;
        jsSender.writableStream = writable;
      }
      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'encode',
          'kind': kind,
          'participantId': participantId,
          'trackId': trackId,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    FrameCryptor cryptor = FrameCryptorImpl(
        this, worker, participantId, trackId,
        jsSender: jsSender);
    _frameCryptors[trackId] = cryptor;
    return Future.value(cryptor);
  }

  void removeFrameCryptor(String trackId) {
    _frameCryptors.remove(trackId);
  }
}
