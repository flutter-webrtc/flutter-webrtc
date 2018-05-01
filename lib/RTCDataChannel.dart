import 'package:webrtc/WebRTC.dart';
import 'package:flutter/services.dart';

class RTCDataChannelInit {
  bool ordered;
  int maxPacketLifeTime;
  int maxRetransmits;
  String protocol;
  bool negotiated;
  int id;
}

enum RTCDataChannelState {
  RTCDataChannelConnecting,
  RTCDataChannelOpen,
  RTCDataChannelClosing,
  RTCDataChannelClosed,
}

class RTCDataChannel {
  String _peerConnectionId;
  String _label;
  String _dataChannelId;
  MethodChannel _channel = WebRTC.methodChannel();

  RTCDataChannel(this._peerConnectionId, this._label,this._dataChannelId);

  void send(dynamic data) {
    //"dataChannelSendMessage"
  }

  void close() {
    //"dataChannelClose"
  }
}
