package com.instrumentisto.medea_flutter_webrtc.controller

import io.flutter.plugin.common.MethodChannel
import org.webrtc.ThreadUtils

/** Interface for a controller that handles calls from Dart. */
interface Controller : MethodChannel.MethodCallHandler {
  companion object {
    /** Last unique ID created for this [Controller]. */
    private var counter: Long = 0

    /** List of all [Controller]s in the order the should be disposed. */
    private var disposeOrder =
        listOf(
            VideoRendererFactoryController::class,
            VideoRendererController::class,
            MediaStreamTrackController::class,
            RtpSenderController::class,
            RtpTransceiverController::class,
            PeerConnectionFactoryController::class,
            PeerConnectionController::class,
            MediaDevicesController::class)
  }

  /** Returns the dispose order for this [Controller]. */
  fun disposeOrder(): Int {
    return disposeOrder.indexOf(this::class).takeIf { it >= 0 }!!
  }

  /** Frees resources allocated by this [Controller]. */
  fun dispose()

  /** @return New unique ID for this [Controller]'s channel. */
  fun nextChannelId(): Long {
    ThreadUtils.checkIsOnMainThread()
    return counter++
  }
}
