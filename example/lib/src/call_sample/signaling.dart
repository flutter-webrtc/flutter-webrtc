import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:webrtc/webrtc.dart';

class Signaling {
  var _socket;
  List<int> _sockets;
  int _self;

  var _connections = new Map<int, RTCPeerConnection>();
  var _data = new Map<int, RTCDataChannel>();
  var _streams = new List<MediaStream>();

  var _messageController = new StreamController();
  Stream _messages;
  Stream _messageStream;

  var _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'}
    ]
  };

  var _dataConfig = {
    'optional': [
      {'RtpDataChannels': true},
      {'DtlsSrtpKeyAgreement': true}
    ]
  };

  var _constraints = {};

  Signaling(url, name) {
    _socket = WebSocket.connect(url);
    _messageStream = _messageController.stream.asBroadcastStream();
    _socket.onOpen.listen((e) {
      _send('join', {'name': name});
    });

    _socket.onClose.listen((e) {});

    _messages = _socket.onMessage.map((e) => JSON.decode(e.data));

    onPeers.listen((message) {
      _self = message['you'];
      _sockets = message['connections'];
    });

    onCandidate.listen((message) {
      var candidate = new RTCIceCandidate(
          message['candidate'], message['sdpMid'], message['sdpMLineIndex']);
      _connections[message['id']].addCandidate(candidate);
    });

    onNew.listen((message) {
      var id = message['id'];
      var pc = _createPeerConnection(message['id']);
      _sockets.add(id);
      _connections[id] = pc;
      _streams.forEach((s) {
        pc.addStream(s);
      });
    });

    onLeave.listen((message) {
      var id = message['id'];
      _connections.remove(id);
      _data.remove(id);
      _sockets.remove(id);
    });

    onOffer.listen((message) {
      var pc = _connections[message['id']];
      pc.setRemoteDescription(new RTCSessionDescription(
          message['description']['sdp'], message['description']['type']));
      _createAnswer(message['id'], pc);
    });

    onAnswer.listen((message) {
      var pc = _connections[message['id']];
      pc.setRemoteDescription(new RTCSessionDescription(
          message['description']['sdp'], message['description']['type']));
    });
  }

  get onOffer => _messages.where((m) => m['type'] == 'offer');

  get onAnswer => _messages.where((m) => m['type'] == 'answer');

  get onCandidate => _messages.where((m) => m['type'] == 'candidate');

  get onNew => _messages.where((m) => m['type'] == 'new');

  get onPeers => _messages.where((m) => m['type'] == 'peers');

  get onLeave => _messages.where((m) => m['type'] == 'leave');

  get onAdd => _messageStream.where((m) => m['type'] == 'add');

  get onRemove => _messageStream.where((m) => m['type'] == 'remove');

  get onData => _messageStream.where((m) => m['type'] == 'data');

  createStream({audio: false, video: false}) {
    var completer = new Completer<MediaStream>();

    navigator.getUserMedia({audio: audio, video: video}).then((stream) {
      /*TODO: */
      _streams.add(stream);

      _sockets.forEach((s) {
        _connections[s] = _createPeerConnection(s);
      });

      _streams.forEach((s) {
        _connections.forEach((k, c) => c.addStream(s));
      });

      _connections.forEach((s, c) => _createDataChannel(s, c));

      _connections.forEach((s, c) => _createOffer(s, c));

      completer.complete(stream);
    });

    return completer.future;
  }

  send(data) {
    _data.forEach((k, d) {
      d.send('text', data);
    });
  }

  _createPeerConnection(id) async  {
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _dataConfig);

    pc.onIceCandidate = (candidate) {
      _send('candidate', {
        'id': id,
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      });
    };

    pc.onAddStream = ((stream) {
      _messageController.add({'type': 'add', 'id': id, 'stream': stream});
    });

    pc.onRemoveStream = (stream) {
      _messageController.add({'type': 'remove', 'id': id, 'stream': stream});
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (data) {
      _messageController.add({'type': 'data', 'id': id, 'data': data});
    };
    _data[id] = channel;
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(int socket, RTCPeerConnection pc) {
    pc.createOffer(_constraints).then((RTCSessionDescription s) {
      pc.setLocalDescription(s);
      _send('offer', {
        'id': socket,
        'description': {'sdp': s.sdp, 'type': s.type}
      });
    });
  }

  _createAnswer(int socket, RTCPeerConnection pc) {
    pc.createAnswer(_constraints).then((RTCSessionDescription s) {
      pc.setLocalDescription(s);
      _send('answer', {
        'id': socket,
        'description': {'sdp': s.sdp, 'type': s.type}
      });
    });
  }

  _send(event, data) {
    data['type'] = event;
    _socket.send(JSON.encode(data));
  }
}
