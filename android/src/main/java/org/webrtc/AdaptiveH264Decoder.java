/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Based on AndroidVideoDecoder from the WebRTC project. The BSD-style
 *  license and patent grant are in Android resources META-INF/webrtc-sdk.
 */

package org.webrtc;

import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCodecInfo.VideoCapabilities;
import android.media.MediaFormat;
import android.os.SystemClock;
import android.util.Log;
import android.view.Surface;
import androidx.annotation.Nullable;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.concurrent.BlockingDeque;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.TimeUnit;
import org.webrtc.ThreadUtils.ThreadChecker;

/**
 * Surface-only H.264 decoder for switching input resolutions on one MediaCodec instance.
 */
final class AdaptiveH264Decoder implements VideoDecoder, VideoSink {
  private static final String TAG = "AdaptiveH264Decoder";
  static final String MIME_TYPE = "video/avc";

  // MediaCodec.release() occasionally hangs.  Release stops waiting and reports failure after
  // this timeout.
  private static final int MEDIA_CODEC_RELEASE_TIMEOUT_MS = 5000;

  // WebRTC queues input frames quickly in the beginning on the call. Wait for input buffers with a
  // long timeout (500 ms) to prevent this from causing the codec to return an error.
  private static final int DEQUEUE_INPUT_TIMEOUT_US = 500000;

  // Dequeuing an output buffer will block until a buffer is available (up to 100 milliseconds).
  // If this timeout is exceeded, the output thread will unblock and check if the decoder is still
  // running.  If it is, it will block on dequeue again.  Otherwise, it will stop and release the
  // MediaCodec.
  private static final int DEQUEUE_OUTPUT_BUFFER_TIMEOUT_US = 100000;

  private final MediaCodecWrapperFactory mediaCodecWrapperFactory;
  private final String codecName;
  private final int preferredMaxWidth;
  private final int preferredMaxHeight;

  private static class FrameInfo {
    final long decodeStartTimeMs;
    final int rotation;

    FrameInfo(long decodeStartTimeMs, int rotation) {
      this.decodeStartTimeMs = decodeStartTimeMs;
      this.rotation = rotation;
    }
  }

  private final BlockingDeque<FrameInfo> frameInfos;
  // Set before starting the output thread. Its per-frame state is synchronized.
  @Nullable private AdaptiveResolution adaptive;
  private boolean adaptiveDisabled;

  // Output thread runs a loop which polls MediaCodec for decoded output buffers.  It reformats
  // those buffers into VideoFrames and delivers them to the callback.  Variable is set on decoder
  // thread and is immutable while the codec is running.
  @Nullable private Thread outputThread;

  // Checker that ensures work is run on the output thread.
  private ThreadChecker outputThreadChecker;

  // Checker that ensures work is run on the decoder thread.  The decoder thread is owned by the
  // caller and must be used to call initDecode, decode, and release.
  private ThreadChecker decoderThreadChecker;

  private volatile boolean running;
  @Nullable private volatile Exception shutdownException;

  // Decoder input and output threads share the current output dimensions.
  private final Object dimensionLock = new Object();
  private int width;
  private int height;

  // A non-adaptive codec may only change output dimensions before its first frame.
  // Only accessed on the output thread while the decoder is running.
  private boolean hasDecodedFirstFrame;
  // Whether the decoder has seen a key frame.  The first frame must be a key frame.  Only accessed
  // on the decoder thread.
  private boolean keyFrameRequired;

  private final EglBase.Context sharedContext;
  // Valid and immutable while the decoder is running.
  @Nullable private SurfaceTextureHelper surfaceTextureHelper;
  @Nullable private Surface surface;

  private static class DecodedTextureMetadata {
    final long presentationTimestampUs;
    final Integer decodeTimeMs;

    DecodedTextureMetadata(long presentationTimestampUs, Integer decodeTimeMs) {
      this.presentationTimestampUs = presentationTimestampUs;
      this.decodeTimeMs = decodeTimeMs;
    }
  }

