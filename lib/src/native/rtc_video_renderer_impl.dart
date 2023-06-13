import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import '../helper.dart';
import 'utils.dart';

enum RTCVideoFrameFormat { KI420, KRGBA, KMJPEG } // KI420 use NV12

extension RTCVideoFrameFormatExtension on RTCVideoFrameFormat {
  String getStringValue() {
    switch (this) {
      case RTCVideoFrameFormat.KI420:
        return "KI420";
      case RTCVideoFrameFormat.KMJPEG:
        return "KMJPEG";
      case RTCVideoFrameFormat.KRGBA:
        return "KRGBA";
      default:
        return "";
    }
  }
}

class RTCVideoFrame {
  RTCVideoFrame(this.format, this.data, this.width, this.height);
  RTCVideoFrameFormat format;
  Uint8List data;
  int width;
  int height;
}

class ExportFrame {
  ExportFrame(
      {this.enabledExportFrame = false,
      this.frameCount = -1,
      this.format = RTCVideoFrameFormat.KMJPEG});
  final bool enabledExportFrame;
  final int frameCount;
  final RTCVideoFrameFormat format;
}

class RTCVideoRenderer extends ValueNotifier<RTCVideoValue>
    implements VideoRenderer {
  RTCVideoRenderer() : super(RTCVideoValue.empty);
  int? _textureId;
  MediaStream? _srcObject;
  StreamSubscription<dynamic>? _eventSubscription;
  Function(RTCVideoFrame frame)? onFrame;

  @override
  Future<void> initialize({ExportFrame? exportFrame}) async {
    if (_textureId != null) {
      return;
    }
    final response = await WebRTC.invokeMethod('createVideoRenderer', {
      "enabledExportFrame":
          exportFrame != null ? exportFrame.enabledExportFrame : false,
      "frameCount": exportFrame != null ? exportFrame.frameCount : -1,
      "format": exportFrame != null
          ? exportFrame.format.getStringValue()
          : RTCVideoFrameFormat.KMJPEG
    });
    _textureId = response['textureId'];
    _eventSubscription = EventChannel('FlutterWebRTC/Texture$textureId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  @override
  int get videoWidth => value.width.toInt();

  @override
  int get videoHeight => value.height.toInt();

  @override
  int? get textureId => _textureId;

  @override
  MediaStream? get srcObject => _srcObject;

  @override
  Function? onResize;

  @override
  Function? onFirstFrameRendered;

  @override
  set srcObject(MediaStream? stream) {
    if (textureId == null) throw 'Call initialize before setting the stream';

    _srcObject = stream;
    WebRTC.invokeMethod('videoRendererSetSrcObject', <String, dynamic>{
      'textureId': textureId,
      'streamId': stream?.id ?? '',
      'ownerTag': stream?.ownerTag ?? ''
    }).then((_) {
      value = (stream == null)
          ? RTCVideoValue.empty
          : value.copyWith(renderVideo: renderVideo);
    });
  }

  void setSrcObject({MediaStream? stream, String? trackId}) {
    if (textureId == null) throw 'Call initialize before setting the stream';

    _srcObject = stream;
    WebRTC.invokeMethod('videoRendererSetSrcObject', <String, dynamic>{
      'textureId': textureId,
      'streamId': stream?.id ?? '',
      'ownerTag': stream?.ownerTag ?? '',
      'trackId': trackId ?? '0'
    }).then((_) {
      value = (stream == null)
          ? RTCVideoValue.empty
          : value.copyWith(renderVideo: renderVideo);
    });
  }

  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    if (_textureId != null) {
      await WebRTC.invokeMethod('videoRendererDispose', <String, dynamic>{
        'textureId': _textureId,
      });
      _textureId = null;
    }
    return super.dispose();
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didTextureChangeRotation':
        value =
            value.copyWith(rotation: map['rotation'], renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'didTextureChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'didFirstFrameRendered':
        value = value.copyWith(renderVideo: renderVideo);
        onFirstFrameRendered?.call();
        break;
      case 'onVideoFrame':
        Uint8List data = map['data'];
        int width = map['width'];
        int height = map['height'];
        String format = map['format'];
        onFrame
            ?.call(RTCVideoFrame(stringToEnum(format)!, data, width, height));
        break;
    }
  }

  RTCVideoFrameFormat? stringToEnum(String value) {
    return RTCVideoFrameFormat.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => RTCVideoFrameFormat.KMJPEG,
    );
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  bool get renderVideo => _textureId != null && _srcObject != null;

  @override
  bool get muted => _srcObject?.getAudioTracks()[0].muted ?? true;

  @override
  set muted(bool mute) {
    if (_srcObject == null) {
      throw Exception('Can\'t be muted: The MediaStream is null');
    }
    if (_srcObject!.ownerTag != 'local') {
      throw Exception(
          'You\'re trying to mute a remote track, this is not supported');
    }
    if (_srcObject!.getAudioTracks().isEmpty) {
      throw Exception('Can\'t be muted: The MediaStreamTrack(audio) is empty');
    }

    Helper.setMicrophoneMute(mute, _srcObject!.getAudioTracks()[0]);
  }

  @override
  Future<bool> audioOutput(String deviceId) async {
    try {
      await Helper.selectAudioOutput(deviceId);
    } catch (e) {
      print('Helper.selectAudioOutput ${e.toString()}');
      return false;
    }
    return true;
  }
}
