package com.cloudwebrtc.flutterflutterexample.flutter_webrtc_example;

import androidx.annotation.NonNull;

import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin;
import com.cloudwebrtc.webrtc.LocalTrack;
import com.cloudwebrtc.webrtc.video.LocalVideoTrack;

import org.webrtc.JavaI420Buffer;
import org.webrtc.VideoFrame;
import org.webrtc.YuvHelper;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Shows how an app or another native plugin can modify the frames of a
 * flutter_webrtc local video track on Android. It attaches a black and white
 * filter to a track through {@link LocalVideoTrack#addProcessor}.
 *
 * <p>The Android counterpart of cpp/video_processor_sample.cpp and
 * darwin/VideoProcessorSample.m. It handles the
 * "flutter_webrtc_example/video_processor" method channel:
 * <pre>
 *   setGrayscale({trackId, enabled})
 *   remove({trackId})
 * </pre>
 * See lib/src/video_processor_sample.dart for the Dart side.
 */
public class VideoProcessorSample implements MethodChannel.MethodCallHandler {

  /**
   * Removes the color of a frame: keeps the Y (luma) plane and sets both
   * chroma planes to 128, the neutral value, which gives a black and white
   * picture. onFrame runs on the capture thread while enabled is set from the
   * platform thread, hence the volatile.
   */
  static class GrayscaleProcessor implements LocalVideoTrack.ExternalVideoFrameProcessing {
    private volatile boolean enabled = false;
    // Neutral chroma plane, only touched on the capture thread.
    private byte[] chroma = new byte[0];

    void setEnabled(boolean enabled) {
      this.enabled = enabled;
    }

    @Override
    public VideoFrame onFrame(VideoFrame frame) {
      if (!enabled) return frame;

      // Camera frames usually come as textures; toI420 handles that and any
      // cropping or scaling.
      VideoFrame.I420Buffer src = frame.getBuffer().toI420();
      if (src == null) return frame;
      final int width = src.getWidth();
      final int height = src.getHeight();

      // The input frame must not be modified, so build a new one. The track
      // releases it once delivered.
      JavaI420Buffer dst = JavaI420Buffer.allocate(width, height);
      YuvHelper.copyPlane(src.getDataY(), src.getStrideY(), dst.getDataY(), dst.getStrideY(),
          width, height);
      src.release();

      final int chromaSize = dst.getStrideU() * ((height + 1) / 2);
      if (chroma.length != chromaSize) {
        chroma = new byte[chromaSize];
        Arrays.fill(chroma, (byte) 128);
      }
      dst.getDataU().put(chroma, 0, chromaSize);
      dst.getDataV().put(chroma, 0, chromaSize);

      return new VideoFrame(dst, frame.getRotation(), frame.getTimestampNs());
    }
  }

  private final MethodChannel channel;
  // Filters by track id. Only touched on the platform thread.
  private final Map<String, GrayscaleProcessor> processors = new HashMap<>();

  public VideoProcessorSample(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "flutter_webrtc_example/video_processor");
    channel.setMethodCallHandler(this);
  }

  /** Detaches every filter and stops handling the channel. */
  public void dispose() {
    channel.setMethodCallHandler(null);
    for (Map.Entry<String, GrayscaleProcessor> entry : processors.entrySet()) {
      LocalVideoTrack track = localVideoTrack(entry.getKey());
      if (track != null) track.removeProcessor(entry.getValue());
    }
    processors.clear();
  }

  /** Returns null if trackId is not a local video track of flutter_webrtc. */
  private static LocalVideoTrack localVideoTrack(String trackId) {
    FlutterWebRTCPlugin plugin = FlutterWebRTCPlugin.sharedSingleton;
    LocalTrack track = plugin != null ? plugin.getLocalTrack(trackId) : null;
    return track instanceof LocalVideoTrack ? (LocalVideoTrack) track : null;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    String trackId = call.argument("trackId");
    if (trackId == null) {
      result.error("bad_args", "trackId is required", null);
      return;
    }

    switch (call.method) {
      case "setGrayscale": {
        Boolean enabled = call.argument("enabled");
        if (enabled == null) {
          result.error("bad_args", "enabled is required", null);
          return;
        }
        GrayscaleProcessor processor = processors.get(trackId);
        if (processor == null) {
          LocalVideoTrack track = localVideoTrack(trackId);
          if (track == null) {
            result.error("no_track", "not a local video track of flutter_webrtc: " + trackId, null);
            return;
          }
          processor = new GrayscaleProcessor();
          track.addProcessor(processor);
          processors.put(trackId, processor);
        }
        processor.setEnabled(enabled);
        result.success(null);
        break;
      }
      case "remove": {
        GrayscaleProcessor processor = processors.remove(trackId);
        if (processor != null) {
          // The track is gone if it was disposed first, and the processor went
          // with it. Either way it is safe to drop it now.
          LocalVideoTrack track = localVideoTrack(trackId);
          if (track != null) track.removeProcessor(processor);
        }
        result.success(processor != null);
        break;
      }
      default:
        result.notImplemented();
    }
  }
}