  // Metadata for the last frame rendered to the texture.
  private final Object renderedTextureMetadataLock = new Object();
  @Nullable private DecodedTextureMetadata renderedTextureMetadata;

  // Decoding proceeds asynchronously.  This callback returns decoded frames to the caller.  Valid
  // and immutable while the decoder is running.
  @Nullable private Callback callback;

  // Valid and immutable while the decoder is running.
  @Nullable private MediaCodecWrapper codec;

  AdaptiveH264Decoder(MediaCodecWrapperFactory mediaCodecWrapperFactory, String codecName,
      EglBase.Context sharedContext, int preferredMaxWidth, int preferredMaxHeight) {
    this.preferredMaxWidth = preferredMaxWidth;
    this.preferredMaxHeight = preferredMaxHeight;
    this.mediaCodecWrapperFactory = mediaCodecWrapperFactory;
    this.codecName = codecName;
    this.sharedContext = sharedContext;
    this.frameInfos = new LinkedBlockingDeque<>();
  }

  @Override
  public VideoCodecStatus initDecode(Settings settings, Callback callback) {
    if (surfaceTextureHelper != null || outputThread != null) {
      Logging.e(TAG, "initDecode called before the previous decoder was released");
      return VideoCodecStatus.FALLBACK_SOFTWARE;
    }
    decoderThreadChecker = new ThreadChecker();
    this.callback = callback;
    adaptiveDisabled = false;
    surfaceTextureHelper = SurfaceTextureHelper.create("decoder-texture-thread", sharedContext);
    if (surfaceTextureHelper == null) {
      this.callback = null;
      return VideoCodecStatus.FALLBACK_SOFTWARE;
    }
    surface = new Surface(surfaceTextureHelper.getSurfaceTexture());
    surfaceTextureHelper.startListening(this);
    VideoCodecStatus status = initDecodeInternal(settings.width, settings.height);
    if (status != VideoCodecStatus.OK) {
      release();
    }
    return status;
  }

  @Nullable
  private AdaptiveResolution adaptiveConfiguration(int width, int height) {
    if (adaptiveDisabled) return null;
    try {
      MediaCodecInfo info = codec.getCodecInfo();
      if (!AdaptiveH264DecoderFactory.supportsAdaptivePlayback(info)) return null;
      VideoCapabilities sizes = info.getCapabilitiesForType(MIME_TYPE).getVideoCapabilities();
      return AdaptiveResolution.create(width, height, preferredMaxWidth, preferredMaxHeight,
          (w, h) -> {
            try {
              return sizes.isSizeSupported(w, h);
            } catch (RuntimeException e) {
              Logging.w(TAG, "Cannot query decoder size " + w + "x" + h, e);
              return false;
            }
          });
    } catch (RuntimeException e) {
      Logging.w(TAG, "Cannot query decoder capabilities", e);
      return null;
    }
  }

