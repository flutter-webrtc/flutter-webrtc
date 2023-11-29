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
  gainTransientMayDuck
}

extension AndroidAudioFocusModeExt on AndroidAudioFocusMode {
  String get value => describeEnum(this);
}

extension AndroidAudioFocusModeEnumEx on String {
  AndroidAudioFocusMode toAndroidAudioFocusMode() =>
      AndroidAudioFocusMode.values
          .firstWhere((d) => describeEnum(d) == toLowerCase());
}

enum AndroidAudioStreamType {
  accessibility,
  alarm,
  dtmf,
  music,
  notification,
  ring,
  system,
  voiceCall
}

extension AndroidAudioStreamTypeExt on AndroidAudioStreamType {
  String get value => describeEnum(this);
}

extension AndroidAudioStreamTypeEnumEx on String {
  AndroidAudioStreamType toAndroidAudioStreamType() =>
      AndroidAudioStreamType.values
          .firstWhere((d) => describeEnum(d) == toLowerCase());
}

enum AndroidAudioAttributesUsageType {
  alarm,
  assistanceAccessibility,
  assistanceNavigationGuidance,
  assistanceSonification,
  assistant,
  game,
  media,
  notification,
  notificationEvent,
  notificationRingtone,
  unknown,
  voiceCommunication,
  voiceCommunicationSignalling
}

extension AndroidAudioAttributesUsageTypeExt
    on AndroidAudioAttributesUsageType {
  String get value => describeEnum(this);
}

extension AndroidAudioAttributesUsageTypeEnumEx on String {
  AndroidAudioAttributesUsageType toAndroidAudioAttributesUsageType() =>
      AndroidAudioAttributesUsageType.values
          .firstWhere((d) => describeEnum(d) == toLowerCase());
}

enum AndroidAudioAttributesContentType {
  movie,
  music,
  sonification,
  speech,
  unknown
}

extension AndroidAudioAttributesContentTypeExt
    on AndroidAudioAttributesContentType {
  String get value => describeEnum(this);
}

extension AndroidAudioAttributesContentTypeEnumEx on String {
  AndroidAudioAttributesContentType toAndroidAudioAttributesContentType() =>
      AndroidAudioAttributesContentType.values
          .firstWhere((d) => describeEnum(d) == toLowerCase());
}

class AndroidAudioConfiguration {
  AndroidAudioConfiguration({
    this.manageAudioFocus,
    this.androidAudioMode,
    this.androidAudioFocusMode,
    this.androidAudioStreamType,
    this.androidAudioAttributesUsageType,
    this.androidAudioAttributesContentType,
    this.forceHandleAudioRouting,
  });

  /// Controls whether audio focus should be automatically managed during
  /// a WebRTC session.
  final bool? manageAudioFocus;
  final AndroidAudioMode? androidAudioMode;
  final AndroidAudioFocusMode? androidAudioFocusMode;
  final AndroidAudioStreamType? androidAudioStreamType;
  final AndroidAudioAttributesUsageType? androidAudioAttributesUsageType;
  final AndroidAudioAttributesContentType? androidAudioAttributesContentType;

  /// On certain Android devices, audio routing does not function properly and
  /// bluetooth microphones will not work unless audio mode is set to
  /// `inCommunication` or `inCall`. Audio routing is turned off those cases.
  ///
  /// If this set to true, will attempt to do audio routing regardless of audio mode.
  final bool? forceHandleAudioRouting;

  Map<String, dynamic> toMap() => <String, dynamic>{
        if (manageAudioFocus != null) 'manageAudioFocus': manageAudioFocus!,
        if (androidAudioMode != null)
          'androidAudioMode': androidAudioMode!.value,
        if (androidAudioFocusMode != null)
          'androidAudioFocusMode': androidAudioFocusMode!.value,
        if (androidAudioStreamType != null)
          'androidAudioStreamType': androidAudioStreamType!.value,
        if (androidAudioAttributesUsageType != null)
          'androidAudioAttributesUsageType':
              androidAudioAttributesUsageType!.value,
        if (androidAudioAttributesContentType != null)
          'androidAudioAttributesContentType':
              androidAudioAttributesContentType!.value,
        if (forceHandleAudioRouting != null)
          'forceHandleAudioRouting': forceHandleAudioRouting!,
      };

  /// A pre-configured AndroidAudioConfiguration for media playback.
  static final media = AndroidAudioConfiguration(
    manageAudioFocus: true,
    androidAudioMode: AndroidAudioMode.normal,
    androidAudioFocusMode: AndroidAudioFocusMode.gain,
    androidAudioStreamType: AndroidAudioStreamType.music,
    androidAudioAttributesUsageType: AndroidAudioAttributesUsageType.media,
    androidAudioAttributesContentType:
        AndroidAudioAttributesContentType.unknown,
  );

  /// A pre-configured AndroidAudioConfiguration for voice communication.
  static final communication = AndroidAudioConfiguration(
    manageAudioFocus: true,
    androidAudioMode: AndroidAudioMode.inCommunication,
    androidAudioFocusMode: AndroidAudioFocusMode.gain,
    androidAudioStreamType: AndroidAudioStreamType.voiceCall,
    androidAudioAttributesUsageType:
        AndroidAudioAttributesUsageType.voiceCommunication,
    androidAudioAttributesContentType: AndroidAudioAttributesContentType.speech,
  );
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
