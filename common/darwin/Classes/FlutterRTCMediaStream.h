#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"

@interface FlutterWebRTCPlugin (RTCMediaStream)

- (void)getUserMedia:(NSDictionary*)constraints result:(FlutterResult)result;

- (void)createLocalMediaStream:(FlutterResult)result;

- (void)getSources:(FlutterResult)result;

- (void)mediaStreamTrackHasTorch:(RTCMediaStreamTrack*)track result:(FlutterResult)result;

- (void)mediaStreamTrackSetTorch:(RTCMediaStreamTrack*)track
                           torch:(BOOL)torch
                          result:(FlutterResult)result;

- (void)mediaStreamTrackSwitchCamera:(RTCMediaStreamTrack*)track result:(FlutterResult)result;

- (void)mediaStreamTrackCaptureFrame:(RTCMediaStreamTrack*)track
                              toPath:(NSString*)path
                              result:(FlutterResult)result;

- (void)selectAudioInput:(NSString*)deviceId result:(FlutterResult)result;

- (void)selectAudioOutput:(NSString*)deviceId result:(FlutterResult)result;
@end
