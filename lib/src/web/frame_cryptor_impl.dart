import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;

import 'package:webrtc_interface/webrtc_interface.dart';
// ignore: implementation_imports
import 'package:dart_webrtc/src/rtc_rtp_receiver_impl.dart';
// ignore: implementation_imports
import 'package:dart_webrtc/src/rtc_rtp_sender_impl.dart';

import '../frame_cryptor.dart';
import 'rtc_transform_stream.dart';

extension RtcRtpReceiverExt on html.RtcRtpReceiver {
  html.RtcRtpReceiver get jsRtpReceiver => this;
}

class FrameCryptorImpl implements FrameCryptor {
  FrameCryptorImpl(this.worker, this._participantId, this._trackId);
  html.Worker worker;
  bool _enabled = false;
  int _keyIndex = 0;
  final String _participantId;
  final String _trackId;

  @override
  Future<void> dispose() async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'dispose',
        'participantId': participantId,
      })
    ]);
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
  }

  static final FrameCryptorFactoryImpl instance =
      FrameCryptorFactoryImpl._internal();
  late html.Worker worker;
  Map<String, FrameCryptor> _frameCryptors = {};

  var videoCodec = 'vp8';
  var audioCodec = 'opus';

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
        'codec': videoCodec,
      };
      jsutil.setProperty(jsReceiver, 'transform',
          RTCRtpScriptTransform(worker, jsutil.jsify(options)));
    } else {
      EncodedStreams streams =
          jsutil.callMethod(jsReceiver, 'createEncodedStreams', []);
      var readable = streams.readable;
      var writable = streams.writable;

      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'decode',
          'kind': kind,
          'participantId': participantId,
          'trackId': trackId,
          'codec': kind == 'audio' ? audioCodec : videoCodec,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    FrameCryptor cryptor = FrameCryptorImpl(worker, participantId, trackId);
    _frameCryptors[participantId] = cryptor;
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
        'codec': videoCodec,
      };
      jsutil.setProperty(jsSender, 'transform',
          RTCRtpScriptTransform(worker, jsutil.jsify(options)));
    } else {
      EncodedStreams streams =
          jsutil.callMethod(jsSender, 'createEncodedStreams', []);
      var readable = streams.readable;
      var writable = streams.writable;
      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'encode',
          'kind': kind,
          'participantId': participantId,
          'trackId': trackId,
          'codec': kind == 'audio' ? audioCodec : videoCodec,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    FrameCryptor cryptor = FrameCryptorImpl(worker, participantId, trackId);
    _frameCryptors[participantId] = cryptor;
    return Future.value(cryptor);
  }
}
