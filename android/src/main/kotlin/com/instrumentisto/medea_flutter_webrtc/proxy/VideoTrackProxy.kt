package com.instrumentisto.medea_flutter_webrtc.proxy

import com.instrumentisto.medea_flutter_webrtc.SurfaceTextureRenderer
import org.webrtc.VideoTrack as WVideoTrack

/**
 * Wrapper around a [MediaStreamTrackProxy] with a video kind.
 *
 * @property track Underlying [MediaStreamTrackProxy] with a video kind.
 *
 * @throws Exception If the provided [MediaStreamTrackProxy] isn't a video.
 */
class VideoTrackProxy(private val track: MediaStreamTrackProxy) {
  /** Actual list of the added [SurfaceTextureRenderer]s. */
  private val sinks: MutableList<SurfaceTextureRenderer> = mutableListOf()

  init {
    if (track.obj !is WVideoTrack) {
      throw Exception("Provided not video MediaStreamTrack")
    }

    track.addOnSyncListener { renewSinks() }
  }

  /** Removes the specified [SurfaceTextureRenderer] from the underlying [WVideoTrack] sinks. */
  fun removeSink(sink: SurfaceTextureRenderer) {
    getVideoTrack().removeSink(sink)
    sinks.remove(sink)
  }

  /** Adds the specified [SurfaceTextureRenderer] to the underlying [WVideoTrack] sinks. */
  fun addSink(sink: SurfaceTextureRenderer) {
    getVideoTrack().addSink(sink)
    sinks.add(sink)
  }

  /** @return Underlying [WVideoTrack]. */
  private fun getVideoTrack(): WVideoTrack {
    return track.obj as WVideoTrack
  }

  /**
   * Adds every [SurfaceTextureRenderer] from the [sinks] to the updater underlying [WVideoTrack].
   */
  private fun renewSinks() {
    sinks.forEach { getVideoTrack().addSink(it) }
  }
}
