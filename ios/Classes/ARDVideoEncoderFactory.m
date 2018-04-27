/*
 *  Copyright 2017 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDVideoEncoderFactory.h"

#import "WebRTC/RTCVideoCodecH264.h"
#import "WebRTC/RTCVideoEncoderVP8.h"
#import "WebRTC/RTCVideoEncoderVP9.h"

static NSString *kLevel31ConstrainedHigh = @"640c1f";
static NSString *kLevel31ConstrainedBaseline = @"42e01f";

@implementation ARDVideoEncoderFactory

- (id<RTCVideoEncoder>)createEncoder:(RTCVideoCodecInfo *)info {
  if ([info.name isEqualToString:@"H264"]) {
    return [[RTCVideoEncoderH264 alloc] initWithCodecInfo:info];
  } else if ([info.name isEqualToString:@"VP8"]) {
    return [RTCVideoEncoderVP8 vp8Encoder];
  } else if ([info.name isEqualToString:@"VP9"]) {
    return [RTCVideoEncoderVP9 vp9Encoder];
  }

  return nil;
}

- (NSArray<RTCVideoCodecInfo *> *)supportedCodecs {
  NSMutableArray<RTCVideoCodecInfo *> *codecs = [NSMutableArray array];

  NSDictionary<NSString *, NSString *> *constrainedHighParams = @{
    @"profile-level-id" : kLevel31ConstrainedHigh,
    @"level-asymmetry-allowed" : @"1",
    @"packetization-mode" : @"1",
  };
  RTCVideoCodecInfo *constrainedHighInfo =
      [[RTCVideoCodecInfo alloc] initWithName:@"H264" parameters:constrainedHighParams];
  [codecs addObject:constrainedHighInfo];

  NSDictionary<NSString *, NSString *> *constrainedBaselineParams = @{
    @"profile-level-id" : kLevel31ConstrainedBaseline,
    @"level-asymmetry-allowed" : @"1",
    @"packetization-mode" : @"1",
  };
  RTCVideoCodecInfo *constrainedBaselineInfo =
      [[RTCVideoCodecInfo alloc] initWithName:@"H264" parameters:constrainedBaselineParams];
  [codecs addObject:constrainedBaselineInfo];

  RTCVideoCodecInfo *vp8Info = [[RTCVideoCodecInfo alloc] initWithName:@"VP8" parameters:nil];
  [codecs addObject:vp8Info];

  RTCVideoCodecInfo *vp9Info = [[RTCVideoCodecInfo alloc] initWithName:@"VP9" parameters:nil];
  [codecs addObject:vp9Info];

  return [codecs copy];
}

@end
