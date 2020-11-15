import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:js_util' as jsutil;

import 'package:dart_webrtc/dart_webrtc.dart' as dart_webrtc;

import '../interface/enums.dart';
import '../interface/rtc_data_channel.dart';

class RTCDataChannelWeb extends RTCDataChannel {
  RTCDataChannelWeb(this._jsDc) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    _jsDc.onclose = allowInterop((dart_webrtc.Event event) {
      _state = RTCDataChannelState.RTCDataChannelClosed;
      _stateChangeController.add(_state);
      onDataChannelState?.call(_state);
    });

    _jsDc.onopen = allowInterop((dart_webrtc.Event event) {
      _state = RTCDataChannelState.RTCDataChannelOpen;
      _stateChangeController.add(_state);
      onDataChannelState?.call(_state);
    });

    _jsDc.onmessage = allowInterop((dart_webrtc.MessageEvent event) async {
      if (event == null || event.data == null) {
        return;
      }
      var msg = await _parse(event.data);
      _messageController.add(msg);
      onMessage?.call(msg);
    });
  }

  final dart_webrtc.RTCDataChannel _jsDc;
  RTCDataChannelState _state = RTCDataChannelState.RTCDataChannelConnecting;

  @override
  RTCDataChannelState get state => _state;

  final _stateChangeController =
      StreamController<RTCDataChannelState>.broadcast(sync: true);
  final _messageController =
      StreamController<RTCDataChannelMessage>.broadcast(sync: true);

  Future<RTCDataChannelMessage> _parse(dynamic data) async {
    if (data is String) return RTCDataChannelMessage(data);
    dynamic arrayBuffer;
    if (data is Blob) {
      // This should never happen actually
      arrayBuffer = await jsutil
          .promiseToFuture(jsutil.callMethod(data, 'arrayBuffer', []));
    } else {
      arrayBuffer = data;
    }
    return RTCDataChannelMessage.fromBinary(arrayBuffer.asUint8List());
  }

  @override
  Future<void> send(RTCDataChannelMessage message) {
    try {
      _jsDc.send(message.isBinary ? message.binary : message.text);
    } catch (e) {
      print(e.toString());
    }

    return Future.value();
  }

  @override
  Future<void> close() {
    _jsDc.close();
    return Future.value();
  }
}
