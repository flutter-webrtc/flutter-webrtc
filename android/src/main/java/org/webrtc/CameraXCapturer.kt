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
import android.hardware.camera2.CameraManager
import androidx.annotation.OptIn
import androidx.camera.camera2.interop.ExperimentalCamera2Interop
import androidx.camera.core.Camera
import androidx.camera.core.UseCase
import androidx.lifecycle.LifecycleOwner
import com.cloudwebrtc.webrtc.CameraCapturerWithSize
import com.cloudwebrtc.webrtc.CameraEventsDispatchHandler
import com.cloudwebrtc.webrtc.utils.FlowObservable
import com.cloudwebrtc.webrtc.utils.flow
import com.cloudwebrtc.webrtc.utils.flowDelegate
import kotlinx.coroutines.flow.StateFlow

@ExperimentalCamera2Interop
internal class CameraXCapturer(
    enumerator: CameraXEnumerator,
    private val lifecycleOwner: LifecycleOwner,
    cameraName: String?,
    eventsHandler: CameraVideoCapturer.CameraEventsHandler?,
    private val useCases: Array<out UseCase> = emptyArray(),
) : CameraCapturer(cameraName, eventsHandler, enumerator) {

    @FlowObservable
    @get:FlowObservable
    var currentCamera by flowDelegate<Camera?>(null)

    override fun createCameraSession(
        createSessionCallback: CameraSession.CreateSessionCallback,
        events: CameraSession.Events,
        applicationContext: Context,
        surfaceTextureHelper: SurfaceTextureHelper,
        cameraName: String,
        width: Int,
        height: Int,
        framerate: Int,
    ) {
        CameraXSession(
            object : CameraSession.CreateSessionCallback {
                override fun onDone(session: CameraSession) {
                    createSessionCallback.onDone(session)
                    currentCamera = (session as CameraXSession).camera
                }

                override fun onFailure(failureType: CameraSession.FailureType, error: String) {
                    createSessionCallback.onFailure(failureType, error)
                }
            },
            object : CameraSession.Events {
                override fun onCameraOpening() {
                    events.onCameraOpening()
                }

                override fun onCameraError(session: CameraSession, error: String) {
                    events.onCameraError(session, error)
                }

                override fun onCameraDisconnected(session: CameraSession) {
                    events.onCameraDisconnected(session)
                }

                override fun onCameraClosed(session: CameraSession) {
                    events.onCameraClosed(session)
                }

                override fun onFrameCaptured(session: CameraSession, frame: VideoFrame) {
                    events.onFrameCaptured(session, frame)
                }
            },
            applicationContext,
            lifecycleOwner,
            surfaceTextureHelper,
            cameraName,
            width,
            height,
            framerate,
            useCases,
        )
    }
}

@ExperimentalCamera2Interop
internal class CameraXCapturerWithSize(
    internal val capturer: CameraXCapturer,
    private val cameraManager: CameraManager,
    private val deviceName: String?,
    cameraEventsDispatchHandler: CameraEventsDispatchHandler,
) : CameraCapturerWithSize(cameraEventsDispatchHandler), CameraVideoCapturer by capturer {
    override fun findCaptureFormat(width: Int, height: Int): Size {
        return CameraXHelper.findClosestCaptureFormat(cameraManager, deviceName, width, height)
    }
}

/**
 * Gets the [androidx.camera.core.Camera] from the VideoCapturer if it's using CameraX.
 */
@OptIn(ExperimentalCamera2Interop::class)
fun VideoCapturer.getCameraX(): StateFlow<Camera?>? {
    val actualCapturer = if (this is CameraXCapturerWithSize) {
        this.capturer
    } else {
        this
    }

    if (actualCapturer is CameraXCapturer) {
        return actualCapturer::currentCamera.flow
    }
    return null
}

