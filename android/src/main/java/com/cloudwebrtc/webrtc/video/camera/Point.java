package com.cloudwebrtc.webrtc.video.camera;

import androidx.annotation.Nullable;

/** Represents a point on an x/y axis. */
public class Point {
  public final Double x;
  public final Double y;

  public Point(@Nullable Double x, @Nullable Double y) {
    this.x = x;
    this.y = y;
  }
}
