package com.cloudwebrtc.webrtc.proxy

import android.util.Log
import com.cloudwebrtc.webrtc.TrackRepository
import com.cloudwebrtc.webrtc.model.MediaStreamTrackState
import com.cloudwebrtc.webrtc.model.MediaType
import org.webrtc.MediaStreamTrack

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
    private val deviceId: String = "remote",
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

  init {
    TrackRepository.addTrack(this)
  }

  companion object {
    /** Observer of [MediaStreamTrackProxy] events. */
    interface EventObserver {
      fun onEnded()
    }
  }

  /**
   * Returns ID of the underlying [MediaStreamTrack].
   *
   * @return ID of the underlying [MediaStreamTrack].
   */
  fun id(): String {
    return obj.id()
  }

  /** @return [MediaType] of the underlying [MediaStreamTrack]. */
  fun kind(): MediaType {
    return when (obj.kind()) {
      MediaStreamTrack.VIDEO_TRACK_KIND -> MediaType.VIDEO
      MediaStreamTrack.AUDIO_TRACK_KIND -> MediaType.AUDIO
      else -> throw Exception("LibWebRTC provided unknown MediaType value")
    }
  }

  /** @return Unique device ID of the underlying [MediaStreamTrack]. */
  fun deviceId(): String {
    return deviceId
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
    } else {
      Log.w("FlutterWebRTC", "Double stop detected [deviceId: $deviceId]!")
    }
  }

  /** @return [MediaStreamTrackState] of the underlying [MediaStreamTrack]. */
  fun state(): MediaStreamTrackState {
    return MediaStreamTrackState.fromWebRtcState(obj.state())
  }

  /**
   * Sets enabled state of the underlying [MediaStreamTrack].
   *
   * @param enabled State which will be set to the underlying [MediaStreamTrack].
   */
  fun setEnabled(enabled: Boolean) {
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
}
