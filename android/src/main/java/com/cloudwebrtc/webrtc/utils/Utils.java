package com.cloudwebrtc.webrtc.utils;

import androidx.annotation.Nullable;

import org.webrtc.PeerConnection;

public class Utils {

  @Nullable
  static public String iceConnectionStateString(PeerConnection.IceConnectionState iceConnectionState) {
    switch (iceConnectionState) {
      case NEW:
        return "new";
      case CHECKING:
        return "checking";
      case CONNECTED:
        return "connected";
      case COMPLETED:
        return "completed";
      case FAILED:
        return "failed";
      case DISCONNECTED:
        return "disconnected";
      case CLOSED:
        return "closed";
    }
    return null;
  }

  @Nullable
  static public String iceGatheringStateString(PeerConnection.IceGatheringState iceGatheringState) {
    switch (iceGatheringState) {
      case NEW:
        return "new";
      case GATHERING:
        return "gathering";
      case COMPLETE:
        return "complete";
    }
    return null;
  }

  @Nullable
  static public String signalingStateString(PeerConnection.SignalingState signalingState) {
    switch (signalingState) {
      case STABLE:
        return "stable";
      case HAVE_LOCAL_OFFER:
        return "have-local-offer";
      case HAVE_LOCAL_PRANSWER:
        return "have-local-pranswer";
      case HAVE_REMOTE_OFFER:
        return "have-remote-offer";
      case HAVE_REMOTE_PRANSWER:
        return "have-remote-pranswer";
      case CLOSED:
        return "closed";
    }
    return null;
  }

  @Nullable
  static public String connectionStateString(PeerConnection.PeerConnectionState connectionState) {
    switch (connectionState) {
      case NEW:
        return "new";
      case CONNECTING:
        return "connecting";
      case CONNECTED:
        return "connected";
      case DISCONNECTED:
        return "disconnected";
      case FAILED:
        return "failed";
      case CLOSED:
        return "closed";
    }
    return null;
  }
}