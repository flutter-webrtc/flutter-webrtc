package com.cloudwebrtc.webrtc.model

/**
 * Media device kind.
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class MediaDeviceKind(val value: Int) {
  /** Represents an audio input device (for example, a microphone). */
  AUDIO_INPUT(0),

  /** Represents an audio output device (for example, a pair of headphones). */
  AUDIO_OUTPUT(1),

  /** Represents a video input device (for example, a webcam). */
  VIDEO_INPUT(2),
}

/**
 * Represents an information about some media device.
 *
 * @property deviceId Identifier of the represented media device.
 * @property label Human-readable device description (for example, "External USB Webcam").
 * @property kind Media kind of the media device.
 */
data class MediaDeviceInfo(val deviceId: String, val label: String, val kind: MediaDeviceKind) {
  /** Converts this [MediaDeviceInfo] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> =
      mapOf("deviceId" to deviceId, "label" to label, "kind" to kind.value)
}
