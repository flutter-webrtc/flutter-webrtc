package com.cloudwebrtc.webrtc.utils;

import java.util.HashMap;
import java.util.Map;

/** libwebrtc field-trial strings: "Name/Value/Name/Value/". */
public final class FieldTrials {
  private FieldTrials() {}

  /**
   * Appends extra to builtIn after checking its form. A trial may repeat with the same value; a
   * different value is rejected, since libwebrtc would silently keep the first one.
   */
  public static String merge(String builtIn, String extra) {
    Map<String, String> trials = new HashMap<>();
    add(trials, builtIn);
    return builtIn + add(trials, extra);
  }

  // Returns the trials of s that aren't in trials yet, and adds them.
  private static String add(Map<String, String> trials, String s) {
    if (s.isEmpty()) return "";
    if (!s.endsWith("/")) throw new IllegalArgumentException("field trials must end with '/': " + s);
    String[] parts = s.substring(0, s.length() - 1).split("/", -1);
    if (parts.length % 2 != 0) throw new IllegalArgumentException("field trial without a value: " + s);
    StringBuilder added = new StringBuilder();
    for (int i = 0; i < parts.length; i += 2) {
      String name = parts[i], value = parts[i + 1];
      if (name.isEmpty() || value.isEmpty()) {
        throw new IllegalArgumentException("empty field trial name or value: " + s);
      }
      String previous = trials.putIfAbsent(name, value);
      if (previous == null) {
        added.append(name).append('/').append(value).append('/');
      } else if (!previous.equals(value)) {
        throw new IllegalArgumentException(
            "conflicting field trial " + name + ": " + previous + " and " + value);
      }
    }
    return added.toString();
  }
}
