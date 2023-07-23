import 'package:flutter/foundation.dart';

import '../utils.dart';

enum AndroidAudioMode {
  normal,
  callScreening,
  inCall,
  inCommunication,
  ringtone,
}

extension AndroidAudioModeExt on AndroidAudioMode {
  String get value => describeEnum(this);
}

extension AndroidAudioModeEnumEx on String {
  AndroidAudioMode toAndroidAudioMode() => AndroidAudioMode.values
      .firstWhere((d) => describeEnum(d) == toLowerCase());
}

enum AndroidAudioFocusMode {
  gain,
  gainTransient,
  gainTransientExclusive,
  gainTransientMayDuck,
}

extension AndroidAudioFocusModeExt on AndroidAudioFocusMode {
  String get value => describeEnum(this);
}

extension AndroidAudioFocusModeEnumEx on String {
  AndroidAudioFocusMode toAndroidAudioFocusMode() =>
      AndroidAudioFocusMode.values
          .firstWhere((d) => describeEnum(d) == toLowerCase());
}

class AndroidAudioConfiguration {
  AndroidAudioConfiguration({
    this.androidAudioMode,
    this.androidAudioFocusMode,
  });
  final AndroidAudioMode? androidAudioMode;
  final AndroidAudioFocusMode? androidAudioFocusMode;

  Map<String, dynamic> toMap() => <String, dynamic>{
        if (androidAudioMode != null)
          'androidAudioMode': androidAudioMode!.value,
        if (androidAudioFocusMode != null)
          'androidAudioFocusMode': androidAudioFocusMode!.value,
      };
}

class AndroidNativeAudioManagement {
  static Future<void> setAndroidAudioConfiguration(
      AndroidAudioConfiguration config) async {
    if (WebRTC.platformIsAndroid) {
      await WebRTC.invokeMethod(
        'setAndroidAudioConfiguration',
        <String, dynamic>{'configuration': config.toMap()},
      );
    }
  }
}
