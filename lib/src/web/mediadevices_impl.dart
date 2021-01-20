import 'dart:async';
import 'dart:html' as html;
import 'dart:js';
import 'dart:js_util' as jsutil;

import '../interface/media_stream.dart';
import '../interface/mediadevices.dart';
import 'media_stream_impl.dart';

class MediaDevicesWeb extends MediaDevices {
  @override
  Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    mediaConstraints ??= <String, dynamic>{};

    try {
      if (mediaConstraints['video'] is Map) {
        if (mediaConstraints['video']['facingMode'] != null) {
          mediaConstraints['video'].remove('facingMode');
        }
      }

      mediaConstraints.putIfAbsent('video', () => false);
      mediaConstraints.putIfAbsent('audio', () => false);

      final mediaDevices = html.window.navigator.mediaDevices;

      if (jsutil.hasProperty(mediaDevices, 'getUserMedia')) {
        var args = jsutil.jsify(mediaConstraints);
        final jsStream = await jsutil.promiseToFuture<html.MediaStream>(
            jsutil.callMethod(mediaDevices, 'getUserMedia', [args]));

        return MediaStreamWeb(jsStream, 'local');
      } else {
        final jsStream = await html.window.navigator.getUserMedia(
          audio: mediaConstraints['audio'],
          video: mediaConstraints['video'],
        );
        return MediaStreamWeb(jsStream, 'local');
      }
    } catch (e) {
      throw 'Unable to getUserMedia: ${e.toString()}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (jsutil.hasProperty(mediaDevices, 'getDisplayMedia')) {
        final arg = jsutil.jsify(mediaConstraints);
        final jsStream = await jsutil.promiseToFuture<html.MediaStream>(
            jsutil.callMethod(mediaDevices, 'getDisplayMedia', [arg]));
        return MediaStreamWeb(jsStream, 'local');
      } else {
        final jsStream = await html.window.navigator.getUserMedia(
            video: {'mediaSource': 'screen'},
            audio: mediaConstraints['audio'] ?? false);
        return MediaStreamWeb(jsStream, 'local');
      }
    } catch (e) {
      throw 'Unable to getDisplayMedia: ${e.toString()}';
    }
  }

  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    final devices = await getSources();

    return devices.map((e) {
      var input = e as html.MediaDeviceInfo;
      return MediaDeviceInfo(
          deviceId: input.deviceId,
          groupId: input.groupId,
          kind: input.kind,
          label: input.label);
    }).toList();
  }

  @override
  Future<List<dynamic>> getSources() async {
    return await html.window.navigator.mediaDevices.enumerateDevices();
  }

  @override
  MediaTrackSupportedConstraints getSupportedConstraints() {
    final mediaDevices = html.window.navigator.mediaDevices;
    var _mapConstraints = mediaDevices.getSupportedConstraints();

    return MediaTrackSupportedConstraints(
        aspectRatio: _mapConstraints['aspectRatio'],
        autoGainControl: _mapConstraints['autoGainControl'],
        brightness: _mapConstraints['brightness'],
        channelCount: _mapConstraints['channelCount'],
        colorTemperature: _mapConstraints['colorTemperature'],
        contrast: _mapConstraints['contrast'],
        deviceId: _mapConstraints['_mapConstraints'],
        echoCancellation: _mapConstraints['echoCancellation'],
        exposureCompensation: _mapConstraints['exposureCompensation'],
        exposureMode: _mapConstraints['exposureMode'],
        exposureTime: _mapConstraints['exposureTime'],
        facingMode: _mapConstraints['facingMode'],
        focusDistance: _mapConstraints['focusDistance'],
        focusMode: _mapConstraints['focusMode'],
        frameRate: _mapConstraints['frameRate'],
        groupId: _mapConstraints['groupId'],
        height: _mapConstraints['height'],
        iso: _mapConstraints['iso'],
        latency: _mapConstraints['latency'],
        noiseSuppression: _mapConstraints['noiseSuppression'],
        pan: _mapConstraints['pan'],
        pointsOfInterest: _mapConstraints['pointsOfInterest'],
        resizeMode: _mapConstraints['resizeMode'],
        saturation: _mapConstraints['saturation'],
        sampleRate: _mapConstraints['sampleRate'],
        sampleSize: _mapConstraints['sampleSize'],
        sharpness: _mapConstraints['sharpness'],
        tilt: _mapConstraints['tilt'],
        torch: _mapConstraints['torch'],
        whiteBalanceMode: _mapConstraints['whiteBalanceMode'],
        width: _mapConstraints['width'],
        zoom: _mapConstraints['zoom']);
  }
}
