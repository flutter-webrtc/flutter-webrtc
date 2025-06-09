`medea_flutter_webrtc` changelog
================================

All user visible changes to this project will be documented in this file. This project uses [Semantic Versioning 2.0.0].




## main

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.14.0...main)

## BC Breaks

- Bumped up [macOS] deployment target to 10.15. ([#203])

### Changed

- Upgraded [libwebrtc] to [137.0.7151.68] version. ([#203], [007bd441])
- Upgraded [`flutter_rust_bridge`] crate to [2.10.0][frb-2.10.0] version. ([#201])

### Fixed

- Resources cleanup when `medea_flutter_webrtc` Flutter plugin is detached on Android. ([#202])

[#201]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/201
[#202]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/202
[#203]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/203
[007bd441]: https://github.com/instrumentisto/medea-flutter-webrtc/commit/007bd441ce5386aa84e47b3dcc49bdfee070241d
[137.0.7151.68]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/137.0.7151.68
[frb-2.10.0]: https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.10.0




## [0.14.0] · 2025-05-15
[0.14.0]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.14.0

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.13.3...0.14.0)

### Added

- Support for changing audio processing settings for local audio `MediaStreamTrack`s on desktop: ([#197])
    - `MediaStreamTrack.isAudioProcessingAvailable` method checking whether audio processing controls are available for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.setNoiseSuppressionEnabled` method enabling/disabling noise suppression for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.setNoiseSuppressionLevel` method configuring noise suppression aggressiveness for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.setHighPassFilterEnabled` method enabling/disabling high-pass filter for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.setEchoCancellationEnabled` method enabling/disabling acoustic echo cancellation for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.setAutoGainControlEnabled` method enabling/disabling auto gain control for local audio `MediaStreamTrack`.
    - `AudioConstraints.noiseSuppression`, `AudioConstraints.noiseSuppressionLevel`, `AudioConstraints.highPassFilter`, `AudioConstraints.echoCancellation` fields to control audio processing when creating local audio `MediaStreamTrack`.
- Support for getting audio processing settings for local audio `MediaStreamTrack`s on desktop: ([#199])
    - `MediaStreamTrack.isNoiseSuppressionEnabled` method checking whether noise suppression is enabled for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.getNoiseSuppressionLevel` method returning noise suppression level of local audio `MediaStreamTrack`.
    - `MediaStreamTrack.isHighPassFilterEnabled` method checking whether high pass filter is enabled for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.isEchoCancellationEnabled` method checking whether acoustic echo cancellation is enabled for local audio `MediaStreamTrack`.
    - `MediaStreamTrack.isAutoGainControlEnabled` method checking whether automatic gain control is enabled for local audio `MediaStreamTrack`.

### Changed

- Upgraded [OpenAL] library to [1.24.3][openal-1.24.3] version. ([#193])
- Upgraded [libwebrtc] to [136.0.7103.92] version. ([#196], [170d6d8c])
- Increased default noise suppression level for local audio `MediaStreamTrack`s on desktop from `moderate` to `veryHigh`. ([#197])

### Fixed

- Audio processing not working properly on multiple local audio sources. ([#195])
- Default device video resolution to 640x480. ([#198])

[#193]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/193
[#195]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/195
[#196]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/196
[#197]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/197
[#198]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/198
[#199]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/199
[170d6d8c]: https://github.com/instrumentisto/medea-flutter-webrtc/commit/170d6d8c73a72e0012a3c0c578c4b259021ca1fb
[136.0.7103.92]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/136.0.7103.92
[openal-1.24.3]: https://github.com/kcat/openal-soft/releases/tag/1.24.3




## [0.13.3] · 2025-03-27
[0.13.3]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.13.3

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.13.2...0.13.3)

### Changed

- Made number of utilized threads not depending on CPUs count. ([#192])
- Upgraded [`flutter_rust_bridge`] crate to [2.9.0][frb-2.9.0] version. ([#192])

[#192]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/192
[frb-2.9.0]: https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.9.0




## [0.13.2] · 2025-03-18
[0.13.2]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.13.2

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.13.1...0.13.2)

### Changed

- Upgraded [libwebrtc] to [134.0.6998.165] version. ([24750229])

[24750229]: https://github.com/instrumentisto/medea-flutter-webrtc/commit/24750229034753705cfc6f5e240f4cabd8bfbd04
[134.0.6998.165]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/134.0.6998.165




## [0.13.1] · 2025-03-18
[0.13.1]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.13.1

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.13.0...0.13.1)

### Changed

- Upgraded [libwebrtc] to [134.0.6998.88] version. ([#190], [bb9df198])

[#190]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/190
[bb9df198]: https://github.com/instrumentisto/medea-flutter-webrtc/commit/bb9df198a7d77a24e477684368bef58bb40c0d0f
[134.0.6998.88]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/134.0.6998.88




## [0.13.0] · 2025-03-07
[0.13.0]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.13.0

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.12.2...0.13.0)

### Fixed

- `MediaStreamTrack.onEnded` callback not firing for local tracks when corresponding media input device is disconnected on desktop platforms. ([#189])

### Changed

- Upgraded [`flutter_rust_bridge`] crate to [2.8.0][frb-2.8.0] version. ([#185])
- Upgraded [libwebrtc] to [133.0.6943.141] version. ([#186])

[#185]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/185
[#186]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/186
[#189]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/189
[133.0.6943.141]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/133.0.6943.141
[frb-2.8.0]: https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.8.0




## [0.12.2] · 2025-02-03
[0.12.2]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.12.2

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.12.1...0.12.2)

### Changed

- Upgraded [libwebrtc] to [132.0.6834.159] version. ([0708b1fc])

[0708b1fc]: https://github.com/instrumentisto/medea-flutter-webrtc/commit/0708b1fc075643a94e6e63eb0e17842e587e8aa6
[132.0.6834.159]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/132.0.6834.159




## [0.12.1] · 2025-01-23
[0.12.1]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.12.1

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.12.0...0.12.1)

### Changed

- Upgraded [OpenAL] library to [1.24.2][openal-1.24.2] version. ([494eb2fa])
- Upgraded [libwebrtc] to [132.0.6834.83] version. ([#184])

[#184]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/184
[494eb2fa]: https://github.com/instrumentisto/medea-flutter-webrtc/commit/494eb2fae899f26b4f65d8dae74adda55dc5f7d2
[132.0.6834.83]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/132.0.6834.83
[openal-1.24.2]: https://github.com/kcat/openal-soft/releases/tag/1.24.2




## [0.12.0] · 2024-12-16
[0.12.0]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.12.0

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.11.2...0.12.0)

### Changed

- Upgraded [OpenAL] library to [1.24.1][openal-1.24.1] version. ([#182], [#181])
- Upgraded [libwebrtc] to [131.0.6778.139] version. ([#180], [cec4e41e])
- Upgraded [`flutter_rust_bridge`] crate to [2.7.0][frb-2.7.0] version. ([#183])

[#180]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/180
[#181]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/181
[#182]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/182
[#183]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/183
[cec4e41e]: https://github.com/instrumentisto/medea-flutter-webrtc/commit/cec4e41e4b345340e1a7e7749a5d1ca106946e63
[131.0.6778.139]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/131.0.6778.139
[openal-1.24.1]: https://github.com/kcat/openal-soft/releases/tag/1.24.1
[frb-2.7.0]: https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.7.0




## [0.11.2] · 2024-10-28
[0.11.2]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.11.2

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.11.1...0.11.2)

### Added

- `RtpReceiver.getCapabilities()` method. ([#173])

### Changed

- Upgraded [`flutter_rust_bridge`] crate to [2.4.0][frb-2.4.0] version. ([#172])
- Upgraded [libwebrtc] to [130.0.6723.69] version. ([#176], [#177])

### Fixed

- `AVAudioSession` activation in push notification context on [iOS]. ([#175])

[#172]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/172
[#173]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/173
[#175]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/175
[#176]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/176
[#177]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/177
[130.0.6723.69]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/130.0.6723.69
[frb-2.4.0]: https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.4.0




## [0.11.1] · 2024-09-11
[0.11.1]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.11.1

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.11.0...0.11.1)

### Changed

- Upgraded [libwebrtc] to [128.0.6613.119] version. ([#170])

[#170]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/170
[128.0.6613.119]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/128.0.6613.119




## [0.11.0] · 2024-08-26
[0.11.0]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.11.0

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.10.0...0.11.0)

### Changed

- Upgraded [`flutter_rust_bridge`] crate to [2.2.0][frb-2.2.0] version. ([#167])

[#167]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/167
[frb-2.2.0]: https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.2.0




## [0.10.0] · 2024-08-01
[0.10.0]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.10.0

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.9.0...0.10.0)

### Added

- `PeerConnection.videoDecoders()` and `PeerConnection.videoEncoders()` methods enumerating available video codecs and their capability of hardware acceleration. ([#144])
- Support for multiple input audio devices usage at one time on desktop platforms. ([#145])
- `MediaStreamTrack.isAudioLevelAvailable` function and `MediaStreamTrack.onAudioLevelChanged` callback for detecting input audio level changes of local `MediaStreamTrack`. ([#149])
- `RtpSender.getCapabilities()` and `RtpTransceiver.setCodecPreferences()` operating by `RtpCapabilities`, `RtpHeaderExtensionCapability` and `RtpCodecCapability`. ([#137])
- `AudioConstraints.autoGainControl` field. ([#156])

### Changed

- Upgraded [libwebrtc] to [127.0.6533.72] version. ([#155], [#162], [#166])
- Disable [H264] software encoders and decoders. ([#153])
- Migrated from [`dart:html`] to [`package:web`]. ([#164])

### Fixed

- Double free when [macOS] video renderer is reused for different tracks. ([#139])
- [Swift] exceptions not being propagated to [Dart] side on [iOS]. ([#142])
- Segfault when switching to external camera on [macOS]. ([#142])
- Unexpected audio category on `setOutputAudioId` call on [iOS]. ([#146])
- Race condition bug on `setOutputAudioId` call on [Android]. ([#146])
- Race condition bug on input/output device switch on desktop platforms. ([#151])
- `RtpReceiver` use after free on [Android]. ([#165])

[#137]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/137
[#139]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/139
[#142]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/142
[#144]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/144
[#145]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/145
[#146]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/146
[#149]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/149
[#151]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/151
[#153]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/153
[#155]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/155
[#156]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/156
[#162]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/162
[#164]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/164
[#165]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/165
[#166]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/166
[`dart:html`]: https://dart.dev/libraries/dart-html
[`package:web`]: https://pub.dev/packages/web
[127.0.6533.72]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/127.0.6533.72




## [0.9.0] · 2023-12-07
[0.9.0]: https://github.com/instrumentisto/medea-flutter-webrtc/tree/0.9.0

[Diff](https://github.com/instrumentisto/medea-flutter-webrtc/compare/0.8.2...0.9.0)

### Added

- `RtpTransceiverInit.sendEncodings` field with `SendEncodingParameters`. ([#125])
- `MediaStreamTrack.height()` and `MediaStreamTrack.width()` methods. ([#129])
- `RtpParameters` class, `RtpSender.getParameters()` and `RtpSender.setParameters()` methods. ([#135])
- `VideoRenderer.onCanPlay` callback. ([#134])

### Changed

- Refactor Audio Device Module to use [OpenAL] library for playout and recording. ([#117], [#136])
- Fire `onDeviceChange` callback whenever an output audio device is changed in system settings on desktop platforms. ([#119], [#120])
- Upgraded [libwebrtc] to [118.0.5993.88] version. ([#134])
- `VideoRenderer.width` and `VideoRenderer.height` now take rotation into account. ([#124])

### Fixed

- Video renderer stretching a picture after rotation. ([#124], [#134])
- Screen sharing leaking memory on [macOS]. ([#133])

[#117]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/117
[#119]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/119
[#120]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/120
[#124]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/124
[#125]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/125
[#129]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/129
[#133]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/133
[#134]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/134
[#135]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/135
[#136]: https://github.com/instrumentisto/medea-flutter-webrtc/pull/136
[118.0.5993.88]: https://github.com/instrumentisto/libwebrtc-bin/releases/tag/118.0.5993.88




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




[`flutter_rust_bridge`]: https://docs.rs/flutter_rust_bridge
[Android]: https://www.android.com
[Dart]: https://dart.dev
[Flutter]: https://www.flutter.dev
[H264]: https://bloggeek.me/webrtcglossary/h-264/
[Linux]: https://www.linux.org
[OpenAL]: https://github.com/kcat/openal-soft
[Semantic Versioning 2.0.0]: https://semver.org
[Swift]: https://developer.apple.com/swift
[Windows]: https://www.microsoft.com/windows
[iOS]: https://www.apple.com/ios
[libwebrtc]: https://github.com/instrumentisto/libwebrtc-bin
[macOS]: https://www.apple.com/macos
