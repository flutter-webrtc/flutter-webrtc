import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as jsutil;

import '../interface/enums.dart';
import '../interface/rtc_data_channel.dart';

class RTCDataChannelWeb extends RTCDataChannel {
  RTCDataChannelWeb(this._jsDc) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    _jsDc.onClose.listen((_) {
      _state = RTCDataChannelState.RTCDataChannelClosed;
      _stateChangeController.add(_state);
      onDataChannelState?.call(_state);
    });
    _jsDc.onOpen.listen((_) {
      _state = RTCDataChannelState.RTCDataChannelOpen;
      _stateChangeController.add(_state);
      onDataChannelState?.call(_state);
    });
    _jsDc.onMessage.listen((event) async {
      var msg = await _parse(event.data);
      _messageController.add(msg);
      onMessage?.call(msg);
    });
  }

  final html.RtcDataChannel _jsDc;
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
    if (data is html.Blob) {
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
    if (!message.isBinary) {
      _jsDc.send(message.text);
    } else {
      // This may just work
      _jsDc.sendByteBuffer(message.binary.buffer);
      // If not, convert to ArrayBuffer/Blob
    }
    return Future.value();
  }

  @override
  Future<void> close() {
    _jsDc.close();
    return Future.value();
  }
}
