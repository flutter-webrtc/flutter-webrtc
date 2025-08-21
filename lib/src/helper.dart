import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';

import '../flutter_webrtc.dart';
import 'native_logs_listener.dart';

class Helper {
  /// Set Logger object for webrtc;
  ///
  /// Params:
  ///
  /// "severity": possible values: ['verbose', 'info', 'warning', 'error', 'none']
  static void setLogger(Logger logger, [String severity = 'none']) {
    NativeLogsListener.instance.setLogger(logger, severity);
  }

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

  static Future<void> setZoom(MediaStreamTrack videoTrack, double zoomLevel) =>
      CameraUtils.setZoom(videoTrack, zoomLevel);

  static Future<void> setFocusMode(
          MediaStreamTrack videoTrack, CameraFocusMode focusMode) =>
      CameraUtils.setFocusMode(videoTrack, focusMode);

  static Future<void> setFocusPoint(
          MediaStreamTrack videoTrack, Point<double>? point) =>
      CameraUtils.setFocusPoint(videoTrack, point);

  static Future<void> setExposureMode(
          MediaStreamTrack videoTrack, CameraExposureMode exposureMode) =>
      CameraUtils.setExposureMode(videoTrack, exposureMode);

  static Future<void> setExposurePoint(
          MediaStreamTrack videoTrack, Point<double>? point) =>
      CameraUtils.setExposurePoint(videoTrack, point);

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
  static Future<void> selectAudioInput(String deviceId) =>
      NativeAudioManagement.selectAudioInput(deviceId);

  /// Enable or disable speakerphone
  /// for iOS/Android only
  static Future<void> setSpeakerphoneOn(bool enable) =>
      NativeAudioManagement.setSpeakerphoneOn(enable);

  /// Ensure audio session
  /// for iOS only
  static Future<void> ensureAudioSession() =>
      NativeAudioManagement.ensureAudioSession();

  /// Enable speakerphone, but use bluetooth if audio output device available
  /// for iOS/Android only
  static Future<void> setSpeakerphoneOnButPreferBluetooth() =>
      NativeAudioManagement.setSpeakerphoneOnButPreferBluetooth();

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

  /// Set the volume for Flutter native
  static Future<void> setVolume(double volume, MediaStreamTrack track) =>
      NativeAudioManagement.setVolume(volume, track);

  /// Set the microphone mute/unmute for Flutter native
  static Future<void> setMicrophoneMute(bool mute, MediaStreamTrack track) =>
      NativeAudioManagement.setMicrophoneMute(mute, track);

  /// Set the audio configuration to for Android.
  /// Must be set before initiating a WebRTC session and cannot be changed
  /// mid session.
  static Future<void> setAndroidAudioConfiguration(
          AndroidAudioConfiguration androidAudioConfiguration) =>
      AndroidNativeAudioManagement.setAndroidAudioConfiguration(
          androidAudioConfiguration);

  /// After Android app finishes a session, on audio focus loss, clear the active communication device.
  static Future<void> clearAndroidCommunicationDevice() =>
      WebRTC.invokeMethod('clearAndroidCommunicationDevice');

  /// Set the audio configuration for iOS
  static Future<void> setAppleAudioConfiguration(
          AppleAudioConfiguration appleAudioConfiguration) =>
      AppleNativeAudioManagement.setAppleAudioConfiguration(
          appleAudioConfiguration);

  /// Set the audio configuration for iOS
  static Future<void> setAppleAudioIOMode(AppleAudioIOMode mode,
          {bool preferSpeakerOutput = false}) =>
      AppleNativeAudioManagement.setAppleAudioConfiguration(
          AppleNativeAudioManagement.getAppleAudioConfigurationForMode(mode,
              preferSpeakerOutput: preferSpeakerOutput));

  /// Request capture permission for Android
  static Future<bool> requestCapturePermission() async {
    if (WebRTC.platformIsAndroid) {
      return await WebRTC.invokeMethod('requestCapturePermission');
    } else {
      throw Exception('requestCapturePermission only support for Android');
    }
  }
}
