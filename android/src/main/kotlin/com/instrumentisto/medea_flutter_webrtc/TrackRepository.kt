package com.instrumentisto.medea_flutter_webrtc

import com.instrumentisto.medea_flutter_webrtc.proxy.MediaStreamTrackProxy
import java.lang.ref.WeakReference

/**
 * Repository for all the [MediaStreamTrackProxy]s.
 *
 * All created in the `flutter_webrtc` [MediaStreamTrackProxy]s will be stored here under weak
 * references. So if, a [MediaStreamTrackProxy] is disposed, then it will be `null` here.
 */
object TrackRepository {
  /** All [MediaStreamTrackProxy]s created in `flutter_webrtc`. */
  private val tracks: HashMap<String, WeakReference<MediaStreamTrackProxy>> = HashMap()

  /**
   * Adds a new [MediaStreamTrackProxy].
   *
   * @param track Actual [MediaStreamTrackProxy] which will be stored here.
   */
  fun addTrack(track: MediaStreamTrackProxy) {
    tracks[track.id] = WeakReference(track)
  }

  /**
   * Lookups [MediaStreamTrackProxy] with the provided unique ID.
   *
   * @param id Unique [MediaStreamTrackProxy] to perform the lookup via.
   *
   * @return Found [MediaStreamTrackProxy] with the provided ID, or `null` if the
   * [MediaStreamTrackProxy] isn't found or was disposed.
   */
  fun getTrack(id: String): MediaStreamTrackProxy? {
    return tracks[id]?.get()
  }
}
