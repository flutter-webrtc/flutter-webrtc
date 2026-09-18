# Picture in Picture

`RTCPictureInPictureController` drives the native picture-in-picture window on
Android 8+ and iOS 15+. The two platforms behave differently:

- **Android** shrinks the whole activity. Flutter keeps rendering inside the
  small window, so the app is expected to switch to a reduced layout (usually
  just the remote video) while picture-in-picture is active.
- **iOS** shows a native view that renders a single video track. The Flutter UI
  is not visible while picture-in-picture is active.

## Usage

```dart
final pip = RTCPictureInPictureController();
final videoKey = GlobalKey();

// After the remote stream is attached to a renderer:
await pip.configure(
  stream: remoteStream,
  sourceRect: RTCPictureInPictureController.globalRectOf(videoKey),
  aspectRatio: remoteRenderer.value.aspectRatio,
);

// Enter explicitly (for example from a button). With autoEnter (the default)
// the system also enters when the app goes to the background.
await pip.start();

// Rebuild with a reduced layout while active.
RTCPictureInPictureBuilder(
  controller: pip,
  builder: (context, isInPictureInPicture, child) =>
      isInPictureInPicture ? child! : fullLayout(child!),
  child: RTCVideoView(remoteRenderer, key: videoKey),
);

// State changes.
pip.events.listen((event) => print(event.state));

// When the call ends.
await pip.dispose();
```

`configure` can be called again at any time to switch the video track, update
the source rect after a layout change, or change the aspect ratio.

Check `RTCPictureInPictureController.isSupported()` before showing a
picture-in-picture button. It returns `false` on web, desktop, Android below
8, iOS below 15 and on the iOS simulator.

## Android setup

Declare picture-in-picture support on the activity in
`android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:supportsPictureInPicture="true"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|screenLayout|density|uiMode"
    ...>
```

Without `android:supportsPictureInPicture` `start()` returns `false`.

On Android 12 and newer, `autoEnter` works without additional code. On
Android 8 to 11 the system only allows entering picture-in-picture from
`Activity.onUserLeaveHint`, which plugins cannot observe, so forward it from
your `MainActivity`:

```java
import android.content.res.Configuration;
import androidx.annotation.NonNull;
import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    public void onUserLeaveHint() {
        super.onUserLeaveHint();
        FlutterWebRTCPlugin.onUserLeaveHint();
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode,
                                              @NonNull Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        FlutterWebRTCPlugin.onPictureInPictureModeChanged(isInPictureInPictureMode);
    }
}
```

Forwarding `onPictureInPictureModeChanged` is optional: the plugin also detects
the transition from the activity lifecycle.

Camera and microphone keep working while the activity is in
picture-in-picture.

## iOS setup

Add the `audio` background mode to `ios/Runner/Info.plist`, otherwise the
process is suspended when the app leaves the foreground and the video freezes:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

Picture-in-picture uses the video-call content source, so it requires iOS 15
and a physical device.

### Camera in the background

iOS interrupts the camera when the app goes to the background, so a local
camera track stops producing frames while remote tracks keep rendering. Apps
granted the `com.apple.developer.avfoundation.multitasking-camera-access`
entitlement can keep the camera running on iOS 16+ by enabling it before the
first `getUserMedia`:

```dart
await WebRTC.initialize(options: {'multitaskingCameraAccess': true});
```

### Using a platform view as the animation source

When the video is shown with `RTCVideoPlatFormView`, pass its controller's
`textureId` as `platformViewId` so the system animates from that view instead
of `sourceRect`:

```dart
await pip.configure(stream: remoteStream, platformViewId: controller.textureId);
```

## Events

| State | Android | iOS |
|---|---|---|
| `willStart` | | ✔ |
| `started` | ✔ | ✔ |
| `willStop` | | ✔ |
| `stopped` | ✔ | ✔ |
| `failed` | | ✔ (`error` describes the failure) |
| `restoreUserInterface` | | ✔ (the user tapped the restore button) |
