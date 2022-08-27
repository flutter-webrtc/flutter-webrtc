package com.cloudwebrtc.webrtc.utils;

import android.util.Log;
import java.util.List;
import java.util.Map.Entry;
import org.webrtc.MediaConstraints;
import org.webrtc.MediaConstraints.KeyValuePair;

public class MediaConstraintsUtils {

  static public final String TAG = "MediaConstraintsUtils";

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
  public static MediaConstraints parseMediaConstraints(ConstraintsMap constraints) {
    MediaConstraints mediaConstraints = new MediaConstraints();

    // TODO: change getUserMedia constraints format to support new syntax
    //   constraint format seems changed, and there is no mandatory any more.
    //   and has a new syntax/attrs to specify resolution
    //   should change `parseConstraints()` according
    //   see: https://www.w3.org/TR/mediacapture-streams/#idl-def-MediaTrackConstraints
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
      ConstraintsMap src,
      List<KeyValuePair> dst) {

    for (Entry<String, Object> entry : src.toMap().entrySet()) {
      String key = entry.getKey();
      String value = getMapStrValue(src, entry.getKey());
      dst.add(new KeyValuePair(key, value));
    }
  }

  private static String getMapStrValue(ConstraintsMap map, String key) {
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
