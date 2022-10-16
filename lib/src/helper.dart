import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../flutter_webrtc.dart';

class Helper {
  static Future<List<MediaDeviceInfo>> enumerateDevices(String type) async {
    var devices = await navigator.mediaDevices.enumerateDevices();
    return devices.where((d) => d.kind == type).toList();
  }

  /// Return the available cameras
  ///
  /// Note: Make sure to call this gettet after
  /// navigator.mediaDevices.getUserMedia(), otherwise the devices will not be
  /// listed.
  static Future<List<MediaDeviceInfo>> get cameras =>
      enumerateDevices('videoinput');

  /// Return the available audiooutputs
  ///
  /// Note: Make sure to call this gettet after
  /// navigator.mediaDevices.getUserMedia(), otherwise the devices will not be
  /// listed.
  static Future<List<MediaDeviceInfo>> get audiooutputs =>
      enumerateDevices('audiooutput');

  /// Used to select a specific audio output device.
  ///
  /// Note: This method is only used for Flutter native,
  /// supported on iOS/Android/macOS/Windows.
  ///
  /// Android/macOS/Windows: Can be used to switch all output devices.
  /// iOS: you can only switch directly between the
  /// speaker and the preferred device
  /// web: flutter web can use RTCVideoRenderer.audioOutput instead
  static Future<void> selectAudioOutput(String deviceId) async {
    await navigator.mediaDevices
        .selectAudioOutput(AudioOutputOptions(deviceId: deviceId));
  }

  /// Set audio input device for Flutter native
  /// Note: The usual practice in flutter web is to use deviceId as the
  /// `getUserMedia` parameter to get a new audio track and replace it with the
  ///  audio track in the original rtpsender.
  static Future<void> selectAudioInput(String deviceId) async {
    await WebRTC.invokeMethod(
      'selectAudioInput',
      <String, dynamic>{'deviceId': deviceId},
    );
  }

  /// Set microphone mute/unmute for Flutter native.
  /// for iOS/Android only
  static Future<void> setSpeakerphoneOn(bool enable) async {
    await WebRTC.invokeMethod(
      'enableSpeakerphone',
      <String, dynamic>{'enable': enable},
    );
  }

  /// To select a a specific camera, you need to set constraints
  /// eg.
  /// var constraints = {
  ///      'audio': true,
  ///      'video': {
  ///          'deviceId': Helper.cameras[0].deviceId,
  ///          }
  ///      };
  ///
  /// var stream = await Helper.openCamera(constraints);
  ///
  static Future<MediaStream> openCamera(Map<String, dynamic> mediaConstraints) {
    return navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  /// For web implementation, make sure to pass the target deviceId
  static Future<bool> switchCamera(MediaStreamTrack track,
      [String? deviceId, MediaStream? stream]) async {
    if (track.kind != 'video') {
      throw 'The is not a video track => $track';
    }

    if (!kIsWeb) {
      return WebRTC.invokeMethod(
        'mediaStreamTrackSwitchCamera',
        <String, dynamic>{'trackId': track.id},
      ).then((value) => value ?? false);
    }

    if (deviceId == null) throw 'You need to specify the deviceId';
    if (stream == null) throw 'You need to specify the stream';

    var cams = await cameras;
    if (!cams.any((e) => e.deviceId == deviceId)) {
      throw 'The provided deviceId is not available, make sure to retreive the deviceId from Helper.cammeras()';
    }

    // stop only video tracks
    // so that we can recapture video track
    stream.getVideoTracks().forEach((track) {
      track.stop();
      stream.removeTrack(track);
    });

    var mediaConstraints = {
      'audio': false, // NO need to capture audio again
      'video': {'deviceId': deviceId}
    };

    var newStream = await openCamera(mediaConstraints);
    var newCamTrack = newStream.getVideoTracks()[0];

    await stream.addTrack(newCamTrack, addToNative: true);

    return Future.value(true);
  }

  static Future<void> setVolume(double volume, MediaStreamTrack track) async {
    if (track.kind == 'audio') {
      if (kIsWeb) {
        final constraints = track.getConstraints();
        constraints['volume'] = volume;
        await track.applyConstraints(constraints);
      } else {
        await WebRTC.invokeMethod(
          'setVolume',
          <String, dynamic>{'trackId': track.id, 'volume': volume},
        );
      }
    }

    return Future.value();
  }

  static void setMicrophoneMute(bool mute, MediaStreamTrack track) async {
    if (track.kind != 'audio') {
      throw 'The is not an audio track => $track';
    }

    if (!kIsWeb) {
      try {
        await WebRTC.invokeMethod(
          'setMicrophoneMute',
          <String, dynamic>{'trackId': track.id, 'mute': mute},
        );
      } on PlatformException catch (e) {
        throw 'Unable to MediaStreamTrack::setMicrophoneMute: ${e.message}';
      }
    }
    track.enabled = !mute;
  }
}
