/*
 * Copyright 2023-2024 LiveKit, Inc.
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

package com.cloudwebrtc.webrtc

import android.hardware.camera2.CameraManager
import org.webrtc.VideoCapturer
import org.webrtc.Size
import org.webrtc.Camera1Capturer
import org.webrtc.CameraVideoCapturer
import org.webrtc.Camera1Helper
import org.webrtc.Camera2Capturer
import org.webrtc.Camera2Helper

/**
 * A [VideoCapturer] that declares that it can determine the actual size of the capture format it will use.
 */
interface VideoCapturerWithSize : VideoCapturer {
    fun findCaptureFormat(width: Int, height: Int): Size
}

abstract class CameraCapturerWithSize(
    @JvmField val cameraEventsDispatchHandler: CameraEventsDispatchHandler,
) : VideoCapturerWithSize

/**
 * @suppress
 */
internal class Camera1CapturerWithSize(
    private val capturer: Camera1Capturer,
    private val deviceName: String?,
    cameraEventsDispatchHandler: CameraEventsDispatchHandler,
) : CameraCapturerWithSize(cameraEventsDispatchHandler), CameraVideoCapturer by capturer {
    override fun findCaptureFormat(width: Int, height: Int): Size {
        val cameraId = Camera1Helper.getCameraId(deviceName)
        return Camera1Helper.findClosestCaptureFormat(cameraId, width, height)
    }
}

/**
 * @suppress
 */
internal class Camera2CapturerWithSize(
    private val capturer: Camera2Capturer,
    private val cameraManager: CameraManager,
    private val deviceName: String?,
    cameraEventsDispatchHandler: CameraEventsDispatchHandler,
) : CameraCapturerWithSize(cameraEventsDispatchHandler), CameraVideoCapturer by capturer {
    override fun findCaptureFormat(width: Int, height: Int): Size {
        return Camera2Helper.findClosestCaptureFormat(cameraManager, deviceName, width, height)
    }
}

