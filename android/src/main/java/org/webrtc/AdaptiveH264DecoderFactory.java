package org.webrtc;

import android.media.MediaCodecInfo;
import android.media.MediaCodecInfo.CodecCapabilities;
import android.media.MediaCodecList;
import android.os.Build;
import androidx.annotation.Nullable;

/** Uses adaptive playback for the SDK-selected H.264 hardware decoder in Surface mode. */
public final class AdaptiveH264DecoderFactory extends WrappedVideoDecoderFactory {
  private final @Nullable EglBase.Context sharedContext;
  private final HardwareVideoDecoderFactory hardwareFactory;
  private final VideoDecoderFactory softwareFactory;
  private final PlatformSoftwareVideoDecoderFactory platformSoftwareFactory;
  private final int preferredMaxWidth;
  private final int preferredMaxHeight;

  public AdaptiveH264DecoderFactory(@Nullable EglBase.Context sharedContext,
      VideoDecoderFactory softwareFactory, int preferredMaxWidth, int preferredMaxHeight) {
    super(sharedContext);
    this.sharedContext = sharedContext;
    this.softwareFactory = softwareFactory;
    this.hardwareFactory = new HardwareVideoDecoderFactory(sharedContext);
    this.platformSoftwareFactory = new PlatformSoftwareVideoDecoderFactory(sharedContext);
    this.preferredMaxWidth = preferredMaxWidth;
    this.preferredMaxHeight = preferredMaxHeight;
  }

  @Override
  @Nullable
  public VideoDecoder createDecoder(VideoCodecInfo codecInfo) {
    if (sharedContext == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q
        || !VideoCodecMimeType.H264.name().equals(codecInfo.name)) {
      return super.createDecoder(codecInfo);
    }

    // The SDK selects the codec here. No MediaCodec or Surface is allocated until initDecode().
    VideoDecoder hardwareDecoder = hardwareFactory.createDecoder(codecInfo);
    if (hardwareDecoder == null) {
      return super.createDecoder(codecInfo);
    }
    String codecName = hardwareDecoder.getImplementationName();
    if (!supportsAdaptiveSurface(codecName)) {
      return super.createDecoder(codecInfo);
    }

    VideoDecoder adaptive = new AdaptiveH264Decoder(new MediaCodecWrapperFactoryImpl(), codecName,
        sharedContext, preferredMaxWidth, preferredMaxHeight);
    // Match WrappedVideoDecoderFactory's fallback order.
    VideoDecoder fallback = softwareFactory.createDecoder(codecInfo);
    if (fallback == null) {
      fallback = platformSoftwareFactory.createDecoder(codecInfo);
    }
    return fallback == null ? adaptive : new VideoDecoderFallback(fallback, adaptive);
  }

  private static boolean supportsAdaptiveSurface(String codecName) {
    // WrappedVideoDecoderFactory uses byte-buffer output for these implementations.
    if (codecName.startsWith("OMX.qcom.") || codecName.startsWith("OMX.hisi.")) {
      return false;
    }
    try {
      for (MediaCodecInfo info : new MediaCodecList(MediaCodecList.ALL_CODECS).getCodecInfos()) {
        if (codecName.equals(info.getName())) {
          return supportsAdaptivePlayback(info);
        }
      }
    } catch (RuntimeException e) {
      Logging.w("AdaptiveH264DecoderFactory", "Cannot query codec " + codecName, e);
    }
    return false;
  }

  static boolean supportsAdaptivePlayback(MediaCodecInfo info) {
    return Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && info.isHardwareAccelerated()
        && info.getCapabilitiesForType(VideoCodecMimeType.H264.mimeType())
               .isFeatureSupported(CodecCapabilities.FEATURE_AdaptivePlayback);
  }
}
