# Experimental external media sources

Depends on the external-audio-only factory proposal. This topic is separate from
SDK distribution and application capture/processing. Existing default factories
retain their existing behavior.

Call `RTCExternalMediaSource.create()` before any ordinary factory operation.
Only Windows and macOS are implemented; other platforms fail explicitly. One
external source per factory is supported. `stream` exposes standard tracks for
normal peer negotiation; no capture device is acquired by this source.

`pushAudio` accepts exactly 480 mono 48 kHz PCM16 little-endian samples (960 bytes).
Processing defaults off because callers supply processed audio. `pushVideo`
accepts tightly packed BGRA up to 1920x1080 and increasing microsecond timestamps.
Windows uses the wrapper frame arrival clock; macOS uses the caller timestamp.
A successful push means submission, not successful RTP delivery. macOS discards
input while the SDK is not recording and bounds capture buffering to 200 ms to accommodate 100-ms recorder bursts plus
jitter. Statistics distinguish inactive input drops, queue overflow and explicit
flushes; none imply delivery or physical capture. Render-reference buffering
remains bounded to 100 ms.

Detach senders before disposal. Mute tracks and discard caller queues when ending
transmission; `flush` cannot retract media already submitted to WebRTC or RTP.
`dispose` is idempotent. Closing a source does not stop caller-owned capture.

macOS uses an output-only custom audio device (AVAudioEngine) and provides a
bounded PCM render reference through `renderReference`. It follows the system
default output; the plugin output selector is explicitly unsupported in this mode.
This reference does not itself provide echo cancellation. Windows uses native
SDK playout; obtaining a render reference requires a separate output-loopback
adapter. Capability flags expose this difference; no synthetic reference is used.

## Validation

Twenty Flutter channel/lifecycle tests and focused Dart analysis pass on macOS.
Native macOS debug and Windows x64 release builds/source smokes pass. The
[downstream physical fixture](https://github.com/kiarina/labs/tree/5894f2c/2026/10/20/flutter-fork-external-media-aec)
feeds one camera/record capture through the public source/bridge and caller-owned
AEC to an independent receiver. It verifies source capture/DSP continue during
sender off/on and zero additional SDK microphone input using negotiated positive
controls (Windows ETW and macOS input-node/audio-unit stacks).

This is not universal AEC/quality acceptance: the Mac participant reports slight
double-talk loss despite no echo, and Windows has a positive general assessment
with full-scale peaks remaining. Processing/RAW capture/render-loopback adapters
belong to that fixture/application, not this API. New-peer reconnect, long sessions,
permission/device changes and other platforms remain separate validation gates.
