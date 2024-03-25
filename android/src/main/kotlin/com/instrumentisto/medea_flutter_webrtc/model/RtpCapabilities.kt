package com.instrumentisto.medea_flutter_webrtc.model

/**
 * Representation of an [org.webrtc.RtpCapabilities.HeaderExtensionCapability].
 *
 * @property uri `uri` of this [HeaderExtensionCapability].
 * @property preferredId `preferredId` of this [HeaderExtensionCapability].
 * @property preferredEncrypted `preferredEncrypted` of this [HeaderExtensionCapability].
 */
data class HeaderExtensionCapability(
    val uri: String,
    val preferredId: Int,
    val preferredEncrypted: Boolean,
) {
  companion object {
    /**
     * Converts the provided [org.webrtc.RtpCapabilities.HeaderExtensionCapability] into [RtcStats].
     *
     * @return [HeaderExtensionCapability] created based on the provided
     * [org.webrtc.RtpCapabilities.HeaderExtensionCapability].
     */
    fun fromWebRtc(
        header: org.webrtc.RtpCapabilities.HeaderExtensionCapability
    ): HeaderExtensionCapability {
      return HeaderExtensionCapability(header.uri, header.preferredId, header.preferredEncrypted)
    }
  }

  /**
   * Converts this [HeaderExtensionCapability] into a [Map] which can be returned to the Flutter
   * side.
   */
  fun asFlutterResult(): Map<String, Any> {
    return mapOf(
        "uri" to uri, "preferredId" to preferredId, "preferredEncrypted" to preferredEncrypted)
  }
}

/**
 * Representation of an [org.webrtc.RtpCapabilities.CodecCapability].
 *
 * @property preferredPayloadType `preferredPayloadType` of this [CodecCapability].
 * @property name `name` of this [CodecCapability].
 * @property kind `kind` of this [CodecCapability].
 * @property clockRate `clockRate` of this [CodecCapability].
 * @property numChannels `numChannels` of this [CodecCapability].
 * @property parameters `parameters` of this [CodecCapability].
 * @property mimeType `mimeType` of this [CodecCapability].
 */
data class CodecCapability(
    val preferredPayloadType: Int,
    val name: String,
    val kind: MediaType,
    val clockRate: Int,
    val numChannels: Int?,
    val parameters: Map<String, String>,
    val mimeType: String,
) {
  companion object {
    /**
     * Converts the provided [org.webrtc.RtpCapabilities.CodecCapability] into a [CodecCapability].
     *
     * @return [CodecCapability] created based on the provided
     * [org.webrtc.RtpCapabilities.CodecCapability].
     */
    fun fromWebRtc(codec: org.webrtc.RtpCapabilities.CodecCapability): CodecCapability {
      var parameters = codec.parameters
      return CodecCapability(
          codec.preferredPayloadType,
          codec.name,
          MediaType.fromInt(codec.kind.ordinal),
          codec.clockRate,
          codec.numChannels,
          codec.parameters,
          codec.mimeType)
    }
  }

  /** Converts this [CodecCapability] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any?> {
    return mapOf(
        "preferredPayloadType" to preferredPayloadType,
        "name" to name,
        "kind" to kind.value,
        "clockRate" to clockRate,
        "numChannels" to numChannels as Any?,
        "parameters" to parameters,
        "mimeType" to mimeType)
  }
}

/**
 * Representation of an [org.webrtc.RtpCapabilities].
 *
 * @property codecs `codecs` of these [RtpCapabilities].
 * @property headerExtensions `headerExtensions` of these [RtpCapabilities].
 */
data class RtpCapabilities(
    val codecs: List<CodecCapability>,
    val headerExtensions: List<HeaderExtensionCapability>,
) {
  companion object {
    /**
     * Converts the provided [org.webrtc.RtpCapabilities] into [RtpCapabilities].
     *
     * @return [RtpCapabilities] created based on the provided [org.webrtc.RtpCapabilities].
     */
    fun fromWebRtc(capability: org.webrtc.RtpCapabilities): RtpCapabilities {
      val codecs = capability.codecs.map { CodecCapability.fromWebRtc(it) }
      val header = capability.headerExtensions.map { HeaderExtensionCapability.fromWebRtc(it) }
      return RtpCapabilities(codecs, header)
    }
  }

  /** Converts these [RtpCapabilities] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> {
    return mapOf(
        "codecs" to codecs.map { it.asFlutterResult() },
        "headerExtensions" to headerExtensions.map { it.asFlutterResult() })
  }
}
