`medea_flutter_webrtc` changelog
================================

All user visible changes to this project will be documented in this file. This project uses [Semantic Versioning 2.0.0].




## [0.8.3] · 2023-??-?? (unreleased)
[0.8.3]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.8.3

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.8.2...0.8.3)

### Added

- `RtpTransceiverInit.sendEncodings` field with `SendEncodingParameters`. ([#125])
- `RtpParameters` class, `RtpSender.getParameters()` and `RtpSender.setParameters()` methods. ([#135])

### Changed

- Refactor Audio Device Module to use [OpenAL] library for playout and recording. ([#117], [#136])
- Fire `onDeviceChange` callback whenever an output audio device is changed in system settings on desktop platforms. ([#119], [#120])
- Upgraded [libwebrtc] to [116.0.5845.110] version. ([#123])
- `VideoRenderer.width` and `VideoRenderer.height` now take rotation into account. ([#124])

### Fixed

- Video renderer stretching a picture after rotation. ([#124])
- Screen sharing leaking memory on [macOS]. ([#133])

[#117]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/117
[#119]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/119
[#120]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/120
[#123]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/123
[#124]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/124
[#125]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/125
[#133]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/133
[#135]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/135
[#136]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/136
[116.0.5845.110]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/116.0.5845.110




## [0.8.2] · 2023-06-09
[0.8.2]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.8.2

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.8.1...0.8.2)

### Changed

- Upgraded [libwebrtc] to [112.0.5615.165] version. ([#113])

[#113]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/113
[112.0.5615.165]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/112.0.5615.165




## [0.8.1] · 2023-05-29
[0.8.1]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.8.1

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.8.0...0.8.1)

### Fixed

- FFI bridge initialization on desktop platforms. ([#116])

[#116]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/116




## [0.8.0] · 2023-05-19
[0.8.0]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.8.0

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/35858a85...0.8.0)

### Added

- `MediaStreamTrack.facingMode` getter. ([#109])
- `MediaStreamTrack.state` getter. ([#69])
- `MediaStreamTrack.onEnded` callback on [Windows] platform. ([#10], [#35], [#37])
- `MediaStreamTrack.setEnabled` method. ([#28])
- [Flutter]-side video rotation for all native platforms. ([#103])
- `onDeviceChange` callback. ([#26], [#42], [#54], [#101])
- [Linux] platform implementation. ([#10], [#18], [#19], [#34], [#50], [#86])
- `getDisplayMedia` method. ([#10], [#20])
- `enumerateDisplays` method. ([#85])
- `setOutputAudioId` method. ([#39], [#98])
- `microphoneVolumeIsAvailable`, `microphoneVolume`, `setMicrophoneVolume` methods. ([#57])
- `AudioRenderer` object. ([#45])
- `getStats` method. ([#88], [#91])
- `enableFakeMedia` method. ([#65], [#71], [#82])
- Atomic `RtpTransceiver.setRecv` and `RtpTransceiver.setSend` methods. ([#73])
- Way to disable context menu over `RTCVideoView` on Web platform. ([#9])
  
### Fixed

- `WebVideoRenderer` not applying `mirror` and `enableContextMenu` values. ([#62])
- Unsynchronized renderers after Java `VideoTrack` update. ([#76])
- `WebAudioRenderer` not removing its audio element. ([#46])
- Mirroring issues with `RTCVideoRendererWeb`. ([#15], [#14])
- Initial video rendering glitch on [macOS] platform. ([#102])
- Bluetooth headset detection on [Android] platform. ([#78])

### Changed

- Fully rewrote [Android] platform implementation. ([#6], [#31], [#48], [#75], [#77], [#80])
- Fully rewrote [iOS] platform implementation. ([#89], [#92], [#93], [#94], [#100])

[#6]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/6
[#9]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/9
[#10]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/10
[#14]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/14
[#15]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/15
[#18]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/18
[#19]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/19
[#20]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/20
[#26]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/26
[#28]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/28
[#31]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/31
[#34]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/34
[#35]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/35
[#37]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/37
[#39]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/39
[#42]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/42
[#45]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/45
[#46]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/46
[#48]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/48
[#50]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/50
[#54]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/54
[#57]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/57
[#62]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/62
[#65]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/65
[#69]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/69
[#71]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/71
[#73]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/73
[#75]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/75
[#76]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/76
[#77]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/77
[#78]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/78
[#80]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/80
[#82]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/82
[#85]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/85
[#86]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/86
[#88]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/88
[#89]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/89
[#91]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/91
[#92]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/92
[#93]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/93
[#94]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/94
[#98]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/98
[#100]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/100
[#101]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/101
[#102]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/102
[#103]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/103
[#109]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/109




## Previous releases

See [changelog in upstream repository](https://github.com/flutter-webrtc/flutter-webrtc/blob/0.7.0%2Bhotfix.2/CHANGELOG.md).




[Android]: https://www.android.com
[Flutter]: https://www.flutter.dev
[iOS]: https://www.apple.com/ios
[libwebrtc]: https://github.com/instrumentisto/libwebrtc-bin
[Linux]: https://www.linux.org
[macOS]: https://www.apple.com/macos
[OpenAL]: https://github.com/kcat/openal-soft
[Semantic Versioning 2.0.0]: https://semver.org
[Windows]: https://www.microsoft.com/windows
