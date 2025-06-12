enum RTCDegradationPreference {
  balanced,
  maintainFramerate,
  maintainResolution,
  disabled,
}

String? rtcDegradationPreferenceToString(RTCDegradationPreference? preference) {
  switch (preference) {
    case RTCDegradationPreference.balanced:
      return 'balanced';
    case RTCDegradationPreference.maintainFramerate:
      return 'maintain-framerate';
    case RTCDegradationPreference.maintainResolution:
      return 'maintain-resolution';
    case RTCDegradationPreference.disabled:
      return 'disabled';
    default:
      return null;
  }
}

RTCDegradationPreference? rtcDegradationPreferencefromString(String? value) {
  switch (value) {
    case 'balanced':
      return RTCDegradationPreference.balanced;
    case 'maintain-framerate':
      return RTCDegradationPreference.maintainFramerate;
    case 'maintain-resolution':
      return RTCDegradationPreference.maintainResolution;
    case 'disabled':
      return RTCDegradationPreference.disabled;
    default:
      return null;
  }
}
