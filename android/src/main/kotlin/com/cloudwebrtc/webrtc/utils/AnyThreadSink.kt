package com.cloudwebrtc.webrtc.utils

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel.EventSink

/**
 * Thread agnostic [EventSink] for sending events from Android side to the Flutter side.
 *
 * @property eventSink Underlying socket, into which all events will be sent.
 */
class AnyThreadSink(private val eventSink: EventSink) : EventSink {
  /** [Runnable] executor on the main Android looper. */
  private val handler = Handler(Looper.getMainLooper())

  override fun success(o: Any) {
    post { eventSink.success(o) }
  }

  override fun error(s: String, s1: String, o: Any) {
    post { eventSink.error(s, s1, o) }
  }

  override fun endOfStream() {
    post { eventSink.endOfStream() }
  }

  /**
   * Schedules the provided [Runnable] on the main Android looper using the [handler].
   *
   * @param r [Runnable] to be scheduled.
   */
  private fun post(r: Runnable) {
    if (Looper.getMainLooper() == Looper.myLooper()) {
      r.run()
    } else {
      handler.post(r)
    }
  }
}
