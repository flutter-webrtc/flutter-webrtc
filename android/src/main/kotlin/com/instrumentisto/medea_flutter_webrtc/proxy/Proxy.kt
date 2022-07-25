package com.instrumentisto.medea_flutter_webrtc.proxy

import org.webrtc.ThreadUtils

/**
 * Class responsible for the proxy's underlying `libwebrtc` object update.
 *
 * For example, when `PeerConnection.getSenders` is called, then all the old `libwebrtc`'s
 * `RtpSender` will be outdated. To keep this from happening `PeerConnection` should update its
 * `RtpSender`s with a newly obtained `RtpSender`s via [Proxy.replace] method.
 */
abstract class Proxy<T> constructor(obj: T) {

  /** Underlying `libwebrtc` object of this proxy. */
  var obj: T = obj

  /** List of subscribers to be notified when underlying [obj] is replaced. */
  private var onSyncListeners: MutableList<() -> Unit> = mutableListOf()

  /** Subscribes to the [obj] update. */
  fun addOnSyncListener(listener: () -> Unit) {
    onSyncListeners.add(listener)
  }

  /** Replaces the [obj] and notifies proxy about it. */
  fun replace(newObj: T) {
    ThreadUtils.checkIsOnMainThread()
    obj = newObj
    onSyncListeners.forEach { sub -> sub() }
  }
}
