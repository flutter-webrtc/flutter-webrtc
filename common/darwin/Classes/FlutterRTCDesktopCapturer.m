#import <objc/runtime.h>

#import "FlutterRTCDesktopCapturer.h"

RTCDesktopMediaList *_screen = nil;
RTCDesktopMediaList *_window = nil;
BOOL _captureWindow = NO;
BOOL _captureScreen = NO;
NSArray<RTCDesktopSource *>* _captureSources;

@implementation FlutterWebRTCPlugin (DesktopCapturer)

-(void)getDisplayMedia:(NSDictionary *)constraints
                result:(FlutterResult)result {
    BOOL captureDefaultScreen = YES;
    RTCDesktopSource *source = nil;

    /*
     'deviceId':  {'exact': sourceId},
     'mandatory': {
                    'minWidth': 1280,
                    'minHeight': 720,
                    'frameRate': 30.0
                   }
     */

    NSDictionary *mandatory = nil;
    id videoConstraints = constraints[@"video"];
    if ([videoConstraints isKindOfClass:[NSDictionary class]]) {
        captureDefaultScreen = NO;
         NSDictionary *deviceId = videoConstraints[@"deviceId"];
        if (deviceId != nil && [deviceId isKindOfClass:[NSDictionary class]]) {
            if(deviceId[@"exact"] != nil) {
                NSString *sourceId = deviceId[@"exact"];
                source = [self getSourceById:sourceId];
                if(source == nil) {
                    result(@{@"error": @"No source found"});
                    return;
                }
            }
        }
        mandatory = videoConstraints[@"mandatory"];
    } else if([constraints[@"video"] boolValue] == YES) {
        captureDefaultScreen = YES;
    }
    
    NSString *mediaStreamId = [[NSUUID UUID] UUIDString];
    RTCMediaStream *mediaStream = [self.peerConnectionFactory mediaStreamWithStreamId:mediaStreamId];

    RTCVideoSource *videoSource = [self.peerConnectionFactory videoSource];

#if TARGET_OS_IPHONE
    FlutterRPScreenRecorder *screenCapturer = [[FlutterRPScreenRecorder alloc] initWithDelegate:videoSource];

    [screenCapturer startCapture];

    //TODO:
    self.videoCapturer = screenCapturer;
#endif
    
#if TARGET_OS_MAC
    RTCDesktopCapturer *desktopCapturer;
    if(captureDefaultScreen){
        desktopCapturer  = [[RTCDesktopCapturer alloc] initWithDefaultScreen:videoSource];
    } else {
        desktopCapturer  = [[RTCDesktopCapturer alloc] initWithSource:source delegate:videoSource];
    }
    [desktopCapturer startCapture:30];

    self.desktopCapturer = desktopCapturer;
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
}

-(void)getDesktopSourceThumbnail:(NSDictionary *)argsMap
             result:(FlutterResult)result {
    NSString* sourceId = argsMap[@"sourceId"];
    RTCDesktopSource *object = [self getSourceById:sourceId];
    if(object == nil) {
        result(@{@"error": @"No source found"});
        return;
    }
   NSData *data = [object.thumbnail TIFFRepresentation];
   result(data);
}

-(RTCDesktopSource *)getSourceById:(NSString *)sourceId {
    NSEnumerator *enumerator = [_captureSources objectEnumerator];
    RTCDesktopSource *object;
    while ((object = enumerator.nextObject) != nil) {
        if(sourceId == object.sourceId) {
            return object;
        }
    }
    return nil;
}


-(void)StartHandling:(BOOL)captureWindow captureScreen:(BOOL) captureScreen {
    _captureSources = [NSMutableArray array];

    if(_captureWindow) {
        if(!_window) _window = [[RTCDesktopMediaList alloc] initWithDelegate:self type:RTCDesktopSourceTypeWindow];
        [_window UpdateSourceList];
        NSArray<RTCDesktopSource *>* sources = [_window getSources];
        _captureSources = [_captureSources arrayByAddingObjectsFromArray:sources];
        NSData *data = [sources[0].thumbnail TIFFRepresentation];
        NSLog(@"Window: %lu, data %lu", [sources count], data.length);
    }

    if(_captureScreen) {
        if(!_screen) _screen = [[RTCDesktopMediaList alloc] initWithDelegate:self type:RTCDesktopSourceTypeScreen];
         [_screen UpdateSourceList];
        NSArray<RTCDesktopSource *>* sources = [_screen getSources];
        NSData *data = [sources[0].thumbnail TIFFRepresentation];
        _captureSources = [_captureSources arrayByAddingObjectsFromArray:sources];
        NSLog(@"Screen: %lu, data %lu", [sources count], data.length);
    }
    
    NSLog(@"captureSources: %lu", [_captureSources count]);
}

-(void)mediaSourceAdded:(int)index fromSource:(RTCDesktopSource *) source {
     NSLog(@"mediaSourceAdded");
}

-(void)mediaSourceRemoved:(int)index fromSource:(RTCDesktopSource *) source {
    NSLog(@"mediaSourceRemoved");
}

-(void)mediaSourceMoved:(int) oldIndex newIndex:(int) newIndex fromSource:(RTCDesktopSource *) source {
    NSLog(@"mediaSourceMoved");
}

-(void)mediaSourceNameChanged:(int)index fromSource:(RTCDesktopSource *) source{
    NSLog(@"mediaSourceNameChanged");
}

-(void)mediaSourceThumbnailChanged:(int)index fromSource:(RTCDesktopSource *) source {
    NSLog(@"mediaSourceThumbnailChanged");
}

@end
