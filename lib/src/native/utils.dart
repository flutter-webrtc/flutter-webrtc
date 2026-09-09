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
  /// "androidUseHardwareAudioProcessing": (Android only) defaults to true. Set to false to leave
  ///                    the platform hardware AEC/NS off and let the WebRTC software APM handle
  ///                    echo/noise instead (useful when a device's built-in AEC is unreliable).
  ///
  /// "audioSampleRate": (Android only) Sets both input and output sample rate in Hz (e.g., 48000).
  ///                    If not specified, uses the native device's default sample rate.
  ///
  /// "audioOutputSampleRate": (Android only) Sets only output sample rate in Hz (e.g., 48000).
  ///                          Takes precedence over audioSampleRate for output.
  ///                          If not specified, uses audioSampleRate or native default.
  ///
  /// "enableWARP": (Android/iOS/macOS/Windows/Linux) a boolean that opts into WARP
  ///               (WebRTC Abridged Roundtrip Protocol, draft-uberti-tsvwg-warp),
  ///               which shortens the ~6 RTT WebRTC setup down to ~2 RTT. It
  ///               piggybacks the DTLS handshake on the ICE STUN binding exchange
  ///               (the `WebRTC-IceHandshakeDtls` field trial) so the DTLS and ICE
  ///               negotiations run in parallel instead of one after the other,
  ///               and turns on DSCP marking (`enableDscp`) for every peer
  ///               connection. Field trials are process global and are read when a
  ///               peer connection builds its transports, which is why this lives
  ///               here and not in the peer connection configuration: it has to be
  ///               set before the first peer connection is created.
  ///               See https://www.ietf.org/archive/id/draft-uberti-tsvwg-warp-00.html
  ///
  /// "zeroPlayoutDelay": (Android/iOS/macOS/Windows/Linux) a boolean that plays out every
  ///                     received frame as soon as it is decoded instead of
  ///                     holding it back for the jitter buffer target delay (the
  ///                     `WebRTC-ForcePlayoutDelay/min_ms:0,max_ms:0/` field
  ///                     trial, which pins the playout delay to 0 ms). Trades the
  ///                     jitter buffer's smoothing for latency, so it is meant
  ///                     for low latency scenarios on reliable networks. Like
  ///                     `enableWARP` it is a field trial, so it has to be set
  ///                     before the first peer connection is created.
  static Future<void> initialize({Map<String, dynamic>? options}) async {
    if (!initialized) {
      await _channel.invokeMethod<void>('initialize', <String, dynamic>{
        'options': options ?? {},
      });
      initialized = true;
    }
  }
}
