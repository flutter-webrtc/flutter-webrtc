
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

@file:Suppress("MemberVisibilityCanBePrivate", "unused")

package com.cloudwebrtc.webrtc

import android.content.Context
import android.hardware.camera2.CameraManager
import android.util.Log
import android.util.Pair
import org.webrtc.Camera1Capturer
import org.webrtc.Camera1Enumerator
import org.webrtc.Camera1Helper
import org.webrtc.Camera2Capturer
import org.webrtc.Camera2Enumerator
import org.webrtc.CameraEnumerator
import org.webrtc.VideoCapturer

/**
 * Various utils for handling camera capturers.
 */
object CameraCapturerUtils {
    private val TAG = CameraCapturerUtils.javaClass.name

    private val cameraProviders = mutableListOf<CameraProvider>().apply {
        add(createCamera1Provider())
        add(createCamera2Provider())
    }

    /**
     * Register external camera provider
     */
    @JvmStatic
    fun registerCameraProvider(cameraProvider: CameraProvider) {
        Log.d(TAG, "Registering camera provider: Camera version:${cameraProvider.cameraVersion}" )
        cameraProviders.add(cameraProvider)
    }

    /**
     * Unregister external camera provider
     */
    @JvmStatic
    fun unregisterCameraProvider(cameraProvider: CameraProvider) {
        Log.d(TAG, "Removing camera provider: Camera version:${cameraProvider.cameraVersion}" )
        cameraProviders.remove(cameraProvider)
    }

    /**
     * Obtain a CameraEnumerator based on platform capabilities.
     */
     @JvmStatic
    fun createCameraEnumerator(context: Context): CameraEnumerator {
        return getCameraProvider(context).provideEnumerator(context)
    }

    /**
     * Create a CameraProvider based on platform capabilities.
     *
     * Picks CameraProvider of highest available version that is supported on device
     */
    private fun getCameraProvider(context: Context): CameraProvider {
        return cameraProviders
            .sortedByDescending { it.cameraVersion }
            .first { it.isSupported(context) }
    }

    /**
     * Creates a Camera capturer.
     */
    @JvmStatic
    fun createCameraCapturer(
        context: Context,
        isFacing: Boolean?,
        sourceId: String?,
           ): Pair<String, VideoCapturer >? {
        val pair = createCameraCapturer(context, getCameraProvider(context), isFacing, sourceId)

        if (pair == null) {
            Log.d(TAG, "Failed to open camera" )
            return null
        }
        return pair
    }

    private fun createCameraCapturer(
        context: Context,
        provider: CameraProvider,
        isFacing: Boolean?,
        sourceId: String?,
    ): Pair<String, VideoCapturer>? {
        val cameraEnumerator = provider.provideEnumerator(context)
        val cameraEventsDispatchHandler = CameraEventsDispatchHandler()
        val targetDevice = cameraEnumerator.findCamera(sourceId, isFacing) ?: return null
        val targetVideoCapturer = provider.provideCapturer(context, isFacing, sourceId, cameraEventsDispatchHandler)

        if (targetVideoCapturer !is VideoCapturerWithSize) {
            Log.w(TAG, "unknown CameraCapturer class: ${targetVideoCapturer.javaClass.canonicalName}")
        }

        return Pair(
            targetDevice.deviceId,
            targetVideoCapturer,
        )
    }

    private fun createCamera1Provider() = object : CameraProvider {
        private val enumerator by lazy { Camera1Enumerator(true) }

        override val cameraVersion = 1

        override fun provideEnumerator(context: Context) = enumerator

        override fun provideCapturer(
            context: Context,
            isFront: Boolean?,
            deviceId: String?,
            eventsHandler: CameraEventsDispatchHandler,
        ): VideoCapturer {
            val targetDevice = enumerator.findCamera(deviceId, isFront)
            // Cache supported capture formats ahead of time to avoid future camera locks.
            Camera1Helper.getSupportedFormats(Camera1Helper.getCameraId(targetDevice?.deviceId))
            val targetVideoCapturer = enumerator.createCapturer(targetDevice?.deviceId, eventsHandler)
            return Camera1CapturerWithSize(
                targetVideoCapturer as Camera1Capturer,
                targetDevice?.deviceId,
                eventsHandler,
            )
        }

        override fun isSupported(context: Context) = true
    }

