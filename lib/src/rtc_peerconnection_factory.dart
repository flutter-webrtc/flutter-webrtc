import 'dart:async';

import 'media_devives_native.dart';
import 'media_recorder_native.dart';
import 'media_stream_native.dart';
import 'model/factory.dart';
import 'model/media_device.dart';
import 'model/media_recorder.dart';
import 'model/media_stream.dart';
import 'model/rtc_peerconnection.dart';
import 'model/rtc_video_renderer.dart';
import 'rtc_peerconnection_native.dart';
import 'rtc_video_view.dart';
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
