import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'interface/media_stream.dart';
import 'interface/mediadevices.dart';

class Helper {
  static Future<List<MediaDeviceInfo>> enumerateDevices(String type) async {
    var devices = await navigator.mediaDevices.enumerateDevices();
    return devices.where((d) => d.kind == type).toList();
  }

  static Future<List<MediaDeviceInfo>> get cameras =>
      enumerateDevices('videoinput');

  /// To select a a specific camera, you need to set constraints
  /// eg.
  /// constraints = {
  ///      'audio': true,
  ///      'video': {
  ///          'deviceId': Helper.cameras[0].deviceId,
  ///          }
  ///      };
  ///
  /// Helper.openCamera(constraints);
  ///
  static Future<MediaStream> openCamera(Map<String, dynamic> mediaConstraints) {
    return navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  static Future<void> setVolume(double volume, MediaStreamTrack track) async {
    if (track.kind == 'audio') {
      if (kIsWeb) {
        final constraints = track.getConstraints();
        constraints['volume'] = volume;
        await track.applyConstraints(constraints);
      } else {
        var _channel = WebRTC.methodChannel();
        await _channel.invokeMethod(
          'setVolume',
          <String, dynamic>{'trackId': track.id, 'volume': volume},
        );
      }
    }

    return Future.value();
  }
}