    private fun createCamera2Provider() = object : CameraProvider {
        private var enumerator: Camera2Enumerator? = null

        override val cameraVersion = 2

        override fun provideEnumerator(context: Context): CameraEnumerator = enumerator ?: Camera2Enumerator(context).also {
            enumerator = it
        }

        override fun provideCapturer(
            context: Context,
            isFront: Boolean?,
            deviceId: String?,
            eventsHandler: CameraEventsDispatchHandler,
        ): VideoCapturer {
            val enumerator = provideEnumerator(context)
            val targetDevice = enumerator.findCamera(deviceId, isFront)
            val targetVideoCapturer = enumerator.createCapturer(targetDevice?.deviceId, eventsHandler)
            return Camera2CapturerWithSize(
                targetVideoCapturer as Camera2Capturer,
                context.getSystemService(Context.CAMERA_SERVICE) as CameraManager,
                targetDevice?.deviceId,
                eventsHandler,
            )
        }

        override fun isSupported(context: Context) = Camera2Enumerator.isSupported(context)
    }

    /**
     * Finds the device id of first available camera based on the criteria given. Returns null if no camera matches the criteria.
     *
     * @param deviceId an id of a camera. Available device ids can be found through [CameraEnumerator.getDeviceNames]. If null, device id search is skipped. Defaults to null.
     * @param position the position of a camera. If null, search based on camera position is skipped. Defaults to null.
     * @param fallback if true, when no camera is found by device id/position search, the first available camera on the list will be returned.
     */
    fun CameraEnumerator.findCamera(
        deviceId: String? = null,
        isFront: Boolean? = null,
        fallback: Boolean = true,
    ): CameraDeviceInfo? {
        var targetDevice: CameraDeviceInfo? = null
        // Prioritize search by deviceId first
        if (deviceId != null) {
            targetDevice = findCamera { id, _ ->
                id == deviceId
            }
        }

        // Search by camera position
        if (targetDevice == null && isFront != null) {
            targetDevice = findCamera { _, pos ->
                pos == isFront
            }
        }

        // Fall back by choosing first available camera.
        if (targetDevice == null && fallback) {
            targetDevice = findCamera { _, _ -> true }
        }

        return targetDevice
    }

    data class CameraDeviceInfo(val deviceId: String, val front: Boolean?)

    /**
     * Returns information about a camera by searching for the specified device ID.
     *
     * @param predicate with deviceId and position, return true if camera is found
     * @return [CameraDeviceInfo] with camera id and position if found, null otherwise
     */
    fun CameraEnumerator.findCamera(
        predicate: (deviceId: String?, front: Boolean?) -> Boolean,
    ): CameraDeviceInfo? {
        for (id in deviceNames) {
            val position = if (isFrontFacing(id)) {
                true
            } else if (isBackFacing(id)) {
                false
            } else {
                null
            }

            if (predicate(id, position)) {
                return CameraDeviceInfo(id, position)
            }
        }
        return null
    }

    /**
     * An interface declaring a provider of camera capturers.
     */
    interface CameraProvider {
        /**
         * This acts as the priority of the CameraProvider when determining which provider to use (in order of highest to lowest).
         */
        val cameraVersion: Int
        fun provideEnumerator(context: Context): CameraEnumerator
        fun provideCapturer(context: Context, isFront: Boolean?, deviceId: String?, eventsHandler: CameraEventsDispatchHandler): VideoCapturer

        /**
         * If the return value of this method is false, this provider will be skipped when querying providers to use.
         */
        fun isSupported(context: Context): Boolean
    }
}

