import 'dart:io';

import 'package:flutter/services.dart';

import '../native_logs_listener.dart';

class WebRTC {
  static const MethodChannel _channel = MethodChannel('FlutterWebRTC.Method');

  static bool get platformIsDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool get platformIsWindows => Platform.isWindows;

  static bool get platformIsMacOS => Platform.isMacOS;

  static bool get platformIsLinux => Platform.isLinux;

  static bool get platformIsMobile => Platform.isIOS || Platform.isAndroid;

  static bool get platformIsIOS => Platform.isIOS;

  static bool get platformIsAndroid => Platform.isAndroid;

  static bool get platformIsWeb => false;

  static Future<T?> invokeMethod<T, P>(String methodName,
      [dynamic param]) async {
    await initialize(options: {
      'logSeverity': NativeLogsListener.instance.severity,
    });

    return _channel.invokeMethod<T>(
      methodName,
      param,
    );
  }

  static bool initialized = false;

  /// Initialize the WebRTC plugin. If this is not manually called, will be
  /// initialized with default settings.
  ///
  /// Params:
  ///
  /// "networkIgnoreMask": a list of AdapterType objects converted to string with `.value`
  ///
  /// Android specific params:
  ///
  /// "forceSWCodec": a boolean that forces software codecs to be used for video.
  ///
  /// "forceSWCodecList": a list of strings of software codecs that should use software.
  ///
  /// "androidAudioConfiguration": an AndroidAudioConfiguration object mapped with toMap()
  ///
  /// "bypassVoiceProcessing": a boolean that bypasses the audio processing for the audio device.
  ///
  /// "audioSampleRate": (Android only) Sets both input and output sample rate in Hz (e.g., 48000).
  ///                    If not specified, uses the native device's default sample rate.
  ///
  /// "audioOutputSampleRate": (Android only) Sets only output sample rate in Hz (e.g., 48000).
  ///                          Takes precedence over audioSampleRate for output.
  ///                          If not specified, uses audioSampleRate or native default.
  static Future<void> initialize({Map<String, dynamic>? options}) async {
    if (!initialized) {
      await _channel.invokeMethod<void>('initialize', <String, dynamic>{
        'options': options ?? {},
      });
      initialized = true;
    }
  }
}