  // Internal variant is used when restarting the codec due to reconfiguration.
  private VideoCodecStatus initDecodeInternal(int width, int height) {
    decoderThreadChecker.checkIsOnValidThread();
    if (outputThread != null) {
      Logging.e(TAG, "initDecodeInternal called while the codec is already running");
      return VideoCodecStatus.FALLBACK_SOFTWARE;
    }

    // Note:  it is not necessary to initialize dimensions under the lock, since the output thread
    // is not running.
    this.width = width;
    this.height = height;

    hasDecodedFirstFrame = false;
    keyFrameRequired = true;

    try {
      codec = mediaCodecWrapperFactory.createByCodecName(codecName);
    } catch (IOException | IllegalArgumentException | IllegalStateException e) {
      Logging.e(TAG, "Cannot create media decoder " + codecName);
      return VideoCodecStatus.FALLBACK_SOFTWARE;
    }
    try {
      MediaFormat format = MediaFormat.createVideoFormat(MIME_TYPE, width, height);
      adaptive = adaptiveConfiguration(width, height);
      if (adaptive != null) {
        format.setInteger(MediaFormat.KEY_MAX_WIDTH, adaptive.maxWidth);
        format.setInteger(MediaFormat.KEY_MAX_HEIGHT, adaptive.maxHeight);
      }
      codec.configure(format, surface, null, 0);
      codec.start();
    } catch (IllegalStateException | IllegalArgumentException e) {
      boolean retryWithoutAdaptation = adaptive != null;
      adaptive = null;
      try {
        codec.release();
      } catch (RuntimeException releaseError) {
        Logging.e(TAG, "Release of unstarted codec failed", releaseError);
      }
      codec = null;
      if (retryWithoutAdaptation) {
        Log.w(TAG, "Adaptive configure failed; retrying stock configuration", e);
        adaptiveDisabled = true;
        return initDecodeInternal(width, height);
      }
      Logging.e(TAG, "initDecode failed", e);
      return VideoCodecStatus.FALLBACK_SOFTWARE;
    }
    Log.i(TAG, "start codec=" + codecName + " size=" + width + "x" + height
        + " adaptive=" + (adaptive != null));
    running = true;
    outputThread = createOutputThread(codec);
    outputThread.start();

    Logging.d(TAG, "initDecodeInternal done");
    return VideoCodecStatus.OK;
  }

  @Override
  public VideoCodecStatus decode(EncodedImage frame, DecodeInfo info) {
    if (codec == null || callback == null) {
      return VideoCodecStatus.UNINITIALIZED;
    }
    decoderThreadChecker.checkIsOnValidThread();
    if (!running) {
      return VideoCodecStatus.FALLBACK_SOFTWARE;
    }

    if (frame.buffer == null) {
      Logging.e(TAG, "decode() - no input data");
      return VideoCodecStatus.ERR_PARAMETER;
    }

    int size = frame.buffer.remaining();
    if (size == 0) {
      Logging.e(TAG, "decode() - input buffer empty");
      return VideoCodecStatus.ERR_PARAMETER;
    }

    // Load dimensions from shared memory under the dimension lock.
    final int width;
    final int height;
    synchronized (dimensionLock) {
      width = this.width;
      height = this.height;
    }

    // Check if the resolution changed and reset the codec if necessary.
    if (adaptive != null) {
      AdaptiveResolution.Input decision = adaptive.input(frame.encodedWidth, frame.encodedHeight,
          frame.frameType == EncodedImage.FrameType.VideoFrameKey, SystemClock.elapsedRealtime());
      if (decision == AdaptiveResolution.Input.RECONFIGURE) {
        VideoCodecStatus status = reinitDecode(frame.encodedWidth, frame.encodedHeight);
        if (status != VideoCodecStatus.OK) return status;
      } else if (decision == AdaptiveResolution.Input.RECOVER
          || (decision == AdaptiveResolution.Input.SWITCH
              && !AdaptiveResolution.hasConfigAndIdr(frame.buffer))) {
        return reopenWithoutAdaptation(frame, info);
      }
    } else if (frame.encodedWidth > 0 && frame.encodedHeight > 0
        && (frame.encodedWidth != width || frame.encodedHeight != height)) {
      VideoCodecStatus status = reinitDecode(frame.encodedWidth, frame.encodedHeight);
      if (status != VideoCodecStatus.OK) {
        return status;
      }
    }

    if (keyFrameRequired) {
      // Need to process a key frame first.
      if (frame.frameType != EncodedImage.FrameType.VideoFrameKey) {
        Logging.e(TAG, "decode() - key frame required first");
        return VideoCodecStatus.NO_OUTPUT;
      }
    }

    int index;
    try {
      index = codec.dequeueInputBuffer(DEQUEUE_INPUT_TIMEOUT_US);
    } catch (IllegalStateException e) {
      Logging.e(TAG, "dequeueInputBuffer failed", e);
      return adaptive != null && adaptive.switchingOrFailed()
          ? reopenWithoutAdaptation(frame, info) : VideoCodecStatus.ERROR;
    }
    if (index < 0) {
      // Decoder is falling behind.  No input buffers available.
      // The decoder can't simply drop frames; it might lose a key frame.
      Logging.e(TAG, "decode() - no HW buffers available; decoder falling behind");
      return adaptive != null && adaptive.switchingOrFailed()
          ? reopenWithoutAdaptation(frame, info) : VideoCodecStatus.ERROR;
    }

    ByteBuffer buffer;
    try {
      buffer = codec.getInputBuffer(index);
    } catch (IllegalStateException e) {
      Logging.e(TAG, "getInputBuffer with index=" + index + " failed", e);
      return adaptive != null && adaptive.switchingOrFailed()
          ? reopenWithoutAdaptation(frame, info) : VideoCodecStatus.ERROR;
    }

    if (buffer.capacity() < size) {
      Logging.e(TAG, "decode() - HW buffer too small");
      return adaptive != null && adaptive.switchingOrFailed()
          ? reopenWithoutAdaptation(frame, info) : VideoCodecStatus.ERROR;
    }
    // Preserve the original access unit for a one-time retry on an adaptive codec error.
    buffer.put(adaptive == null ? frame.buffer : frame.buffer.duplicate());

    frameInfos.offer(new FrameInfo(SystemClock.elapsedRealtime(), frame.rotation));
    try {
      codec.queueInputBuffer(index, 0 /* offset */, size,
          TimeUnit.NANOSECONDS.toMicros(frame.captureTimeNs), 0 /* flags */);
    } catch (IllegalStateException e) {
      Logging.e(TAG, "queueInputBuffer failed", e);
      frameInfos.pollLast();
      return adaptive != null && adaptive.switchingOrFailed()
          ? reopenWithoutAdaptation(frame, info) : VideoCodecStatus.ERROR;
    }
    if (keyFrameRequired) {
      keyFrameRequired = false;
    }
    return VideoCodecStatus.OK;
  }

