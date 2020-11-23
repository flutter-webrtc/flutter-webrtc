# Flutter-WebRTC

[![Financial Contributors on Open Collective](https://opencollective.com/flutter-webrtc/all/badge.svg?label=financial+contributors)](https://opencollective.com/flutter-webrtc) [![pub package](https://img.shields.io/pub/v/flutter_webrtc.svg)](https://pub.dartlang.org/packages/flutter_webrtc) [![Gitter](https://badges.gitter.im/flutter-webrtc/Lobby.svg)](https://gitter.im/flutter-webrtc/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

WebRTC plugin for Flutter Mobile/Desktop/Web

## Functionality

| Feature | Android | iOS | [Web](https://flutter.dev/web) | macOS | Windows | Linux | [Fuchsia](https://fuchsia.googlesource.com/) |
| :-------------: | :-------------:| :-----: | :-----: | :-----: | :-----: | :-----: | :-----: |
| Audio/Video | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | [WIP] | [WIP] | |
| Data Channel | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | [WIP] | [WIP] | |
| Screen Capture | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | | | |
| Unified-Plan | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | | |
| Simulcast | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | | |
| MediaRecorder| :warning: | :warning: | :heavy_check_mark: | | | | |

## Usage

Add `flutter_webrtc` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### iOS

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) Camera Usage!</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) Microphone Usage!</string>
```

This entry allows your app to access camera and microphone.

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

If you need to use a Bluetooth device, please add:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```

The Flutter project template adds it, so it may already be there.

Also you will need to set your build settings to Java 8, because official WebRTC jar now uses static methods in `EglBase` interface. Just add this to your app level `build.gradle`:

```groovy
android {
    //...
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

If necessary, in the same `build.gradle` you will need to increase `minSdkVersion` of `defaultConfig` up to `18` (currently default Flutter generator set it to `16`).

## Contributing

The project is inseparable from the contributors of the community.

- [CloudWebRTC](https://github.com/cloudwebrtc) - Original Author
- [RainwayApp](https://github.com/rainwayapp) - Sponsor
- [亢少军](https://github.com/kangshaojun) - Sponsor
- [ION](https://github.com/pion/ion) - Sponsor

### Example

For more examples, please refer to [flutter-webrtc-demo](https://github.com/cloudwebrtc/flutter-webrtc-demo/).

## Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/cloudwebrtc/flutter-webrtc/graphs/contributors"><img src="https://opencollective.com/flutter-webrtc/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Become a financial contributor and help us sustain our community. [[Contribute](https://opencollective.com/flutter-webrtc/contribute)]

#### Individuals

<a href="https://opencollective.com/flutter-webrtc"><img src="https://opencollective.com/flutter-webrtc/individuals.svg?width=890"></a>

#### Organizations

Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/flutter-webrtc/contribute)]

<a href="https://opencollective.com/flutter-webrtc/organization/0/website"><img src="https://opencollective.com/flutter-webrtc/organization/0/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/1/website"><img src="https://opencollective.com/flutter-webrtc/organization/1/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/2/website"><img src="https://opencollective.com/flutter-webrtc/organization/2/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/3/website"><img src="https://opencollective.com/flutter-webrtc/organization/3/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/4/website"><img src="https://opencollective.com/flutter-webrtc/organization/4/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/5/website"><img src="https://opencollective.com/flutter-webrtc/organization/5/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/6/website"><img src="https://opencollective.com/flutter-webrtc/organization/6/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/7/website"><img src="https://opencollective.com/flutter-webrtc/organization/7/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/8/website"><img src="https://opencollective.com/flutter-webrtc/organization/8/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/9/website"><img src="https://opencollective.com/flutter-webrtc/organization/9/avatar.svg"></a>
