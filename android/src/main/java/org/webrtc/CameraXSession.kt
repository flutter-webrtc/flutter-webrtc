/*
 * Copyright 2024-2025 LiveKit, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.webrtc

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata
import android.hardware.camera2.CameraMetadata.CONTROL_VIDEO_STABILIZATION_MODE_OFF
import android.hardware.camera2.CameraMetadata.CONTROL_VIDEO_STABILIZATION_MODE_ON
import android.hardware.camera2.CameraMetadata.LENS_OPTICAL_STABILIZATION_MODE_OFF
import android.hardware.camera2.CameraMetadata.LENS_OPTICAL_STABILIZATION_MODE_ON
import android.hardware.camera2.CaptureRequest
import android.os.Build
import android.os.Build.VERSION
import android.os.Handler
import android.util.Range
import android.util.Size
import android.view.Surface
import androidx.camera.camera2.interop.Camera2CameraInfo
import androidx.camera.camera2.interop.Camera2Interop
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExtendableBuilder
import androidx.camera.core.Preview
import androidx.camera.core.Preview.SurfaceProvider
import androidx.camera.core.UseCase
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import org.webrtc.CameraEnumerationAndroid.CaptureFormat
import java.util.concurrent.Executor
import java.util.concurrent.TimeUnit

/**
 * @suppress
 */
