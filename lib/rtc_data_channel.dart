import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'utils.dart';
import 'dart:io' show Platform;

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
  dynamic _data;
  bool _isBinary;

  /// Construct a text message with a [String].
  RTCDataChannelMessage(String text) {
    this._data = text;
    this._isBinary = false;
  }

  /// Construct a binary message with a [Uint8List].
  RTCDataChannelMessage.fromBinary(Uint8List binary) {
    this._data = binary;
    this._isBinary = true;
  }

  /// Construct a binary message with a base64 encoded [String]
  /// to be decoded into binary.
  RTCDataChannelMessage.fromBase64Binary(String encodedBinary) {
    this._data = base64.decode(encodedBinary);
    this._isBinary = true;
  }

  /// Tells whether this message contains binary.
  /// If this is false, it's a text message.
  bool get isBinary => _isBinary;

  /// Text contents of this message as [String].
  /// Use only on text messages.
  /// See: [isBinary].
  String get text => _data;

  /// Binary contents of this message as [Uint8List].
  /// Use only on binary messages.
  /// See: [isBinary].
  Uint8List get binary => _data;

  /// Binary contents of this message as a base64 encoded [String].
  /// Use only on binary messages.
  String get binaryAsBase64 => base64.encode(_data);
}

enum RTCDataChannelState {
  RTCDataChannelConnecting,
  RTCDataChannelOpen,
  RTCDataChannelClosing,
  RTCDataChannelClosed,
}

typedef void RTCDataChannelStateCallback(RTCDataChannelState state);
typedef void RTCDataChannelOnMessageCallback(String type, RTCDataChannelMessage message);

/// A class that represents a WebRTC datachannel.
/// Can send and receive text and binary messages.
class RTCDataChannel {
  String _peerConnectionId;
  String _label;
  int _dataChannelId;
  RTCDataChannelState _state;
  MethodChannel _channel = WebRTC.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;
  
  /// Get current state.
  RTCDataChannelState get state => _state;

  /// Event handler for datachannel state changes.
  /// Assign this property to listen for state changes.
  /// Will be passed one argument, [state], which is an [RTCDataChannelState]. 
  RTCDataChannelStateCallback onDataChannelState;

  /// Event handler for messages. Assign this property 
  /// to listen for messages from this [RTCDataChannel].
  /// Will be passed a [type] argument, which can be either "binary" or "text"
  /// depending on the type of message recieved 
  /// and a [message] argument, which is an [RTCDataChannelMessage] that will contain either
  /// binary data as a [Uint8List] or text data as a [String], as defined by [type].
  RTCDataChannelOnMessageCallback onMessage;

  RTCDataChannel(this._peerConnectionId, this._label, this._dataChannelId){
    _eventSubscription = _eventChannelFor(_dataChannelId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }
  
  /// RTCDataChannel event listener.
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'dataChannelStateChanged':
        //int dataChannelId = map['id'];
        _state = rtcDataChannelStateForString(map['state']);
        if (this.onDataChannelState != null)
          this.onDataChannelState(_state);
        break;
      case 'dataChannelReceiveMessage':
        //int dataChannelId = map['id'];
        
        String type = map['type'];
        dynamic data = map['data'];
        RTCDataChannelMessage message;
        if (type == 'binary') {
          if (Platform.isAndroid) {
            message = RTCDataChannelMessage.fromBase64Binary(data);
          }
          else {
            message = RTCDataChannelMessage.fromBinary(data);
          }
        }
        else {
          message = RTCDataChannelMessage(data);
        }

        if (this.onMessage != null)
          this.onMessage(type, message);
        break;
    }
  }

  EventChannel _eventChannelFor(int dataChannelId) {
    return new EventChannel(
        'cloudwebrtc.com/WebRTC/dataChannelEvent$dataChannelId');
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }

  /// Send a message to this datachannel.
  /// To send a text message, pass "text" to [type]
  /// And use the default constructor to instantiate a text [RTCDataChannelMessage]
  /// for the [message] parameter.
  /// To send a binary message, pass "binary" to [type]
  /// and pass a binary [RTCDataChannelMessage]
  /// constructed with [RTCDataChannelMessage.fromBinary]
  /// or [RTCDataChannelMessage.fromBase64Binary].
  Future<void> send(String type, RTCDataChannelMessage message) async {
    dynamic data;
    if (message.isBinary) {
      if (Platform.isAndroid) {
        data = message.binaryAsBase64;
      }
      else {
        data = message.binary;
      }
    }
    else {
      data = message.text;
    }
    await _channel.invokeMethod('dataChannelSend',
        <String, dynamic>{ 'peerConnectionId': _peerConnectionId,
        'dataChannelId': _dataChannelId,
        'type': type,
        'data': data});
  }

  Future<void> close() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod('dataChannelClose',
        <String, dynamic>{'peerConnectionId': _peerConnectionId, 'dataChannelId': _dataChannelId});
  }
}
