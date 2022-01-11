package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.Map;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnectionFactory;

/**
 * Provides interested components with access to the current application state.
 *
 * <p>It is encouraged to use this class instead of a component directly.
 */
public interface StateProvider {

  @NonNull
  Map<String, MediaStream> getLocalStreams();

  String getNextStreamUUID();

  @Nullable
  MediaStreamTrack getLocalTrack(String id);

  @Nullable
  MediaStreamTrack getLocalTrack(String id);

  String getNextTrackUUID();

  PeerConnectionFactory getPeerConnectionFactory();

  @Nullable
  Activity getActivity();

  @Nullable
  Context getApplicationContext();
}
