package com.instrumentisto.medea_flutter_webrtc.model

import org.webrtc.CameraEnumerator

/**
 * Direction in which the camera produces the video.
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class FacingMode(val value: Int) {
  /**
   * Indicates that the video source is facing toward the user (this includes, for example, the
   * front-facing camera on a smartphone).
   */
  USER(0),

  /**
   * Indicates that the video source is facing away from the user, thereby viewing their
   * environment. This is the back camera on a smartphone.
   */
  ENVIRONMENT(1);

  companion object {
    /**
     * Tries to create a [FacingMode] based on the provided [Int].
     *
     * @param value [Int] value to create the [FacingMode] from.
     *
     * @return [FacingMode] based on the provided [Int].
     */
    fun fromInt(value: Int) = values().first { it.value == value }
  }
}

/**
 * Score of [VideoConstraints].
 *
 * This score will be determined by a [ConstraintChecker] and basing on it, more suitable video
 * device will be selected by `getUserMedia` request.
 */
enum class ConstraintScore {
  /**
   * Indicates that the constraint is not suitable at all.
   *
   * So, the device with this score wouldn't used event if there is no other devices.
   */
  NO,

  /** Indicates that the constraint can be used, but more suitable devices can be found. */
  MAYBE,

  /** Indicates that the constraint suits ideally. */
  YES;

  companion object {
    /**
     * Calculates the total score based on which media devices will be sorted.
     *
     * @param scores List of [ConstraintScore]s of some device.
     *
     * @return Total score calculated based on the provided list.
     */
    fun totalScore(scores: List<ConstraintScore>): Int? {
      var total = 1
      for (score in scores) {
        when (score) {
          NO -> return null
          YES -> total++
          MAYBE -> {}
        }
      }

      return total
    }
  }
}

/** Interface for all the video constraints which can check suitability of some device. */
interface ConstraintChecker {
  /** Indicates that this constraint is mandatory or not. */
  val isMandatory: Boolean

  /**
   * Calculates a [ConstraintScore] of the device based on the underlying algorithm of the concrete
   * constraint.
   *
   * @param enumerator Object for interaction with Camera API.
   * @param deviceId ID of the device which should be checked for this constraint.
   *
   * @return [ConstraintScore] based on the underlying scoring algorithm.
   */
  fun score(enumerator: CameraEnumerator, deviceId: String): ConstraintScore {
    val fits = isFits(enumerator, deviceId)
    return when {
      fits -> {
        ConstraintScore.YES
      }
      isMandatory && !fits -> {
        ConstraintScore.NO
      }
      else -> {
        ConstraintScore.MAYBE
      }
    }
  }

  /**
   * Calculates suitability to the provided device.
   *
   * @param enumerator Object for an interaction with Camera API.
   * @param deviceId ID of device which suitability should be checked.
   *
   * @return `true` if device is suitable, or `false` otherwise.
   */
  fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean
}

/**
 * Constraint searching for a device with some concrete `deviceId`.
 *
 * @property id Concrete `deviceId` to be searched.
 * @property isMandatory Indicates that this constraint is mandatory.
 */
data class DeviceIdConstraint(val id: String, override val isMandatory: Boolean) :
    ConstraintChecker {
  override fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean {
    return deviceId == id
  }
}

/**
 * Constraint searching for a device with some [FacingMode].
 *
 * @property facingMode [FacingMode] which will be searched.
 * @property isMandatory Indicates that this constraint is mandatory.
 */
data class FacingModeConstraint(val facingMode: FacingMode, override val isMandatory: Boolean) :
    ConstraintChecker {
  override fun isFits(enumerator: CameraEnumerator, deviceId: String): Boolean {
    return when (facingMode) {
      FacingMode.USER -> enumerator.isFrontFacing(deviceId)
      FacingMode.ENVIRONMENT -> enumerator.isBackFacing(deviceId)
    }
  }
}

/**
 * List of constraints for video devices.
 *
 * @property constraints List of the [ConstraintChecker] provided by user.
 * @property width Width of the device video.
 * @property height Height of the device video.
 * @property fps FPS of the device video.
 */
data class VideoConstraints(
    val constraints: List<ConstraintChecker>,
    val width: Int?,
    val height: Int?,
    val fps: Int?,
) {
  companion object {
    /**
     * Creates new [VideoConstraints] object based on the method call received from the Flutter
     * side.
     *
     * @return [VideoConstraints] created from the provided [Map].
     */
    fun fromMap(map: Map<*, *>): VideoConstraints? {
      val constraintCheckers = mutableListOf<ConstraintChecker>()
      var width: Int? = null
      var height: Int? = null
      var fps: Int? = null

      val mandatoryArg = map["mandatory"] as Map<*, *>?
      val optionalArg = map["optional"] as Map<*, *>?

      if (mandatoryArg == null && optionalArg == null) {
        return null
      } else {
        for ((key, value) in mandatoryArg ?: mapOf<Any, Any>()) {
          if (value != null) {
            when (key as String) {
              "deviceId" -> {
                constraintCheckers.add(DeviceIdConstraint(value as String, true))
              }
              "facingMode" -> {
                constraintCheckers.add(FacingModeConstraint(FacingMode.fromInt(value as Int), true))
              }
              "width" -> {
                width = value as Int
              }
              "height" -> {
                height = value as Int
              }
              "fps" -> {
                fps = value as Int
              }
            }
          }
        }

        for ((key, value) in optionalArg ?: mapOf<Any, Any>()) {
          if (value != null) {
            when (key as String) {
              "deviceId" -> {
                constraintCheckers.add(DeviceIdConstraint(value as String, false))
              }
              "facingMode" -> {
                constraintCheckers.add(
                    FacingModeConstraint(FacingMode.fromInt(value as Int), false))
              }
              "width" -> {
                width = value as Int
              }
              "height" -> {
                height = value as Int
              }
              "fps" -> {
                fps = value as Int
              }
            }
          }
        }

        return VideoConstraints(constraintCheckers, width, height, fps)
      }
    }
  }

  /**
   * Calculates a score for the device with the provided ID.
   *
   * @param enumerator Object for interaction with Camera API.
   * @param deviceId ID of the device to check suitability with.
   * @return total Score calculated based on the provided list.
   */
  fun calculateScoreForDeviceId(enumerator: CameraEnumerator, deviceId: String): Int? {
    val scores = mutableListOf<ConstraintScore>()
    for (constraint in constraints) {
      scores.add(constraint.score(enumerator, deviceId))
    }

    return ConstraintScore.totalScore(scores)
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (javaClass != other?.javaClass) return false

    other as VideoConstraints

    if (width != other.width) return false
    if (height != other.height) return false
    if (fps != other.fps) return false

    return true
  }

  override fun hashCode(): Int {
    var result = width ?: 0
    result = 31 * result + (height ?: 0)
    result = 31 * result + (fps ?: 0)
    return result
  }
}