@androidx.camera.camera2.interop.ExperimentalCamera2Interop
class CameraXSession
internal constructor(
    private val sessionCallback: CameraSession.CreateSessionCallback,
    private val events: CameraSession.Events,
    private val context: Context,
    private val lifecycleOwner: LifecycleOwner,
    private val surfaceTextureHelper: SurfaceTextureHelper,
    private val cameraId: String,
    private val width: Int,
    private val height: Int,
    private val frameRate: Int,
    private val useCases: Array<out UseCase> = emptyArray(),
) : CameraSession {

    private var state = SessionState.RUNNING
    private var cameraThreadHandler: Handler = surfaceTextureHelper.handler
    private lateinit var cameraProvider: ProcessCameraProvider
    private lateinit var surfaceProvider: SurfaceProvider
    var camera: Camera? = null
        private set
    private var surface: Surface? = null
    private var cameraOrientation: Int = 0
    private var isCameraFrontFacing: Boolean = true
    private var firstFrameReported = false
    private val constructionTimeNs = System.nanoTime()
    private var fpsUnitFactor = 1
    private var captureFormat: CaptureFormat? = null
    private var stabilizationMode = StabilizationMode.NONE
    private var surfaceTextureListener = { frame: VideoFrame ->
        checkIsOnCameraThread()
        if (state != SessionState.RUNNING) {
            Logging.d(TAG, "Texture frame captured but camera is no longer running.")
        } else {
            if (!firstFrameReported) {
                firstFrameReported = true
                val startTimeMs = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - constructionTimeNs).toInt()
                cameraXStartTimeMsHistogram.addSample(startTimeMs)
            }
            // Undo the mirror that the OS "helps" us with.
            // http://developer.android.com/reference/android/hardware/Camera.html#setDisplayOrientation(int)
            // Also, undo camera orientation, we report it as rotation instead.
            val modifiedFrame = VideoFrame(
                CameraSession.createTextureBufferWithModifiedTransformMatrix(
                    frame.buffer as TextureBufferImpl,
                    isCameraFrontFacing,
                    -cameraOrientation,
                ),
                getFrameOrientation(),
                frame.timestampNs,
            )
            events.onFrameCaptured(this@CameraXSession, modifiedFrame)
            modifiedFrame.release()
        }
    }

    private val cameraDevice: CameraDeviceId
        get() {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            return findCamera(cameraManager, cameraId)
                ?: throw IllegalArgumentException("Camera ID $cameraId not found")
        }

    init {
        cameraThreadHandler.post {
            start()
        }
    }

    private fun start() {
        checkIsOnCameraThread()
        surfaceTextureHelper.startListening(surfaceTextureListener)
        openCamera()
    }

    override fun stop() {
        Logging.d(TAG, "Stop cameraX session on camera $cameraId")
        checkIsOnCameraThread()
        if (state != SessionState.STOPPED) {
            val stopStartTime = System.nanoTime()
            state = SessionState.STOPPED
            stopInternal()
            val stopTimeMs = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - stopStartTime).toInt()
            cameraXStopTimeMsHistogram.addSample(stopTimeMs)
        }
    }

    private fun openCamera() {
        checkIsOnCameraThread()
        Logging.d(TAG, "Opening camera $cameraId")
        events.onCameraOpening()
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        val helperExecutor = Executor { command ->
            surfaceTextureHelper.handler.let {
                if (it.looper.thread.isAlive) {
                    it.post(command)
                }
            }
        }
        cameraProviderFuture.addListener(
            {
                // Used to bind the lifecycle of cameras to the lifecycle owner
                cameraProvider = cameraProviderFuture.get()
                obtainCameraConfiguration()

                surfaceTextureHelper.setTextureSize(captureFormat?.width ?: width, captureFormat?.height ?: height)

                surface = Surface(surfaceTextureHelper.surfaceTexture)
                surfaceProvider = SurfaceProvider { request ->
                    surface?.let {
                        request.provideSurface(it, helperExecutor) { }
                    } ?: request.willNotProvideSurface()
                }

                // Select camera by ID
                val cameraSelector = CameraSelector.Builder()
                    .addCameraFilter { cameraInfo -> cameraInfo.filter { Camera2CameraInfo.from(it).cameraId == cameraDevice.deviceId } }
                    .build()

                try {
                    ContextCompat.getMainExecutor(context).execute {
                        // Preview
                        val preview = Preview.Builder()
                            .setResolutionSelector(
                                ResolutionSelector.Builder()
                                    .setResolutionStrategy(
                                        ResolutionStrategy(
                                            Size(captureFormat?.width ?: width, captureFormat?.height ?: height),
                                            ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER,
                                        ),
                                    )
                                    .build(),
                            )
                            .applyCameraSettings()
                            .build()
                            .also {
                                it.surfaceProvider = surfaceProvider
                            }

                        // Unbind use cases before rebinding
                        cameraProvider.unbindAll()

                        // Bind use cases to camera
                        camera = cameraProvider.bindToLifecycle(
                            lifecycleOwner,
                            cameraSelector,
                            preview,
                            *useCases,
                        )

                        cameraThreadHandler.post {
                            sessionCallback.onDone(this@CameraXSession)
                        }
                    }
                } catch (e: Exception) {
                    reportError("Failed to open camera: $e")
                }
            },
            helperExecutor,
        )
    }

    private fun <T> ExtendableBuilder<T>.applyCameraSettings(): ExtendableBuilder<T> {
        val cameraExtender = Camera2Interop.Extender(this)

        cameraDevice.physicalId?.let { physicalId ->
            if (VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                cameraExtender.setPhysicalCameraId(physicalId)
            }
        }

        val captureFormat = this@CameraXSession.captureFormat ?: return this
        cameraExtender.setCaptureRequestOption(
            CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
            Range(
                captureFormat.framerate.min / fpsUnitFactor,
                captureFormat.framerate.max / fpsUnitFactor,
            ),
        )
        cameraExtender.setCaptureRequestOption(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON)
        cameraExtender.setCaptureRequestOption(CaptureRequest.CONTROL_AE_LOCK, false)
        when (stabilizationMode) {
            StabilizationMode.OPTICAL -> {
                cameraExtender.setCaptureRequestOption(CaptureRequest.LENS_OPTICAL_STABILIZATION_MODE, LENS_OPTICAL_STABILIZATION_MODE_ON)
                cameraExtender.setCaptureRequestOption(CaptureRequest.CONTROL_VIDEO_STABILIZATION_MODE, CONTROL_VIDEO_STABILIZATION_MODE_OFF)
            }

            StabilizationMode.VIDEO -> {
                cameraExtender.setCaptureRequestOption(CaptureRequest.CONTROL_VIDEO_STABILIZATION_MODE, CONTROL_VIDEO_STABILIZATION_MODE_ON)
                cameraExtender.setCaptureRequestOption(CaptureRequest.LENS_OPTICAL_STABILIZATION_MODE, LENS_OPTICAL_STABILIZATION_MODE_OFF)
            }

            else -> {
            }
        }
        return this
    }

    private fun stopInternal() {
        checkIsOnCameraThread()
        surfaceTextureHelper.stopListening()

        if (surface != null) {
            surface!!.release()
            surface = null
        }

        ContextCompat.getMainExecutor(context).execute {
            cameraProvider.unbindAll()
            cameraThreadHandler.postAtFrontOfQueue {
                events.onCameraClosed(this)
            }
        }
    }

    private fun reportError(error: String) {
        checkIsOnCameraThread()
        Logging.e(TAG, "Error: $error")
        val startFailure = camera == null && state != SessionState.STOPPED
        state = SessionState.STOPPED
        stopInternal()
        if (startFailure) {
            sessionCallback.onFailure(CameraSession.FailureType.ERROR, error)
        } else {
            events.onCameraError(this, error)
        }
    }

    private fun obtainCameraConfiguration() {
        val camera = cameraProvider.availableCameraInfos.map { Camera2CameraInfo.from(it) }.first { it.cameraId == cameraDevice.deviceId }

        cameraOrientation = camera.getCameraCharacteristic(CameraCharacteristics.SENSOR_ORIENTATION) ?: -1
        isCameraFrontFacing = camera.getCameraCharacteristic(CameraCharacteristics.LENS_FACING) == CameraMetadata.LENS_FACING_FRONT

        findCaptureFormat(camera)
        findStabilizationMode(camera)
    }

    private fun findCaptureFormat(camera: Camera2CameraInfo) {
        val fpsRanges = camera.getCameraCharacteristic(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES)
        fpsUnitFactor = Camera2Enumerator.getFpsUnitFactor(fpsRanges)
        val framerateRanges = Camera2Enumerator.convertFramerates(fpsRanges, fpsUnitFactor)
        val sizes = CameraXEnumerator.getSupportedSizes(camera)
        Logging.d(TAG, "Available preview sizes: $sizes")
        Logging.d(TAG, "Available fps ranges: $framerateRanges")
        if (framerateRanges.isEmpty() || sizes.isEmpty()) {
            reportError("No supported capture formats.")
            return
        }
        val bestFpsRange = CameraEnumerationAndroid.getClosestSupportedFramerateRange(framerateRanges, frameRate)
        val bestSize = CameraEnumerationAndroid.getClosestSupportedSize(sizes, width, height)
        CameraEnumerationAndroid.reportCameraResolution(cameraXResolutionHistogram, bestSize)
        captureFormat = CaptureFormat(bestSize.width, bestSize.height, bestFpsRange)
        Logging.d(TAG, "Using capture format: $captureFormat")
    }

    private fun findStabilizationMode(camera: Camera2CameraInfo) {
        val availableOpticalStabilization: IntArray? = camera.getCameraCharacteristic(CameraCharacteristics.LENS_INFO_AVAILABLE_OPTICAL_STABILIZATION)
        if (availableOpticalStabilization?.contains(LENS_OPTICAL_STABILIZATION_MODE_ON) == true) {
            stabilizationMode = StabilizationMode.OPTICAL
        } else {
            val availableVideoStabilization: IntArray? = camera.getCameraCharacteristic(CameraCharacteristics.LENS_INFO_AVAILABLE_OPTICAL_STABILIZATION)
            if (availableVideoStabilization?.contains(CONTROL_VIDEO_STABILIZATION_MODE_ON) == true) {
                stabilizationMode = StabilizationMode.VIDEO
            }
        }
    }

    private fun checkIsOnCameraThread() {
        check(Thread.currentThread() === cameraThreadHandler.looper.thread) { "Wrong thread" }
    }

    private fun getFrameOrientation(): Int {
        var rotation = CameraSession.getDeviceOrientation(context)
        if (!isCameraFrontFacing) {
            rotation = 360 - rotation
        }
        return (cameraOrientation + rotation) % 360
    }

    private data class CameraDeviceId(val deviceId: String, val physicalId: String?)

    private fun findCamera(
        cameraManager: CameraManager,
        deviceId: String,
    ): CameraDeviceId? {
        for (id in cameraManager.cameraIdList) {
            // First check if deviceId is a direct logical camera ID
            if (id == deviceId) return CameraDeviceId(id, null)

            // Then check if deviceId is a physical camera ID in a logical camera
            if (VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val characteristic = cameraManager.getCameraCharacteristics(id)

                for (physicalId in characteristic.physicalCameraIds) {
                    if (deviceId == physicalId) {
                        return CameraDeviceId(id, physicalId)
                    }
                }
            }
        }
        return null
    }

    companion object {
        private const val TAG = "CameraXSession"
        private val cameraXStartTimeMsHistogram = Histogram.createCounts("WebRTC.Android.CameraX.StartTimeMs", 1, 10000, 50)
        private val cameraXStopTimeMsHistogram = Histogram.createCounts("WebRTC.Android.CameraX.StopTimeMs", 1, 10000, 50)
        private val cameraXResolutionHistogram = Histogram.createEnumeration("WebRTC.Android.CameraX.Resolution", CameraEnumerationAndroid.COMMON_RESOLUTIONS.size)
    }

    internal enum class SessionState {
        RUNNING, STOPPED
    }

    internal enum class StabilizationMode {
        OPTICAL, VIDEO, NONE
    }
}


