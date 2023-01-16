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

class KeyManagerImpl implements KeyManager {
  KeyManagerImpl(this._id);
  final String _id;
  @override
  String get id => _id;

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<List<Uint8List>> getKeys({required String participantId}) {
    // TODO: implement getKeys
    throw UnimplementedError();
  }

  @override
  Future<bool> setKey(
      {required String participantId,
      required int index,
      required Uint8List key}) {
    // TODO: implement setKey
    throw UnimplementedError();
  }

  @override
  Future<bool> setKeys(
      {required String participantId, required List<Uint8List> keys}) {
    // TODO: implement setKeys
    throw UnimplementedError();
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
  var videoCodec = 'vp8';
  var audioCodec = 'opus';

  @override
  Future<KeyManager> createDefaultKeyManager() async {
    return KeyManagerImpl('default');
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpReceiver(
      {required String participantId,
      required RTCRtpReceiver receiver,
      required Algorithm algorithm,
      required KeyManager keyManager}) {
    html.RtcRtpReceiver jsReceiver =
        (receiver as RTCRtpReceiverWeb).jsRtpReceiver;

    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
      var options = {
        'msgType': 'decode',
        'kind': jsReceiver.track!.kind!,
        'participantId': jsReceiver.track!.id!,
        'trackId': jsReceiver.track!.id!,
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
          'kind': jsReceiver.track!.kind!,
          'participantId': jsReceiver.track!.id!,
          'trackId': jsReceiver.track!.id!,
          'codec': jsReceiver.track!.kind == 'audio' ? audioCodec : videoCodec,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    throw UnimplementedError();
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpSender(
      {required String participantId,
      required RTCRtpSender sender,
      required Algorithm algorithm,
      required KeyManager keyManager}) {
    html.RtcRtpSender jsSender = (sender as RTCRtpSenderWeb).jsRtpSender;

    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
      var options = {
        'msgType': 'encode',
        'kind': jsSender.track!.kind!,
        'participantId': jsSender.track!.id!,
        'trackId': jsSender.track!.id!,
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
          'kind': jsSender.track!.kind!,
          'participantId': jsSender.track!.id!,
          'trackId': jsSender.track!.id!,
          'codec': jsSender.track!.kind == 'audio' ? audioCodec : videoCodec,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    throw UnimplementedError();
  }
}
