package com.cloudwebrtc.webrtc.utils;

import androidx.annotation.NonNull;

import org.webrtc.PeerConnection;
import org.webrtc.RtpTransceiver;

public final class EnumStringifier {
  @NonNull
  public static String iceConnectionStateString(
          @NonNull PeerConnection.IceConnectionState state) {
    switch (state) {
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
      default:
        throw new IllegalArgumentException(String.format("Unknown variant %s", state));
    }
  }

  @NonNull
  public static String iceGatheringStateString(@NonNull PeerConnection.IceGatheringState state) {
    switch (state) {
      case NEW:
        return "new";
      case GATHERING:
        return "gathering";
      case COMPLETE:
        return "complete";
      default:
        throw new IllegalArgumentException(String.format("Unknown variant %s", state));
    }
  }

  @NonNull
  public static String signalingStateString(@NonNull PeerConnection.SignalingState state) {
    switch (state) {
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
      default:
        throw new IllegalArgumentException(String.format("Unknown variant %s", state));
    }
  }

  @NonNull
  public static String connectionStateString(@NonNull PeerConnection.PeerConnectionState state) {
    switch (state) {
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
      default:
        throw new IllegalArgumentException(String.format("Unknown variant %s", state));
    }
  }

  @NonNull
  public static String transceiverDirectionString(
          @NonNull RtpTransceiver.RtpTransceiverDirection direction) {
    switch (direction) {
      case SEND_RECV:
        return "sendrecv";
      case SEND_ONLY:
        return "sendonly";
      case RECV_ONLY:
        return "recvonly";
      case INACTIVE:
        return "inactive";
      default:
        throw new IllegalArgumentException(String.format("Unknown variant %s", direction));
    }
  }

  @NonNull
  public static RtpTransceiver.RtpTransceiverDirection stringToTransceiverDirection(
          @NonNull String direction) {
    switch (direction) {
      case "sendrecv":
        return RtpTransceiver.RtpTransceiverDirection.SEND_RECV;
      case "sendonly":
        return RtpTransceiver.RtpTransceiverDirection.SEND_ONLY;
      case "recvonly":
        return RtpTransceiver.RtpTransceiverDirection.RECV_ONLY;
      default:
        return RtpTransceiver.RtpTransceiverDirection.INACTIVE;
    }
  }
}
