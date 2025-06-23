package com.instrumentisto.medea_flutter_webrtc

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.content.res.AssetFileDescriptor
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.IconCompat
import com.instrumentisto.medea_flutter_webrtc.exception.PermissionException
import io.flutter.FlutterInjector
import java.io.FileInputStream
import org.webrtc.ThreadUtils

private val TAG = ForegroundCallService::class.java.simpleName

/** [ForegroundCallService] [Notification] ID. */
private const val FG_CALL_NOTIFICATION_ID: Int = 834557517

/** [ForegroundCallService] [NotificationChannel] ID. */
private const val NOTIFICATION_CHAN_ID: String = "FOREGROUND_CALL_CHAN"

/**
 * Foreground [Service] ensuring that audio/video recording/playback will keep working when
 * application is in the background.
 */
class ForegroundCallService : Service() {

  /** [ForegroundCallService] configuration received from Dart side. */
  class Config {
    /**
     * Indicator whether a [ForegroundCallService] is enabled, meaning that it will be started
     * whenever [ForegroundCallService.start] is called.
     */
    var enabled: Boolean = true

    /** [NotificationCompat.Builder.setOngoing] value. */
    var notificationOngoing: Boolean = true

    /** [NotificationCompat.Builder.setContentTitle] value. */
    var notificationTitle: String = "Ongoing call"

    /** [NotificationCompat.Builder.setContentText] value. */
    var notificationText: String = "Ongoing text"

    /** [NotificationCompat.Builder.setSmallIcon] value. */
    var notificationIcon: String = "assets/icons/app_icon.png"

    companion object {
      /** Creates a new [Config] object based on the data received from Dart. */
      fun fromMap(map: Map<String, Any>): Config {
        val config = Config()

        config.enabled = map["enabled"] as Boolean
        config.notificationOngoing = map["notificationOngoing"] as Boolean
        config.notificationTitle = map["notificationTitle"] as String
        config.notificationText = map["notificationText"] as String
        config.notificationIcon = map["notificationIcon"] as String

        return config
      }
    }

    override fun equals(other: Any?): Boolean {
      if (this === other) return true
      if (javaClass != other?.javaClass) return false

      other as Config

      if (enabled != other.enabled) return false
      if (notificationOngoing != other.notificationOngoing) return false
      if (notificationTitle != other.notificationTitle) return false
      if (notificationText != other.notificationText) return false
      if (notificationIcon != other.notificationIcon) return false

      return true
    }

    override fun hashCode(): Int {
      var result = enabled.hashCode()
      result = 31 * result + notificationOngoing.hashCode()
      result = 31 * result + notificationTitle.hashCode()
      result = 31 * result + notificationText.hashCode()
      result = 31 * result + notificationIcon.hashCode()
      return result
    }
  }

