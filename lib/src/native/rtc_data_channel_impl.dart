import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'rtc_data_channel_ffi.dart';
import 'utils.dart';

/// State codes used by the FFI transport, see [DataChannelFfiEvent].
const _ffiStateCodes = <RTCDataChannelState>[
  RTCDataChannelState.RTCDataChannelConnecting,
  RTCDataChannelState.RTCDataChannelOpen,
  RTCDataChannelState.RTCDataChannelClosing,
  RTCDataChannelState.RTCDataChannelClosed,
];

final _typeStringToMessageType = <String, MessageType>{
  'text': MessageType.text,
  'binary': MessageType.binary
};

/// A class that represents a WebRTC datachannel.
/// Can send and receive text and binary messages.
class RTCDataChannelNative extends RTCDataChannel {
  RTCDataChannelNative(
      this._peerConnectionId, this._label, this._dataChannelId, this._flutterId,
      {RTCDataChannelState? state, int? ffiHandle})
      : _ffiHandle = ffiHandle {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    if (state != null) {
      _state = state;
    }
    // The platform queues events until one of the transports attaches, so
    // waiting for the FFI table to load loses nothing.
    if (_ffiHandle == null ||
        !DataChannelFfi.enabled ||
        DataChannelFfi.loaded) {
      _connectTransport(DataChannelFfi.instance);
    } else {
      _ready = DataChannelFfi.load().then(_connectTransport);
    }
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
  bool _isClosed = false;

  /// Handle for the FFI transport, null when the platform has none.
  final int? _ffiHandle;

  /// Set once the channel's events arrive through FFI; sends then go through
  /// FFI too.
  DataChannelFfi? _ffi;
  RawReceivePort? _ffiPort;

  /// Completes once the transport is chosen. Sends wait for it so they
  /// cannot overtake each other across transports.
  Future<void>? _ready;

  /// Whether close() has run on this channel. Owners use it to drop channels
  /// they no longer have to close.
  bool get isClosed => _isClosed;

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

  void _connectTransport(DataChannelFfi? ffi) {
    _ready = null;
    if (_isClosed) {
      return;
    }
    final handle = _ffiHandle;
    if (ffi != null && handle != null && DataChannelFfi.enabled) {
      final port = RawReceivePort(_ffiEventListener, 'RTCDataChannel $_label');
      if (ffi.attach(handle, port.sendPort)) {
        _ffi = ffi;
        _ffiPort = port;
        return;
      }
      port.close();
    }
    _eventSubscription = _eventChannelFor(_peerConnectionId, _flutterId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  void _ffiEventListener(dynamic event) {
    if (_isClosed) {
      return;
    }
    final list = event as List<dynamic>;
    _dataChannelId = list[1] as int;
    switch (list[0] as int) {
      case DataChannelFfiEvent.kStateChanged:
        _onStateChanged(_ffiStateCodes[list[2] as int]);
        break;
      case DataChannelFfiEvent.kMessage:
        final bytes = list[3] as Uint8List;
        _onMessage(list[2] as bool
            ? RTCDataChannelMessage.fromBinary(bytes)
            : RTCDataChannelMessage(utf8.decode(bytes, allowMalformed: true)));
        break;
      case DataChannelFfiEvent.kBufferedAmount:
        _onBufferedAmountChange(list[2] as int, list[3] as int);
        break;
    }
  }

  void _onStateChanged(RTCDataChannelState state) {
    _state = state;
    onDataChannelState?.call(state);
    if (!_stateChangeController.isClosed) {
      _stateChangeController.add(state);
    }
  }

  void _onMessage(RTCDataChannelMessage message) {
    onMessage?.call(message);
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  void _onBufferedAmountChange(int bufferedAmount, int changedAmount) {
    _bufferedAmount = bufferedAmount;
    if (bufferedAmountLowThreshold != null) {
      if (_bufferedAmount < bufferedAmountLowThreshold!) {
        onBufferedAmountLow?.call(_bufferedAmount);
      }
    }
    onBufferedAmountChange?.call(_bufferedAmount, changedAmount);
  }

  /// RTCDataChannel event listener.
  void eventListener(dynamic event) {
    // Nothing to report once the channel is closed. The controller guards
    // below cover the other case, where the app's callback closes this channel
    // or its peer connection while the event is being delivered.
    if (_isClosed) {
      return;
    }
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'dataChannelStateChanged':
        _dataChannelId = map['id'];
        _onStateChanged(rtcDataChannelStateForString(map['state']));
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
        _onMessage(message);
        break;

      case 'dataChannelBufferedAmountChange':
        _onBufferedAmountChange(map['bufferedAmount'], map['changedAmount']);
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
    await _ready;
    final ffi = _ffi;
    if (ffi != null) {
      final amount = ffi.bufferedAmount(_ffiHandle!);
      if (amount >= 0) {
        _bufferedAmount = amount;
      }
      return _bufferedAmount;
    }
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
    if (_isClosed) {
      throw Exception('Can\'t send: The RTCDataChannel is closed');
    }
    if (_ready != null) {
      await _ready;
    }
    final ffi = _ffi;
    if (ffi != null) {
      // Like the method channel path, a refused send is not reported here;
      // the channel's state events tell the app what happened.
      ffi.send(
          _ffiHandle!,
          message.isBinary ? message.binary : utf8.encode(message.text),
          message.isBinary);
      return;
    }
    await WebRTC.invokeMethod('dataChannelSend', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _flutterId,
      'type': message.isBinary ? 'binary' : 'text',
      'data': message.isBinary ? message.binary : message.text,
    });
  }

  @override
  Future<void> close() async {
    // The first call wins. Owners close their channels on dispose without
    // knowing whether the app already did, and the platform side only knows
    // the channel once.
    if (_isClosed) {
      return;
    }
    _isClosed = true;
    _state = RTCDataChannelState.RTCDataChannelClosed;
    onDataChannelState?.call(_state!);
    if (!_stateChangeController.isClosed) {
      _stateChangeController.add(_state!);
    }
    await _stateChangeController.close();
    await _messageController.close();
    await _eventSubscription?.cancel();
    if (_ffi != null) {
      _ffi!.detach(_ffiHandle!);
      _ffi = null;
    }
    _ffiPort?.close();
    _ffiPort = null;
    await WebRTC.invokeMethod('dataChannelClose', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _flutterId
    });
  }
}
