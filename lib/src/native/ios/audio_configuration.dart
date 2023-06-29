import 'package:flutter/foundation.dart';

import '../utils.dart';

enum AppleAudioMode {
  default_,
  gameChat,
  measurement,
  moviePlayback,
  spokenAudio,
  videoChat,
  videoRecording,
  voiceChat,
  voicePrompt,
}

extension AppleAudioModeExt on AppleAudioMode {
  String get value => describeEnum(this);
}

extension AppleAudioModeEnumEx on String {
  AppleAudioMode toAppleAudioMode() =>
      AppleAudioMode.values.firstWhere((d) => describeEnum(d) == toLowerCase());
}

enum AppleAudioCategory {
  soloAmbient,
  playback,
  record,
  playAndRecord,
  multiRoute,
}

extension AppleAudioCategoryExt on AppleAudioCategory {
  String get value => describeEnum(this);
}

extension AppleAudioCategoryEnumEx on String {
  AppleAudioCategory toAppleAudioCategory() => AppleAudioCategory.values
      .firstWhere((d) => describeEnum(d) == toLowerCase());
}

enum AppleAudioCategoryOption {
  mixWithOthers,
  duckOthers,
  interruptSpokenAudioAndMixWithOthers,
  allowBluetooth,
  allowBluetoothA2DP,
  allowAirPlay,
  defaultToSpeaker,
}

extension AppleAudioCategoryOptionExt on AppleAudioCategoryOption {
  String get value => describeEnum(this);
}

extension AppleAudioCategoryOptionEnumEx on String {
  AppleAudioCategoryOption toAppleAudioCategoryOption() =>
      AppleAudioCategoryOption.values
          .firstWhere((d) => describeEnum(d) == toLowerCase());
}

class AppleAudioConfiguration {
  AppleAudioConfiguration({
    this.appleAudioCategory,
    this.appleAudioCategoryOptions,
    this.appleAudioMode,
  });
  final AppleAudioCategory? appleAudioCategory;
  final Set<AppleAudioCategoryOption>? appleAudioCategoryOptions;
  final AppleAudioMode? appleAudioMode;

  Map<String, dynamic> toMap() => <String, dynamic>{
        if (appleAudioCategory != null)
          'appleAudioCategory': appleAudioCategory!.value,
        if (appleAudioCategoryOptions != null)
          'appleAudioCategoryOptions':
              appleAudioCategoryOptions!.map((e) => e.value).toList(),
        if (appleAudioMode != null) 'appleAudioMode': appleAudioMode!.value,
      };
}

enum AppleAudioIOMode {
  none,
  remoteOnly,
  localOnly,
  localAndRemote,
}

AppleAudioConfiguration getAppleAudioConfigurationForMode(AppleAudioIOMode mode,
    {bool preferSpeakerOutput = false}) {
  if (mode == AppleAudioIOMode.remoteOnly) {
    return AppleAudioConfiguration(
      appleAudioCategory: AppleAudioCategory.playback,
      appleAudioCategoryOptions: {
        AppleAudioCategoryOption.mixWithOthers,
      },
      appleAudioMode: AppleAudioMode.spokenAudio,
    );
  } else if ([
    AppleAudioIOMode.localOnly,
    AppleAudioIOMode.localAndRemote,
  ].contains(mode)) {
    return AppleAudioConfiguration(
      appleAudioCategory: AppleAudioCategory.playAndRecord,
      appleAudioCategoryOptions: {
        AppleAudioCategoryOption.allowBluetooth,
        AppleAudioCategoryOption.mixWithOthers,
      },
      appleAudioMode: preferSpeakerOutput
          ? AppleAudioMode.videoChat
          : AppleAudioMode.voiceChat,
    );
  }

  return AppleAudioConfiguration(
    appleAudioCategory: AppleAudioCategory.soloAmbient,
    appleAudioCategoryOptions: {},
    appleAudioMode: AppleAudioMode.default_,
  );
}

class AppleNativeAudioManagement {
  static Future<void> setAppleAudioConfiguration(
      AppleAudioConfiguration config) async {
    if (WebRTC.platformIsIOS) {
      await WebRTC.invokeMethod(
        'setAppleAudioConfiguration',
        <String, dynamic>{'configuration': config.toMap()},
      );
    }
  }
}
