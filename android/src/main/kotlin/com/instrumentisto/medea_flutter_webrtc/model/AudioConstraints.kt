package com.instrumentisto.medea_flutter_webrtc.model

import org.webrtc.MediaConstraints

/**
 * Mandatory and optional constraints related to audio.
 *
 * @see [Constraints]
 * (https://developer.mozilla.org/en-US/docs/Web/API/Media_Streams_API/Constraints)
 */
data class AudioConstraints(val mandatory: Map<String, String>, val optional: Map<String, String>) {
  companion object {
    /**
     * Creates [AudioConstraints] object based on the [Map] received from the Flutter side.
     *
     * @return [AudioConstraints] based on the provided [Map].
     */
    fun fromMap(map: Map<*, *>): AudioConstraints? {
      val mandatoryArg = map["mandatory"] as Map<*, *>?
      val optionalArg = map["optional"] as Map<*, *>?

      return if (mandatoryArg == null && optionalArg == null) {
        null
      } else {
        val mandatory = mapOf<String, String>()
        val optional = mapOf<String, String>()

        optionalArg?.entries?.associate { it.key as String to it.value as String }
        mandatoryArg?.entries?.associate { it.key as String to it.value as String }

        AudioConstraints(mandatory, optional)
      }
    }
  }

  /**
   * Converts this [AudioConstraints] into `libwebrtc` object.
   *
   * @return `libwebrtc`'s [MediaConstraints] object.
   */
  fun intoWebRtc(): MediaConstraints {
    val mediaConstraints = MediaConstraints()
    for (entry in mandatory) {
      mediaConstraints.mandatory.add(MediaConstraints.KeyValuePair(entry.key, entry.value))
    }
    for (entry in optional) {
      mediaConstraints.optional.add(MediaConstraints.KeyValuePair(entry.key, entry.value))
    }
    return mediaConstraints
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (javaClass != other?.javaClass) return false

    other as AudioConstraints

    if (mandatory != other.mandatory) return false
    if (optional != other.optional) return false

    return true
  }

  override fun hashCode(): Int {
    var result = mandatory.hashCode()
    result = 31 * result + optional.hashCode()
    return result
  }
}
