import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:webrtc/webrtc.dart';

const ASCII_START = 33;
const ASCII_END = 126;
const NUMERIC_START = 48;
const NUMERIC_END = 57;

/// Generates a random integer where [from] <= [to].
int randomBetween(int from, int to) {
  if (from > to) throw new Exception('$from cannot be > $to');
  var rand = new Random();
  return ((to - from) * rand.nextDouble()).toInt() + from;
}

/// Generates a random string of [length] with characters
/// between ascii [from] to [to].
/// Defaults to characters of ascii '!' to '~'.
String randomString(int length, {int from: ASCII_START, int to: ASCII_END}) {
  return new String.fromCharCodes(
      new List.generate(length, (index) => randomBetween(from, to)));
}

/// Generates a random string of [length] with only numeric characters.
String randomNumeric(int length) =>
    randomString(length, from: NUMERIC_START, to: NUMERIC_END);

class Signaling {
  String _self_id = randomNumeric(6);
  var _socket;
  var _peerConnections = new Map<String, RTCPeerConnection>();
  var _data = new Map<int, RTCDataChannel>();
  var _messageController = new StreamController();
  Stream _messageStream;
  var _session_id;

  MediaStream _localStream;

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  close() {
    if (_socket != null) _socket.close();
  }

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  var _url;
  var _name;
  Signaling(this._url, this._name);

  void invite(String peer_id, String media) {
    String sessionId = this._self_id + '-' + peer_id;
    _send('invite', {
      'session_id': sessionId,
      'id': _self_id,
      'to': peer_id,
      'media': media,
    });
    this._session_id = sessionId;
  }

  void leave() {
    _send('bye', {
      'session_id': this._session_id,
      'from': this._self_id,
    });
  }

  void connect() async {
    _messageStream = _messageController.stream.asBroadcastStream();
    _socket = await WebSocket.connect(_url);
    _socket.listen((data) {
      print('Recivied data: ' + data);
      _messageController.add(JSON.decode(data));
    }, onDone: () {
      print('Closed by server!');
      _messageController.add({
        'type': 'close',
        'id': _self_id,
      });
    });

    _send('new', {
      'name': _name,
      'id': _self_id,
      'user_agent': 'flutter-webrtc/ios-plugin 0.0.1'
    });

    onRinging.listen((message) {
      Map<String, dynamic> mapData = message;
      var data = mapData['data'];
      var id = data['id'];
      var media = data['media'];
      _createPeerConnection(id, media).then((pc) {
        _peerConnections[id] = pc;
        _createOffer(id, pc);
      });
    });

    onBye.listen((message) {
      Map<String, dynamic> mapData = message;
      var data = mapData['data'];
      var from = data['from'];
      var to = data['to'];
      var session_id = data['session_id'];
      print('bye: ' + session_id);

      if (_localStream != null) {
        _localStream.dispose();
        _localStream = null;
      }

      var pc = _peerConnections[to];
      if (pc != null) {
        pc.close();
        _peerConnections.remove(to);
      }
      this._session_id = null;
    });

    onCandidate.listen((message) {
      Map<String, dynamic> mapData = message;
      var data = mapData['data'];
      var id = data['from'];
      var candidateMap = data['candidate'];
      var pc = _peerConnections[id];

      if (pc != null) {
        RTCIceCandidate candidate = new RTCIceCandidate(
            candidateMap['candidate'],
            candidateMap['sdpMid'],
            candidateMap['sdpMLineIndex']);
        pc.addCandidate(candidate);
      }
    });

    onInvite.listen((message) async {
      /*Create stream and pc for called side*/
      Map<String, dynamic> mapData = message;
      var data = mapData['data'];
      var id = data['from'];
      var media = data['media'];
      var session_id = data['session_id'];
      this._session_id = session_id;

      _createPeerConnection(id, media).then((pc) {
        _peerConnections[id] = pc;
      });
    });

    onLeave.listen((message) {
      Map<String, dynamic> data = message;
      var id = data['data'];
      _peerConnections.remove(id);
      _data.remove(id);
    });

    onOffer.listen((message) async {
      Map<String, dynamic> mapData = message;
      var data = mapData['data'];
      var id = data['from'];
      var description = data['description'];

      RTCPeerConnection pc = _peerConnections[id];
      if (pc != null) {
        await pc.setRemoteDescription(
            new RTCSessionDescription(description['sdp'], description['type']));
        _createAnswer(id, pc);
      }
    });

    onAnswer.listen((message) {
      Map<String, dynamic> mapData = message;
      var data = mapData['data'];
      var id = data['from'];
      var description = data['description'];

      var pc = _peerConnections[id];
      if (pc != null) {
        pc.setRemoteDescription(
            new RTCSessionDescription(description['sdp'], description['type']));
      }
    });
  }

  get onRinging => _messageStream.where((m) => m['type'] == 'ringing');

  get onInvite => _messageStream.where((m) => m['type'] == 'invite');

  get onOffer => _messageStream.where((m) => m['type'] == 'offer');

  get onAnswer => _messageStream.where((m) => m['type'] == 'answer');

  get onCandidate => _messageStream.where((m) => m['type'] == 'candidate');

  get onPeers => _messageStream.where((m) => m['type'] == 'peers');

  get onLeave => _messageStream.where((m) => m['type'] == 'leave');

  get onBye => _messageStream.where((m) => m['type'] == 'bye');

  get onRemoteStreamAdd => _messageStream.where((m) => m['type'] == 'add');

  get onRemoteStreamRemoved =>
      _messageStream.where((m) => m['type'] == 'remove');

  get onData => _messageStream.where((m) => m['type'] == 'data');

  get onClose => _messageStream.where((m) => m['type'] == 'close');

  get onLocalStream => _messageStream.where((m) => m['type'] == 'localstream');

  Future<MediaStream> createStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = await navigator.getUserMedia(mediaConstraints);
    _messageController.add({'type': 'localstream', 'stream': stream});
    return stream;
  }

  send(data) {
    _data.forEach((k, d) {
      d.send('text', data);
    });
  }

  _createPeerConnection(id, media) async {
    _localStream = await createStream();
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    pc.addStream(_localStream);
    pc.onIceCandidate = (candidate) {
      _send('candidate', {
        'to': id,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMlineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
        'session_id': this._session_id,
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

  _createOffer(String id, RTCPeerConnection pc) async {
    try {
      RTCSessionDescription s = await pc.createOffer(_constraints);
      pc.setLocalDescription(s);
      _send('offer', {
        'to': id,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._session_id,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _createAnswer(String id, RTCPeerConnection pc) async {
    try {
      RTCSessionDescription s = await pc.createAnswer(_constraints);
      pc.setLocalDescription(s);
      _send('answer', {
        'to': id,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._session_id,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _send(event, data) {
    data['type'] = event;
    if (_socket != null) _socket.add(JSON.encode(data));
    print('send: ' + JSON.encode(data));
  }
}
