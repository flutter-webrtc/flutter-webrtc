package org.webrtc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertNull;
import static org.webrtc.AdaptiveResolution.Input.KEEP;
import static org.webrtc.AdaptiveResolution.Input.RECOVER;
import static org.webrtc.AdaptiveResolution.Input.RECONFIGURE;
import static org.webrtc.AdaptiveResolution.Input.SWITCH;

import java.nio.ByteBuffer;
import java.util.concurrent.TimeUnit;
import org.junit.Test;

public class AdaptiveResolutionTest {
  @Test
  public void arbitraryPortraitResolutionCanSwitchWithinCurrentAllocation() {
    AdaptiveResolution state = newState(1080, 1920);
    assertEquals(SWITCH, state.input(540, 960, true, 10));
    assertTrue(state.output(540, 960));
    assertEquals(SWITCH, state.input(1080, 1920, true, 20));
  }

  private AdaptiveResolution newState(int width, int height) {
    return AdaptiveResolution.create(width, height, 0, 0, (w, h) -> true);
  }

  @Test
  public void firstUpswitchGrowsAllocationInsteadOfDisablingAdaptivePlayback() {
    AdaptiveResolution state = newState(640, 360);
    assertEquals(640, state.maxWidth);
    assertEquals(RECONFIGURE, state.input(960, 540, true, 10));
    state = newState(960, 540);
    assertEquals(SWITCH, state.input(640, 360, true, 20));
    assertTrue(state.output(640, 360));
    assertEquals(SWITCH, state.input(960, 540, true, 30));
  }

  @Test
  public void optionalEnvelopeEnablesFirstUpswitchOnlyWhenPairIsSupportedAndFits() {
    AdaptiveResolution.SizeSupport supported = (w, h) -> (w <= 1280 && h <= 720)
        || (w <= 720 && h <= 1280);
    AdaptiveResolution state = AdaptiveResolution.create(640, 360, 1280, 720, supported);
    assertEquals(SWITCH, state.input(960, 540, true, 10));
    state = AdaptiveResolution.create(640, 360, 1280, 1280, supported);
    assertEquals(640, state.maxWidth);
    assertEquals(360, state.maxHeight);
    state = AdaptiveResolution.create(720, 1280, 1280, 720, supported);
    assertEquals(720, state.maxWidth);
    assertEquals(1280, state.maxHeight);
    assertNull(AdaptiveResolution.create(1920, 1080, 0, 0, supported));
  }

  @Test
  public void checksTargetSizeAgainstCodecEvenWithinReservedEnvelope() {
    AdaptiveResolution state = AdaptiveResolution.create(1920, 1080, 0, 0,
        (width, height) -> width % 16 == 0);
    assertEquals(RECONFIGURE, state.input(853, 480, true, 10));
  }

  @Test
  public void confirmsEachProfileChangeFromTheActualDecoderOutput() {
    AdaptiveResolution state = newState(1920, 1080);
    assertEquals(KEEP, state.input(1920, 1080, true, 0));
    assertEquals(SWITCH, state.input(1280, 720, true, 10));
    assertEquals(KEEP, state.input(1280, 720, false, 20));
    assertTrue(state.output(1920, 1080));
    assertTrue(state.output(1280, 720));
    assertEquals(KEEP, state.input(1280, 720, false, 2000));
    assertEquals(SWITCH, state.input(1920, 1080, true, 2010));
    assertTrue(state.output(1920, 1080));
    assertEquals(KEEP, state.input(0, 0, false, 3000));
    assertEquals(SWITCH, state.input(640, 480, true, 3001));
  }

  @Test
  public void reopensForMissingKeyframeTimeoutOverlapOrUnexpectedOutput() {
    AdaptiveResolution state = AdaptiveResolution.create(1280, 720, 1920, 1080, (w, h) -> true);
    assertEquals(RECOVER, state.input(1920, 1080, false, 0));

    state = AdaptiveResolution.create(1280, 720, 1920, 1080, (w, h) -> true);
    assertEquals(SWITCH, state.input(1920, 1080, true, 10));
    assertEquals(RECOVER, state.input(0, 0, false, 2000));

    state = newState(1920, 1080);
    assertEquals(SWITCH, state.input(1280, 720, true, 10));
    assertEquals(RECOVER, state.input(1920, 1080, true, 12));

    state = newState(1920, 1080);
    assertFalse(state.output(1280, 720));
    assertEquals(RECOVER, state.input(1920, 1080, false, 10));
  }

  @Test
  public void switchesOnlyOnSpsPpsAndIdrInTheSameAccessUnit() {
    byte[] key = {99, 0, 0, 1, 0x67, 52, 0, 0, 0, 1, 0x68, 33, 0, 0, 1, 0x65, 20};
    ByteBuffer data = ByteBuffer.wrap(key);
    data.position(1);
    assertTrue(AdaptiveResolution.hasConfigAndIdr(data));
    assertEquals(1, data.position());
    data.limit(15);
    assertFalse(AdaptiveResolution.hasConfigAndIdr(data));
    data.limit(key.length);
    data.position(5);
    assertFalse(AdaptiveResolution.hasConfigAndIdr(data));
  }

  @Test
  public void outputErrorWaitsForCodecRecoveryOrRelease() throws InterruptedException {
    AdaptiveResolution state = newState(1920, 1080);
    Thread output = new Thread(state::awaitReleaseOnOutputError);
    output.setDaemon(true);
    output.start();
    try {
      long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(2);
      while (output.isAlive() && !state.failed() && System.nanoTime() < deadline) {
        Thread.sleep(1);
      }
      assertEquals(RECOVER, state.input(0, 0, false, 0));
      output.join(50);
      assertTrue(output.isAlive());
    } finally {
      state.requestRelease();
    }
    output.join(2000);
    assertFalse(output.isAlive());
  }

  @Test
  public void releaseMayArriveBeforeOutputError() throws InterruptedException {
    AdaptiveResolution state = newState(1920, 1080);
    state.requestRelease();
    Thread output = new Thread(state::awaitReleaseOnOutputError);
    output.setDaemon(true);
    output.start();
    output.join(2000);
    assertFalse(output.isAlive());
  }
}
