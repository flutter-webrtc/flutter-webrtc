import 'dart:async';

import '../interface/factory.dart';
import '../interface/media_device.dart';
import '../interface/media_recorder.dart';
import '../interface/media_stream.dart';
import '../interface/rtc_peerconnection.dart';
import '../interface/rtc_video_renderer.dart';
import 'media_devives_impl.dart';
import 'media_recorder_impl.dart';
import 'media_stream_impl.dart';
import 'rtc_peerconnection_impl.dart';
import 'rtc_video_view_impl.dart';
import 'utils.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    [Map<String, dynamic> constraints = const {}]) async {
  return _RTCFactoryNative.instance
      .createPeerConnection(configuration, constraints);
}

Future<MediaStream> createLocalMediaStream(String label) async {
  return _RTCFactoryNative.instance.createLocalMediaStream(label);
}

MediaDevices mediaDevices() {
  return _RTCFactoryNative.instance.mediaDevices();
}

MediaRecorder mediaRecorder() {
  return _RTCFactoryNative.instance.mediaRecorder();
}

RTCVideoRenderer videoRenderer() {
  return _RTCFactoryNative.instance.videoRenderer();
}

class _RTCFactoryNative extends RTCFactory {
  _RTCFactoryNative._internal();

  static final RTCFactory instance = _RTCFactoryNative._internal();

  @override
  Future<MediaStream> createLocalMediaStream(String label) async {
    var _channel = WebRTC.methodChannel();

    final response = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('createLocalMediaStream');

    return MediaStreamNative(response['streamId'], label);
  }

  @override
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
    return RTCPeerConnectionNative(peerConnectionId, configuration);
  }

  @override
  MediaDevices mediaDevices() {
    return MediaDevicesNative();
  }

  @override
  MediaRecorder mediaRecorder() {
    return MediaRecorderNative();
  }

  @override
  RTCVideoRenderer videoRenderer() {
    return RTCVideoRendererNative();
  }
}
