package com.instrumentisto.medea_flutter_webrtc.proxy

/** Interface which can create new [MediaStreamTrackProxy]s from some media device. */
interface MediaTrackSource {
  /** Creates a new [MediaStreamTrackProxy] based on this [MediaTrackSource]. */
  fun newTrack(): MediaStreamTrackProxy
}
