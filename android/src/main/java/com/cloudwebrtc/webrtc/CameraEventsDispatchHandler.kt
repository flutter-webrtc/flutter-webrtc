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

import org.webrtc.CameraVideoCapturer.CameraEventsHandler

/**
 * Dispatches CameraEventsHandler callbacks to registered handlers.
 */
class CameraEventsDispatchHandler : CameraEventsHandler {
    private val handlers = mutableSetOf<CameraEventsHandler>()

    @Synchronized
    fun registerHandler(handler: CameraEventsHandler) {
        handlers.add(handler)
    }

    @Synchronized
    fun unregisterHandler(handler: CameraEventsHandler) {
        handlers.remove(handler)
    }

    override fun onCameraError(errorDescription: String) {
        val handlersCopy = handlers.toMutableSet()
        for (handler in handlersCopy) {
            handler.onCameraError(errorDescription)
        }
    }

    override fun onCameraDisconnected() {
        val handlersCopy = handlers.toMutableSet()
        for (handler in handlersCopy) {
            handler.onCameraDisconnected()
        }
    }

    override fun onCameraFreezed(errorDescription: String) {
        val handlersCopy = handlers.toMutableSet()
        for (handler in handlersCopy) {
            handler.onCameraFreezed(errorDescription)
        }
    }

    override fun onCameraOpening(cameraName: String) {
        val handlersCopy = handlers.toMutableSet()
        for (handler in handlersCopy) {
            handler.onCameraOpening(cameraName)
        }
    }

    override fun onFirstFrameAvailable() {
        val handlersCopy = handlers.toMutableSet()
        for (handler in handlersCopy) {
            handler.onFirstFrameAvailable()
        }
    }

    override fun onCameraClosed() {
        val handlersCopy = handlers.toMutableSet()
        for (handler in handlersCopy) {
            handler.onCameraClosed()
        }
    }
}

