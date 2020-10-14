class MediaConstraints {
  MediaConstraints({this.mandatory, this.optional});
  final List<KeyValuePair> mandatory;
  final List<KeyValuePair> optional;
}

class KeyValuePair {
  KeyValuePair({this.key, this.value});
  final String key;
  final dynamic value;
}

// Audio constraints.
const String kGoogEchoCancellation = 'googEchoCancellation';
const String kAutoGainControl = 'googAutoGainControl';
const String kExperimentalAutoGainControl = 'googAutoGainControl2';
const String kNoiseSuppression = 'googNoiseSuppression';
const String kExperimentalNoiseSuppression = 'googNoiseSuppression2';
const String kHighpassFilter = 'googHighpassFilter';
const String kTypingNoiseDetection = 'googTypingNoiseDetection';
const String kAudioMirroring = 'googAudioMirroring';
const String kAudioNetworkAdaptorConfig = 'googAudioNetworkAdaptorConfig';

// Constraint keys for CreateOffer / CreateAnswer defined in W3C specification.
const String kOfferToReceiveAudio = 'OfferToReceiveAudio';
const String kOfferToReceiveVideo = 'OfferToReceiveVideo';
const String kVoiceActivityDetection = 'VoiceActivityDetection';
const String kIceRestart = 'IceRestart';

// Google specific constraint for BUNDLE enable/disable.
const String kUseRtpMux = 'googUseRtpMUX';

// Below constraints should be used during PeerConnection construction.
final String kEnableDtlsSrtp = 'DtlsSrtpKeyAgreement';
final String kEnableRtpDataChannels = 'RtpDataChannels';

// Google-specific constraint keys.
const String kEnableDscp = 'googDscp';
const String kEnableIPv6 = 'googIPv6';
const String kEnableVideoSuspendBelowMinBitrate = 'googSuspendBelowMinBitrate';
const String kCombinedAudioVideoBwe = 'googCombinedAudioVideoBwe';
const String kScreencastMinBitrate = 'googScreencastMinBitrate';

// TODO(ronghuawu): Remove once cpu overuse detection is stable.
const String kCpuOveruseDetection = 'googCpuOveruseDetection';
const String kRawPacketizationForVideoEnabled =
    'googRawPacketizationForVideoEnabled';
const String kNumSimulcastLayers = 'googNumSimulcastLayers';

// Video constraints.
const String kMinAspectRatio = 'minAspectRatio';
const String kMaxAspectRatio = 'maxAspectRatio';
const String kMaxWidth = 'maxWidth';
const String kMinWidth = 'minWidth';
const String kMaxHeight = 'maxHeight';
const String kMinHeight = 'minHeight';
const String kMaxFrameRate = 'maxFrameRate';
const String kMinFrameRate = 'minFrameRate';

// MediaDevices
const String kSourceId = 'sourceId';

enum FacingMode { User, Environment }
