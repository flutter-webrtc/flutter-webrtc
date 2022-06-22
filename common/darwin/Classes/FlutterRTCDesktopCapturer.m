#import <objc/runtime.h>

#import "FlutterRTCDesktopCapturer.h"

#if TARGET_OS_OSX
RTCDesktopMediaList *_screen = nil;
RTCDesktopMediaList *_window = nil;
BOOL _captureWindow = NO;
BOOL _captureScreen = NO;
NSArray<RTCDesktopSource *>* _captureSources;
#endif

@implementation FlutterWebRTCPlugin (DesktopCapturer)

-(void)getDisplayMedia:(NSDictionary *)constraints
                result:(FlutterResult)result {
    NSString *mediaStreamId = [[NSUUID UUID] UUIDString];
    RTCMediaStream *mediaStream = [self.peerConnectionFactory mediaStreamWithStreamId:mediaStreamId];
    RTCVideoSource *videoSource = [self.peerConnectionFactory videoSource];

#if TARGET_OS_IPHONE
    FlutterRPScreenRecorder *screenCapturer = [[FlutterRPScreenRecorder alloc] initWithDelegate:videoSource];
    [screenCapturer startCapture];
    NSLog(@"start replykit capture");
    self.videoCapturerStopHandlers[mediaStreamId] = ^(CompletionHandler handler) {
        NSLog(@"stop replykit capture");
        [screenCapturer stopCaptureWithCompletionHandler:handler];
    };
#endif
    
#if TARGET_OS_OSX
/* example for constraints:
    {
        'audio': false,
        'video": {
            'deviceId':  {'exact': sourceId},
            'mandatory': {
                'frameRate': 30.0
            },
        }
    }
*/
    NSString *sourceId = nil;
    NSInteger fps = 30;
    id videoConstraints = constraints[@"video"];
    if ([videoConstraints isKindOfClass:[NSDictionary class]]) {
         NSDictionary *deviceId = videoConstraints[@"deviceId"];
        if (deviceId != nil && [deviceId isKindOfClass:[NSDictionary class]]) {
            if(deviceId[@"exact"] != nil) {
                sourceId = deviceId[@"exact"];
                if(sourceId == nil) {
                    result(@{@"error": @"No sourceId found"});
                    return;
                }
            }
        }
        id mandatory = videoConstraints[@"mandatory"];
        if (mandatory != nil && [mandatory isKindOfClass:[NSDictionary class]]) {
            id frameRate = mandatory[@"frameRate"];
            if (frameRate != nil && [frameRate isKindOfClass:[NSNumber class]]) {
                fps = [frameRate integerValue];
            }
        }
    }
    RTCDesktopCapturer *desktopCapturer;
    RTCDesktopSource *source = nil;
    if([videoConstraints isKindOfClass:[NSNumber class]] && [videoConstraints boolValue] == YES){
        desktopCapturer  = [[RTCDesktopCapturer alloc] initWithDefaultScreen:videoSource];
    } else {
         source = [self getSourceById:sourceId];
        if(source == nil) {
            result(@{@"error": @"No source found"});
            return;
        }
        desktopCapturer  = [[RTCDesktopCapturer alloc] initWithSource:source delegate:videoSource];
    }
    [desktopCapturer startCaptureWithFPS:fps];
    NSLog(@"start desktop capture: sourceId: %@, type: %@, fps: %lu", sourceId, source.sourceType == RTCDesktopSourceTypeScreen ? @"screen" : @"window", fps);

    self.videoCapturerStopHandlers[mediaStreamId] = ^(CompletionHandler handler) {
        NSLog(@"stop desktop capture: sourceId: %@, type: %@", sourceId, source.sourceType == RTCDesktopSourceTypeScreen ? @"screen" : @"window");
        [desktopCapturer stopCapture];
        handler();
    };
#endif

    NSString *trackUUID = [[NSUUID UUID] UUIDString];
    RTCVideoTrack *videoTrack = [self.peerConnectionFactory videoTrackWithSource:videoSource trackId:trackUUID];
    [mediaStream addVideoTrack:videoTrack];

    NSMutableArray *audioTracks = [NSMutableArray array];
    NSMutableArray *videoTracks = [NSMutableArray array];

    for (RTCVideoTrack *track in mediaStream.videoTracks) {
        [self.localTracks setObject:track forKey:track.trackId];
        [videoTracks addObject:@{@"id": track.trackId, @"kind": track.kind, @"label": track.trackId, @"enabled": @(track.isEnabled), @"remote": @(YES), @"readyState": @"live"}];
    }

    self.localStreams[mediaStreamId] = mediaStream;
    result(@{@"streamId": mediaStreamId, @"audioTracks" : audioTracks, @"videoTracks" : videoTracks });
}

