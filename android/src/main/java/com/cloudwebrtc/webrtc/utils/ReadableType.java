/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.cloudwebrtc.webrtc.utils;

/**
 * Defines the type of an object stored in a {@link ReadableArray} or
 * {@link ReadableMap}.
 */

public enum ReadableType {
  Null,
  Boolean,
  Number,
  String,
  Map,
  Array,
}
