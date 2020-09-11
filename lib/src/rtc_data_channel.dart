import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'enums.dart';
import 'utils.dart';

final _typeStringToMessageType = <String, MessageType>{
  'text': MessageType.text,
  'binary': MessageType.binary
};

/// Initialization parameters for [RTCDataChannel].
class RTCDataChannelInit {
  bool ordered = true;
  int maxRetransmitTime = -1;
  int maxRetransmits = -1;
  String protocol = 'sctp'; //sctp | quic
  bool negotiated = false;
  int id = 0;
  Map<String, dynamic> toMap() {
    return {
      'ordered': ordered,
      'maxRetransmitTime': maxRetransmitTime,
      'maxRetransmits': maxRetransmits,
      'protocol': protocol,
      'negotiated': negotiated,
      'id': id
    };
  }
}

/// A class that represents a datachannel message.
/// Can either contain binary data as a [Uint8List] or
/// text data as a [String].
class RTCDataChannelMessage {
  /// Construct a text message with a [String].
  RTCDataChannelMessage(String text) {
    _data = text;
    _isBinary = false;
  }

  /// Construct a binary message with a [Uint8List].
  RTCDataChannelMessage.fromBinary(Uint8List binary) {
    _data = binary;
    _isBinary = true;
  }

  dynamic _data;
  bool _isBinary;

  /// Tells whether this message contains binary.
  /// If this is false, it's a text message.
  bool get isBinary => _isBinary;

  MessageType get type => isBinary ? MessageType.binary : MessageType.text;

  /// Text contents of this message as [String].
  /// Use only on text messages.
  /// See: [isBinary].
  String get text => _data;

  /// Binary contents of this message as [Uint8List].
  /// Use only on binary messages.
  /// See: [isBinary].
  Uint8List get binary => _data;
}

typedef RTCDataChannelStateCallback = void Function(RTCDataChannelState state);
typedef RTCDataChannelOnMessageCallback = void Function(
    RTCDataChannelMessage message);

/// A class that represents a WebRTC datachannel.
/// Can send and receive text and binary messages.
class RTCDataChannel {
  RTCDataChannel(this._peerConnectionId, this._label, this._dataChannelId) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    _eventSubscription = _eventChannelFor(_peerConnectionId, _dataChannelId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }
  final String _peerConnectionId;
  final String _label;
  final int _dataChannelId;
  RTCDataChannelState _state;
  final _channel = WebRTC.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;

  /// Get current state.
  RTCDataChannelState get state => _state;

  /// Get label.
  String get label => _label;

  /// Event handler for datachannel state changes.
  /// Assign this property to listen for state changes.
  /// Will be passed one argument, [state], which is an [RTCDataChannelState].
  RTCDataChannelStateCallback onDataChannelState;

  /// Event handler for messages. Assign this property
  /// to listen for messages from this [RTCDataChannel].
  /// Will be passed a a [message] argument, which is an [RTCDataChannelMessage] that will contain either
  /// binary data as a [Uint8List] or text data as a [String].
  RTCDataChannelOnMessageCallback onMessage;

  final _stateChangeController =
      StreamController<RTCDataChannelState>.broadcast(sync: true);
  final _messageController =
      StreamController<RTCDataChannelMessage>.broadcast(sync: true);

  /// Stream of state change events. Emits the new state on change.
  /// Closes when the [RTCDataChannel] is closed.
  Stream<RTCDataChannelState> stateChangeStream;

  /// Stream of incoming messages. Emits the message.
  /// Closes when the [RTCDataChannel] is closed.
  Stream<RTCDataChannelMessage> messageStream;

  /// RTCDataChannel event listener.
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'dataChannelStateChanged':
        //int dataChannelId = map['id'];
        _state = rtcDataChannelStateForString(map['state']);
        onDataChannelState?.call(_state);

        _stateChangeController.add(_state);
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
    final PlatformException e = obj;
    throw e;
  }

  /// Send a message to this datachannel.
  /// To send a text message, use the default constructor to instantiate a text [RTCDataChannelMessage]
  /// for the [message] parameter.
  /// To send a binary message, pass a binary [RTCDataChannelMessage]
  /// constructed with [RTCDataChannelMessage.fromBinary]
  Future<void> send(RTCDataChannelMessage message) async {
    await _channel.invokeMethod('dataChannelSend', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'dataChannelId': _dataChannelId,
      'type': message.isBinary ? 'binary' : 'text',
      'data': message.isBinary ? message.binary : message.text,
    });
  }

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
