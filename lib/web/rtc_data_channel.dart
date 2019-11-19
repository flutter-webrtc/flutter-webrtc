import 'dart:async';
import 'dart:html' as HTML;
import 'dart:js_util' as JSUtils;
import 'dart:typed_data';

import '../enums.dart';

final _typeStringToMessageType = <String, MessageType>{
  'text': MessageType.text,
  'binary': MessageType.binary
};

final _messageTypeToTypeString = <MessageType, String>{
  MessageType.text: 'text',
  MessageType.binary: 'binary'
};

class RTCDataChannelInit {
  bool ordered = true;
  int maxRetransmitTime = -1;
  int maxRetransmits = -1;
  String protocol = 'sctp'; //sctp | quic
  String binaryType = 'text'; // "binary" || text
  bool negotiated = false;
  int id = 0;
  Map<String, dynamic> toMap() {
    return {
      'ordered': ordered,
      if (maxRetransmitTime > 0)
        //https://www.chromestatus.com/features/5198350873788416
        'maxPacketLifeTime': maxRetransmitTime,
      if (maxRetransmits > 0) 'maxRetransmits': maxRetransmits,
      'protocol': protocol,
      'negotiated': negotiated,
      if (id != 0) 'id': id
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

typedef void RTCDataChannelStateCallback(RTCDataChannelState state);
typedef void RTCDataChannelOnMessageCallback(RTCDataChannelMessage data);

class RTCDataChannel {
  final HTML.RtcDataChannel _jsDc;
  RTCDataChannelStateCallback onDataChannelState;
  RTCDataChannelOnMessageCallback onMessage;
  RTCDataChannelState _state = RTCDataChannelState.RTCDataChannelConnecting;

  /// Get current state.
  RTCDataChannelState get state => _state;

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

  RTCDataChannel(this._jsDc) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    _jsDc.onClose.listen((_) {
      _state = RTCDataChannelState.RTCDataChannelClosed;
      _stateChangeController.add(_state);
      if (onDataChannelState != null) {
        onDataChannelState(_state);
      }
    });
    _jsDc.onOpen.listen((_) {
      _state = RTCDataChannelState.RTCDataChannelOpen;
      _stateChangeController.add(_state);
      if (onDataChannelState != null) {
        onDataChannelState(_state);
      }
    });
    _jsDc.onMessage.listen((event) async {
      RTCDataChannelMessage msg = await _parse(event.data);
      _messageController.add(msg);
      if (onMessage != null) {
        onMessage(msg);
      }
    });
  }

  Future<RTCDataChannelMessage> _parse(dynamic data) async {
    if (data is String) return RTCDataChannelMessage(data);
    dynamic arrayBuffer;
    if (data is HTML.Blob) {
      // This should never happen actually
      arrayBuffer = await JSUtils.promiseToFuture(
          JSUtils.callMethod(data, 'arrayBuffer', []));
    } else {
      arrayBuffer = data;
    }
    return RTCDataChannelMessage.fromBinary(arrayBuffer.asUint8List());
  }

  Future<void> send(RTCDataChannelMessage message) {
    if (!message.isBinary) {
      _jsDc.send(message.text);
    } else {
      // This may just work
      _jsDc.sendByteBuffer(message.binary.buffer);
      // If not, convert to ArrayBuffer/Blob
    }
    return Future.value();
  }

  Future<void> close() {
    _jsDc.close();
    return Future.value();
  }
}
