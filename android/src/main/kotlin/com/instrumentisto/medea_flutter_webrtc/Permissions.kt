package com.instrumentisto.medea_flutter_webrtc

import android.app.Activity
import android.content.pm.PackageManager
import androidx.annotation.MainThread
import androidx.core.app.ActivityCompat
import com.instrumentisto.medea_flutter_webrtc.exception.PermissionException
import io.flutter.plugin.common.PluginRegistry
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import org.webrtc.ThreadUtils

/** Random ID for the permission requests. */
const val PERMISSIONS_REQUEST_ID = 856146223

/** Service for requesting Android Permissions. */
class Permissions(private val activity: Activity) :
    PluginRegistry.RequestPermissionsResultListener {
  /**
   * Ongoing permission request [Continuation].
   *
   * This [Continuation] will be resumed when permission request will be resolved.
   */
  private var permissionRequest: Continuation<Unit>? = null

  /**
   * Queue for the permission requests which was received while some another request was going.
   *
   * This requests will be continued with LIFO manner.
   */
  private val requestsQueue: MutableList<Continuation<Unit>> = mutableListOf()

  /** Flag which indicates that [Permissions] service has ongoing permission request. */
  private var hasOngoingRequest: Boolean = false

  /**
   * Requests user for provided permission granting.
   *
   * @throws [PermissionException] if user rejected permission request.
   */
  @MainThread
  suspend fun requestPermission(permission: String) {
    ThreadUtils.checkIsOnMainThread()
    waitForRequestEnd()
    if (activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
      return
    }
    return suspendCoroutine {
      hasOngoingRequest = true
      ActivityCompat.requestPermissions(activity, arrayOf(permission), PERMISSIONS_REQUEST_ID)
      permissionRequest = it
    }
  }

  /**
   * Waits for the ongoing permission request end.
   *
   * Does nothing if [Permissions] service doesn't has ongoing requests.
   */
  private suspend fun waitForRequestEnd() {
    if (hasOngoingRequest) {
      return suspendCoroutine { requestsQueue.add(it) }
    }
  }

  /**
   * Notifies [Permissions] service that permission request was ended.
   *
   * Starts next permission request (if it is queued) in LIFO manner.
   */
  private fun requestResolved() {
    val request = requestsQueue.removeFirstOrNull()
    if (request != null) {
      request.resume(Unit)
    } else {
      hasOngoingRequest = false
    }
  }

  /** Checks permission request result and continues [permissionRequest] coroutine. */
  override fun onRequestPermissionsResult(
      requestCode: Int,
      permissions: Array<out String>,
      grantResults: IntArray
  ): Boolean {
    return if (requestCode == PERMISSIONS_REQUEST_ID) {
      for (entry in permissions.withIndex()) {
        if (grantResults[entry.index] == PackageManager.PERMISSION_GRANTED) {
          permissionRequest?.resume(Unit)
        } else {
          permissionRequest?.resumeWithException(
              PermissionException("Permission '${entry.value}' not granted"))
        }
        permissionRequest = null
      }
      requestResolved()
      true
    } else {
      false
    }
  }
}
