package com.instrumentisto.medea_flutter_webrtc.proxy

import android.util.Log
import com.instrumentisto.medea_flutter_webrtc.TrackRepository
import com.instrumentisto.medea_flutter_webrtc.model.FacingMode
import com.instrumentisto.medea_flutter_webrtc.model.MediaStreamTrackState
import com.instrumentisto.medea_flutter_webrtc.model.MediaType
import kotlinx.coroutines.CompletableDeferred
import org.webrtc.MediaStreamTrack
import org.webrtc.VideoSink
import org.webrtc.VideoTrack

private val TAG = MediaStreamTrackProxy::class.java.simpleName

/**
 * Wrapper around a [MediaStreamTrack].
 *
 * @param track Underlying [MediaStreamTrack].
 * @property deviceId Unique ID of device on which this [MediaStreamTrackProxy] is based.
 * @property source [MediaTrackSource] from which this [MediaStreamTrackProxy] is created. `null`
 * for [MediaStreamTrackProxy]s received from the remote side.
 */
class MediaStreamTrackProxy(
    track: MediaStreamTrack,
    val facingMode: FacingMode? = null,
    val deviceId: String = "remote",
    private val source: MediaTrackSource? = null
) : Proxy<MediaStreamTrack>(track) {
  /**
   * Subscribers for the [onStop] callback.
   *
   * Will be called once on a [stop] call.
   */
  private var onStopSubscribers: MutableList<() -> Unit> = mutableListOf()

  /** Indicates that this [stop] was called on this [MediaStreamTrackProxy]. */
  private var isStopped: Boolean = false

  /** List of [EventObserver]s belonging to this [MediaStreamTrackProxy]. */
  private var eventObservers: HashSet<EventObserver> = HashSet()

  /** Indicator whether the underlying [MediaStreamTrack] had been disposed. */
  private var disposed: Boolean = false

  /** [VideoSink] that tracks height and width changes. */
  private var sink: VideoSink? = null

  /** Provides asynchronous wait for [width] and [height] initialization. */
  private val fetchDimensions = CompletableDeferred<Unit>()

  /** Video width */
  @Volatile private var width: Int = 0

  /** Video height */
  @Volatile private var height: Int = 0

  /** [MediaType] of the underlying [MediaStreamTrack]. */
  val kind: MediaType =
      when (obj.kind()) {
        MediaStreamTrack.VIDEO_TRACK_KIND -> MediaType.VIDEO
        MediaStreamTrack.AUDIO_TRACK_KIND -> MediaType.AUDIO
        else -> throw Exception("LibWebRTC provided unknown MediaType value")
      }

  /** ID of the underlying [MediaStreamTrack] */
  val id: String = obj.id()

  /** [MediaStreamTrackState] of the underlying [MediaStreamTrack]. */
  var state: MediaStreamTrackState = MediaStreamTrackState.LIVE
    get() {
      field =
          if (disposed) {
            MediaStreamTrackState.ENDED
          } else {
            MediaStreamTrackState.fromWebRtcState(obj.state())
          }

      return field
    }

  init {
    TrackRepository.addTrack(this)

    if (kind == MediaType.VIDEO) {
      sink = VideoSink { frame ->
        width = frame.buffer.width
        height = frame.buffer.height
        fetchDimensions.complete(Unit)
      }
      (obj as VideoTrack).addSink(sink)

      addOnSyncListener { (obj as VideoTrack).addSink(sink) }
    }
  }

  /** Returns the video [width] of the track. */
  suspend fun width(): Int? {
    if (kind == MediaType.AUDIO) {
      return null
    }

    fetchDimensions.await()
    return width
  }

  /** Returns the video [height] of the track. */
  suspend fun height(): Int? {
    if (kind == MediaType.AUDIO) {
      return null
    }
    fetchDimensions.await()
    return height
  }

  /** Sets the [disposed] property to `true`. */
  fun setDisposed() {
    disposed = true
  }

  companion object {
    /** Observer of [MediaStreamTrackProxy] events. */
    interface EventObserver {
      fun onEnded()
    }
  }

  /**
   * Creates a broadcaster to all the [eventObservers] of this [MediaStreamTrackProxy].
   *
   * @return [EventObserver] broadcasting calls to all the [eventObservers].
   */
  fun observableEventBroadcaster(): EventObserver {
    return object : EventObserver {
      override fun onEnded() {
        eventObservers.forEach { it.onEnded() }
        eventObservers.clear()
      }
    }
  }

  /**
   * Adds the specified [EventObserver] to this [MediaStreamTrackProxy].
   *
   * @param eventObserver [EventObserver] to be subscribed.
   */
  fun addEventObserver(eventObserver: EventObserver) {
    eventObservers.add(eventObserver)
  }

  /**
   * Removes the specified [EventObserver] from the list of [EventObserver]s.
   *
   * @param eventObserver [EventObserver] to be removed.
   */
  fun removeEventObserver(eventObserver: EventObserver) {
    eventObservers.remove(eventObserver)
  }

  /**
   * Creates a new [MediaStreamTrackProxy] based on the same [MediaTrackSource] as this
   * [MediaStreamTrackProxy].
   *
   * Can be called only on local [MediaStreamTrackProxy]s.
   *
   * @throws Exception If called on a remote [MediaStreamTrackProxy].
   *
   * @return Created [MediaStreamTrackProxy].
   */
  fun fork(): MediaStreamTrackProxy {
    if (this.source == null) {
      throw Exception("Remote MediaStreamTracks can't be cloned")
    } else {
      return source.newTrack()
    }
  }

  /**
   * Stops this [MediaStreamTrackProxy].
   *
   * Media source will be disposed only if there is no another [MediaStreamTrackProxy] depending on
   * a [MediaTrackSource].
   */
  fun stop() {
    if (!isStopped) {
      isStopped = true
      onStopSubscribers.forEach { sub -> sub() }
      onStopSubscribers.clear()
      if (sink != null) {
        (obj as VideoTrack).removeSink(sink)
        sink = null
      }
    } else {
      Log.w(TAG, "Double stop detected [deviceId: $deviceId]!")
    }
  }

  /**
   * Sets enabled state of the underlying [MediaStreamTrack]. Does nothing if the underlying
   * [MediaStreamTrack] has been [disposed].
   *
   * @param enabled State which will be set to the underlying [MediaStreamTrack].
   */
  fun setEnabled(enabled: Boolean) {
    if (disposed) {
      return
    }

    obj.setEnabled(enabled)
  }

  /**
   * Subscribes to the [stop] event of this [MediaStreamTrackProxy].
   *
   * This callback is guaranteed to be called only once.
   */
  fun onStop(f: () -> Unit) {
    onStopSubscribers.add(f)
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (javaClass != other?.javaClass) return false

    other as MediaStreamTrackProxy

    if (id != other.id) return false

    return true
  }

  override fun hashCode(): Int {
    return id.hashCode()
  }
}
