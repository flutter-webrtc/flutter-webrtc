/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.cloudwebrtc.webrtc.utils;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import android.support.v4.util.Pools;

/**
 * Implementation of Dynamic wrapping a ReadableArray.
 */
public class DynamicFromArray implements Dynamic {
  private static final Pools.SimplePool<DynamicFromArray> sPool = new Pools.SimplePool<>(10);

  private @Nullable ReadableArray mArray;
  private int mIndex = -1;

  // This is a pools object. Hide the constructor.
  private DynamicFromArray() {}

  public static DynamicFromArray create(ReadableArray array, int index) {
    DynamicFromArray dynamic = sPool.acquire();
    if (dynamic == null) {
      dynamic = new DynamicFromArray();
    }
    dynamic.mArray = array;
    dynamic.mIndex = index;
    return dynamic;
  }

  @Override
  public void recycle() {
    mArray = null;
    mIndex = -1;
    sPool.release(this);
  }

  @Override
  public boolean isNull() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.isNull(mIndex);
  }

  @Override
  public boolean asBoolean() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.getBoolean(mIndex);
  }

  @Override
  public double asDouble() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.getDouble(mIndex);
  }

  @Override
  public int asInt() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.getInt(mIndex);
  }

  @Override
  public String asString() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.getString(mIndex);
  }

  @Override
  public ReadableArray asArray() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.getArray(mIndex);
  }

  @Override
  public ReadableMap asMap() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.getMap(mIndex);
  }

  @Override
  public ReadableType getType() {
    if (mArray == null) {
      throw new IllegalStateException("This dynamic value has been recycled");
    }
    return mArray.getType(mIndex);
  }
}
