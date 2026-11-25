package com.cloudwebrtc.webrtc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertThrows;

import org.junit.Test;
import org.webrtc.CapturerObserver;
import org.webrtc.VideoFrame;

public class CameraCaptureOrientationTest {
  private static final class Receiver implements CapturerObserver {
    VideoFrame frame;
    public void onFrameCaptured(VideoFrame frame) { this.frame = frame; }
    public void onCapturerStarted(boolean success) {}
    public void onCapturerStopped() {}
  }

  private final Receiver receiver = new Receiver();
  private final CameraCaptureOrientation camera = new CameraCaptureOrientation(receiver);
  private static final class TestBuffer implements VideoFrame.Buffer {
    int references = 1;
    public int getWidth() { return 8; }
    public int getHeight() { return 4; }
    public VideoFrame.I420Buffer toI420() { throw new AssertionError("unexpected pixel copy"); }
    public VideoFrame.Buffer cropAndScale(int x, int y, int w, int h, int sw, int sh) {
      throw new AssertionError("unexpected crop");
    }
    public void retain() { references++; }
    public void release() { references--; }
  }
  private final TestBuffer buffer = new TestBuffer();

  @Test
  public void overridesDeviceMotionUntilUnlockedAndPreservesFrameData() {
    camera.setMount(new CameraCaptureOrientation.Mount(270, true));
    VideoFrame portrait = new VideoFrame(buffer, 270, 1000);
    VideoFrame upsideDown = new VideoFrame(buffer, 90, 2000);
    camera.onFrameCaptured(portrait);
    assertSame(portrait, receiver.frame);

    camera.setOrientation("landscapeLeft", false);
    camera.onFrameCaptured(portrait);
    assertEquals(0, receiver.frame.getRotation());
    camera.onFrameCaptured(upsideDown);
    assertEquals(0, receiver.frame.getRotation());
    assertSame(buffer, receiver.frame.getBuffer());
    assertEquals(2000, receiver.frame.getTimestampNs());
    assertEquals(1, buffer.references);

    // The same capture source switches to a back camera whose sensor is mounted at 0°.
    camera.setMount(new CameraCaptureOrientation.Mount(0, false));
    camera.onFrameCaptured(portrait);
    assertEquals(270, receiver.frame.getRotation());
    camera.setOrientation(null, false);
    camera.onFrameCaptured(upsideDown);
    assertSame(upsideDown, receiver.frame);
  }

  @Test
  public void mapsBothPortraitNativeAndLandscapeNativeDisplays() {
    String[] selections = {"portraitUp", "landscapeLeft", "portraitDown", "landscapeRight"};
    int[] backPhone = {90, 0, 270, 180};
    int[] frontTablet = {270, 0, 90, 180};
    VideoFrame frame = new VideoFrame(buffer, 0, 0);
    for (int i = 0; i < selections.length; ++i) {
      camera.setMount(new CameraCaptureOrientation.Mount(90, false));
      camera.setOrientation(selections[i], false);
      camera.onFrameCaptured(frame);
      assertEquals(backPhone[i], receiver.frame.getRotation());
      camera.setMount(new CameraCaptureOrientation.Mount(0, true));
      camera.setOrientation(selections[i], true);
      camera.onFrameCaptured(frame);
      assertEquals(frontTablet[i], receiver.frame.getRotation());
    }
  }

  @Test
  public void failsToLockWhenMountIsUnknownButAlwaysAllowsUnlock() {
    assertThrows(IllegalStateException.class, () -> camera.setOrientation("portraitUp", false));
    camera.setOrientation(null, false);
  }

  @Test
  public void invalidNameIsRejectedWithoutChangingAnExistingLock() {
    camera.setMount(new CameraCaptureOrientation.Mount(90, false));
    camera.setOrientation("landscapeLeft", false);
    assertThrows(IllegalArgumentException.class, () -> camera.setOrientation("landscape", false));
    camera.onFrameCaptured(new VideoFrame(buffer, 180, 3000));
    assertEquals(0, receiver.frame.getRotation());
  }
}
