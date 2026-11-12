# Caller-owned audio capture (proposed)

On Windows, call `WebRTC.initialize(options: {'externalAudioInputOnly': true})`
before any plugin operation when a separate capturer owns the microphone.
The policy is immutable for that factory; omitted subsequent options preserve it.
Initialization requests are serialized, and failures can be retried.

This opt-in depends on webrtc-sdk/libwebrtc#158 and webrtc-sdk/webrtc#314.
The stock SDK remains buildable; requesting the option without the dependent
native API fails explicitly. The matching DLL, import library and headers must
be supplied together. There is no silent fallback to microphone recording.

The default remains ordinary recording. Playout is unaffected. Other factories
and other plugins can still record. Device-audio getUserMedia requests are
rejected in this mode; video-only requests are allowed. This policy does not
create external tracks or implement AEC. A separate external-media API/adapter
proposal handles caller-supplied PCM and video. Other OS are not implemented by
this policy-only proposal.
