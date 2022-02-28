package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaConstraints

/**
 * Mandatory and optional constraints related to audio.
 *
 * @see [Constraints](https://developer.mozilla.org/en-US/docs/Web/API/Media_Streams_API/Constraints)
 */
data class AudioConstraints(
    val mandatory: Map<String, String>,
    val optional: Map<String, String>
) {
    companion object {
        /**
         * Creates [AudioConstraints] object based on the [Map] received from
         * the Flutter side.
         *
         * @return  [AudioConstraints] based on the provided [Map].
         */
        fun fromMap(map: Map<*, *>): AudioConstraints {
            val mandatoryArg =
                map["mandatory"] as Map<*, *>? ?: mapOf<String, String>()
            val optionalArg =
                map["optional"] as Map<*, *>? ?: mapOf<String, String>()
            val mandatory =
                mandatoryArg.entries.associate { it.key as String to it.value as String }
            val optional =
                optionalArg.entries.associate { it.key as String to it.value as String }

            return AudioConstraints(mandatory, optional)
        }
    }

    /**
     * Converts this [AudioConstraints] into `libwebrtc` object.
     *
     * @return  `libwebrtc`'s [MediaConstraints] object.
     */
    fun intoWebRtc(): MediaConstraints {
        val mediaConstraints = MediaConstraints()
        for (entry in mandatory) {
            mediaConstraints.mandatory.add(
                MediaConstraints.KeyValuePair(
                    entry.key,
                    entry.value
                )
            )
        }
        for (entry in optional) {
            mediaConstraints.optional.add(
                MediaConstraints.KeyValuePair(
                    entry.key,
                    entry.value
                )
            )
        }
        return mediaConstraints
    }
}
