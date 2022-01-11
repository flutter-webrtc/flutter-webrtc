package com.cloudwebrtc.webrtc.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;
import org.webrtc.IceCandidate;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.RtpParameters;
import org.webrtc.RtpReceiver;
import org.webrtc.RtpSender;
import org.webrtc.RtpTransceiver;
import org.webrtc.VideoTrack;

public final class ObjectExporter {
  @Nullable
  public static Map<String, Object> exportMediaStream(
      String ownerTag, @NonNull MediaStream stream) {
    ConstraintsMap params = new ConstraintsMap();
    params.putString("streamId", stream.getId());
    params.putString("ownerTag", ownerTag);
    ConstraintsArray audioTracks = new ConstraintsArray();
    ConstraintsArray videoTracks = new ConstraintsArray();

    for (MediaStreamTrack track : stream.audioTracks) {
      audioTracks.pushMap(new ConstraintsMap(exportMediaStreamTrack(track)));
    }

    for (MediaStreamTrack track : stream.videoTracks) {
      videoTracks.pushMap(new ConstraintsMap(exportMediaStreamTrack(track)));
    }

    params.putArray("audioTracks", audioTracks.toArrayList());
    params.putArray("videoTracks", videoTracks.toArrayList());
    return params.toMap();
  }

  @Nullable
  public static Map<String, Object> exportMediaStreamTrack(@Nullable MediaStreamTrack track) {
    ConstraintsMap info = new ConstraintsMap();
    if (track != null) {
      info.putString("id", track.id());
      info.putString("label", track.getClass() == VideoTrack.class ? "video" : "audio");
      info.putString("kind", track.kind());
      info.putBoolean("enabled", track.enabled());
      info.putString("readyState", track.state().toString());
    }
    return info.toMap();
  }

  public static Map<String, Object> exportRtpSender(@NonNull RtpSender sender) {
    ConstraintsMap info = new ConstraintsMap();
    info.putString("senderId", sender.id());
    info.putBoolean("ownsTrack", true);
    info.putMap("rtpParameters", exportRtpParameters(sender.getParameters()));
    info.putMap("track", exportMediaStreamTrack(sender.track()));
    return info.toMap();
  }

  public static Map<String, Object> exportRtpReceiver(@NonNull RtpReceiver receiver) {
    ConstraintsMap info = new ConstraintsMap();
    info.putString("receiverId", receiver.id());
    info.putMap("rtpParameters", exportRtpParameters(receiver.getParameters()));
    info.putMap("track", exportMediaStreamTrack(receiver.track()));
    return info.toMap();
  }

  public static Map<String, Object> exportTransceiver(int id, @NonNull RtpTransceiver transceiver) {
    ConstraintsMap info = new ConstraintsMap();
    info.putInt("transceiverId", id);
    info.putString("mid", transceiver.getMid());
    info.putString(
        "direction", EnumStringifier.transceiverDirectionString(transceiver.getDirection()));
    info.putMap("sender", exportRtpSender(transceiver.getSender()));
    info.putMap("receiver", exportRtpReceiver(transceiver.getReceiver()));
    return info.toMap();
  }

  public static Map<String, Object> exportIceCandidate(@NonNull IceCandidate candidate) {
    ConstraintsMap candidateParams = new ConstraintsMap();
    candidateParams.putInt("sdpMLineIndex", candidate.sdpMLineIndex);
    candidateParams.putString("sdpMid", candidate.sdpMid);
    candidateParams.putString("candidate", candidate.sdp);
    return candidateParams.toMap();
  }

  private static Map<String, Object> exportRtpParameters(@NonNull RtpParameters rtpParameters) {
    ConstraintsMap info = new ConstraintsMap();
    info.putString("transactionId", rtpParameters.transactionId);

    ConstraintsMap rtcp = new ConstraintsMap();
    rtcp.putString("cname", rtpParameters.getRtcp().getCname());
    rtcp.putBoolean("reducedSize", rtpParameters.getRtcp().getReducedSize());
    info.putMap("rtcp", rtcp.toMap());

    ConstraintsArray headerExtensions = new ConstraintsArray();
    for (RtpParameters.HeaderExtension extension : rtpParameters.getHeaderExtensions()) {
      ConstraintsMap map = new ConstraintsMap();
      map.putString("uri", extension.getUri());
      map.putInt("id", extension.getId());
      map.putBoolean("encrypted", extension.getEncrypted());
      headerExtensions.pushMap(map);
    }
    info.putArray("headerExtensions", headerExtensions.toArrayList());

    ConstraintsArray encodings = new ConstraintsArray();
    for (RtpParameters.Encoding encoding : rtpParameters.encodings) {
      ConstraintsMap map = new ConstraintsMap();
      map.putBoolean("active", encoding.active);
      if (encoding.maxBitrateBps != null) {
        map.putInt("maxBitrate", encoding.maxBitrateBps);
      }
      if (encoding.minBitrateBps != null) {
        map.putInt("minBitrate", encoding.minBitrateBps);
      }
      if (encoding.maxFramerate != null) {
        map.putInt("maxFramerate", encoding.maxFramerate);
      }
      if (encoding.numTemporalLayers != null) {
        map.putInt("numTemporalLayers", encoding.numTemporalLayers);
      }
      if (encoding.scaleResolutionDownBy != null) {
        map.putDouble("scaleResolutionDownBy", encoding.scaleResolutionDownBy);
      }
      if (encoding.ssrc != null) {
        map.putLong("ssrc", encoding.ssrc);
      }
      encodings.pushMap(map);
    }
    info.putArray("encodings", encodings.toArrayList());

    ConstraintsArray codecs = new ConstraintsArray();
    for (RtpParameters.Codec codec : rtpParameters.codecs) {
      ConstraintsMap map = new ConstraintsMap();
      map.putString("name", codec.name);
      map.putInt("payloadType", codec.payloadType);
      map.putInt("clockRate", codec.clockRate);
      if (codec.numChannels != null) {
        map.putInt("numChannels", codec.numChannels);
      }
      map.putMap("parameters", new HashMap<>(codec.parameters));
      try {
        Field field = codec.getClass().getDeclaredField("kind");
        field.setAccessible(true);
        if (field.get(codec).equals(MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO)) {
          map.putString("kind", "audio");
        } else if (field.get(codec).equals(MediaStreamTrack.MediaType.MEDIA_TYPE_VIDEO)) {
          map.putString("kind", "video");
        }
      } catch (@NonNull
          NoSuchFieldException
          | IllegalArgumentException
          | IllegalAccessException e) {
        e.printStackTrace();
      }
      codecs.pushMap(map);
    }

    info.putArray("codecs", codecs.toArrayList());
    return info.toMap();
  }
}
