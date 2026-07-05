import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_track_impl.dart';
import 'utils.dart';

/// Strategy used by the AVAudioEngine-based audio device module to mute
/// microphone input. iOS/macOS only.
enum MicrophoneMuteMode {
  /// Mute using Voice Processing I/O's input mute. Fast and allows muted
  /// talker detection, but plays the platform's mute/unmute sound effect.
  voiceProcessing,

  /// Mute by restarting the audio engine without microphone input. Slower,
  /// but silent and stops microphone input entirely while muted.
  restartEngine,

  /// Mute by muting the engine's input mixer node. Fast and silent; the
  /// engine and audio session keep running.
  inputMixer,

  /// The mode could not be determined (e.g. unsupported platform).
  unknown,
}

class NativeAudioManagement {
  static Future<void> selectAudioInput(String deviceId) async {
    await WebRTC.invokeMethod(
      'selectAudioInput',
      <String, dynamic>{'deviceId': deviceId},
    );
  }

  static Future<void> setSpeakerphoneOn(bool enable) async {
    await WebRTC.invokeMethod(
      'enableSpeakerphone',
      <String, dynamic>{'enable': enable},
    );
  }

  static Future<void> ensureAudioSession() async {
    await WebRTC.invokeMethod('ensureAudioSession');
  }

  static Future<void> setSpeakerphoneOnButPreferBluetooth() async {
    await WebRTC.invokeMethod('enableSpeakerphoneButPreferBluetooth');
  }

  static Future<void> setVolume(double volume, MediaStreamTrack track) async {
    if (track.kind == 'audio') {
      if (kIsWeb) {
        final constraints = track.getConstraints();
        constraints['volume'] = volume;
        await track.applyConstraints(constraints);
      } else {
        await WebRTC.invokeMethod('setVolume', <String, dynamic>{
          'trackId': track.id,
          'volume': volume,
          'peerConnectionId':
              track is MediaStreamTrackNative ? track.peerConnectionId : null
        });
      }
    }

    return Future.value();
  }

  static Future<void> setMicrophoneMute(
      bool mute, MediaStreamTrack track) async {
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

  // ADM APIs
  static Future<void> startLocalRecording() async {
    if (!kIsWeb) {
      try {
        await WebRTC.invokeMethod(
          'startLocalRecording',
          <String, dynamic>{},
        );
      } on PlatformException catch (e) {
        throw 'Unable to start local recording: ${e.message}';
      }
    }
  }

  static Future<void> stopLocalRecording() async {
    if (!kIsWeb) {
      try {
        await WebRTC.invokeMethod(
          'stopLocalRecording',
          <String, dynamic>{},
        );
      } on PlatformException catch (e) {
        throw 'Unable to stop local recording: ${e.message}';
      }
    }
  }

  static Future<bool> isVoiceProcessingEnabled() async {
    if (kIsWeb) return false;

    try {
      final result = await WebRTC.invokeMethod(
        'isVoiceProcessingEnabled',
        <String, dynamic>{},
      );
      return result as bool;
    } on PlatformException catch (e) {
      throw 'Unable to get isVoiceProcessingEnabled: ${e.message}';
    }
  }

  static Future<bool> isVoiceProcessingBypassed() async {
    if (kIsWeb) return false;

    try {
      final result = await WebRTC.invokeMethod(
        'isVoiceProcessingBypassed',
        <String, dynamic>{},
      );
      return result as bool;
    } on PlatformException catch (e) {
      throw 'Unable to get isVoiceProcessingBypassed: ${e.message}';
    }
  }

  static Future<void> setIsVoiceProcessingBypassed(bool value) async {
    if (kIsWeb) return;

    try {
      await WebRTC.invokeMethod(
        'setIsVoiceProcessingBypassed',
        <String, dynamic>{"value": value},
      );
    } on PlatformException catch (e) {
      throw 'Unable to set isVoiceProcessingBypassed: ${e.message}';
    }
  }

  static bool get _supportsMicrophoneMuteMode =>
      !kIsWeb && (WebRTC.platformIsIOS || WebRTC.platformIsMacOS);

  static bool get _supportsAdmMicrophoneMute =>
      !kIsWeb &&
      (WebRTC.platformIsIOS ||
          WebRTC.platformIsMacOS ||
          WebRTC.platformIsAndroid);

  /// Returns the current microphone mute mode of the audio device module.
  ///
  /// iOS/macOS only. On all other platforms (Android, web, desktop) this
  /// returns [MicrophoneMuteMode.unknown] without calling into native code,
  /// so it is always safe to call from cross-platform code.
  static Future<MicrophoneMuteMode> getMicrophoneMuteMode() async {
    if (!_supportsMicrophoneMuteMode) {
      return MicrophoneMuteMode.unknown;
    }

    try {
      final result = await WebRTC.invokeMethod(
        'getMicrophoneMuteMode',
        <String, dynamic>{},
      );
      return MicrophoneMuteMode.values.firstWhere(
        (mode) => mode.name == result,
        orElse: () => MicrophoneMuteMode.unknown,
      );
    } on PlatformException catch (e) {
      throw 'Unable to get microphoneMuteMode: ${e.message}';
    }
  }

  /// Sets how the audio device module mutes microphone input.
  ///
  /// iOS/macOS only. On all other platforms (Android, web, desktop) this is
  /// a no-op that completes normally, so it is always safe to call from
  /// cross-platform code. Passing [MicrophoneMuteMode.unknown] (the value
  /// [getMicrophoneMuteMode] reports on unsupported platforms) is also a
  /// no-op, so `set(await get())` round-trips safely everywhere.
  static Future<void> setMicrophoneMuteMode(MicrophoneMuteMode mode) async {
    if (mode == MicrophoneMuteMode.unknown) return;

    if (!_supportsMicrophoneMuteMode) return;

    try {
      await WebRTC.invokeMethod(
        'setMicrophoneMuteMode',
        <String, dynamic>{'mode': mode.name},
      );
    } on PlatformException catch (e) {
      throw 'Unable to set microphoneMuteMode: ${e.message}';
    }
  }

  /// Returns whether microphone input is muted at the audio device module
  /// level. Unrelated to `MediaStreamTrack.enabled`.
  ///
  /// Supported on iOS/macOS and Android; on all other platforms this returns
  /// `false` without calling into native code.
  static Future<bool> isMicrophoneMuted() async {
    if (!_supportsAdmMicrophoneMute) return false;

    try {
      final result = await WebRTC.invokeMethod(
        'isMicrophoneMuted',
        <String, dynamic>{},
      );
      return result as bool;
    } on PlatformException catch (e) {
      throw 'Unable to get isMicrophoneMuted: ${e.message}';
    }
  }

  /// Mutes or unmutes microphone input at the audio device module level.
  /// Unrelated to `MediaStreamTrack.enabled`.
  ///
  /// Supported on iOS/macOS (where the muting strategy is controlled by
  /// [setMicrophoneMuteMode]) and Android; on all other platforms this is a
  /// no-op that completes normally.
  static Future<void> setMicrophoneMuted(bool muted) async {
    if (!_supportsAdmMicrophoneMute) return;

    try {
      await WebRTC.invokeMethod(
        'setMicrophoneMuted',
        <String, dynamic>{'muted': muted},
      );
    } on PlatformException catch (e) {
      throw 'Unable to set isMicrophoneMuted: ${e.message}';
    }
  }
}