  companion object {
    /** Current [ForegroundCallService] configuration. */
    private var currentConfig: Config? = null

    /**
     * Indicator whether this [ForegroundCallService] should be running.
     *
     * However, it can still be disabled via [Config.enabled] option.
     *
     * This exists because the [ForegroundCallService.start] methid might be called before it's
     * allowed by the [Config]. In this case this [ForegroundCallService] will be started in the
     * [ForegroundCallService.setup] menthod once the [Config] update is handled.
     */
    private var shouldBeRunning: Boolean = false

    /**
     * [NotificationChannel] that [Notification]s will be posted on.
     *
     * It's created with [NOTIFICATION_CHAN_ID] on the first [ForegroundCallService.start] call if
     * API level >= 26.
     */
    private var notificationChannel: NotificationChannel? = null

    /**
     * [Permissions.Companion.GrantedObserver] updating foreground service type if a new permission
     * has been granted after initial start.
     */
    private var grantedObserver: Permissions.Companion.GrantedObserver? = null

    /** Latest foreground service type provided to the [startForeground] method. */
    private var currentForegroundServiceType: Int? = null

    /**
     * Updates the [ForegroundCallService]'s current [Config].
     *
     * Might start or stop if the [Config.enabled] option has changed.
     */
    suspend fun setup(newConfig: Config, context: Context, permissions: Permissions) {
      ThreadUtils.checkIsOnMainThread()

      if (currentConfig == newConfig) {
        return
      }

      if (shouldBeRunning && !newConfig.enabled) {
        internalStop(context, permissions)
      } else if (shouldBeRunning) {
        currentConfig = newConfig
        // Start or update settings if already running.
        start(context, permissions)
      } else {
        // Not running so just update config.
        currentConfig = newConfig
      }
    }

    /**
     * Starts [ForegroundCallService] and its [Notification], but only if it's enabled by the
     * current [Config].
     */
    suspend fun start(context: Context, permissions: Permissions) {
      Log.v(TAG, "Start")
      ThreadUtils.checkIsOnMainThread()

      shouldBeRunning = true

      if (currentConfig == null || currentConfig!!.enabled == false) {
        return
      }

      // `POST_NOTIFICATIONS` permission is only required since API level 33.
      if (Build.VERSION.SDK_INT >= 33) {
        try {
          permissions.requestPermission(Manifest.permission.POST_NOTIFICATIONS)
        } catch (e: PermissionException) {
          Log.w(TAG, "POST_NOTIFICATIONS is declined, foreground service will have no notification")
        }
      }

      if (notificationChannel == null && Build.VERSION.SDK_INT >= 26) {
        notificationChannel =
            NotificationChannel(
                    NOTIFICATION_CHAN_ID, "Ongoing call", NotificationManager.IMPORTANCE_LOW)
                .apply {
                  enableLights(false)
                  enableVibration(false)
                  setShowBadge(false)
                }
        NotificationManagerCompat.from(context).createNotificationChannel(notificationChannel!!)
      }

      // `foregroundServiceType` was added in API 29.
      if (Build.VERSION.SDK_INT >= 29 && grantedObserver == null) {
        // If the foreground service needs new permissions after launching, the `startForeground()`
        // should be called again and add the new service types.
        grantedObserver =
            object : Permissions.Companion.GrantedObserver {
              override fun onGranted(granted: String) {
                if (granted == Manifest.permission.RECORD_AUDIO ||
                    granted == Manifest.permission.CAMERA &&
                        currentForegroundServiceType != serviceType(context)) {
                  ContextCompat.startForegroundService(
                      context, Intent(context, ForegroundCallService::class.java))
                }
              }
            }
        permissions.addObserver(grantedObserver!!)
      }

      ContextCompat.startForegroundService(
          context, Intent(context, ForegroundCallService::class.java))
    }

    /** Stops [ForegroundCallService] if it's running. */
    fun stop(context: Context, permissions: Permissions) {
      ThreadUtils.checkIsOnMainThread()

      shouldBeRunning = false

      internalStop(context, permissions)
    }

    /**
     * Stops [ForegroundCallService] if it's running.
     *
     * For internal use only.
     */
    private fun internalStop(context: Context, permissions: Permissions) {
      Log.v(TAG, "Stop")

      ThreadUtils.checkIsOnMainThread()

      if (grantedObserver != null) {
        permissions.removeObserver(grantedObserver!!)
        grantedObserver = null
      }

      val intent = Intent(context, ForegroundCallService::class.java)
      context.stopService(intent)
    }

    /**
     * Returns service type that should be provided to the [startForeground] method based on the
     * granted permissions.
     */
    private fun serviceType(ctx: Context): Int {
      // `foregroundServiceType` was added in API 29.
      return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        var serviceType = ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK

        // `FOREGROUND_SERVICE_TYPE_CAMERA` and `FOREGROUND_SERVICE_TYPE_MICROPHONE` were added in
        // API 30.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
          if (ctx.checkSelfPermission(Manifest.permission.CAMERA) ==
              PackageManager.PERMISSION_GRANTED) {
            serviceType = serviceType or ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
          }
          if (ctx.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
              PackageManager.PERMISSION_GRANTED) {
            serviceType = serviceType or ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
          }
        }

        serviceType
      } else {
        0
      }
    }
  }

  override fun onCreate() {
    Log.v(TAG, "onCreate")

    super.onCreate()
  }

  override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
    Log.v(TAG, "Started with startId = $startId")

    if (currentConfig == null || !currentConfig!!.enabled) {
      ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
      stopSelf()

      return START_NOT_STICKY
    }

    val notification =
        NotificationCompat.Builder(this, NOTIFICATION_CHAN_ID)
            .setOngoing(currentConfig!!.notificationOngoing)
            .setContentTitle(currentConfig!!.notificationTitle)
            .setContentText(currentConfig!!.notificationText)
            .setSilent(true)
            .setSmallIcon(getIcon(currentConfig!!.notificationIcon))
            .build()

    currentForegroundServiceType = serviceType(this)

    // Once the service has been created, it must call its `startForeground()` method within
    // 5 seconds.
    ServiceCompat.startForeground(
        this, FG_CALL_NOTIFICATION_ID, notification, currentForegroundServiceType!!)

    return START_NOT_STICKY
  }

  /** Returns the [IconCompat] from the provided [path] to a bitmap file. */
  private fun getIcon(path: String): IconCompat {
    var assetFd: AssetFileDescriptor? = null
    var assetIS: FileInputStream? = null

    try {
      val assetPath = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(path)
      assetFd = this.assets.openFd(assetPath)
      assetIS = assetFd.createInputStream()

      return IconCompat.createWithBitmap(BitmapFactory.decodeStream(assetIS))
    } catch (e: Exception) {
      Log.e(TAG, "Failed to open icon at `$e`, will use fallback.")

      return IconCompat.createWithResource(this, android.R.drawable.ic_menu_call)
    } finally {
      assetIS?.close()
      assetFd?.close()
    }
  }

  override fun onDestroy() {
    Log.v(TAG, "onDestroy")
    (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).cancel(FG_CALL_NOTIFICATION_ID)
    super.onDestroy()
  }

  override fun onBind(intent: Intent?): IBinder? {
    return null
  }

  override fun onTaskRemoved(rootIntent: Intent?) {
    Log.v(TAG, "onTaskRemoved")

    ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
    stopSelf()
  }
}
