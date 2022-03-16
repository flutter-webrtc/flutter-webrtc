package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaStreamTrack.MediaType as WMediaType

/**
 * [org.webrtc.MediaStreamTrack.MediaType] representation.
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class MediaType(val value: Int) {
  AUDIO(0),
  VIDEO(1);

  companion object {
    /**
     * Tries to create a [MediaType] based on the provided [Int].
     *
     * @param value [Int] value from which [MediaType] will be created.
     *
     * @return [MediaType] based on the provided [Int].
     */
    fun fromInt(value: Int) = values().first { it.value == value }
  }

  /**
   * Converts this [MediaType] into an [org.webrtc.MediaStreamTrack.MediaType].
   *
   * @return [org.webrtc.MediaStreamTrack.MediaType] based on this [MediaType].
   */
  fun intoWebRtc(): WMediaType {
    return when (this) {
      AUDIO -> WMediaType.MEDIA_TYPE_AUDIO
      VIDEO -> WMediaType.MEDIA_TYPE_VIDEO
    }
  }
}
