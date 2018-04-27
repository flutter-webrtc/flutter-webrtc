/*
 *  Copyright 2017 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDVideoDecoderFactory.h"

#import "WebRTC/RTCVideoCodecH264.h"
#import "WebRTC/RTCVideoDecoderVP8.h"
#import "WebRTC/RTCVideoDecoderVP9.h"

@implementation ARDVideoDecoderFactory

- (id<RTCVideoDecoder>)createDecoder:(RTCVideoCodecInfo *)info {
  if ([info.name isEqualToString:@"H264"]) {
    return [[RTCVideoDecoderH264 alloc] init];
  } else if ([info.name isEqualToString:@"VP8"]) {
    return [RTCVideoDecoderVP8 vp8Decoder];
  } else if ([info.name isEqualToString:@"VP9"]) {
    return [RTCVideoDecoderVP9 vp9Decoder];
  }

  return nil;
}

- (NSArray<RTCVideoCodecInfo *> *)supportedCodecs {
  return @[
    [[RTCVideoCodecInfo alloc] initWithName:@"H264" parameters:nil],
    [[RTCVideoCodecInfo alloc] initWithName:@"VP8" parameters:nil],
    [[RTCVideoCodecInfo alloc] initWithName:@"VP9" parameters:nil]
  ];
}

@end
