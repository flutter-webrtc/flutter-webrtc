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
      api!.setOnDeviceChanged().listen(
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

/// Represents the `cause` of the [GetMediaException].
enum GetMediaExceptionKind {
  /// If the [getUserMedia] or [getDisplayMedia] request failed on getting
  /// `audio`.
  audio,

  /// If the [getUserMedia] or [getDisplayMedia] request failed on getting
  /// `video`.
  video,
}

/// [Exception] thrown if there is an `error` while calling [getUserMedia] or
/// [getDisplayMedia].
class GetMediaException implements Exception {
  /// Constructs a new [GetMediaException].
  GetMediaException(this._kind, this._message);

  /// [GetMediaExceptionKind] of this [GetMediaException].
  final GetMediaExceptionKind _kind;

  /// The `message` of this [GetMediaException].
  final String? _message;

  @override
  String toString() {
    return _message ?? '';
  }

  /// Returns the [GetMediaExceptionKind] of this [GetMediaException]
  GetMediaExceptionKind kind() {
    return _kind;
  }
}

/// [MethodChannel] used for the messaging with a native side.
final _mediaDevicesMethodChannel = methodChannel('MediaDevices', 0);

/// Returns list of [MediaDeviceInfo]s for the currently available devices.
Future<List<MediaDeviceInfo>> enumerateDevices() async {
  if (isDesktop) {
    return (await api!.enumerateDevices())
        .map((e) => MediaDeviceInfo.fromFFI(e))
        .toList();
  } else {
    final List<dynamic>? devices =
        await _mediaDevicesMethodChannel.invokeMethod('enumerateDevices');
    return devices!.map((i) => MediaDeviceInfo.fromMap(i)).toList();
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
    await api!.setAudioPlayoutDevice(deviceId: deviceId);
  } else {
    await _mediaDevicesMethodChannel
        .invokeMethod('setOutputAudioId', {'deviceId': deviceId});
  }
}

/// Indicates whether the microphone is available to set volume.
Future<bool> microphoneVolumeIsAvailable() async {
  if (isDesktop) {
    return await api!.microphoneVolumeIsAvailable();
  } else {
    // TODO(logist322): Implement for Channel-based implementation.
    return false;
  }
}

/// Sets the microphone system volume according to the specified [level] in
/// percents.
Future<void> setMicrophoneVolume(int level) async {
  await api!.setMicrophoneVolume(level: level);
}

/// Returns the current level of the microphone volume in percents.
Future<int> microphoneVolume() async {
  return await api!.microphoneVolume();
}

/// [MethodChannel]-based implementation of a [getUserMedia] function.
Future<List<NativeMediaStreamTrack>> _getUserMediaChannel(
    DeviceConstraints constraints) async {
  try {
    List<dynamic>? res = await _mediaDevicesMethodChannel
        .invokeMethod('getUserMedia', {'constraints': constraints.toMap()});
    return res!.map((t) => NativeMediaStreamTrack.from(t)).toList();
  } on PlatformException catch (e) {
    if (e.code == 'GetUserMediaAudioException') {
      throw GetMediaException(GetMediaExceptionKind.audio, e.message);
    } else if (e.code == 'GetUserMediaVideoException') {
      throw GetMediaException(GetMediaExceptionKind.video, e.message);
    } else {
      rethrow;
    }
  }
}

/// FFI-based implementation of a [getUserMedia] function.
Future<List<NativeMediaStreamTrack>> _getUserMediaFFI(
    DeviceConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null ||
          constraints.audio.optional != null
      ? ffi.AudioConstraints(deviceId: constraints.audio.mandatory?.deviceId)
      : null;

  var videoConstraints = constraints.video.mandatory != null ||
          constraints.video.optional != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId ??
              constraints.video.optional?.deviceId,
          height: constraints.video.mandatory?.height ?? defaultUserMediaHeight,
          width: constraints.video.mandatory?.width ?? defaultUserMediaWidth,
          frameRate: constraints.video.mandatory?.fps ?? defaultFrameRate,
          isDisplay: false)
      : null;

  var result = await api!.getMedia(
      constraints: ffi.MediaStreamConstraints(
          audio: audioConstraints, video: videoConstraints));

  if (result is ffi.Ok) {
    return result.field0.map((e) => NativeMediaStreamTrack.from(e)).toList();
  } else {
    if ((result as ffi.Err).field0 is ffi.Video) {
      throw GetMediaException(
          GetMediaExceptionKind.video, result.field0.field0);
    } else {
      throw GetMediaException(
          GetMediaExceptionKind.audio, result.field0.field0);
    }
  }
}

/// [MethodChannel]-based implementation of a [getDisplayMedia] function.
Future<List<NativeMediaStreamTrack>> _getDisplayMediaChannel(
    DisplayConstraints constraints) async {
  List<dynamic>? res = await _mediaDevicesMethodChannel
      .invokeMethod('getDisplayMedia', {'constraints': constraints.toMap()});
  return res!.map((t) => NativeMediaStreamTrack.from(t)).toList();
}

/// FFI-based implementation of a [getDisplayMedia] function.
Future<List<NativeMediaStreamTrack>> _getDisplayMediaFFI(
    DisplayConstraints constraints) async {
  var audioConstraints = constraints.audio.mandatory != null ||
          constraints.audio.optional != null
      ? ffi.AudioConstraints(deviceId: constraints.audio.mandatory?.deviceId)
      : null;

  var videoConstraints = constraints.video.mandatory != null ||
          constraints.video.optional != null
      ? ffi.VideoConstraints(
          deviceId: constraints.video.mandatory?.deviceId,
          height:
              constraints.video.mandatory?.height ?? defaultDisplayMediaHeight,
          width: constraints.video.mandatory?.width ?? defaultDisplayMediaWidth,
          frameRate: constraints.video.mandatory?.fps ?? defaultFrameRate,
          isDisplay: true)
      : null;

  var result = await api!.getMedia(
      constraints: ffi.MediaStreamConstraints(
          audio: audioConstraints, video: videoConstraints));

  if (result is ffi.Ok) {
    return result.field0.map((e) => NativeMediaStreamTrack.from(e)).toList();
  } else {
    if ((result as ffi.Err) is ffi.Video) {
      throw GetMediaException(
          GetMediaExceptionKind.video, result.field0.field0);
    } else {
      throw GetMediaException(
          GetMediaExceptionKind.audio, result.field0.field0);
    }
  }
}

/// Sets the provided [`OnDeviceChangeCallback`] as the callback to be called
/// whenever a set of available media devices changes.
void onDeviceChange(OnDeviceChangeCallback? cb) {
  _DeviceHandler().setHandler(cb);
}
