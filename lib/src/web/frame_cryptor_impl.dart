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
import 'package:collection/collection.dart';

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
      {this.jsSender, this.jsReceiver, required this.keyProvider});
  html.Worker worker;
  bool _enabled = false;
  int _keyIndex = 0;
  final String _participantId;
  final String _trackId;
  final html.RtcRtpSender? jsSender;
  final html.RtcRtpReceiver? jsReceiver;
  final FrameCryptorFactoryImpl _factory;
  final KeyProviderImpl keyProvider;

  @override
  Future<void> dispose() async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'dispose',
        'trackId': _trackId,
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

  String get trackId => _trackId;

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

class KeyProviderImpl implements KeyProvider {
  KeyProviderImpl(this._id, this.worker, this.options);
  final String _id;
  final html.Worker worker;
  final KeyProviderOptions options;
  final Map<String, List<Uint8List>> _keys = {};

  @override
  String get id => _id;

  Future<void> init() async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'init',
        'id': id,
        'keyOptions': {
          'sharedKey': options.sharedKey,
          'ratchetSalt': base64Encode(options.ratchetSalt),
          'ratchetWindowSize': options.ratchetWindowSize,
          if (options.uncryptedMagicBytes != null)
            'uncryptedMagicBytes': base64Encode(options.uncryptedMagicBytes!),
        },
      })
    ]);
  }

  @override
  Future<void> dispose() {
    return Future.value();
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
        'keyIndex': index,
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

  Completer<Uint8List>? _ratchetKeyCompleter;

  void onRatchetKey(Uint8List key) {
    if (_ratchetKeyCompleter != null) {
      _ratchetKeyCompleter!.complete(key);
      _ratchetKeyCompleter = null;
    }
  }

  @override
  Future<Uint8List> ratchetKey(
      {required String participantId, required int index}) async {
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'ratchetKey',
        'participantId': participantId,
        'keyIndex': index,
      })
    ]);

    _ratchetKeyCompleter ??= Completer();

    return _ratchetKeyCompleter!.future;
  }
}

class FrameCryptorFactoryImpl implements FrameCryptorFactory {
  FrameCryptorFactoryImpl._internal() {
    worker = html.Worker('e2ee.worker.dart.js');
    worker.onMessage.listen((msg) {
      print('master got ${msg.data}');
      var type = msg.data['type'];
      if (type == 'cryptorState') {
        var trackId = msg.data['trackId'];
        var participantId = msg.data['participantId'];
        var frameCryptor = _frameCryptors.values.firstWhereOrNull(
            (element) => (element as FrameCryptorImpl).trackId == trackId);
        var state = msg.data['state'];
        FrameCryptorState frameCryptorState =
            FrameCryptorState.FrameCryptorStateNew;
        switch (state) {
          case 'ok':
            frameCryptorState = FrameCryptorState.FrameCryptorStateOk;
            break;
          case 'decryptError':
            frameCryptorState =
                FrameCryptorState.FrameCryptorStateDecryptionFailed;
            break;
          case 'encryptError':
            frameCryptorState =
                FrameCryptorState.FrameCryptorStateEncryptionFailed;
            break;
          case 'missingKey':
            frameCryptorState = FrameCryptorState.FrameCryptorStateMissingKey;
            break;
          case 'internalError':
            frameCryptorState =
                FrameCryptorState.FrameCryptorStateInternalError;
            break;
          case 'keyRatcheted':
            frameCryptorState = FrameCryptorState.FrameCryptorStateKeyRatcheted;
            break;
        }
        frameCryptor?.onFrameCryptorStateChanged
            ?.call(participantId, frameCryptorState);
      } else if (type == 'ratchetKey') {
        var trackId = msg.data['trackId'];
        var frameCryptor = _frameCryptors.values.firstWhereOrNull(
            (element) => (element as FrameCryptorImpl).trackId == trackId);
        if (frameCryptor != null) {
          ((frameCryptor as FrameCryptorImpl).keyProvider)
              .onRatchetKey(base64Decode(msg.data['key']));
        }
      }
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
  Future<KeyProvider> createDefaultKeyProvider(
      KeyProviderOptions options) async {
    var keyProvider = KeyProviderImpl('default', worker, options);
    await keyProvider.init();
    return keyProvider;
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpReceiver(
      {required String participantId,
      required RTCRtpReceiver receiver,
      required Algorithm algorithm,
      required KeyProvider keyProvider}) {
    html.RtcRtpReceiver jsReceiver =
        (receiver as RTCRtpReceiverWeb).jsRtpReceiver;

    var trackId = jsReceiver.hashCode.toString();
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
      bool exist = true;
      if (writable == null || readable == null) {
        EncodedStreams streams =
            jsutil.callMethod(jsReceiver, 'createEncodedStreams', []);
        readable = streams.readable;
        jsReceiver.readableStream = readable;
        writable = streams.writable;
        jsReceiver.writableStream = writable;
        exist = false;
      }

      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'decode',
          'kind': kind,
          'exist': exist,
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
        jsReceiver: jsReceiver, keyProvider: keyProvider as KeyProviderImpl);
    _frameCryptors[trackId] = cryptor;
    return Future.value(cryptor);
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpSender(
      {required String participantId,
      required RTCRtpSender sender,
      required Algorithm algorithm,
      required KeyProvider keyProvider}) {
    html.RtcRtpSender jsSender = (sender as RTCRtpSenderWeb).jsRtpSender;
    var trackId = jsSender.hashCode.toString();
    var kind = jsSender.track!.kind!;

    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
      var options = {
        'msgType': 'encode',
        'kind': kind,
        'participantId': participantId,
        'trackId': trackId,
        'options': (keyProvider as KeyProviderImpl).options.toJson(),
      };
      jsutil.setProperty(jsSender, 'transform',
          RTCRtpScriptTransform(worker, jsutil.jsify(options)));
    } else {
      var writable = jsSender.writable;
      var readable = jsSender.readable;
      bool exist = true;
      if (writable == null || readable == null) {
        EncodedStreams streams =
            jsutil.callMethod(jsSender, 'createEncodedStreams', []);
        readable = streams.readable;
        jsSender.readableStream = readable;
        writable = streams.writable;
        jsSender.writableStream = writable;
        exist = false;
      }
      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'encode',
          'kind': kind,
          'exist': exist,
          'participantId': participantId,
          'trackId': trackId,
          'options': (keyProvider as KeyProviderImpl).options.toJson(),
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    FrameCryptor cryptor = FrameCryptorImpl(
        this, worker, participantId, trackId,
        jsSender: jsSender, keyProvider: keyProvider);
    _frameCryptors[trackId] = cryptor;
    return Future.value(cryptor);
  }

  void removeFrameCryptor(String trackId) {
    _frameCryptors.remove(trackId);
  }
}