  private VideoCodecStatus reopenWithoutAdaptation(EncodedImage frame, DecodeInfo info) {
    adaptiveDisabled = true;
    boolean hasFrameSize = frame.encodedWidth > 0 && frame.encodedHeight > 0;
    int width = hasFrameSize ? frame.encodedWidth : adaptive.inputWidth();
    int height = hasFrameSize ? frame.encodedHeight : adaptive.inputHeight();
    Log.w(TAG, "fallback to stock size=" + width + "x" + height);
    VideoCodecStatus result = reinitDecode(width, height);
    return result == VideoCodecStatus.OK ? decode(frame, info) : result;
  }

  @Override
  public String getImplementationName() {
    return codecName;
  }

  @Override
  public VideoCodecStatus release() {
    // TODO(sakal): This is not called on the correct thread but is still called synchronously.
    // Re-enable the check once this is called on the correct thread.
    // decoderThreadChecker.checkIsOnValidThread();
    Logging.d(TAG, "release");
    VideoCodecStatus status = releaseInternal();
    if (surface != null) {
      surface.release();
      surface = null;
      surfaceTextureHelper.stopListening();
      surfaceTextureHelper.dispose();
      surfaceTextureHelper = null;
    }
    synchronized (renderedTextureMetadataLock) {
      renderedTextureMetadata = null;
    }
    callback = null;
    return status;
  }

