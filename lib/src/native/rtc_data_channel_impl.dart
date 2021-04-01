import 'dart:async';

import 'package:flutter/services.dart';

import '../interface/enums.dart';
import '../interface/rtc_data_channel.dart';
import 'utils.dart';

final _typeStringToMessageType = <String, MessageType>{
  'text': MessageType.text,
  'binary': MessageType.binary
};

/// A class that represents a WebRTC datachannel.
/// Can send and receive text and binary messages.
class RTCDataChannelNative extends RTCDataChannel {
  RTCDataChannelNative(
      this._peerConnectionId, this._label, this._dataChannelId) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    _eventSubscription = _eventChannelFor(_peerConnectionId, _dataChannelId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }
  final String _peerConnectionId;
  final String _label;
  final int _dataChannelId;
  RTCDataChannelState? _state;
  final _channel = WebRTC.methodChannel();
  StreamSubscription<dynamic>? _eventSubscription;

  @override
  RTCDataChannelState? get state => _state;

  /// Get label.
  String get label => _label;

  final _stateChangeController =
      StreamController<RTCDataChannelState>.broadcast(sync: true);
  final _messageController =
      StreamController<RTCDataChannelMessage>.broadcast(sync: true);

  /// RTCDataChannel event listener.
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'dataChannelStateChanged':
        //int dataChannelId = map['id'];
        _state = rtcDataChannelStateForString(map['state']);
        onDataChannelState?.call(_state!);

        _stateChangeController.add(_state!);
        break;
      case 'dataChannelReceiveMessage':
        //int dataChannelId = map['id'];

        var type = _typeStringToMessageType[map['type']];
        dynamic data = map['data'];
        RTCDataChannelMessage message;
        if (type == MessageType.binary) {
          message = RTCDataChannelMessage.fromBinary(data);
        } else {
          message = RTCDataChannelMessage(data);
        }

        onMessage?.call(message);

        _messageController.add(message);
        break;
    }
  }

  EventChannel _eventChannelFor(String peerConnectionId, int dataChannelId) {
    return EventChannel(
        'FlutterWebRTC/dataChannelEvent$peerConnectionId$dataChannelId');
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  Future<void> send(RTCDataChannelMessage message) async {
    await _channel.invokeMethod('dataChannelSend', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _dataChannelId,
      'type': message.isBinary ? 'binary' : 'text',
      'data': message.isBinary ? message.binary : message.text,
    });
  }

  @override
  Future<void> close() async {
    await _stateChangeController.close();
    await _messageController.close();
    await _eventSubscription?.cancel();
    await _channel.invokeMethod('dataChannelClose', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _dataChannelId
    });
  }
}
