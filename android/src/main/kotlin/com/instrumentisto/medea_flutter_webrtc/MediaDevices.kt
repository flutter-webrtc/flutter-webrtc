package com.instrumentisto.medea_flutter_webrtc

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.instrumentisto.medea_flutter_webrtc.exception.GetUserMediaException
import com.instrumentisto.medea_flutter_webrtc.exception.PermissionException
import com.instrumentisto.medea_flutter_webrtc.model.*
import com.instrumentisto.medea_flutter_webrtc.proxy.AudioMediaTrackSource
import com.instrumentisto.medea_flutter_webrtc.proxy.MediaStreamTrackProxy
import com.instrumentisto.medea_flutter_webrtc.proxy.VideoMediaTrackSource
import com.instrumentisto.medea_flutter_webrtc.utils.EglUtils
import java.util.*
import kotlinx.coroutines.CompletableDeferred
import org.webrtc.*

/**
 * Default device video width.
 *
 * This width will be used, if no width provided in the constraints.
 *
 * SD resolution used by default.
 */
private const val DEFAULT_WIDTH = 720

/**
 * Default device video height.
 *
 * This width will be used, if no height provided in the constraints.
 *
 * SD resolution used by default.
 */
private const val DEFAULT_HEIGHT = 576

/**
 * Default device video FPS.
 *
 * This width will be used, if no FPS provided in the constraints.
 */
private const val DEFAULT_FPS = 30

/** Identifier for the ear speaker audio output device. */
private const val EAR_SPEAKER_DEVICE_ID: String = "ear-speaker"

/** Identifier for the speakerphone audio output device. */
private const val SPEAKERPHONE_DEVICE_ID: String = "speakerphone"

/** Identifier for the bluetooth headset audio output device. */
private const val BLUETOOTH_HEADSET_DEVICE_ID: String = "bluetooth-headset"

/** Cloned tracks for `getUserVideoTrack()` if the video source has not been released. */
private val videoTracks: HashMap<VideoConstraints, MediaStreamTrackProxy> = HashMap()

/**
 * Processor for `getUserMedia` requests.
 *
 * @property state Global state used for enumerating devices and creation new
 * [MediaStreamTrackProxy]s.
 */
class MediaDevices(val state: State, private val permissions: Permissions) : BroadcastReceiver() {
  /** Indicator of bluetooth headset connection state. */
  private var isBluetoothHeadsetConnected: Boolean = false

  /**
   * Enumerator for the camera devices, based on which new video [MediaStreamTrackProxy]s will be
   * created.
   */
  private val cameraEnumerator: CameraEnumerator = getCameraEnumerator(state.getAppContext())

  /** List of [EventObserver]s of these [MediaDevices]. */
  private var eventObservers: HashSet<EventObserver> = HashSet()

  /** [AudioManager] system service. */
  private val audioManager: AudioManager = state.getAudioManager()

  /** Currently selected audio output ID by [setOutputAudioId] call. */
  private var selectedAudioOutputId: String = SPEAKERPHONE_DEVICE_ID

  /** Indicator whether the last Bluetooth SCO connection attempt failed. */
  private var isBluetoothScoFailed: Boolean = false

  /** [CompletableDeferred] being resolved once Bluetooth SCO request is completed. */
  private var bluetoothScoDeferred: CompletableDeferred<Unit>? = null

  companion object {
    /** Observer of [MediaDevices] events. */
    interface EventObserver {
      /** Notifies the subscriber about [enumerateDevices] list update. */
      fun onDeviceChange()
    }

    /**
     * Creates a new [CameraEnumerator] instance based on the supported Camera API version.
     *
     * @param context Android context which needed for the [CameraEnumerator] creation.
     *
     * @return [CameraEnumerator] based on the available Camera API version.
     */
    private fun getCameraEnumerator(context: Context): CameraEnumerator {
      return if (Camera2Enumerator.isSupported(context)) {
        Camera2Enumerator(context)
      } else {
        Camera1Enumerator(false)
      }
    }

    /** Indicates if the provided [AudioDeviceInfo] is related to a Bluetooth headset. */
    private fun isBluetoothDevice(info: AudioDeviceInfo): Boolean {
      return info.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
          (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
              info.type == AudioDeviceInfo.TYPE_BLE_HEADSET)
    }
  }

