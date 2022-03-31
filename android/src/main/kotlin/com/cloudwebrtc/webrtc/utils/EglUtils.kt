package com.cloudwebrtc.webrtc.utils

import org.webrtc.EglBase

/**
 * Lazily creates and returns the one and only [EglBase] which will serve as the root for all
 * contexts that are needed.
 */
object EglUtils {
  /**
   * Root [EglBase] instance shared by the entire application for the sake of reducing the
   * utilization of system resources (such as EGL contexts).
   */
  @get:Synchronized
  var rootEglBase: EglBase? = null
    get() {
      if (field == null) {
        field = EglBase.create()
      }
      return field
    }
    private set

  @JvmStatic
  val rootEglBaseContext: EglBase.Context?
    get() {
      val eglBase = rootEglBase
      return eglBase?.eglBaseContext
    }
}
