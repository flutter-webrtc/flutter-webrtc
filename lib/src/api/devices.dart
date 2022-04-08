import 'dart:async';

import 'package:flutter/services.dart';

import '/src/model/constraints.dart';
import '/src/model/device.dart';
import '/src/platform/native/media_stream_track.dart';
import 'bridge.g.dart' as ffi;
import 'channel.dart';
import 'peer.dart';

/// Default video width when capturing user's camera.
const defaultUserMediaWidth = 480;

/// Default video height when capturing user's camera.
const defaultUserMediaHeight = 640;

/// Default video width when capturing user's display.
const defaultDisplayMediaWidth = 1280;

/// Default video height when capturing user's display.
const defaultDisplayMediaHeight = 720;

/// Default video framerate.
const defaultFrameRate = 30;

/// Shortcut for the `on_device_change` callback.
typedef OnDeviceChangeCallback = void Function();

/// Singleton for listening device change.
class _DeviceHandler {
  /// Instance of a [_DeviceHandler] singleton.
  static final _DeviceHandler _instance = _DeviceHandler._internal();

  /// Callback, called whenever a media device such as a camera, microphone, or
  /// speaker is connected to or removed from the system.
  OnDeviceChangeCallback? _handler;

  /// Returns [_DeviceHandler] singleton instance.
  factory _DeviceHandler() {
    return _instance;
  }

  /// Creates a new [_DeviceHandler].
  _DeviceHandler._internal() {
    _listen();
  }

  /// Subscribes to the platform [Stream] emitting device change events.
  void _listen() async {
    if (isDesktop) {
      api.setOnDeviceChanged().listen(
        (event) {
          if (_handler != null) {
            _handler!();
          }
        },
      );
    } else {
      eventChannel('MediaDevicesEvent', 0)
          .receiveBroadcastStream()
          .listen((event) {
        final dynamic e = event;
        switch (e['event']) {
          case 'onDeviceChange':
            if (_handler != null) {
              _handler!();
            }
            break;
        }
      });
    }
  }

  /// Sets the [OnDeviceChangeCallback] callback.
  void setHandler(OnDeviceChangeCallback? handler) {
    _handler = handler;
  }
}

/// [Exception] thrown if the specified constraints resulted in no candidate
/// devices which met the criteria requested. The error is an object of type
/// [OverconstrainedException], and has a constraint property whose string value
/// is the name of a constraint which was impossible to meet.
class OverconstrainedException implements Exception {
  /// Constructs a new [OverconstrainedException].
  OverconstrainedException();

  @override
  String toString() {
    return 'OverconstrainedException';
  }
}

/// [MethodChannel] used for the messaging with a native side.
final _mediaDevicesMethodChannel = methodChannel('MediaDevices', 0);

/// Returns list of [MediaDeviceInfo]s for the currently available devices.
Future<List<MediaDeviceInfo>> enumerateDevices() async {
  if (isDesktop) {
    return (await api.enumerateDevices())
        .map((e) => MediaDeviceInfo.fromFFI(e))
        .toList();
  } else {
    return (await _mediaDevicesMethodChannel.invokeMethod('enumerateDevices'))
        .map((i) => MediaDeviceInfo.fromMap(i))
        .toList();
  }
}

/// Returns list of local audio and video [NativeMediaStreamTrack]s based on the
/// provided [DeviceConstraints].
Future<List<NativeMediaStreamTrack>> getUserMedia(
    DeviceConstraints constraints) async {
  if (isDesktop) {
    return _getUserMediaFFI(constraints);
  } else {
    return _getUserMediaChannel(constraints);
  }
}

/// Returns list of local display [NativeMediaStreamTrack]s based on the
/// provided [DisplayConstraints].
Future<List<NativeMediaStreamTrack>> getDisplayMedia(
    DisplayConstraints constraints) async {
  if (isDesktop) {
    return _getDisplayMediaFFI(constraints);
  } else {
    return _getDisplayMediaChannel(constraints);
  }
}

/// Switches the current output audio device to the provided [deviceId].
///
/// List of output audio devices may be obtained via [enumerateDevices].
Future<void> setOutputAudioId(String deviceId) async {
  if (isDesktop) {
    await api.setAudioPlayoutDevice(deviceId: deviceId);
  } else {
    await _mediaDevicesMethodChannel
        .invokeMethod('setOutputAudioId', {'deviceId': deviceId});
  }
}

/// [MethodChannel]-based implementation of a [getUserMedia] function.
Future<List<NativeMediaStreamTrack>> _getUserMediaChannel(
    DeviceConstraints constraints) async {
  try {
    List<dynamic> res = await _mediaDevicesMethodChannel
        .invokeMethod('getUserMedia', {'constraints': constraints.toMap()});
    return res.map((t) => NativeMediaStreamTrack.from(t)).toList();
  } on PlatformException catch (e) {
    if (e.code == 'OverconstrainedError') {
      throw OverconstrainedException();
    } else {
      rethrow;
    }
  }
}

/// FFI-based implementation of a [getUserMedia] function.
Future<List<NativeMediaStreamTrack>> _getUserMediaFFI(
    DeviceConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null
      ? ffi.AudioConstraints(deviceId: constraints.audio.mandatory?.deviceId)
      : null;

  var videoConstraints = constraints.video.mandatory != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId,
          height: constraints.video.mandatory?.height ?? defaultUserMediaHeight,
          width: constraints.video.mandatory?.width ?? defaultUserMediaWidth,
          frameRate: constraints.video.mandatory?.fps ?? defaultFrameRate,
          isDisplay: false)
      : null;

  var tracks = await api.getMedia(
      constraints: ffi.MediaStreamConstraints(
          audio: audioConstraints, video: videoConstraints));

  return tracks.map((e) => NativeMediaStreamTrack.from(e)).toList();
}

/// [MethodChannel]-based implementation of a [getDisplayMedia] function.
Future<List<NativeMediaStreamTrack>> _getDisplayMediaChannel(
    DisplayConstraints constraints) async {
  List<dynamic> res = await _mediaDevicesMethodChannel
      .invokeMethod('getDisplayMedia', {'constraints': constraints.toMap()});
  return res.map((t) => NativeMediaStreamTrack.from(t)).toList();
}

/// FFI-based implementation of a [getDisplayMedia] function.
Future<List<NativeMediaStreamTrack>> _getDisplayMediaFFI(
    DisplayConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null
      ? ffi.AudioConstraints(deviceId: constraints.audio.mandatory?.deviceId)
      : null;

  var videoConstraints = constraints.video.mandatory != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId,
          height:
              constraints.video.mandatory?.height ?? defaultDisplayMediaHeight,
          width: constraints.video.mandatory?.width ?? defaultDisplayMediaWidth,
          frameRate: constraints.video.mandatory?.fps ?? defaultFrameRate,
          isDisplay: true)
      : null;

  var tracks = await api.getMedia(
      constraints: ffi.MediaStreamConstraints(
          audio: audioConstraints, video: videoConstraints));

  return tracks.map((e) => NativeMediaStreamTrack.from(e)).toList();
}

/// Sets the provided [`OnDeviceChangeCallback`] as the callback to be called
/// whenever a set of available media devices changes.
void onDeviceChange(OnDeviceChangeCallback? cb) {
  _DeviceHandler().setHandler(cb);
}
