import 'dart:async';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'utils.dart';

final _typeStringToMessageType = <String, MessageType>{
  'text': MessageType.text,
  'binary': MessageType.binary
};

/// A class that represents a WebRTC datachannel.
/// Can send and receive text and binary messages.
class RTCDataChannelNative extends RTCDataChannel {
  RTCDataChannelNative(
      this._peerConnectionId, this._label, this._dataChannelId, this._flutterId,
      {RTCDataChannelState? state}) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    if (state != null) {
      _state = state;
    }
    _eventSubscription = _eventChannelFor(_peerConnectionId, _flutterId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }
  final String _peerConnectionId;
  final String _label;
  int _bufferedAmount = 0;
  @override
  // ignore: overridden_fields
  int? bufferedAmountLowThreshold;

  /// Id for the datachannel in the Flutter <-> Native layer.
  final String _flutterId;

  int? _dataChannelId;
  RTCDataChannelState? _state;
  StreamSubscription<dynamic>? _eventSubscription;
  bool _closed = false;

  /// Whether close() has run on this channel. Owners use it to drop channels
  /// they no longer have to close.
  bool get isClosed => _closed;

  @override
  RTCDataChannelState? get state => _state;

  @override
  int? get id => _dataChannelId;

  /// Get label.
  @override
  String? get label => _label;

  @override
  int? get bufferedAmount => _bufferedAmount;

  final _stateChangeController =
      StreamController<RTCDataChannelState>.broadcast(sync: true);
  final _messageController =
      StreamController<RTCDataChannelMessage>.broadcast(sync: true);

  /// RTCDataChannel event listener.
  void eventListener(dynamic event) {
    // Nothing to report once the channel is closed, and the controllers are
    // gone by then. An event can still arrive here after close(): the app's
    // own callback below may close this channel, or close the peer connection
    // that owns it, and close() runs synchronously up to its first await, so
    // the controllers are already closed when control comes back.
    if (_closed) {
      return;
    }
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'dataChannelStateChanged':
        _dataChannelId = map['id'];
        _state = rtcDataChannelStateForString(map['state']);
        onDataChannelState?.call(_state!);

        if (!_stateChangeController.isClosed) {
          _stateChangeController.add(_state!);
        }
        break;
      case 'dataChannelReceiveMessage':
        _dataChannelId = map['id'];

        var type = _typeStringToMessageType[map['type']];
        dynamic data = map['data'];
        RTCDataChannelMessage message;
        if (type == MessageType.binary) {
          message = RTCDataChannelMessage.fromBinary(data);
        } else {
          message = RTCDataChannelMessage(data);
        }

        onMessage?.call(message);

        if (!_messageController.isClosed) {
          _messageController.add(message);
        }
        break;

      case 'dataChannelBufferedAmountChange':
        _bufferedAmount = map['bufferedAmount'];
        if (bufferedAmountLowThreshold != null) {
          if (_bufferedAmount < bufferedAmountLowThreshold!) {
            onBufferedAmountLow?.call(_bufferedAmount);
          }
        }
        onBufferedAmountChange?.call(_bufferedAmount, map['changedAmount']);
        break;
    }
  }

  EventChannel _eventChannelFor(String peerConnectionId, String flutterId) {
    return EventChannel(
        'FlutterWebRTC/dataChannelEvent$peerConnectionId$flutterId');
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  Future<int> getBufferedAmount() async {
    final Map<dynamic, dynamic> response = await WebRTC.invokeMethod(
        'dataChannelGetBufferedAmount', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _flutterId
    });
    _bufferedAmount = response['bufferedAmount'];
    return _bufferedAmount;
  }

  @override
  Future<void> send(RTCDataChannelMessage message) async {
    await WebRTC.invokeMethod('dataChannelSend', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _flutterId,
      'type': message.isBinary ? 'binary' : 'text',
      'data': message.isBinary ? message.binary : message.text,
    });
  }

  @override
  Future<void> close() async {
    // Closing twice would close already closed stream controllers and send a
    // second dataChannelClose for a channel the platform side has forgotten,
    // so the first call wins and later ones do nothing.
    if (_closed) {
      return;
    }
    _closed = true;
    await _stateChangeController.close();
    await _messageController.close();
    await _eventSubscription?.cancel();
    await WebRTC.invokeMethod('dataChannelClose', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _flutterId
    });
  }
}
