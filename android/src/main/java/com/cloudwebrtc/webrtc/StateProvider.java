package com.cloudwebrtc.webrtc;

import android.app.Activity;
import androidx.annotation.Nullable;
import java.util.Map;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnectionFactory;

/**
 * Provides interested components with access to the current application state.
 *
 * It is encouraged to use this class instead of a component directly.
 */
public interface StateProvider {

  Map<String, MediaStream> getLocalStreams();

  Map<String, MediaStreamTrack> getLocalTracks();

  String getNextStreamUUID();

  String getNextTrackUUID();

  PeerConnectionFactory getPeerConnectionFactory();

  @Nullable
  Activity getActivity();
}
