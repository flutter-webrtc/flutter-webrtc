import 'dart:core';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';

class KeyManagerImpl implements KeyManager {
  KeyManagerImpl(this._id);
  final String _id;
  @override
  String get id => _id;

  @override
  Future<bool> setKey(int index, Uint8List key) async {
    try {
      final response = await WebRTC.invokeMethod('setKey', <String, dynamic>{
        'keyManagerId': _id,
        'index': index,
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
      final response = await WebRTC.invokeMethod('setKeys', <String, dynamic>{
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
      final response = await WebRTC.invokeMethod('getKeys', <String, dynamic>{
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
      final response =
          await WebRTC.invokeMethod('disposeKeyManager', <String, dynamic>{
        'keyManagerId': _id,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to KeyManagerImpl::dispose: ${e.message}';
    }
  }
}

class FrameCyrptorFactoryImpl implements FrameCyrptorFactory {
  FrameCyrptorFactoryImpl._internal();

  static final FrameCyrptorFactoryImpl instance =
      FrameCyrptorFactoryImpl._internal();

  @override
  Future<FrameCyrptor> frameCyrptorFromRtpSender({
    required RTCRtpSender sender,
    required Algorithm algorithm,
    required KeyManager keyManager,
  }) async {
    var encryptor =
        FrameCyrptorImplForRTCRtpSender(sender as RTCRtpSenderNative);
    await encryptor.setupFrameCrypto(algorithm, keyManager);
    return encryptor;
  }

  @override
  Future<FrameCyrptor> frameCyrptorFromRtpReceiver({
    required RTCRtpReceiver receiver,
    required Algorithm algorithm,
    required KeyManager keyManager,
  }) async {
    var decryptor =
        FrameCyrptorImplForRtpReceiver(receiver as RTCRtpReceiverNative);
    await decryptor.setupFrameCrypto(algorithm, keyManager);
    return decryptor;
  }

  @override
  Future<KeyManager> createDefaultKeyManager() async {
    try {
      final response =
          await WebRTC.invokeMethod('createKeyManager', <String, dynamic>{});
      String keyManagerId = response['keyManagerId'];
      return KeyManagerImpl(keyManagerId);
    } on PlatformException catch (e) {
      throw 'Unable to FrameCyrptorFactoryImpl::createKeyManager: ${e.message}';
    }
  }
}

class FrameCyrptorImplForRTCRtpSender implements FrameCyrptor {
  FrameCyrptorImplForRTCRtpSender(this._sender);
  final RTCRtpSenderNative _sender;

  Future<bool> setupFrameCrypto(
      Algorithm algorithm, KeyManager keyManager) async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpSenderFrameCryptoSetup', <String, dynamic>{
        'peerConnectionId': _sender.peerConnectionId,
        'rtpSenderId': _sender.senderId,
        'keyManagerId': keyManager.id,
        'algorithm': algorithm.index,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::setupFrameCrypto: ${e.message}';
    }
  }

  @override
  Future<bool> setKeyIndex(int index) async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpSenderFrameSetKeyIndex', <String, dynamic>{
        'peerConnectionId': _sender.peerConnectionId,
        'rtpSenderId': _sender.senderId,
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
          'rtpSenderFrameGetKeyIndex', <String, dynamic>{
        'peerConnectionId': _sender.peerConnectionId,
        'rtpSenderId': _sender.senderId,
      });
      return response['keyIndex'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::keyIndex: ${e.message}';
    }
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpSenderFrameCryptoSetEnabled', <String, dynamic>{
        'peerConnectionId': _sender.peerConnectionId,
        'rtpSenderId': _sender.senderId,
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
      final response = await WebRTC.invokeMethod(
          'rtpSenderFrameCryptoGetEnabled', <String, dynamic>{
        'peerConnectionId': _sender.peerConnectionId,
        'rtpSenderId': _sender.senderId,
      });
      return response['enabled'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::enabled: ${e.message}';
    }
  }

  @override
  RTCRtpSender? get sender => _sender;

  @override
  RTCRtpReceiver? get receiver => null;
}

class FrameCyrptorImplForRtpReceiver implements FrameCyrptor {
  FrameCyrptorImplForRtpReceiver(this._receiver);
  final RTCRtpReceiverNative _receiver;

  Future<bool> setupFrameCrypto(
      Algorithm algorithm, KeyManager keyManager) async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpSenderFrameCryptoSetup', <String, dynamic>{
        'peerConnectionId': _receiver.peerConnectionId,
        'rtpReceiverId': _receiver.receiverId,
        'keyManagerId': keyManager.id,
        'algorithm': algorithm.index,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpReceiverNative::enableFrameCrypto: ${e.message}';
    }
  }

  @override
  Future<bool> setKeyIndex(int index) async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpReceiverFrameSetKeyIndex', <String, dynamic>{
        'peerConnectionId': _receiver.peerConnectionId,
        'rtpSenderId': _receiver.receiverId,
        'keyIndex': index,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpReceiverNative::setKeyIndex: ${e.message}';
    }
  }

  @override
  Future<int> get keyIndex async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpReceiverFrameGetKeyIndex', <String, dynamic>{
        'peerConnectionId': _receiver.peerConnectionId,
        'rtpSenderId': _receiver.receiverId,
      });
      return response['keyIndex'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpReceiverNative::getKeyIndex: ${e.message}';
    }
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpReceiverFrameCryptoSetEnabled', <String, dynamic>{
        'peerConnectionId': _receiver.peerConnectionId,
        'rtpReceiverId': _receiver.receiverId,
        'enabled': enabled,
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpReceiverNative::setEnabled: ${e.message}';
    }
  }

  @override
  Future<bool> get enabled async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpReceiverFrameCryptoGetEnabled', <String, dynamic>{
        'peerConnectionId': _receiver.peerConnectionId,
        'rtpReceiverId': _receiver.receiverId,
      });
      return response['enabled'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpReceiverNative::getEnabled: ${e.message}';
    }
  }

  @override
  RTCRtpReceiver? get receiver => _receiver;

  @override
  RTCRtpSender? get sender => null;
}
