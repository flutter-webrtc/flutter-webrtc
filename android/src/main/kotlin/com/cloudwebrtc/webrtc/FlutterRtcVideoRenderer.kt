package com.cloudwebrtc.webrtc

import android.graphics.SurfaceTexture
import android.os.Handler
import android.os.Looper
import com.cloudwebrtc.webrtc.proxy.VideoTrackProxy
import com.cloudwebrtc.webrtc.utils.EglUtils
import io.flutter.view.TextureRegistry
import org.webrtc.RendererCommon

/**
 * Renders video from a track to a [SurfaceTexture] which can be shown by the Flutter side.
 *
 * @param textureRegistry Registry to create a new [TextureRegistry.SurfaceTextureEntry] with.
 */
class FlutterRtcVideoRenderer(textureRegistry: TextureRegistry) {
  /** Texture entry on which the video will be rendered. */
  private val surfaceTextureEntry: TextureRegistry.SurfaceTextureEntry =
      textureRegistry.createSurfaceTexture()

  /** Texture on which the video will be rendered. */
  private val texture: SurfaceTexture = surfaceTextureEntry.surfaceTexture()

  /** Unique ID of the underlying texture. */
  private val id: Long = surfaceTextureEntry.id()

  /** Listener for the [renderer] events. */
  private var rendererEventsListener: RendererCommon.RendererEvents = rendererEventsListener()

  /** This [FlutterRtcVideoRenderer] events listener. */
  private var eventListener: EventListener? = null

  /** Helper for rendering video on the surface. */
  private val renderer: SurfaceTextureRenderer =
      SurfaceTextureRenderer("flutter-video-renderer-$id")

  /** [VideoTrackProxy] from which [FlutterRtcVideoRenderer] obtains video and renders it. */
  private var track: VideoTrackProxy? = null

  companion object {
    /** Listener for all the events of the [FlutterRtcVideoRenderer]. */
    interface EventListener {
      /**
       * Notifies about a first frame rendering.
       *
       * @param id Unique ID of the texture which produced this event.
       */
      fun onFirstFrameRendered(id: Long)

      /**
       * Notifies about video size change.
       *
       * @param id Unique ID of the texture which produced this event.
       * @param height New height of the video.
       * @param width New width of the video.
       */
      fun onTextureChangeVideoSize(id: Long, height: Int, width: Int)

      /**
       * Notifies about video rotation change.
       *
       * @param id Unique ID of the texture producing this event.
       * @param rotation New rotation of the video.
       */
      fun onTextureChangeRotation(id: Long, rotation: Int)
    }
  }

  init {
    renderer.init(EglUtils.rootEglBaseContext, rendererEventsListener)
    renderer.surfaceCreated(texture)
  }

  /** @return Unique ID of the underlying texture. */
  fun textureId(): Long {
    return surfaceTextureEntry.id()
  }

  /**
   * Subscribes the provided [EventListener] to all the events of this [FlutterRtcVideoRenderer].
   *
   * @param listener Listener which will receive all events.
   */
  fun setEventListener(listener: EventListener) {
    eventListener = listener
  }

  /**
   * Sets the [VideoTrackProxy] from which video will be rendered on the texture surface.
   *
   * @param newTrack [VideoTrackProxy] for rendering.
   */
  fun setVideoTrack(newTrack: VideoTrackProxy?) {
    if (track != newTrack && newTrack != null) {
      track?.removeSink(renderer)

      if (track == null) {
        val sharedContext = EglUtils.rootEglBaseContext!!
        renderer.release()
        rendererEventsListener = rendererEventsListener()
        renderer.init(sharedContext, rendererEventsListener)
        renderer.surfaceCreated(texture)
      }

      newTrack.addSink(renderer)
    }

    track = newTrack
  }

  /**
   * Disposes this [FlutterRtcVideoRenderer].
   *
   * Closes [EventListener], releases all related to the surface texture renderer entities.
   */
  fun dispose() {
    eventListener = null
    track?.removeSink(renderer)
    renderer.release()
    surfaceTextureEntry.release()
    texture.release()
    renderer.surfaceDestroyed()
  }

  /**
   * @return Listener for all renderer events, which will pass this events to the current
   * [EventListener].
   */
  private fun rendererEventsListener(): RendererCommon.RendererEvents {
    return object : RendererCommon.RendererEvents {
      private var rotation: Int = -1
      private var width: Int = 0
      private var height: Int = 0

      override fun onFirstFrameRendered() {
        Handler(Looper.getMainLooper()).post { eventListener?.onFirstFrameRendered(id) }
      }

      override fun onFrameResolutionChanged(newWidth: Int, newHeight: Int, newRotation: Int) {
        if (newWidth != width || newHeight != height) {
          width = newWidth
          height = newHeight
          Handler(Looper.getMainLooper()).post {
            eventListener?.onTextureChangeVideoSize(id, height, width)
          }
        }

        if (newRotation != rotation) {
          rotation = newRotation
          Handler(Looper.getMainLooper()).post {
            eventListener?.onTextureChangeRotation(id, rotation)
          }
        }
      }
    }
  }
}
