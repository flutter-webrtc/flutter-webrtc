# Flutter-WebRTC
[![pub package](https://img.shields.io/pub/v/flutter_webrtc.svg)](https://pub.dartlang.org/packages/flutter_webrtc) [![Join the chat at https://gitter.im/flutter-webrtc/Lobby](https://badges.gitter.im/flutter-webrtc/Lobby.svg)](https://gitter.im/flutter-webrtc/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Flutter WebRTC plugin for iOS/Android

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

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml:

```xml
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
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

## Functionality
We intend to implement support the following features:

- [X] Data Channel
- [ ] Port to [Flutter-Desktop-Embedding](https://github.com/google/flutter-desktop-embedding)
- [X] Screen Capture (iOS/Android)
- [ ] ORTC API
- [ ] Support [Fuchsia](https://fuchsia.googlesource.com/)
- [ ] MediaRecorder

### Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'dart:core';

/**
 * getUserMedia sample
 */
class GetUserMediaSample extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  @override
  _GetUserMediaSampleState createState() => new _GetUserMediaSampleState();
}

class _GetUserMediaSampleState extends State<GetUserMediaSample> {
  MediaStream _localStream;
  final _localRenderer = new RTCVideoRenderer();
  bool _inCalling = false;

  @override
  initState() {
    super.initState();
    initRenderers();
  }

  @override
  deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  _makeCall() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth":'640', // Provide your own width, height and frame rate here
          "minHeight": '480',
          "minFrameRate": '30',
        },
        "facingMode": "user",
        "optional": [],
      }
    };

    try {
      var stream = await navigator.getUserMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  _hangUp() async {
    try {
      await _localStream.dispose();
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GetUserMedia API Test'),
      ),
      body: new OrientationBuilder(
        builder: (context, orientation) {
          return new Center(
            child: new Container(
              margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(_localRenderer),
              decoration: new BoxDecoration(color: Colors.black54),
            ),
          );
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: new Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
```

For more examples, please refer to [flutter-webrtc-demo](https://github.com/cloudwebrtc/flutter-webrtc-demo/).
