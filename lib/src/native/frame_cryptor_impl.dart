import 'dart:async';
import 'dart:core';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';
import 'utils.dart';

class KeyProviderImpl implements KeyProvider {
  KeyProviderImpl(this._id);
  final String _id;
  @override
  String get id => _id;

  @override
  Future<void> setSharedKey({required Uint8List key, int index = 0}) async {
    try {
      await WebRTC.invokeMethod('keyProviderSetSharedKey', <String, dynamic>{
        'keyProviderId': _id,
        'keyIndex': index,
        'key': key,
      });
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::setSharedKey: ${e.message}';
    }
  }

  @override
  Future<Uint8List> ratchetSharedKey({int index = 0}) async {
    try {
      final response = await WebRTC.invokeMethod(
          'keyProviderRatchetSharedKey', <String, dynamic>{
        'keyProviderId': _id,
        'keyIndex': index,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::ratchetSharedKey: ${e.message}';
    }
  }

  @override
  Future<Uint8List> exportSharedKey({int index = 0}) async {
    try {
      final response = await WebRTC.invokeMethod(
          'keyProviderExportSharedKey', <String, dynamic>{
        'keyProviderId': _id,
        'keyIndex': index,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::exportSharedKey: ${e.message}';
    }
  }

  @override
  Future<bool> setKey({
    required String participantId,
    required int index,
    required Uint8List key,
  }) async {
    try {
      final response =
          await WebRTC.invokeMethod('keyProviderSetKey', <String, dynamic>{
        'keyProviderId': _id,
        'keyIndex': index,
        'key': key,
        'participantId': participantId,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::setKey: ${e.message}';
    }
  }

  @override
  Future<Uint8List> ratchetKey({
    required String participantId,
    required int index,
  }) async {
    try {
      final response =
          await WebRTC.invokeMethod('keyProviderRatchetKey', <String, dynamic>{
        'keyProviderId': _id,
        'keyIndex': index,
        'participantId': participantId,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::ratchetKey: ${e.message}';
    }
  }

  @override
  Future<Uint8List> exportKey({
    required String participantId,
    required int index,
  }) async {
    try {
      final response =
          await WebRTC.invokeMethod('keyProviderExportKey', <String, dynamic>{
        'keyProviderId': _id,
        'participantId': participantId,
        'keyIndex': index,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::exportSharedKey: ${e.message}';
    }
  }

  @override
  Future<void> setSifTrailer({required Uint8List trailer}) async {
    try {
      await WebRTC.invokeMethod('keyProviderSetSifTrailer', <String, dynamic>{
        'keyProviderId': _id,
        'sifTrailer': trailer,
      });
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::setSifTrailer: ${e.message}';
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await WebRTC.invokeMethod('keyProviderDispose', <String, dynamic>{
        'keyProviderId': _id,
      });
    } on PlatformException catch (e) {
      throw 'Unable to KeyProviderImpl::dispose: ${e.message}';
    }
  }
}

class FrameCryptorFactoryImpl implements FrameCryptorFactory {
  FrameCryptorFactoryImpl._internal();

  static final FrameCryptorFactoryImpl instance =
      FrameCryptorFactoryImpl._internal();

  @override
  Future<FrameCryptor> createFrameCryptorForRtpSender({
    required String participantId,
    required RTCRtpSender sender,
    required Algorithm algorithm,
    required KeyProvider keyProvider,
  }) async {
    RTCRtpSenderNative nativeSender = sender as RTCRtpSenderNative;
    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorFactoryCreateFrameCryptor', <String, dynamic>{
        'peerConnectionId': nativeSender.peerConnectionId,
        'rtpSenderId': sender.senderId,
        'participantId': participantId,
        'keyProviderId': keyProvider.id,
        'algorithm': algorithm.index,
        'type': 'sender',
      });
      var frameCryptorId = response['frameCryptorId'];
      return FrameCryptorImpl(frameCryptorId, participantId);
    } on PlatformException catch (e) {
      throw 'Unable to FrameCryptorFactory::createFrameCryptorForRtpSender: ${e.message}';
    }
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpReceiver({
    required String participantId,
    required RTCRtpReceiver receiver,
    required Algorithm algorithm,
    required KeyProvider keyProvider,
  }) async {
    RTCRtpReceiverNative nativeReceiver = receiver as RTCRtpReceiverNative;

    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorFactoryCreateFrameCryptor', <String, dynamic>{
        'peerConnectionId': nativeReceiver.peerConnectionId,
        'rtpReceiverId': nativeReceiver.receiverId,
        'participantId': participantId,
        'keyProviderId': keyProvider.id,
        'algorithm': algorithm.index,
        'type': 'receiver',
      });
      var frameCryptorId = response['frameCryptorId'];
      return FrameCryptorImpl(frameCryptorId, participantId);
    } on PlatformException catch (e) {
      throw 'Unable to FrameCryptorFactory::createFrameCryptorForRtpReceiver: ${e.message}';
    }
  }

  @override
  Future<KeyProvider> createDefaultKeyProvider(
      KeyProviderOptions options) async {
    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorFactoryCreateKeyProvider', <String, dynamic>{
        'keyProviderOptions': options.toJson(),
      });
      String keyProviderId = response['keyProviderId'];
      return KeyProviderImpl(keyProviderId);
    } on PlatformException catch (e) {
      throw 'Unable to FrameCryptorFactory::createKeyProvider: ${e.message}';
    }
  }
}

class FrameCryptorImpl extends FrameCryptor {
  FrameCryptorImpl(this._frameCryptorId, this._participantId) {
    _eventSubscription = _eventChannelFor(_frameCryptorId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }
  final String _frameCryptorId;
  final String _participantId;
  @override
  String get participantId => _participantId;

  StreamSubscription<dynamic>? _eventSubscription;

  EventChannel _eventChannelFor(String peerConnectionId) {
    return EventChannel('FlutterWebRTC/frameCryptorEvent$_frameCryptorId');
  }

  void errorListener(Object obj) {
    if (obj is Exception) throw obj;
  }

  FrameCryptorState _cryptorStateFromString(String str) {
    switch (str) {
      case 'new':
        return FrameCryptorState.FrameCryptorStateNew;
      case 'ok':
        return FrameCryptorState.FrameCryptorStateOk;
      case 'decryptionFailed':
        return FrameCryptorState.FrameCryptorStateDecryptionFailed;
      case 'encryptionFailed':
        return FrameCryptorState.FrameCryptorStateEncryptionFailed;
      case 'internalError':
        return FrameCryptorState.FrameCryptorStateInternalError;
      case "keyRatcheted":
        return FrameCryptorState.FrameCryptorStateKeyRatcheted;
      case 'missingKey':
        return FrameCryptorState.FrameCryptorStateMissingKey;
      default:
        throw 'Unknown FrameCryptorState: $str';
    }
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'frameCryptionStateChanged':
        var state = _cryptorStateFromString(map['state']);
        var participantId = map['participantId'];
        onFrameCryptorStateChanged?.call(participantId, state);
        break;
    }
  }

  @override
  Future<void> updateCodec(String codec) async {
    /// only needs for flutter web
  }

  @override
  Future<bool> setKeyIndex(int index) async {
    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorSetKeyIndex', <String, dynamic>{
        'frameCryptorId': _frameCryptorId,
        'keyIndex': index,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::setKeyIndex: ${e.message}';
    }
  }

  @override
  Future<int> get keyIndex async {
    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorGetKeyIndex', <String, dynamic>{
        'frameCryptorId': _frameCryptorId,
      });
      return response['keyIndex'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::keyIndex: ${e.message}';
    }
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    try {
      final response =
          await WebRTC.invokeMethod('frameCryptorSetEnabled', <String, dynamic>{
        'frameCryptorId': _frameCryptorId,
        'enabled': enabled,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::setEnabled: ${e.message}';
    }
  }

  @override
  Future<bool> get enabled async {
    try {
      final response =
          await WebRTC.invokeMethod('frameCryptorGetEnabled', <String, dynamic>{
        'frameCryptorId': _frameCryptorId,
      });
      return response['enabled'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::enabled: ${e.message}';
    }
  }

  @override
  Future<void> dispose() async {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    try {
      final response =
          await WebRTC.invokeMethod('frameCryptorDispose', <String, dynamic>{
        'frameCryptorId': _frameCryptorId,
      });
      var res = response['result'];
      print('res $res');
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::dispose: ${e.message}';
    }
  }
}
