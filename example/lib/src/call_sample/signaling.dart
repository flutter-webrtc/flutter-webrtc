import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:webrtc/webrtc.dart';
import 'random_string.dart';

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

/*
 * 回调类型定义.
 */
typedef void SignalingStateCallback(SignalingState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef void DataChannelMessageCallback(RTCDataChannel dc, data);

class Signaling {
  String _self_id = randomNumeric(6);
  var _socket;
  var _session_id;
  var _url;
  var _name;
  var _peerConnections = new Map<String, RTCPeerConnection>();
  var _daChannels = new Map<int, RTCDataChannel>();
  Timer _timer;
  MediaStream _localStream;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  DataChannelMessageCallback onDataChannel;

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

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  Signaling(this._url, this._name);

  close() {
    if (_socket != null) _socket.close();
  }

  void invite(String peer_id, String media) {
    this._session_id = this._self_id + '-' + peer_id;

    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateNew);
    }

    _createPeerConnection(peer_id, media).then((pc) {
      _peerConnections[peer_id] = pc;
      _createOffer(peer_id, pc, media);
    });
  }

  void bye() {
    _send('bye', {
      'session_id': this._session_id,
      'from': this._self_id,
    });
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    var data = mapData['data'];

    switch(mapData['type']){

      case 'peers':
        {
          List<dynamic> peers = data;
          if(this.onPeersUpdate != null) {
            Map<String, dynamic> event = new  Map<String, dynamic>();
            event['self'] = _self_id;
            event['peers'] = peers;
            this.onPeersUpdate(event);
          }
        }
        break;
      case 'offer':
        {
          var id = data['from'];
          var description = data['description'];
          var media = data['media'];
          var session_id = data['session_id'];
          this._session_id = session_id;

          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateNew);
          }

          _createPeerConnection(id, media).then((pc) {
            _peerConnections[id] = pc;
            pc.setRemoteDescription(
                new RTCSessionDescription(description['sdp'], description['type']));
            _createAnswer(id, pc);
          });
        }
        break;
      case 'answer':
        {
          var id = data['from'];
          var description = data['description'];

          var pc = _peerConnections[id];
          if (pc != null) {
            pc.setRemoteDescription(
                new RTCSessionDescription(description['sdp'], description['type']));
          }
        }
        break;
      case 'candidate':
        {
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
        }
        break;
      case 'leave':
        {
          var id = data;
          _peerConnections.remove(id);
          _daChannels.remove(id);

          if (_localStream != null) {
            _localStream.dispose();
            _localStream = null;
          }
          var pc = _peerConnections[id];
          if (pc != null) {
            pc.close();
            _peerConnections.remove(id);
          }
          this._session_id = null;
          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateBye);
          }
        }
        break;
      case 'bye':
        {
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
          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateBye);
          }
        }
        break;
      case 'keepalive':
        {
          print('keepalive response!');
        }
        break;
      default:
        break;
    }
  }

  void connect() async {
    try {
      _socket = await WebSocket.connect(_url);

      if (this.onStateChange != null) {
        this.onStateChange(SignalingState.ConnectionOpen);
      }

      _socket.listen((data) {
        print('Recivied data: ' + data);
        this.onMessage(JSON.decode(data));
      }, onDone: () {
        print('Closed by server!');
        if (this.onStateChange != null) {
          this.onStateChange(SignalingState.ConnectionClosed);
        }
      });

      _send('new', {
        'name': _name,
        'id': _self_id,
        'user_agent': 'flutter-webrtc/ios-plugin 0.0.1'
      });
    }catch(e){
      if(this.onStateChange != null){
        this.onStateChange(SignalingState.ConnectionError);
      }
    }
  }

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
    if(this.onLocalStream != null){
      this.onLocalStream(stream);
    }
    return stream;
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
      if(this.onAddRemoteStream != null)
        this.onAddRemoteStream(stream);
    });

    pc.onRemoveStream = (stream) {
      if(this.onRemoveRemoteStream != null)
        this.onRemoveRemoteStream(stream);
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (data) {
      if(this.onDataChannel != null)
        this.onDataChannel(channel, data);
    };
    _daChannels[id] = channel;
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(String id, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s = await pc.createOffer(_constraints);
      pc.setLocalDescription(s);
      _send('offer', {
        'to': id,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._session_id,
        'media': media,
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

  _handleStatsReport(Timer timer, pc) async {
    if (pc != null) {
      List<StatsReport> reports = await pc.getStats(null);
      reports.forEach((report) {
        print("report => { ");
        print("    id: " + report.id + ",");
        print("    type: " + report.type + ",");
        print("    timestamp: ${report.timestamp},");
        print("    values => {");
        report.values.forEach((key, value) {
          print("        " + key + " : " + value + ", ");
        });
        print("    }");
        print("}");
      });
    }
  }
}
