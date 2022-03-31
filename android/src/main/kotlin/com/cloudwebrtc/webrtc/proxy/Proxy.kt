package com.cloudwebrtc.webrtc.proxy

import org.webrtc.ThreadUtils

/**
 * Interface responsible for the proxy's underlying `libwebrtc` object update.
 *
 * For example, when `PeerConnection.getSenders` is called, then all the old `libwebrtc`'s
 * `RtpSender` will be outdated. To keep this from happening `PeerConnection` should update its
 * `RtpSender`s with a newly obtained `RtpSender`s via [Proxy.replace] method.
 */
interface Proxy<T> {
  /** Underlying `libwebrtc` object of this proxy. */
  var obj: T

  /** Notifies proxy about the [obj] update. */
  fun syncWithObject() {}

  /** Replaces the [obj] and notifies proxy about it. */
  fun replace(newObj: T) {
    ThreadUtils.checkIsOnMainThread()
    obj = newObj
    syncWithObject()
  }
}
