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

Dart channel-contract tests cover policy, payload rejection and disposal. macOS
native debug build and source create/push/flush/dispose smoke pass. Physical
capture, RTP reception, playout and echo cancellation require separate integration
validation; a native source smoke is not evidence of those properties.
