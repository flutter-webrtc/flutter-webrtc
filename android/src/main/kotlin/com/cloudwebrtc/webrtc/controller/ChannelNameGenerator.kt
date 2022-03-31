package com.cloudwebrtc.webrtc.controller

/**
 * Generator for the all [io.flutter.plugin.common.MethodChannel] names created by `flutter_webrtc`.
 */
object ChannelNameGenerator {
  /** Prefix to prepend generated names with. */
  private const val PREFIX: String = "FlutterWebRtc"

  /**
   * Generates a new channel name for some controller by the provided ID.
   *
   * @param name Name of the controller to generate the channel name for (e.g. `PeerConnection`).
   * @param id Unique identifier of some concrete instance of some entity.
   *
   * @return Generated channel name.
   */
  fun name(name: String, id: Long): String {
    return "$PREFIX/$name/$id"
  }
}
