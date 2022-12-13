import 'dart:core';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';

// List<String> methods = [
//   'keyManagerSetKey',
//   'keyManagerSetKeys',
//   'keyManagerGetKeys',
//   'keyManagerDispose',
//   'frameCryptorFactoryCreateFrameCryptor',
//   'frameCryptorFactoryCreateKeyManager',
//   'frameCryptorSetKeyIndex',
//   'frameCryptorGetKeyIndex',
//   'frameCryptorSetEnabled',
//   'frameCryptorGetEnabled',
//   'frameCryptorDispose',
// ];

class KeyManagerImpl implements KeyManager {
  KeyManagerImpl(this._id);
  final String _id;
  @override
  String get id => _id;

  @override
  Future<bool> setKey(int index, Uint8List key) async {
    try {
      final response =
          await WebRTC.invokeMethod('keyManagerSetKey', <String, dynamic>{
        'keyManagerId': _id,
        'keyIndex': index,
        'key': key,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyManagerImpl::setKey: ${e.message}';
    }
  }

  @override
  Future<bool> setKeys(List<Uint8List> keys) async {
    try {
      final response =
          await WebRTC.invokeMethod('keyManagerSetKeys', <String, dynamic>{
        'keyManagerId': _id,
        'keys': keys,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyManagerImpl::setKeys: ${e.message}';
    }
  }

  @override
  Future<List<Uint8List>> get keys async {
    try {
      final response =
          await WebRTC.invokeMethod('keyManagerGetKeys', <String, dynamic>{
        'keyManagerId': _id,
      });
      return response['keys'] as List<Uint8List>;
    } on PlatformException catch (e) {
      throw 'Unable to get KeyManagerImpl::keys: ${e.message}';
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await WebRTC.invokeMethod('keyManagerDispose', <String, dynamic>{
        'keyManagerId': _id,
      });
    } on PlatformException catch (e) {
      throw 'Unable to KeyManagerImpl::dispose: ${e.message}';
    }
  }
}

class FrameCryptorFactoryImpl implements FrameCryptorFactory {
  FrameCryptorFactoryImpl._internal();

  static final FrameCryptorFactoryImpl instance =
      FrameCryptorFactoryImpl._internal();

  @override
  Future<FrameCryptor> createFrameCryptorForRtpSender({
    required RTCRtpSender sender,
    required Algorithm algorithm,
    required KeyManager keyManager,
  }) async {
    RTCRtpSenderNative nativeSender = sender as RTCRtpSenderNative;
    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorFactoryCreateFrameCryptor', <String, dynamic>{
        'peerConnectionId': nativeSender.peerConnectionId,
        'rtpSenderId': sender.senderId,
        'keyManagerId': keyManager.id,
        'algorithm': algorithm.index,
        'type': 'sender',
      });
      var frameCryptorId = response['frameCryptorId'];
      return FrameCryptorImpl(frameCryptorId);
    } on PlatformException catch (e) {
      throw 'Unable to FrameCryptorFactory::createFrameCryptorForRtpSender: ${e.message}';
    }
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpReceiver({
    required RTCRtpReceiver receiver,
    required Algorithm algorithm,
    required KeyManager keyManager,
  }) async {
    RTCRtpReceiverNative nativeReceiver = receiver as RTCRtpReceiverNative;

    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorFactoryCreateFrameCryptor', <String, dynamic>{
        'peerConnectionId': nativeReceiver.peerConnectionId,
        'rtpReceiverId': nativeReceiver.receiverId,
        'keyManagerId': keyManager.id,
        'algorithm': algorithm.index,
        'type': 'receiver',
      });
      var frameCryptorId = response['frameCryptorId'];
      return FrameCryptorImpl(frameCryptorId);
    } on PlatformException catch (e) {
      throw 'Unable to FrameCryptorFactory::createFrameCryptorForRtpReceiver: ${e.message}';
    }
  }

  @override
  Future<KeyManager> createDefaultKeyManager() async {
    try {
      final response = await WebRTC.invokeMethod(
          'frameCryptorFactoryCreateKeyManager', <String, dynamic>{});
      String keyManagerId = response['keyManagerId'];
      return KeyManagerImpl(keyManagerId);
    } on PlatformException catch (e) {
      throw 'Unable to FrameCryptorFactory::createKeyManager: ${e.message}';
    }
  }
}

class FrameCryptorImpl implements FrameCryptor {
  FrameCryptorImpl(this._frameCryptorId);
  final String _frameCryptorId;

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
