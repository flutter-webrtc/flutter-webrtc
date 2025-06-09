package com.instrumentisto.medea_flutter_webrtc.controller

import android.util.Log
import java.util.TreeMap
import org.webrtc.ThreadUtils

private val TAG = ControllerRegistry::class.java.simpleName

/** Registry for [Controller]s with unique IDs. */
object ControllerRegistry {
  /** All currently registered [ControllerRegistry]s. */
  private val controllers: TreeMap<Int, HashSet<Controller>> = TreeMap()

  /** Registers the provided [Controller] as active. */
  fun register(controller: Controller) {
    ThreadUtils.checkIsOnMainThread()

    val set = controllers.getOrPut(controller.disposeOrder()) { HashSet() }
    set.add(controller)
  }

  /** Unregisters the provided [Controller] once it's disposed. */
  fun unregister(controller: Controller) {
    ThreadUtils.checkIsOnMainThread()

    controllers[controller.disposeOrder()]?.let { set ->
      set.remove(controller)
      if (set.isEmpty()) {
        controllers.remove(controller.disposeOrder())
      }
    }
  }

  /** Disposes all the registered [Controller]s. */
  fun disposeAll() {
    ThreadUtils.checkIsOnMainThread()

    // Clone since calling dispose() modifies the `controllers` map.
    val all = controllers.values.flatten().toList()

    all.forEach {
      try {
        it.dispose()
      } catch (e: Throwable) {
        Log.e(TAG, "Exception while disposing `Controller`: $e")
      }
    }

    if (controllers.isNotEmpty()) {
      Log.e(TAG, "`Controller`s list is not empty after `disposeAll()`")
    }
  }
}