  // Internal variant is used when restarting the codec due to reconfiguration.
  private VideoCodecStatus releaseInternal() {
    if (outputThread == null) {
      Logging.d(TAG, "release: Decoder is not running.");
      return VideoCodecStatus.OK;
    }
    // The output thread owns stop and release. Retain the thread on timeout so another
    // configuration cannot start while the previous codec is still being released.
    running = false;
    if (adaptive != null) {
      adaptive.requestRelease();
    }
    if (!ThreadUtils.joinUninterruptibly(outputThread, MEDIA_CODEC_RELEASE_TIMEOUT_MS)) {
      Logging.e(TAG, "Media decoder release timeout");
      return VideoCodecStatus.TIMEOUT;
    }
    codec = null;
    outputThread = null;
    adaptive = null;
    frameInfos.clear();
    if (shutdownException != null) {
      Logging.e(TAG, "Media decoder release error", shutdownException);
      shutdownException = null;
      return VideoCodecStatus.ERROR;
    }
    return VideoCodecStatus.OK;
  }

  private VideoCodecStatus reinitDecode(int newWidth, int newHeight) {
    decoderThreadChecker.checkIsOnValidThread();
    VideoCodecStatus status = releaseInternal();
    if (status != VideoCodecStatus.OK) {
      return status;
    }
    return initDecodeInternal(newWidth, newHeight);
  }

  private Thread createOutputThread(MediaCodecWrapper outputCodec) {
    return new Thread("AdaptiveH264Decoder.outputThread") {
      @Override
      public void run() {
        outputThreadChecker = new ThreadChecker();
        while (running) {
          deliverDecodedFrame(outputCodec);
        }
        releaseCodecOnOutputThread(outputCodec);
      }
    };
  }

  private void deliverDecodedFrame(MediaCodecWrapper outputCodec) {
    outputThreadChecker.checkIsOnValidThread();
    try {
      MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
      // Block until an output buffer is available (up to 100 milliseconds).  If the timeout is
      // exceeded, deliverDecodedFrame() will be called again on the next iteration of the output
      // thread's loop.  Blocking here prevents the output thread from busy-waiting while the codec
      // is idle.
      int index = outputCodec.dequeueOutputBuffer(info, DEQUEUE_OUTPUT_BUFFER_TIMEOUT_US);
      if (!running) {
        return;
      }
      if (index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
        reformat(outputCodec.getOutputFormat());
        return;
      }

      if (index < 0) {
        Logging.v(TAG, "dequeueOutputBuffer returned " + index);
        return;
      }

      FrameInfo frameInfo = frameInfos.poll();
      Integer decodeTimeMs = null;
      int rotation = 0;
      if (frameInfo != null) {
        decodeTimeMs = (int) (SystemClock.elapsedRealtime() - frameInfo.decodeStartTimeMs);
        rotation = frameInfo.rotation;
      }

      if (adaptive != null && adaptive.failed()) {
        outputCodec.releaseOutputBuffer(index, false);
        return;
      }
      hasDecodedFirstFrame = true;

      deliverTextureFrame(outputCodec, index, info, rotation, decodeTimeMs);

    } catch (IllegalStateException e) {
      Logging.e(TAG, "deliverDecodedFrame failed", e);
      if (adaptive != null) {
        adaptive.awaitReleaseOnOutputError();
      } else {
        stopOnOutputThread(e);
      }
    }
  }

  private void deliverTextureFrame(MediaCodecWrapper outputCodec, int index,
      MediaCodec.BufferInfo info, int rotation, @Nullable Integer decodeTimeMs) {
    // Load dimensions from shared memory under the dimension lock.
    final int width;
    final int height;
    synchronized (dimensionLock) {
      width = this.width;
      height = this.height;
    }

    synchronized (renderedTextureMetadataLock) {
      if (!running || renderedTextureMetadata != null) {
        outputCodec.releaseOutputBuffer(index, false);
        return; // We are still waiting for texture for the previous frame, drop this one.
      }
      surfaceTextureHelper.setTextureSize(width, height);
      surfaceTextureHelper.setFrameRotation(rotation);
      renderedTextureMetadata = new DecodedTextureMetadata(info.presentationTimeUs, decodeTimeMs);
      outputCodec.releaseOutputBuffer(index, /* render= */ true);
    }
  }

