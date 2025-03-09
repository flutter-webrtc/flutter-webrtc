# Flutter-WebRTC

[![Financial Contributors on Open Collective](https://opencollective.com/flutter-webrtc/all/badge.svg?label=financial+contributors)](https://opencollective.com/flutter-webrtc) [![pub package](https://img.shields.io/pub/v/flutter_webrtc.svg)](https://pub.dartlang.org/packages/flutter_webrtc) [![Gitter](https://badges.gitter.im/flutter-webrtc/Lobby.svg)](https://gitter.im/flutter-webrtc/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![slack](https://img.shields.io/badge/join-us%20on%20slack-gray.svg?longCache=true&logo=slack&colorB=brightgreen)](https://join.slack.com/t/flutterwebrtc/shared_invite/zt-q83o7y1s-FExGLWEvtkPKM8ku_F8cEQ)

WebRTC plugin for Flutter Mobile/Desktop/Web

</br>
<p align="center">
<strong>Sponsored with 💖 &nbsp by</strong><br />
<a href="https://getstream.io/chat/flutter/tutorial/?utm_source=https://github.com/flutter-webrtc/flutter-webrtc&utm_medium=github&utm_content=developer&utm_term=flutter" target="_blank">
<img src="assets/sponsors/stream-logo.png" alt="Stream Chat" style="margin: 8px; width: 350px" />
</a>
<br />
Enterprise Grade APIs for Feeds, Chat, & Video. <a href="https://getstream.io/video/docs/flutter/?utm_source=https://github.com/flutter-webrtc/flutter-webrtc&utm_medium=sponsorship&utm_content=&utm_campaign=webrtcFlutterRepo_July2023_video_klmh22" target="_blank">Try the Flutter Video tutorial</a> 💬
</p>

</br>
<p align="center">
<a href="https://livekit.io/?utm_source=opencollective&utm_medium=github&utm_campaign=flutter-webrtc" target="_blank">
<img src="https://avatars.githubusercontent.com/u/69438833?s=200&v=4" alt="LiveKit" style="margin: 8px; width: 100px" />
</a>
<br />
   <a href="https://livekit.io/?utm_source=opencollective&utm_medium=github&utm_campaign=flutter-webrtc" target="_blank">LiveKit</a> - Open source WebRTC and realtime AI infrastructure
<p>

## Functionality

| Feature | Android | iOS | [Web](https://flutter.dev/web) | macOS | Windows | Linux | [Embedded](https://github.com/sony/flutter-elinux) | [Fuchsia](https://fuchsia.dev/) |
| :-------------: | :-------------:| :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: |
| Audio/Video | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Data Channel | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Screen Capture | :heavy_check_mark: | [:heavy_check_mark:(*)](https://github.com/flutter-webrtc/flutter-webrtc/wiki/iOS-Screen-Sharing) | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Unified-Plan | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Simulcast | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| MediaRecorder | :warning: | :warning: | :heavy_check_mark: | | | | | |
| End to End Encryption | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Insertable Streams | | | | | | | | |

Additional platform/OS support from the other community

- flutter-tizen: <https://github.com/flutter-tizen/plugins/tree/master/packages/flutter_webrtc>
- flutter-elinux(WIP): <https://github.com/sony/flutter-elinux-plugins/issues/7>

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

### Note for iOS

The WebRTC.xframework compiled after the m104 release no longer supports iOS arm devices, so need to add the `config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'` to your ios/Podfile in your project

ios/Podfile

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
     target.build_configurations.each do |config|
      # Workaround for https://github.com/flutter/flutter/issues/64502
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES' # <= this line
     end
  end
end
```

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
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
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

If necessary, in the same `build.gradle` you will need to increase `minSdkVersion` of `defaultConfig` up to `23` (currently default Flutter generator set it to `16`).

### Important reminder

When you compile the release apk, you need to add the following operations,
[Setup Proguard Rules](https://github.com/flutter-webrtc/flutter-webrtc/blob/main/android/proguard-rules.pro)

## Contributing

The project is inseparable from the contributors of the community.

- [CloudWebRTC](https://github.com/cloudwebrtc) - Original Author
- [RainwayApp](https://github.com/rainwayapp) - Sponsor
- [亢少军](https://github.com/kangshaojun) - Sponsor
- [ION](https://github.com/pion/ion) - Sponsor
- [reSipWebRTC](https://github.com/reSipWebRTC) - Sponsor
- [沃德米科技](https://github.com/woodemi)-[36记手写板](https://www.36notes.com) - Sponsor
- [阿斯特网络科技有限公司](https://www.astgo.net/) - Sponsor

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
