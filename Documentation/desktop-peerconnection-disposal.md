# Desktop PeerConnection disposal regression check

`example/lib/peer_connection_dispose_smoke.dart` exercises native observer
teardown on Windows and Linux. It creates a remote audio stream from a synthetic
SDP offer, waits for `onAddStream`, then tears the connection down. It runs ten
iterations with `dispose()` followed by `close()` and ten with `close()`
followed by `dispose()`. After each order it asks the plugin, through the
`peerConnectionCounts` method, how many native connections and observers are
still held, and fails unless both are zero. No account, microphone capture, ICE
server, or media connection is needed.

Run this with a desktop runner. `flutter test` uses mocked platform channels and
cannot exercise the native observer lifetime. From the repository root:

```sh
cd example
flutter pub get
flutter run -d linux -t lib/peer_connection_dispose_smoke.dart
```

On Windows, replace `-d linux` with `-d windows`. Success prints:

```text
PASS: 10 native PeerConnections torn down, dispose() then close(), native maps empty
PASS: 10 native PeerConnections torn down, close() then dispose(), native maps empty
```

A retained observer fails the second line with, for example,
`native maps not empty after close() then dispose(): peerConnections=0 observers=10`.

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

The reverse order had the opposite problem. `RTCPeerConnectionClose` erases the
connection map entry, so a following `peerConnectionDispose` could not find the
connection and returned without erasing the observer. The observer, and the
`scoped_refptr` to the closed connection it holds, stayed in
`peerconnection_observers_` for the life of the process. Disposal now falls back
to the connection the observer holds when the map entry is already gone.

Restore the regular example entry point after the check:

```sh
flutter run -d windows -t lib/main.dart
```

Use `-d linux` for the Linux example.