  init {
    state
        .getAppContext()
        .registerReceiver(this, IntentFilter(AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED))
    synchronizeHeadsetState()
    registerHeadsetStateReceiver()
  }

  /**
   * Subscribes to the [AudioManager.registerAudioDeviceCallback] which fires once new audio device
   * is connected.
   *
   * [isBluetoothHeadsetConnected] will be updated based on this subscription.
   */
  private fun registerHeadsetStateReceiver() {
    audioManager.registerAudioDeviceCallback(
        object : AudioDeviceCallback() {
          override fun onAudioDevicesAdded(addedDevices: Array<AudioDeviceInfo>) {
            if (addedDevices.any { isBluetoothDevice(it) }) {
              setHeadsetState(true)
            }
          }

          override fun onAudioDevicesRemoved(removedDevices: Array<AudioDeviceInfo>) {
            if (removedDevices.any { isBluetoothDevice(it) }) {
              synchronizeHeadsetState()
            }
          }
        },
        null)
  }

  /** Actualizes Bluetooth headset state based on the [AudioManager.getDevices]. */
  private fun synchronizeHeadsetState() {
    if (audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS).any { isBluetoothDevice(it) }) {
      setHeadsetState(true)
    } else {
      setHeadsetState(false)
    }
  }

  /**
   * Sets [isBluetoothHeadsetConnected] to the provided value.
   *
   * Fires [EventObserver.onDeviceChange] notification if it changed.
   */
  private fun setHeadsetState(isConnected: Boolean) {
    if (isBluetoothHeadsetConnected != isConnected) {
      isBluetoothHeadsetConnected = isConnected
      Handler(Looper.getMainLooper()).post { eventBroadcaster().onDeviceChange() }
    }
  }

  /**
   * Creates local audio and video [MediaStreamTrackProxy]s based on the provided [Constraints].
   *
   * @param constraints Parameters based on which [MediaDevices] will select most suitable device.
   *
   * @return List of [MediaStreamTrackProxy]s most suitable based on the provided [Constraints].
   */
  suspend fun getUserMedia(constraints: Constraints): List<MediaStreamTrackProxy> {
    val tracks = mutableListOf<MediaStreamTrackProxy>()
    if (constraints.audio != null) {
      try {
        tracks.add(getUserAudioTrack(constraints.audio))
      } catch (e: Exception) {
        throw GetUserMediaException(e.message, GetUserMediaException.Kind.Audio)
      }
    }
    if (constraints.video != null) {
      try {
        tracks.add(getUserVideoTrack(constraints.video))
      } catch (e: Exception) {
        throw GetUserMediaException(e.message, GetUserMediaException.Kind.Video)
      }
    }
    return tracks
  }

  /** @return List of [MediaDeviceInfo]s for the currently available devices. */
  suspend fun enumerateDevices(): List<MediaDeviceInfo> {
    return enumerateAudioDevices() + enumerateVideoDevices()
  }

  /**
   * Cancels Bluetooth SCO request.
   *
   * Throws [GetUserMediaException] from [setOutputAudioId] for enabling Bluetooth SCO (if
   * [MediaDevices] has ongoing request).
   */
  private fun cancelBluetoothSco() {
    bluetoothScoDeferred?.completeExceptionally(
        GetUserMediaException(
            "Bluetooth headset connection request was cancelled", GetUserMediaException.Kind.Audio))
    audioManager.stopBluetoothSco()
    audioManager.isBluetoothScoOn = false
  }

  /**
   * Switches the current output audio device to the device with the provided identifier.
   *
   * @param deviceId Identifier for the output audio device to be selected.
   */
  suspend fun setOutputAudioId(deviceId: String) {
    val audioManager = state.getAudioManager()
    when (deviceId) {
      EAR_SPEAKER_DEVICE_ID -> {
        cancelBluetoothSco()
        audioManager.isSpeakerphoneOn = false
      }
      SPEAKERPHONE_DEVICE_ID -> {
        cancelBluetoothSco()
        audioManager.isSpeakerphoneOn = true
      }
      BLUETOOTH_HEADSET_DEVICE_ID -> {
        val deviceIdBefore = selectedAudioOutputId
        selectedAudioOutputId = deviceId
        if (isBluetoothHeadsetConnected) {
          if (bluetoothScoDeferred == null) {
            isBluetoothScoFailed = false
            Log.d(
                "FlutterWebRtcDebug",
                "Bluetooth headset was selected. Trying to start Bluetooth SCO...")
            bluetoothScoDeferred = CompletableDeferred()
            audioManager.startBluetoothSco()
          }
          try {
            bluetoothScoDeferred?.await()
          } catch (e: Exception) {
            selectedAudioOutputId = deviceIdBefore
            audioManager.stopBluetoothSco()
            isBluetoothScoFailed = true
            throw e
          }
        } else {
          throw IllegalArgumentException("Unknown output device: $deviceId")
        }
      }
      else -> {
        throw IllegalArgumentException("Unknown output device: $deviceId")
      }
    }
  }

  /**
   * Adds the provided [EventObserver] to the list of [EventObserver]s of these [MediaDevices].
   *
   * @param eventObserver [EventObserver] to be subscribed.
   */
  fun addObserver(eventObserver: EventObserver) {
    eventObservers.add(eventObserver)
  }

  /**
   * @return Broadcast [EventObserver] sending events to all the [EventObserver]s of these
   * [MediaDevices].
   */
  private fun eventBroadcaster(): EventObserver {
    return object : EventObserver {
      override fun onDeviceChange() {
        eventObservers.forEach { it.onDeviceChange() }
      }
    }
  }

  /** @return List of [MediaDeviceInfo]s for the currently available audio devices. */
  private fun enumerateAudioDevices(): List<MediaDeviceInfo> {
    val bluetoothDevice =
        audioManager.getDevices(AudioManager.GET_DEVICES_INPUTS).firstOrNull {
          (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
              it.type == AudioDeviceInfo.TYPE_BLE_HEADSET) ||
              it.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
              it.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP
        }

    val devices =
        mutableListOf(
            MediaDeviceInfo(
                EAR_SPEAKER_DEVICE_ID, "Ear-speaker", MediaDeviceKind.AUDIO_OUTPUT, false),
            MediaDeviceInfo(
                SPEAKERPHONE_DEVICE_ID, "Speakerphone", MediaDeviceKind.AUDIO_OUTPUT, false))
    if (bluetoothDevice != null) {
      devices.add(
          MediaDeviceInfo(
              BLUETOOTH_HEADSET_DEVICE_ID,
              bluetoothDevice.productName.toString(),
              MediaDeviceKind.AUDIO_OUTPUT,
              isBluetoothScoFailed))
    }
    devices.add(MediaDeviceInfo("default", "default", MediaDeviceKind.AUDIO_INPUT, false))
    return devices
  }

  /** @return List of [MediaDeviceInfo]s for the currently available video devices. */
  private suspend fun enumerateVideoDevices(): List<MediaDeviceInfo> {
    try {
      permissions.requestPermission(Manifest.permission.CAMERA)
    } catch (e: PermissionException) {
      throw GetUserMediaException(
          "Camera permission was not granted", GetUserMediaException.Kind.Video)
    }
    return cameraEnumerator
        .deviceNames
        .map { deviceId -> MediaDeviceInfo(deviceId, deviceId, MediaDeviceKind.VIDEO_INPUT, false) }
        .toList()
  }

  /**
   * Lookups ID of the video device most suitable basing on the provided [VideoConstraints].
   *
   * @param constraints [VideoConstraints] based on which lookup will be performed.
   *
   * @return `null` if all devices are not suitable for the provided [VideoConstraints], or most
   * suitable device ID for the provided [VideoConstraints].
   */
  private fun findDeviceMatchingConstraints(constraints: VideoConstraints): String? {
    val scoreTable = TreeMap<Int, String>()
    for (deviceId in cameraEnumerator.deviceNames) {
      val deviceScore = constraints.calculateScoreForDeviceId(cameraEnumerator, deviceId)
      if (deviceScore != null) {
        scoreTable[deviceScore] = deviceId
      }
    }

    return scoreTable.lastEntry()?.value
  }

  /**
   * Creates a video [MediaStreamTrackProxy] for the provided [VideoConstraints].
   *
   * @param constraints [VideoConstraints] to perform the lookup with.
   *
   * @return Most suitable [MediaStreamTrackProxy] for the provided [VideoConstraints].
   */
  private suspend fun getUserVideoTrack(constraints: VideoConstraints): MediaStreamTrackProxy {
    try {
      permissions.requestPermission(Manifest.permission.CAMERA)
    } catch (e: PermissionException) {
      throw GetUserMediaException(
          "Camera permission was not granted", GetUserMediaException.Kind.Video)
    }
    val cachedTrack = videoTracks[constraints]
    if (cachedTrack != null) {
      val track = cachedTrack.fork()
      videoTracks[constraints] = track
      track.onStop { videoTracks.remove(constraints, track) }
      return track
    }

    val deviceId =
        findDeviceMatchingConstraints(constraints) ?: throw RuntimeException("Overconstrained")
    val width = constraints.width ?: DEFAULT_WIDTH
    val height = constraints.height ?: DEFAULT_HEIGHT
    val fps = constraints.fps ?: DEFAULT_FPS

    val videoSource = state.getPeerConnectionFactory().createVideoSource(false)
    videoSource.adaptOutputFormat(width, height, fps)

    val surfaceTextureRenderer =
        SurfaceTextureHelper.create(Thread.currentThread().name, EglUtils.rootEglBaseContext)
    val videoCapturer =
        cameraEnumerator.createCapturer(
            deviceId,
            object : CameraVideoCapturer.CameraEventsHandler {
              override fun onCameraError(p0: String?) {}
              override fun onCameraDisconnected() {}
              override fun onCameraFreezed(p0: String?) {}
              override fun onCameraOpening(p0: String?) {}
              override fun onFirstFrameAvailable() {}
              override fun onCameraClosed() {}
            })
    videoCapturer.initialize(
        surfaceTextureRenderer, state.getAppContext(), videoSource.capturerObserver)
    videoCapturer.startCapture(width, height, fps)

    val facingMode =
        if (cameraEnumerator.isBackFacing(deviceId)) FacingMode.ENVIRONMENT else FacingMode.USER

    val videoTrackSource =
        VideoMediaTrackSource(
            videoCapturer,
            videoSource,
            surfaceTextureRenderer,
            state.getPeerConnectionFactory(),
            facingMode,
            deviceId)

    val track = videoTrackSource.newTrack()
    track.onStop { videoTracks.remove(constraints, track) }
    videoTracks[constraints] = track

    return track
  }

  /**
   * Creates an audio [MediaStreamTrackProxy] basing on the provided [AudioConstraints].
   *
   * @param constraints [AudioConstraints] to perform the lookup with.
   *
   * @return Most suitable [MediaStreamTrackProxy] for the provided [AudioConstraints].
   */
  private suspend fun getUserAudioTrack(constraints: AudioConstraints): MediaStreamTrackProxy {
    try {
      permissions.requestPermission(Manifest.permission.RECORD_AUDIO)
    } catch (e: PermissionException) {
      throw GetUserMediaException(
          "Microphone permissions was not granted", GetUserMediaException.Kind.Audio)
    }
    val source = state.getPeerConnectionFactory().createAudioSource(constraints.intoWebRtc())
    val audioTrackSource = AudioMediaTrackSource(source, state.getPeerConnectionFactory())
    return audioTrackSource.newTrack()
  }

  override fun onReceive(ctx: Context?, intent: Intent?) {
    if (intent?.action != null) {
      if (AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED == intent.action) {
        val state =
            intent.getIntExtra(
                AudioManager.EXTRA_SCO_AUDIO_STATE, AudioManager.SCO_AUDIO_STATE_DISCONNECTED)
        if (selectedAudioOutputId == BLUETOOTH_HEADSET_DEVICE_ID) {
          when (state) {
            AudioManager.SCO_AUDIO_STATE_CONNECTED -> {
              Log.d("FlutterWebRtcDebug", "SCO connected")
              isBluetoothScoFailed = false
              bluetoothScoDeferred?.complete(Unit)
              bluetoothScoDeferred = null
              audioManager.isBluetoothScoOn = true
              audioManager.isSpeakerphoneOn = false
            }
            AudioManager.SCO_AUDIO_STATE_DISCONNECTED -> {
              Log.d("FlutterWebRtcDebug", "SCO disconnected")
              isBluetoothScoFailed = true
              bluetoothScoDeferred?.completeExceptionally(
                  GetUserMediaException(
                      "Bluetooth headset is unavailable at this moment",
                      GetUserMediaException.Kind.Audio))
              bluetoothScoDeferred = null
              Handler(Looper.getMainLooper()).post { eventBroadcaster().onDeviceChange() }
            }
          }
        }
      }
    }
  }
}
