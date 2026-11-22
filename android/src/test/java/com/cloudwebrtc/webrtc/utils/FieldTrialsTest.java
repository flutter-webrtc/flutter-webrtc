package com.cloudwebrtc.webrtc.utils;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;

import org.junit.Test;

public class FieldTrialsTest {
  private static final String WARP = "WebRTC-IceHandshakeDtls/Enabled/";

  @Test
  public void appendsSeveralTrialsAndSkipsIdenticalRepeats() {
    assertEquals(WARP + "A/x/B/y:1,z:2/", FieldTrials.merge(WARP, "A/x/" + WARP + "B/y:1,z:2/"));
  }

  @Test
  public void rejectsAConflictWithABuiltInTrial() {
    assertThrows(IllegalArgumentException.class,
        () -> FieldTrials.merge(WARP, "WebRTC-IceHandshakeDtls/Disabled/"));
  }

  @Test
  public void rejectsMalformedStrings() {
    for (String bad : new String[] {"A/x", "A/x/B/", "/x/", "A//"}) {
      assertThrows(bad, IllegalArgumentException.class, () -> FieldTrials.merge("", bad));
    }
  }
}
