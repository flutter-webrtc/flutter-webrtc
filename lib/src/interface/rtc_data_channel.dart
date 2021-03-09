import 'dart:async';
import 'dart:typed_data';

import 'enums.dart';

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

  late dynamic _data;
  late bool _isBinary;

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
    RTCDataChannelMessage data);

abstract class RTCDataChannel {
  RTCDataChannel();

  RTCDataChannelStateCallback? onDataChannelState;
  RTCDataChannelOnMessageCallback? onMessage;

  /// Get current state.
  RTCDataChannelState? get state;

  /// Stream of state change events. Emits the new state on change.
  /// Closes when the [RTCDataChannel] is closed.
  late Stream<RTCDataChannelState> stateChangeStream;

  /// Stream of incoming messages. Emits the message.
  /// Closes when the [RTCDataChannel] is closed.
  late Stream<RTCDataChannelMessage> messageStream;

  /// Send a message to this datachannel.
  /// To send a text message, use the default constructor to instantiate a text [RTCDataChannelMessage]
  /// for the [message] parameter.
  /// To send a binary message, pass a binary [RTCDataChannelMessage]
  /// constructed with [RTCDataChannelMessage.fromBinary]
  Future<void> send(RTCDataChannelMessage message);

  Future<void> close();
}
