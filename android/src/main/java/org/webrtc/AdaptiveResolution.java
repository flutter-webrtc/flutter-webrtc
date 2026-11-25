package org.webrtc;

import java.nio.ByteBuffer;
import java.util.concurrent.Semaphore;

/** Tracks input and output separately while a Surface decoder changes video size. */
final class AdaptiveResolution {
  private static final long FORMAT_CHANGE_TIMEOUT_MS = 1000;

  // RECONFIGURE allocates a new envelope. RECOVER disables in-place switches for this session.
  enum Input { KEEP, SWITCH, RECONFIGURE, RECOVER }

  interface SizeSupport {
    boolean supports(int width, int height);
  }

  final int maxWidth;
  final int maxHeight;
  private final SizeSupport sizeSupport;
  private int inputWidth, inputHeight;
  private int outputWidth, outputHeight;
  private long deadlineMs;
  private boolean failed;
  // One output thread and one release request per configured MediaCodec.
  private final Semaphore releaseRequested = new Semaphore(0);

  private AdaptiveResolution(int width, int height, int maxWidth, int maxHeight,
      SizeSupport sizeSupport) {
    inputWidth = outputWidth = width;
    inputHeight = outputHeight = height;
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;
    this.sizeSupport = sizeSupport;
  }

  static AdaptiveResolution create(int width, int height, int preferredWidth, int preferredHeight,
      SizeSupport sizeSupport) {
    if (width <= 0 || height <= 0 || !sizeSupport.supports(width, height)) {
      return null;
    }
    // Query the dimensions as a pair. Independent codec width/height maxima need not be legal
    // together, and reserving the device maximum for every small stream is wasteful.
    boolean reservePreferredSize = preferredWidth >= width && preferredHeight >= height
        && sizeSupport.supports(preferredWidth, preferredHeight);
    return new AdaptiveResolution(width, height, reservePreferredSize ? preferredWidth : width,
        reservePreferredSize ? preferredHeight : height, sizeSupport);
  }

  synchronized Input input(int width, int height, boolean key, long nowMs) {
    if (failed || (deadlineMs != 0 && nowMs >= deadlineMs)) return Input.RECOVER;
    // WebRTC may omit dimensions on delta frames.
    if (width <= 0 || height <= 0 || (width == inputWidth && height == inputHeight)) {
      return Input.KEEP;
    }
    if (width > maxWidth || height > maxHeight || !sizeSupport.supports(width, height)) {
      return Input.RECONFIGURE;
    }
    if (!key || deadlineMs != 0) return Input.RECOVER;
    inputWidth = width;
    inputHeight = height;
    deadlineMs = nowMs + FORMAT_CHANGE_TIMEOUT_MS;
    return Input.SWITCH;
  }

  synchronized boolean output(int width, int height) {
    if (width == inputWidth && height == inputHeight) {
      outputWidth = width;
      outputHeight = height;
      deadlineMs = 0;
    } else if (width != outputWidth || height != outputHeight) {
      failed = true;
    }
    return !failed;
  }

  void awaitReleaseOnOutputError() {
    synchronized (this) {
      failed = true;
    }
    // Input may be paused. Wait until decode() reopens the codec or release() closes it.
    releaseRequested.acquireUninterruptibly();
  }

  void requestRelease() {
    releaseRequested.release();
  }
  synchronized boolean switchingOrFailed() { return deadlineMs != 0 || failed; }
  synchronized boolean failed() { return failed; }
  synchronized int inputWidth() { return inputWidth; }
  synchronized int inputHeight() { return inputHeight; }

  // Android adaptive AVC needs the new parameter sets and IDR together in one access unit.
  static boolean hasConfigAndIdr(ByteBuffer data) {
    boolean sps = false, pps = false;
    int zeros = 0;
    for (int i = data.position(); i < data.limit(); i++) {
      int value = data.get(i) & 0xff;
      if (value == 1 && zeros >= 2 && i + 1 < data.limit()) {
        int type = data.get(++i) & 0x1f;
        if (type == 7) sps = true;
        if (type == 8) pps = true;
        if (type == 5) return sps && pps;
      }
      zeros = value == 0 ? zeros + 1 : 0;
    }
    return false;
  }
}