  @Override
  public void onFrame(VideoFrame frame) {
    final Integer decodeTimeMs;
    final long timestampNs;
    synchronized (renderedTextureMetadataLock) {
      if (renderedTextureMetadata == null) {
        throw new IllegalStateException(
            "Rendered texture metadata was null in onTextureFrameAvailable.");
      }
      timestampNs = renderedTextureMetadata.presentationTimestampUs * 1000;
      decodeTimeMs = renderedTextureMetadata.decodeTimeMs;
      renderedTextureMetadata = null;
    }
    // Change timestamp of frame.
    final VideoFrame frameWithModifiedTimeStamp =
        new VideoFrame(frame.getBuffer(), frame.getRotation(), timestampNs);
    callback.onDecodedFrame(frameWithModifiedTimeStamp, decodeTimeMs, null /* qp */);
  }

  private void reformat(MediaFormat format) {
    outputThreadChecker.checkIsOnValidThread();
    Logging.d(TAG, "Decoder format changed: " + format);
    final int newWidth;
    final int newHeight;
    if (format.containsKey(MediaFormat.KEY_CROP_LEFT)
        && format.containsKey(MediaFormat.KEY_CROP_RIGHT)
        && format.containsKey(MediaFormat.KEY_CROP_BOTTOM)
        && format.containsKey(MediaFormat.KEY_CROP_TOP)) {
      newWidth = 1 + format.getInteger(MediaFormat.KEY_CROP_RIGHT)
          - format.getInteger(MediaFormat.KEY_CROP_LEFT);
      newHeight = 1 + format.getInteger(MediaFormat.KEY_CROP_BOTTOM)
          - format.getInteger(MediaFormat.KEY_CROP_TOP);
    } else {
      newWidth = format.getInteger(MediaFormat.KEY_WIDTH);
      newHeight = format.getInteger(MediaFormat.KEY_HEIGHT);
    }
    // Compare to existing width, height, and save values under the dimension lock.
    synchronized (dimensionLock) {
      if (adaptive != null && !adaptive.output(newWidth, newHeight)) {
        Log.w(TAG, "unexpected output=" + newWidth + "x" + newHeight);
        return; // Decode thread owns recovery and tears down the codec on the next input.
      }
      if (newWidth != width || newHeight != height) {
        if (adaptive != null) {
          Log.i(TAG, "output=" + newWidth + "x" + newHeight);
        } else if (hasDecodedFirstFrame) {
          stopOnOutputThread(new RuntimeException("Unexpected size change. "
              + "Configured " + width + "*" + height + ". "
              + "New " + newWidth + "*" + newHeight));
          return;
        } else if (newWidth <= 0 || newHeight <= 0) {
          Logging.w(TAG,
              "Unexpected format dimensions. Configured " + width + "*" + height + ". "
                  + "New " + newWidth + "*" + newHeight + ". Skip it");
          return;
        }
        width = newWidth;
        height = newHeight;
      }
    }
  }

  private void releaseCodecOnOutputThread(MediaCodecWrapper outputCodec) {
    outputThreadChecker.checkIsOnValidThread();
    Logging.d(TAG, "Releasing MediaCodec on output thread");
    try {
      outputCodec.stop();
    } catch (Exception e) {
      Logging.e(TAG, "Media decoder stop failed", e);
    }
    try {
      outputCodec.release();
    } catch (Exception e) {
      Logging.e(TAG, "Media decoder release failed", e);
      // Propagate exceptions caught during release back to the main thread.
      shutdownException = e;
    }
    Logging.d(TAG, "Release on output thread done");
  }

  private void stopOnOutputThread(Exception e) {
    outputThreadChecker.checkIsOnValidThread();
    running = false;
    shutdownException = e;
  }
}
