#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"

extern NSString * const kCapturerAssociationKey;

// Constraints helper
@interface NSDictionary (Flutter)
- (int)constraintIntForKey:(NSString *)key;
@end

// Adds feature to associate a FlutterRTCVideoCapturer to RTCMediaStreamTrack
@interface RTCMediaStreamTrack (Flutter)
- (NSObject<FlutterRTCVideoCapturer> *)getAssociatedCapturer;
- (void)setAssociatedCapturer:(NSObject<FlutterRTCVideoCapturer> *)capturer;
- (void)removeAssociatedCapturer;
@end

@interface FlutterWebRTCPlugin (RTCMediaStream)

-(void)getUserMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;

-(void)getDisplayMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;

-(void)createLocalMediaStream:(FlutterResult)result;

-(void)getSources:(FlutterResult)result;

-(void)mediaStreamTrackHasTorch:(RTCMediaStreamTrack *)track
                         result:(FlutterResult) result;

-(void)mediaStreamTrackSetTorch:(RTCMediaStreamTrack *)track
                          torch:(BOOL) torch
                         result:(FlutterResult) result;

-(void)mediaStreamTrackSwitchCamera:(RTCMediaStreamTrack *)track
                             result:(FlutterResult) result;

-(void)mediaStreamTrackCaptureFrame:(RTCMediaStreamTrack *)track
                             toPath:(NSString *) path
                             result:(FlutterResult) result;
@end
