import 'dart:html';

typedef void OnMessageCallback(dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();

class SimpleWebSocket {
  String _url;
  var _socket;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;

  SimpleWebSocket(Uri uri) {
    _url = uri.replace(scheme: uri.scheme == 'http' ? 'ws' : 'wss').toString();
  }

  connect() async {
    try {
      _socket = WebSocket(_url);
      _socket.onOpen.listen((e) {
        this?.onOpen();
      });

      _socket.onMessage.listen((e) {
        this?.onMessage(e.data);
      });

      _socket.onClose.listen((e) {
        this?.onClose(e.code, e.reason);
      });
    } catch (e) {
      this?.onClose(500, e.toString());
    }
  }

  send(data) {
    if (_socket != null && _socket.readyState == WebSocket.OPEN) {
      _socket.send(data);
      print('send: $data');
    } else {
      print('WebSocket not connected, message $data not sent');
    }
  }

  close() {
    if (_socket != null) _socket.close();
  }
}
