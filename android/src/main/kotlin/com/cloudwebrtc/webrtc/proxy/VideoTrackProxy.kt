package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.SurfaceTextureRenderer
import org.webrtc.VideoTrack as WVideoTrack

/**
 * Wrapper around a [MediaStreamTrackProxy] with a video kind.
 *
 * @property track  Underlying [MediaStreamTrackProxy] with a video kind.
 *
 * @throws Exception  If the provided [MediaStreamTrackProxy] isn't a video.
 */
class VideoTrackProxy(private val track: MediaStreamTrackProxy) {
    init {
        if (track.obj !is WVideoTrack) {
            throw Exception("Provided not video MediaStreamTrack")
        }
    }

    /**
     * Removes the specified [SurfaceTextureRenderer] from the underlying
     * [WVideoTrack] sinks.
     */
    fun removeSink(sink: SurfaceTextureRenderer) {
        getVideoTrack().removeSink(sink)
    }

    /**
     * Adds the specified [SurfaceTextureRenderer] to the underlying
     * [WVideoTrack] sinks.
     */
    fun addSink(sink: SurfaceTextureRenderer) {
        getVideoTrack().addSink(sink)
    }

    /**
     * @return  Underlying [WVideoTrack].
     */
    private fun getVideoTrack(): WVideoTrack {
        return track.obj as WVideoTrack
    }
}
