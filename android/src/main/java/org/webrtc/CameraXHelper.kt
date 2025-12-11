
/*
 * Copyright 2023-2025 LiveKit, Inc.
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
import androidx.camera.camera2.interop.ExperimentalCamera2Interop
import androidx.camera.core.UseCase
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.cloudwebrtc.webrtc.CameraCapturerUtils
import com.cloudwebrtc.webrtc.CameraCapturerUtils.findCamera
import com.cloudwebrtc.webrtc.CameraEventsDispatchHandler

class CameraXHelper {
    companion object {
        /**
         * Creates a CameraProvider that uses CameraX for its sessions.
         *
         * For use with [CameraCapturerUtils.registerCameraProvider].
         * Remember to unregister the provider when outside the lifecycle
         * of [lifecycleOwner].
         *
         * @param lifecycleOwner The lifecycleOwner which controls the lifecycle transitions of the use cases.
         * @param useCases The use cases to bind to a lifecycle.
         */
        @JvmOverloads
        @ExperimentalCamera2Interop
        fun createCameraProvider(
            lifecycleOwner: LifecycleOwner,
            useCases: Array<out UseCase> = emptyArray(),
        ) = object : CameraCapturerUtils.CameraProvider {

            private var enumerator: CameraXEnumerator? = null

            override val cameraVersion = 3

            override fun provideEnumerator(context: Context): CameraXEnumerator =
                enumerator ?: CameraXEnumerator(context, lifecycleOwner, useCases).also {
                    enumerator = it
                }

            override fun provideCapturer(
                context: Context,
                isFront: Boolean?, deviceId: String?,
                               eventsHandler: CameraEventsDispatchHandler,
            ): VideoCapturer {
                val enumerator = provideEnumerator(context)
                val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager

                val targetDevice = enumerator.findCamera(deviceId, isFront)
                val targetDeviceId = targetDevice?.deviceId

                val targetVideoCapturer = enumerator.createCapturer(targetDeviceId, eventsHandler) as CameraXCapturer

                return CameraXCapturerWithSize(
                    targetVideoCapturer,
                    cameraManager,
                    targetDeviceId,
                    eventsHandler,
                )
            }

            override fun isSupported(context: Context): Boolean {
                return Camera2Enumerator.isSupported(context) && lifecycleOwner.lifecycle.currentState.isAtLeast(Lifecycle.State.INITIALIZED)
            }
        }

        private fun getSupportedFormats(
            cameraManager: CameraManager,
            cameraId: String?,
        ): List<CameraEnumerationAndroid.CaptureFormat>? =
            Camera2Enumerator.getSupportedFormats(cameraManager, cameraId)

        fun findClosestCaptureFormat(
            cameraManager: CameraManager,
            cameraId: String?,
            width: Int,
            height: Int,
        ): Size {
            val sizes = getSupportedFormats(cameraManager, cameraId)
                ?.map { Size(it.width, it.height) }
                ?: emptyList()
            return CameraEnumerationAndroid.getClosestSupportedSize(sizes, width, height)
        }
    }
}
