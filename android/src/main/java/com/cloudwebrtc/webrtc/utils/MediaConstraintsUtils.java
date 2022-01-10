package com.cloudwebrtc.webrtc.utils;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.webrtc.MediaConstraints;
import org.webrtc.MediaConstraints.KeyValuePair;

import java.util.List;
import java.util.Map.Entry;

public final class MediaConstraintsUtils {

  private static final String TAG = "MediaConstraintsUtils";

  /**
   * Parses mandatory and optional "GUM" constraints described by a specific
   * <tt>ConstraintsMap</tt>.
   *
   * @param constraints A <tt>ConstraintsMap</tt> which represents a JavaScript object specifying
   * the constraints to be parsed into a
   * <tt>MediaConstraints</tt> instance.
   * @return A new <tt>MediaConstraints</tt> instance initialized with the mandatory and optional
   * constraint keys and values specified by
   * <tt>constraints</tt>.
   */
  @NonNull
  public static MediaConstraints parseMediaConstraints(@NonNull ConstraintsMap constraints) {
    MediaConstraints mediaConstraints = new MediaConstraints();

    if (constraints.hasKey("mandatory")
        && constraints.getType("mandatory") == ObjectType.Map) {
      parseConstraints(constraints.getMap("mandatory"),
          mediaConstraints.mandatory);
    } else {
      Log.d(TAG, "mandatory constraints are not a map");
    }

    if (constraints.hasKey("optional")
        && constraints.getType("optional") == ObjectType.Array) {
      ConstraintsArray optional = constraints.getArray("optional");

      for (int i = 0, size = optional.size(); i < size; i++) {
        if (optional.getType(i) == ObjectType.Map) {
          parseConstraints(
              optional.getMap(i),
              mediaConstraints.optional);
        }
      }
    } else {
      Log.d(TAG, "optional constraints are not an array");
    }

    return mediaConstraints;
  }

  /**
   * Parses a constraint set specified in the form of a JavaScript object into a specific
   * <tt>List</tt> of <tt>MediaConstraints.KeyValuePair</tt>s.
   *
   * @param src The constraint set in the form of a JavaScript object to parse.
   * @param dst The <tt>List</tt> of <tt>MediaConstraints.KeyValuePair</tt>s into which the
   * specified <tt>src</tt> is to be parsed.
   */
  private static void parseConstraints(
          @NonNull ConstraintsMap src,
          @NonNull List<KeyValuePair> dst) {

    for (Entry<String, Object> entry : src.toMap().entrySet()) {
      String key = entry.getKey();
      String value = getMapStrValue(src, entry.getKey());
      dst.add(new KeyValuePair(key, value));
    }
  }

  @Nullable
  private static String getMapStrValue(@NonNull ConstraintsMap map, String key) {
    if (!map.hasKey(key)) {
      return null;
    }
    ObjectType type = map.getType(key);
    switch (type) {
      case Boolean:
        return String.valueOf(map.getBoolean(key));
      case Number:
        // Don't know how to distinguish between Int and Double from
        // ReadableType.Number. 'getInt' will fail on double value,
        // while 'getDouble' works for both.
        // return String.valueOf(map.getInt(key));
        return String.valueOf(map.getDouble(key));
      case String:
        return map.getString(key);
      default:
        return null;
    }
  }
}
