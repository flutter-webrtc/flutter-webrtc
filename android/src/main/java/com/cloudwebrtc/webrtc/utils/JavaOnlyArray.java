/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.cloudwebrtc.webrtc.utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Java {@link ArrayList} backed impementation of {@link ReadableArray} and {@link WritableArray}
 * Instances of this class SHOULD NOT be used for communication between java and JS, use instances
 * of {@link WritableNativeArray} created via {@link Arguments#createArray} or just
 * {@link ReadableArray} interface if you want your "native" module method to take an array from JS
 * as an argument.
 *
 * Main purpose for this class is to be used in java-only unit tests, but could also be used outside
 * of tests in the code that operates only in java and needs to communicate with RN modules via
 * their JS-exposed API.
 */
public class JavaOnlyArray implements ReadableArray, WritableArray {

  private final List mBackingList;

  public static JavaOnlyArray from(List list) {
    return new JavaOnlyArray(list);
  }

  public static JavaOnlyArray of(Object... values) {
    return new JavaOnlyArray(values);
  }

  public static JavaOnlyArray deepClone(ReadableArray ary) {
        JavaOnlyArray res = new JavaOnlyArray();
        for (int i = 0, size = ary.size(); i < size; i++) {
            ReadableType type = ary.getType(i);
            switch (type) {
                case Null:
                    res.pushNull();
                    break;
                case Boolean:
                    res.pushBoolean(ary.getBoolean(i));
                    break;
                case Number:
                    res.pushDouble(ary.getDouble(i));
                    break;
                case String:
                    res.pushString(ary.getString(i));
                    break;
                case Map:
                    res.pushMap(JavaOnlyMap.deepClone(ary.getMap(i)));
                    break;
                case Array:
                    res.pushArray(deepClone(ary.getArray(i)));
                    break;
            }
        }
        return res;
    }

  private JavaOnlyArray(Object... values) {
    mBackingList = Arrays.asList(values);
  }

  private JavaOnlyArray(List list) {
    mBackingList = new ArrayList(list);
  }

  public JavaOnlyArray() {
    mBackingList = new ArrayList();
  }

  @Override
  public int size() {
    return mBackingList.size();
  }

  @Override
  public boolean isNull(int index) {
    return mBackingList.get(index) == null;
  }

  @Override
  public double getDouble(int index) {
    return (Double) mBackingList.get(index);
  }

  @Override
  public int getInt(int index) {
    return (Integer) mBackingList.get(index);
  }

  @Override
  public String getString(int index) {
    return (String) mBackingList.get(index);
  }

  @Override
  public JavaOnlyArray getArray(int index) {
    return (JavaOnlyArray) mBackingList.get(index);
  }

  @Override
  public boolean getBoolean(int index) {
    return (Boolean) mBackingList.get(index);
  }

  @Override
  public JavaOnlyMap getMap(int index) {
    return (JavaOnlyMap) mBackingList.get(index);
  }

  @Override
  public Dynamic getDynamic(int index) {
    return DynamicFromArray.create(this, index);
  }

  @Override
  public ReadableType getType(int index) {
    Object object = mBackingList.get(index);

    if (object == null) {
      return ReadableType.Null;
    } else if (object instanceof Boolean) {
      return ReadableType.Boolean;
    } else if (object instanceof Double ||
        object instanceof Float ||
        object instanceof Integer) {
      return ReadableType.Number;
    } else if (object instanceof String) {
      return ReadableType.String;
    } else if (object instanceof ReadableArray) {
      return ReadableType.Array;
    } else if (object instanceof ReadableMap) {
      return ReadableType.Map;
    }
    return null;
  }

  @Override
  public void pushBoolean(boolean value) {
    mBackingList.add(value);
  }

  @Override
  public void pushDouble(double value) {
    mBackingList.add(value);
  }

  @Override
  public void pushInt(int value) {
    mBackingList.add(value);
  }

  @Override
  public void pushString(String value) {
    mBackingList.add(value);
  }

  @Override
  public void pushArray(WritableArray array) {
    mBackingList.add(array);
  }

  @Override
  public void pushMap(WritableMap map) {
    mBackingList.add(map);
  }

  @Override
  public void pushNull() {
    mBackingList.add(null);
  }

  @Override
  public ArrayList<Object> toArrayList() {
    return new ArrayList<Object>(mBackingList);
  }

  @Override
  public String toString() {
    return mBackingList.toString();
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    JavaOnlyArray that = (JavaOnlyArray) o;

    if (mBackingList != null ? !mBackingList.equals(that.mBackingList) : that.mBackingList != null)
      return false;

    return true;
  }

  @Override
  public int hashCode() {
    return mBackingList != null ? mBackingList.hashCode() : 0;
  }
}
