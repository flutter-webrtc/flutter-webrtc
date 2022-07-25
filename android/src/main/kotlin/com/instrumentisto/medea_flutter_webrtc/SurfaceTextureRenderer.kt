package com.instrumentisto.medea_flutter_webrtc

import android.graphics.SurfaceTexture
import java.util.concurrent.CountDownLatch
import org.webrtc.*
import org.webrtc.RendererCommon.GlDrawer
import org.webrtc.RendererCommon.RendererEvents

/** Displays the video stream on a `Surface`. */
class SurfaceTextureRenderer(name: String) : EglRenderer(name) {
  // Callback for reporting renderer events. Read-only after initialization,
  // so no lock is required.
  private var rendererEvents: RendererEvents? = null
  private val layoutLock = Any()

  @Volatile private var isRenderingPaused = false
  private var isFirstFrameRendered = false
  private var rotatedFrameWidth = 0
  private var rotatedFrameHeight = 0
  private var frameRotation = 0
  private var texture: SurfaceTexture? = null

  /**
   * Initialize this class, sharing resources with |sharedContext|. The custom |drawer| will be used
   * for drawing frames on the `EGLSurface`. This class is responsible for calling `release()` on
   * the |drawer|. It's allowed to call `init()` to reinitialize the renderer after the previous
   * `init()`/`release()` cycle.
   */
  @JvmOverloads
  fun init(
      sharedContext: EglBase.Context?,
      rendererEvents: RendererEvents?,
      configAttributes: IntArray? = EglBase.CONFIG_PLAIN,
      drawer: GlDrawer? = GlRectDrawer()
  ) {
    ThreadUtils.checkIsOnMainThread()
    this.rendererEvents = rendererEvents
    synchronized(layoutLock) {
      isFirstFrameRendered = false
      rotatedFrameWidth = 0
      rotatedFrameHeight = 0
      frameRotation = -1
    }
    super.init(sharedContext, configAttributes, drawer)
  }

  override fun init(sharedContext: EglBase.Context?, configAttributes: IntArray, drawer: GlDrawer) {
    init(sharedContext, null, configAttributes, drawer)
  }

  /**
   * Limit render framerate.
   *
   * @param fps Limit render framerate to this value, or use [Float.POSITIVE_INFINITY] to disable
   * FPS reduction.
   */
  override fun setFpsReduction(fps: Float) {
    isRenderingPaused = fps == 0f
    super.setFpsReduction(fps)
  }

  override fun disableFpsReduction() {
    isRenderingPaused = false
    super.disableFpsReduction()
  }

  override fun pauseVideo() {
    isRenderingPaused = true
    super.pauseVideo()
  }

  override fun onFrame(frame: VideoFrame) {
    synchronized(layoutLock) {
      if (isRenderingPaused) {
        return
      }
      if (!isFirstFrameRendered) {
        isFirstFrameRendered = true
        if (rendererEvents != null) {
          rendererEvents!!.onFirstFrameRendered()
        }
      }
      if (rotatedFrameWidth != frame.rotatedWidth ||
          rotatedFrameHeight != frame.rotatedHeight ||
          frameRotation != frame.rotation) {
        if (rendererEvents != null) {
          rendererEvents!!.onFrameResolutionChanged(
              frame.buffer.width, frame.buffer.height, frame.rotation)
        }
        rotatedFrameWidth = frame.rotatedWidth
        rotatedFrameHeight = frame.rotatedHeight
        texture!!.setDefaultBufferSize(rotatedFrameWidth, rotatedFrameHeight)
        frameRotation = frame.rotation
      }
    }
    super.onFrame(frame)
  }

  fun surfaceCreated(texture: SurfaceTexture) {
    ThreadUtils.checkIsOnMainThread()
    this.texture = texture
    createEglSurface(texture)
  }

  fun surfaceDestroyed() {
    ThreadUtils.checkIsOnMainThread()
    val completionLatch = CountDownLatch(1)
    releaseEglSurface { completionLatch.countDown() }
    ThreadUtils.awaitUninterruptibly(completionLatch)
  }
}
