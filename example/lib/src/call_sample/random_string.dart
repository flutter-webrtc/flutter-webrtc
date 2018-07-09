// Copyright (c) 2016, Damon Douglas. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Simple library for generating random ascii strings.
///
/// More dartdocs go here.
///
///
/// A simple usage example:
///
/// import 'package:random_string/random_string.dart' as random;
/// main() {
///     print(randomBetween(10,20)); // some integer between 10 and 20
///     print(randomNumeric(4)); // sequence of 4 random numbers i.e. 3259
///     print(randomString(10)); // random sequence of 10 characters i.e. e~f93(4l-
///     print(randomAlpha(5)); // random sequence of 5 alpha characters i.e. aRztC
///     print(randomAlphaNumeric(10)); // random sequence of 10 alpha numeric i.e. aRztC1y32B
/// }

library random_string;

import 'dart:math';

const ASCII_START = 33;
const ASCII_END = 126;
const NUMERIC_START = 48;
const NUMERIC_END = 57;
const LOWER_ALPHA_START = 97;
const LOWER_ALPHA_END = 122;
const UPPER_ALPHA_START = 65;
const UPPER_ALPHA_END = 90;

/// Generates a random integer where [from] <= [to].
int randomBetween(int from, int to) {
  if (from > to) throw new Exception('$from cannot be > $to');
  var rand = new Random();
  return ((to - from) * rand.nextDouble()).toInt() + from;
}

/// Generates a random string of [length] with characters
/// between ascii [from] to [to].
/// Defaults to characters of ascii '!' to '~'.
String randomString(int length, {int from: ASCII_START, int to: ASCII_END}) {
  return new String.fromCharCodes(
      new List.generate(length, (index) => randomBetween(from, to)));
}

/// Generates a random string of [length] with only numeric characters.
String randomNumeric(int length) =>
    randomString(length, from: NUMERIC_START, to: NUMERIC_END);
/*
/// Generates a random string of [length] with only alpha characters.
String randomAlpha(int length) {
  var lowerAlphaLength = randomBetween(0, length);
  var upperAlphaLength = length - lowerAlphaLength;
  var lowerAlpha = randomString(lowerAlphaLength,
      from: LOWER_ALPHA_START, to: LOWER_ALPHA_END);
  var upperAlpha = randomString(upperAlphaLength,
      from: UPPER_ALPHA_START, to: UPPER_ALPHA_END);
  return randomMerge(lowerAlpha, upperAlpha);
}

/// Generates a random string of [length] with alpha-numeric characters.
String randomAlphaNumeric(int length) {
  var alphaLength = randomBetween(0, length);
  var numericLength = length - alphaLength;
  var alpha = randomAlpha(alphaLength);
  var numeric = randomNumeric(numericLength);
  return randomMerge(alpha, numeric);
}

/// Merge [a] with [b] and scramble characters.
String randomMerge(String a, String b) {
  var mergedCodeUnits = new List.from("$a$b".codeUnits);
  mergedCodeUnits.shuffle();
  return new String.fromCharCodes(mergedCodeUnits);
}*/