-(void)getDesktopSources:(NSDictionary *)argsMap
             result:(FlutterResult)result {
#if TARGET_OS_OSX
    NSArray *types = [argsMap objectForKey:@"types"];
    if (types == nil) {
        result([FlutterError errorWithCode:@"ERROR"
                                   message:@"types is required"
                                   details:nil]);
        return;
    }

    NSEnumerator *typesEnumerator = [types objectEnumerator];
    NSString *type;
    _captureWindow = NO;
    _captureScreen = NO;
    while ((type = typesEnumerator.nextObject) != nil) {
        if ([type isEqualToString:@"screen"]) {
            _captureScreen = YES;
        } else if ([type isEqualToString:@"window"]) {
            _captureWindow = YES;
        } else {
            result([FlutterError errorWithCode:@"ERROR"
                                       message:@"Invalid type"
                                       details:nil]);
            return;
        }
    }

    if(!_captureWindow && !_captureScreen) {
        result([FlutterError errorWithCode:@"ERROR"
                                   message:@"At least one type is required"
                                   details:nil]);
        return;
    }

    NSMutableArray *sources = [NSMutableArray array];
    [self StartHandling:_captureWindow captureScreen:_captureScreen];
    NSEnumerator *enumerator = [_captureSources objectEnumerator];
    RTCDesktopSource *object;
    while ((object = enumerator.nextObject) != nil) {
        [sources addObject:@{
                             @"id": object.sourceId,
                             @"name": object.name,
                             @"thumbnailSize": @{@"width": @0, @"height": @0},
                             @"type": object.sourceType == RTCDesktopSourceTypeScreen? @"screen" : @"window",
                             }];
    }
    result(@{@"sources": sources});
#else
    result([FlutterError errorWithCode:@"ERROR"
                               message:@"Not supported on iOS"
                               details:nil]);
#endif
}

-(void)getDesktopSourceThumbnail:(NSDictionary *)argsMap
             result:(FlutterResult)result {
#if TARGET_OS_OSX
    NSString* sourceId = argsMap[@"sourceId"];
    RTCDesktopSource *object = [self getSourceById:sourceId];
    if(object == nil) {
        result(@{@"error": @"No source found"});
        return;
    }
   NSData *data = [object.thumbnail TIFFRepresentation];
   result(data);
#else
    result([FlutterError errorWithCode:@"ERROR"
                               message:@"Not supported on iOS"
                               details:nil]);
#endif
}

#if TARGET_OS_OSX
-(RTCDesktopSource *)getSourceById:(NSString *)sourceId {
    NSEnumerator *enumerator = [_captureSources objectEnumerator];
    RTCDesktopSource *object;
    while ((object = enumerator.nextObject) != nil) {
        if([sourceId isEqualToString:object.sourceId]) {
            return object;
        }
    }
    return nil;
}

-(void)StartHandling:(BOOL)captureWindow captureScreen:(BOOL) captureScreen {
    _captureSources = [NSMutableArray array];

    if(_captureWindow) {
        if(!_window) _window = [[RTCDesktopMediaList alloc] initWithType:RTCDesktopSourceTypeWindow];
        [_window UpdateSourceList];
        NSArray<RTCDesktopSource *>* sources = [_window getSources];
        _captureSources = [_captureSources arrayByAddingObjectsFromArray:sources];
    }

    if(_captureScreen) {
        if(!_screen) _screen = [[RTCDesktopMediaList alloc] initWithType:RTCDesktopSourceTypeScreen];
        [_screen UpdateSourceList];
        NSArray<RTCDesktopSource *>* sources = [_screen getSources];
        _captureSources = [_captureSources arrayByAddingObjectsFromArray:sources];
    }
    
    NSLog(@"captureSources: %lu", [_captureSources count]);
}
#endif

@end
