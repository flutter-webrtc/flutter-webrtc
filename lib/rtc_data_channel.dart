import 'package:webrtc/webrtc.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class RTCDataChannelInit {
  bool ordered;
  int maxPacketLifeTime;
  int maxRetransmits;
  String protocol;
  bool negotiated;
  int id = 0;
  Map<String, dynamic> toMap() {
    return {
      'ordered': ordered,
      'maxPacketLifeTime': maxPacketLifeTime,
      'maxRetransmits': maxRetransmits,
      'protocol': protocol,
      'negotiated': negotiated,
      'id': id
    };
  }
}

enum RTCDataChannelState {
  RTCDataChannelConnecting,
  RTCDataChannelOpen,
  RTCDataChannelClosing,
  RTCDataChannelClosed,
}

typedef void RTCDataChannelStateCallback(RTCDataChannelState state);
typedef void RTCDataChannelOnMessageCallback(String data);

class RTCDataChannel {
  String _peerConnectionId;
  String _label;
  int _dataChannelId;
  MethodChannel _channel = WebRTC.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;
  RTCDataChannelStateCallback onDataChannelState;
  RTCDataChannelOnMessageCallback onMessage;

  RTCDataChannel(this._peerConnectionId, this._label, this._dataChannelId){
    _eventSubscription = _eventChannelFor(_dataChannelId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  /*
   * RTCDataChannel event listener.
   */
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
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

  void send(String type, dynamic data){
    _channel.invokeMethod('dataChannelSend',
        <String, dynamic>{ 'peerConnectionId': _peerConnectionId,
        'dataChannelId': _dataChannelId,
        'type': type,
        'data': data});
  }

  void close() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod('dataChannelClose',
        <String, dynamic>{'peerConnectionId': _peerConnectionId, 'dataChannelId': _dataChannelId});
  }
}
