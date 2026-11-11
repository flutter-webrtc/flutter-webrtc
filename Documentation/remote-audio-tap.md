# Remote audio tap (experimental)

`RTCRemoteAudioTap.attach(track)` delivers the decoded PCM of a remote audio
track to Dart so that an application can process it (voice conversion, mixing
with other voices, its own echo cancellation) and play it itself.

```dart
final tap = await RTCRemoteAudioTap.attach(event.track);   // silences native playout
tap.pcm.listen((p) => mySpeaker.push(p.data, p.sampleRate, p.channels));
...
await tap.detach();                                        // restores playout volume
```

## What it guarantees

- PCM is taken by the SDK's per-track sink (`RTCAudioRenderer` on macOS,
  `AudioTrackSink` in the C++ wrapper), i.e. after decoding and **before** the
  playout mixer applies the track volume. It is interleaved PCM16 with the
  sample rate and channel count the SDK delivers (48 kHz on the tested
  desktops); converting it is the caller's job.
- With `silenceNativePlayout` (default) the track volume is set to 0. The SDK
  keeps decoding and pulling the track, so the tap keeps receiving, but none of
  it reaches the native speaker. `detach` restores the previous volume (macOS)
  or the SDK default 1 (Windows, where the wrapper has no volume getter).
- The sink runs on a real-time audio thread and never waits: it try-locks,
  copies into a preallocated buffer (up to 1 s of 48 kHz stereo) and returns.
  A separate delivery thread/queue sends the buffered PCM to the per-tap event
  channel `FlutterWebRTC/remoteAudioTap/<id>` every ~10–20 ms. Data that cannot
  be buffered is dropped and counted (`stats()`: `contendedFrames`,
  `overflowFrames`, `formatDroppedFrames`), never blocking audio.
- It is independent of the audio device module, mixers and echo cancellation:
  it only hands PCM over. Whatever the application plays is its own render
  reference.

## Scope

Windows and macOS only; other platforms throw `UnsupportedError`. The tap does
not change the receive pipeline or jitter buffer. Delivery adds the platform
thread hop; the caller should buffer before playing. Tracks are looked up among
the receivers of the plugin's peer connections by track id.

Tested on macOS and Windows with an Opus track from an aiortc test peer: the application played the
tapped PCM through its own speaker after processing it, and used the played audio
as the echo cancellation reference. Setup and numbers:
https://github.com/kiarina/labs/tree/main/2026/10/21/flutter-remote-audio-tap-playout
