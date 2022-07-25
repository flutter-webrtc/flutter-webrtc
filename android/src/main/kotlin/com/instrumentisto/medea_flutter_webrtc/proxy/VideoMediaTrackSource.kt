package com.instrumentisto.medea_flutter_webrtc.proxy

import com.instrumentisto.medea_flutter_webrtc.SurfaceTextureRenderer
import com.instrumentisto.medea_flutter_webrtc.utils.LocalTrackIdGenerator
import org.webrtc.PeerConnectionFactory
import org.webrtc.SurfaceTextureHelper
import org.webrtc.VideoCapturer
import org.webrtc.VideoSource

/**
 * Object representing a source of an input video of an user.
 *
 * This source can create new [MediaStreamTrackProxy]s with the same video source.
 *
 * Also, this object will track all the child [MediaStreamTrackProxy]s and once they all disposed,
 * it disposes the underlying [VideoSource].
 *
 * @property videoCapturer [VideoCapturer] used in the provided [VideoSource].
 * @property videoSource Actual underlying [VideoSource].
 * @property surfaceTextureRenderer [SurfaceTextureRenderer] used in the provided [VideoSource].
 * @property peerConnectionFactoryProxy [PeerConnectionFactoryProxy] to create new
 * [MediaStreamTrackProxy]s with.
 * @property deviceId Unique device ID of the provided [VideoSource].
 */
class VideoMediaTrackSource(
    private val videoCapturer: VideoCapturer,
    private val videoSource: VideoSource,
    private val surfaceTextureRenderer: SurfaceTextureHelper,
    private val peerConnectionFactoryProxy: PeerConnectionFactory,
    private val deviceId: String
) : MediaTrackSource {
  /**
   * Count of currently alive [MediaStreamTrackProxy]ы created from this [VideoMediaTrackSource].
   */
  private var aliveTracksCount: Int = 0

  /**
   * Creates a new [MediaStreamTrackProxy] with the underlying [VideoSource].
   *
   * @return Newly created [MediaStreamTrackProxy].
   */
  override fun newTrack(): MediaStreamTrackProxy {
    val videoTrack =
        MediaStreamTrackProxy(
            peerConnectionFactoryProxy.createVideoTrack(
                LocalTrackIdGenerator.nextId(), videoSource),
            deviceId,
            this)
    aliveTracksCount += 1
    videoTrack.onStop { trackStopped() }

    return videoTrack
  }

  /**
   * Function, called when this [VideoMediaTrackSource] is stopped.
   *
   * Decrements the [aliveTracksCount] and if no [MediaStreamTrackProxy]s left, then disposes this
   * [VideoMediaTrackSource].
   */
  private fun trackStopped() {
    aliveTracksCount--
    if (aliveTracksCount == 0) {
      dispose()
    }
  }

  /**
   * Disposes this [AudioMediaTrackSource].
   *
   * Disposes [VideoSource], [VideoCapturer] and [SurfaceTextureHelper].
   */
  private fun dispose() {
    videoCapturer.stopCapture()
    videoSource.dispose()
    videoCapturer.dispose()
    surfaceTextureRenderer.dispose()
  }
}
