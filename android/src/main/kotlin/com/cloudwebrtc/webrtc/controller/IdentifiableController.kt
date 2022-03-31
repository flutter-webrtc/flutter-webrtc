package com.cloudwebrtc.webrtc.controller

import org.webrtc.ThreadUtils

/** Interface for all the controllers with unique IDs. */
internal interface IdentifiableController {
  companion object {
    /** Last unique ID created for this [IdentifiableController]. */
    private var counter: Long = 0
  }

  /** @return New unique ID for this [IdentifiableController]'s channel. */
  fun nextChannelId(): Long {
    ThreadUtils.checkIsOnMainThread()
    return counter++
  }
}
