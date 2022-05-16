package com.cloudwebrtc.webrtc.model

/**
 * Audio and video constraints data.
 *
 * @property audio Optional constraints to lookup audio devices with.
 * @property video Optional constraints to lookup video devices with.
 */
data class Constraints(val audio: AudioConstraints?, val video: VideoConstraints?) {
  companion object {
    /**
     * Creates new [Constraints] object based on the method call received from the Flutter side.
     *
     * @return [Constraints] created from the provided [Map].
     */
    fun fromMap(map: Map<String, Any>): Constraints {
      val audio = AudioConstraints.fromMap(map["audio"] as Map<*, *>)
      val video = VideoConstraints.fromMap(map["video"] as Map<*, *>)

      return Constraints(audio, video)
    }
  }
}
