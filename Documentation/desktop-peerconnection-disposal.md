# Desktop PeerConnection disposal regression check

`example/lib/peer_connection_dispose_smoke.dart` exercises native observer
teardown on Windows and Linux. It creates a remote audio stream from a synthetic
SDP offer, waits for `onAddStream`, then calls `dispose()` followed by `close()`.
It repeats this sequence ten times. No account, microphone capture, ICE server,
or media connection is needed.

Run this with a desktop runner. `flutter test` uses mocked platform channels and
cannot exercise the native observer lifetime. From the repository root:

```sh
cd example
flutter pub get
flutter run -d linux -t lib/peer_connection_dispose_smoke.dart
```

On Windows, replace `-d linux` with `-d windows`. Success prints:

```text
PASS: 10 native PeerConnections disposed with remote audio
```

To check the native process exit code on Windows (PowerShell, from `example`):

```powershell
flutter build windows --debug -t lib/peer_connection_dispose_smoke.dart
$process = Start-Process -FilePath .\build\windows\x64\runner\Debug\flutter_webrtc_example.exe -WindowStyle Hidden -Wait -PassThru
$process.ExitCode
```

The expected exit code is zero. A Dart failure exits with code 1. A native
access violation can terminate the process before Dart can report a failure.

## Failure being exercised

In `common/cpp/src/flutter_peerconnection.cc`, `RTCPeerConnectionDispose`
previously erased `peerconnection_observers_[uuid]` while the native connection
still had that observer registered. A later `RTCPeerConnectionClose` called
libwebrtc `Close()`, which can deliver `OnRemoveStream` for remaining remote
streams. That callback could access the deleted observer.

Disposal now closes the native connection while its observer is still alive,
unregisters the observer, then erases it. The connection map entry remains for
the subsequent `peerConnectionClose` call, preserving that cleanup sequence.

Restore the regular example entry point after the check:

```sh
flutter run -d windows -t lib/main.dart
```

Use `-d linux` for the Linux example.
