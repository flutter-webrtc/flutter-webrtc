import 'dart:async';
import 'rtc_peerconnection.dart';
import 'media_stream.dart';
import 'utils.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    [Map<String, dynamic> constraints = const {}]) async {
  var channel = WebRTC.methodChannel();

  var defaultConstraints = <String, dynamic>{
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
    'createPeerConnection',
    <String, dynamic>{
      'configuration': configuration,
      'constraints': constraints.isEmpty ? defaultConstraints : constraints
    },
  );

  String peerConnectionId = response['peerConnectionId'];
  return RTCPeerConnection(peerConnectionId, configuration);
}

Future<MediaStream> createLocalMediaStream(String label) async {
  var _channel = WebRTC.methodChannel();

  final response = await _channel
      .invokeMethod<Map<dynamic, dynamic>>('createLocalMediaStream');

  return MediaStream(response['streamId'], label);
}
