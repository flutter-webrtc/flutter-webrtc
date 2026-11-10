#import "FlutterRTCDesktopCapturer.h"

#if TARGET_OS_IPHONE
#import <ReplayKit/ReplayKit.h>
#import <UIKit/UIKit.h>
#import "FlutterBroadcastScreenCapturer.h"
#import "FlutterRPScreenRecorder.h"
#endif

#import "VideoProcessingAdapter.h"
#import "LocalVideoTrack.h"
#if TARGET_OS_OSX
#import "FlutterScreenCaptureKitCapturer.h"
#endif

#if TARGET_OS_OSX
// The source lists below are only used on this queue. Listing sources waits
// for the thumbnails libwebrtc is still capturing, which takes seconds with
// many windows, so it must not run on the main thread, which is also
// Flutter's UI thread on macOS.
static dispatch_queue_t DesktopSourcesQueue(void) {
  static dispatch_queue_t queue;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    queue = dispatch_queue_create("FlutterWebRTC.desktopSources",
                                  dispatch_queue_attr_make_with_qos_class(
                                      DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
  });
  return queue;
}

RTCDesktopMediaList* _screen = nil;
RTCDesktopMediaList* _window = nil;
NSArray<RTCDesktopSource*>* _captureSources;
#endif

@implementation FlutterWebRTCPlugin (DesktopCapturer)

- (void)getDisplayMedia:(NSDictionary*)constraints result:(FlutterResult)result {
  NSString* mediaStreamId = [[NSUUID UUID] UUIDString];
  RTCMediaStream* mediaStream = [self.peerConnectionFactory mediaStreamWithStreamId:mediaStreamId];
  RTCVideoSource* videoSource = [self.peerConnectionFactory videoSourceForScreenCast:YES];
  NSString* trackUUID = [[NSUUID UUID] UUIDString];
  VideoProcessingAdapter *videoProcessingAdapter = [[VideoProcessingAdapter alloc] initWithRTCVideoSource:videoSource];
  
#if TARGET_OS_IPHONE
  BOOL useBroadcastExtension = false;
  BOOL presentBroadcastPicker = false;

  id videoConstraints = constraints[@"video"];
  if ([videoConstraints isKindOfClass:[NSDictionary class]]) {
    // constraints.video.deviceId
    useBroadcastExtension =
        [((NSDictionary*)videoConstraints)[@"deviceId"] hasPrefix:@"broadcast"];
    presentBroadcastPicker =
        useBroadcastExtension &&
        ![((NSDictionary*)videoConstraints)[@"deviceId"] hasSuffix:@"-manual"];
  }

  id screenCapturer;

  if (useBroadcastExtension) {
    screenCapturer = [[FlutterBroadcastScreenCapturer alloc] initWithDelegate:videoProcessingAdapter];
  } else {
    screenCapturer = [[FlutterRPScreenRecorder alloc] initWithDelegate:[videoProcessingAdapter source]];
  }

  [screenCapturer startCapture];
  NSLog(@"start %@ capture", useBroadcastExtension ? @"broadcast" : @"replykit");

  self.videoCapturerStopHandlers[trackUUID] = ^(CompletionHandler handler) {
    NSLog(@"stop %@ capture, trackID %@", useBroadcastExtension ? @"broadcast" : @"replykit",
          trackUUID);
    [screenCapturer stopCaptureWithCompletionHandler:handler];
  };

  if (presentBroadcastPicker) {
    NSString* extension =
        [[[NSBundle mainBundle] infoDictionary] valueForKey:kRTCScreenSharingExtension];

    RPSystemBroadcastPickerView* picker = [[RPSystemBroadcastPickerView alloc] init];
    picker.showsMicrophoneButton = false;
    if (extension) {
      picker.preferredExtension = extension;
    } else {
      NSLog(@"Not able to find the %@ key", kRTCScreenSharingExtension);
    }
    UIButton* button = nil;
    for (UIView* subview in picker.subviews) {
      if ([subview isKindOfClass:[UIButton class]]) {
        button = (UIButton*)subview;
        break;
      }
    }

    if (button != nil) {
      [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
      NSLog(@"Unable to find button in RPSystemBroadcastPickerView");
    }
  }
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
  NSString* sourceId = nil;
  BOOL useDefaultScreen = NO;
  NSInteger fps = 30;
  id videoConstraints = constraints[@"video"];
  if ([videoConstraints isKindOfClass:[NSNumber class]] && [videoConstraints boolValue] == YES) {
    useDefaultScreen = YES;
  } else if ([videoConstraints isKindOfClass:[NSDictionary class]]) {
    NSDictionary* deviceId = videoConstraints[@"deviceId"];
    if (deviceId != nil && [deviceId isKindOfClass:[NSDictionary class]]) {
      if (deviceId[@"exact"] != nil) {
        sourceId = deviceId[@"exact"];
        if (sourceId == nil) {
          result(@{@"error" : @"No deviceId.exact found"});
          return;
        }
      }
    } else {
      // fall back to default screen if no deviceId is specified
      useDefaultScreen = YES;
    }
    id mandatory = videoConstraints[@"mandatory"];
    if (mandatory != nil && [mandatory isKindOfClass:[NSDictionary class]]) {
      id frameRate = mandatory[@"frameRate"];
      if (frameRate != nil && [frameRate isKindOfClass:[NSNumber class]]) {
        fps = [frameRate integerValue];
      }
    }
  }
  if (useDefaultScreen) {
    [self startDesktopCaptureOf:nil
                       sourceId:nil
                       capturer:nil
                            fps:fps
                    mediaStream:mediaStream
                    videoSource:videoSource
                        trackId:trackUUID
                videoProcessing:videoProcessingAdapter
                         result:result];
    return;
  }
  // The source list lives on the desktop sources queue, and a window's
  // capturer reads its native source, so look it up and create the capturer
  // there.
  dispatch_async(DesktopSourcesQueue(), ^{
    RTCDesktopSource* source = [self getSourceById:sourceId];
    RTCDesktopCapturer* desktopCapturer = nil;
    if (source != nil && source.sourceType == RTCDesktopSourceTypeWindow) {
      desktopCapturer = [[RTCDesktopCapturer alloc] initWithSource:source
                                                          delegate:self
                                                   captureDelegate:videoProcessingAdapter];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      if (source == nil) {
        result(@{@"error" : [NSString stringWithFormat:@"No source found for id: %@", sourceId]});
        return;
      }
      [self startDesktopCaptureOf:source
                         sourceId:sourceId
                         capturer:desktopCapturer
                              fps:fps
                      mediaStream:mediaStream
                      videoSource:videoSource
                          trackId:trackUUID
                  videoProcessing:videoProcessingAdapter
                           result:result];
    });
  });
#else
  [self finishDisplayMedia:mediaStream
               videoSource:videoSource
                   trackId:trackUUID
           videoProcessing:videoProcessingAdapter
                    result:result];
#endif
}

#if TARGET_OS_OSX
// Starts capturing [source], a screen or window from the source list, or the
// default screen when it is nil. [desktopCapturer] is the window capturer
// made for it on the desktop sources queue.
- (void)startDesktopCaptureOf:(RTCDesktopSource*)source
                     sourceId:(NSString*)sourceId
                     capturer:(RTCDesktopCapturer*)desktopCapturer
                          fps:(NSInteger)fps
                  mediaStream:(RTCMediaStream*)mediaStream
                  videoSource:(RTCVideoSource*)videoSource
                      trackId:(NSString*)trackUUID
              videoProcessing:(VideoProcessingAdapter*)videoProcessingAdapter
                       result:(FlutterResult)result {
  FlutterScreenCaptureKitCapturer* screenCaptureKitCapturer = nil;
  BOOL useScreenCaptureKit = source == nil || source.sourceType == RTCDesktopSourceTypeScreen;
  if (useScreenCaptureKit) {
    // ScreenCaptureKit can create a live track without delivering frames on
    // macOS Monterey. Use the legacy WebRTC capturer on macOS 12.x.
    if (@available(macOS 13.0, *)) {
      screenCaptureKitCapturer =
          [[FlutterScreenCaptureKitCapturer alloc] initWithDelegate:videoProcessingAdapter];
      [screenCaptureKitCapturer startCaptureWithFPS:fps
                                           sourceId:sourceId
                                          onStarted:^(NSError * _Nullable error) {
                                            if (error != nil) {
                                              NSLog(@"ScreenCaptureKit start failed: %@", error);
                                            } else {
                                              NSLog(@"start screencapturekit capture: for  sourceId: %@, fps: %lu",
                                                    sourceId, fps);
                                            }
                                          }];
    } else {
      NSLog(@"ScreenCaptureKit unavailable or unsupported, falling back to RTCDesktopCapturer");
      desktopCapturer = [[RTCDesktopCapturer alloc] initWithDefaultScreen:self
                                                          captureDelegate:videoProcessingAdapter];
    }
  }

  if (screenCaptureKitCapturer == nil) {
    [desktopCapturer startCaptureWithFPS:fps];
    NSLog(@"start desktop capture: sourceId: %@, type: %@, fps: %lu", sourceId,
          source.sourceType == RTCDesktopSourceTypeScreen ? @"screen" : @"window", fps);

    self.videoCapturerStopHandlers[trackUUID] = ^(CompletionHandler handler) {
      NSLog(@"stop desktop capture: sourceId: %@, type: %@, trackID %@", sourceId,
            source.sourceType == RTCDesktopSourceTypeScreen ? @"screen" : @"window", trackUUID);
      [desktopCapturer stopCapture];
      handler();
    };
  } else {
    self.videoCapturerStopHandlers[trackUUID] = ^(CompletionHandler handler) {
      NSLog(@"stop screencapturekit capture: trackID %@", trackUUID);
      [screenCaptureKitCapturer stopCaptureWithCompletion:handler];
    };
  }

  [self finishDisplayMedia:mediaStream
               videoSource:videoSource
                   trackId:trackUUID
           videoProcessing:videoProcessingAdapter
                    result:result];
}
#endif

// Adds the screen capture's track to [mediaStream] and answers with it.
- (void)finishDisplayMedia:(RTCMediaStream*)mediaStream
               videoSource:(RTCVideoSource*)videoSource
                   trackId:(NSString*)trackUUID
           videoProcessing:(VideoProcessingAdapter*)videoProcessingAdapter
                    result:(FlutterResult)result {
  NSString* mediaStreamId = mediaStream.streamId;
  RTCVideoTrack* videoTrack = [self.peerConnectionFactory videoTrackWithSource:videoSource
                                                                       trackId:trackUUID];
  [mediaStream addVideoTrack:videoTrack];

  LocalVideoTrack *localVideoTrack = [[LocalVideoTrack alloc] initWithTrack:videoTrack videoProcessing:videoProcessingAdapter];

  [self.localTracks setObject:localVideoTrack forKey:trackUUID];

  NSMutableArray* audioTracks = [NSMutableArray array];
  NSMutableArray* videoTracks = [NSMutableArray array];

  for (RTCVideoTrack* track in mediaStream.videoTracks) {
    [videoTracks addObject:@{
      @"id" : track.trackId,
      @"kind" : track.kind,
      @"label" : track.trackId,
      @"enabled" : @(track.isEnabled),
      @"remote" : @(YES),
      @"readyState" : @"live"
    }];
  }

  self.localStreams[mediaStreamId] = mediaStream;
  result(
      @{@"streamId" : mediaStreamId, @"audioTracks" : audioTracks, @"videoTracks" : videoTracks});
}

- (void)getDesktopSources:(NSDictionary*)argsMap result:(FlutterResult)result {
#if TARGET_OS_OSX
  NSLog(@"getDesktopSources");

  NSArray* types = [argsMap objectForKey:@"types"];
  if (![self checkDesktopSourceTypes:types result:result]) {
    return;
  }

  dispatch_async(DesktopSourcesQueue(), ^{
    [self buildDesktopSourcesListWithTypes:types forceReload:YES];

    NSMutableArray* sources = [NSMutableArray array];
    for (RTCDesktopSource* object in _captureSources) {
      [sources addObject:@{
        @"id" : object.sourceId,
        @"name" : object.name,
        @"thumbnailSize" : @{@"width" : @0, @"height" : @0},
        @"type" : object.sourceType == RTCDesktopSourceTypeScreen ? @"screen" : @"window",
      }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      result(@{@"sources" : sources});
    });
  });
#else
  result([FlutterError errorWithCode:@"ERROR" message:@"Not supported on iOS" details:nil]);
#endif
}

- (void)getDesktopSourceThumbnail:(NSDictionary*)argsMap result:(FlutterResult)result {
#if TARGET_OS_OSX
  NSLog(@"getDesktopSourceThumbnail");
  NSString* sourceId = argsMap[@"sourceId"];
  dispatch_async(DesktopSourcesQueue(), ^{
    RTCDesktopSource* object = [self getSourceById:sourceId];
    id reply;
    if (object == nil) {
      reply = @{@"error" : @"No source found"};
    } else {
      NSImage* image = [object UpdateThumbnail];
      if (image != nil) {
        NSImage* resizedImg = [self resizeImage:image forSize:NSMakeSize(320, 180)];
        reply = [resizedImg TIFFRepresentation];
      } else {
        reply = @{@"error" : @"No thumbnail found"};
      }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      result(reply);
    });
  });
#else
  result([FlutterError errorWithCode:@"ERROR" message:@"Not supported on iOS" details:nil]);
#endif
}

- (void)updateDesktopSources:(NSDictionary*)argsMap result:(FlutterResult)result {
#if TARGET_OS_OSX
  NSLog(@"updateDesktopSources");
  NSArray* types = [argsMap objectForKey:@"types"];
  if (![self checkDesktopSourceTypes:types result:result]) {
    return;
  }
  dispatch_async(DesktopSourcesQueue(), ^{
    [self buildDesktopSourcesListWithTypes:types forceReload:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
      result(@{@"result" : @YES});
    });
  });
#else
  result([FlutterError errorWithCode:@"ERROR" message:@"Not supported on iOS" details:nil]);
#endif
}

#if TARGET_OS_OSX
- (NSImage*)resizeImage:(NSImage*)sourceImage forSize:(CGSize)targetSize {
  CGSize imageSize = sourceImage.size;
  CGFloat width = imageSize.width;
  CGFloat height = imageSize.height;
  CGFloat targetWidth = targetSize.width;
  CGFloat targetHeight = targetSize.height;
  CGFloat scaleFactor = 0.0;
  CGFloat scaledWidth = targetWidth;
  CGFloat scaledHeight = targetHeight;
  CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

  if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;

    // scale to fit the longer
    scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
    scaledWidth = ceil(width * scaleFactor);
    scaledHeight = ceil(height * scaleFactor);

    // center the image
    if (widthFactor > heightFactor) {
      thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
    } else if (widthFactor < heightFactor) {
      thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
  }

  NSImage* newImage = [[NSImage alloc] initWithSize:NSMakeSize(scaledWidth, scaledHeight)];
  CGRect thumbnailRect = {thumbnailPoint, {scaledWidth, scaledHeight}};
  NSRect imageRect = NSMakeRect(0.0, 0.0, width, height);

  [newImage lockFocus];
    [sourceImage drawInRect:thumbnailRect fromRect:imageRect operation:NSCompositingOperationCopy fraction:1.0];
  [newImage unlockFocus];

  return newImage;
}

- (RTCDesktopSource*)getSourceById:(NSString*)sourceId {
  NSEnumerator* enumerator = [_captureSources objectEnumerator];
  RTCDesktopSource* object;
  while ((object = enumerator.nextObject) != nil) {
    if ([sourceId isEqualToString:object.sourceId]) {
      return object;
    }
  }
  return nil;
}

// Whether [types] lists at least one source type, and only "screen" or
// "window". Answers [result] with an error if not.
- (BOOL)checkDesktopSourceTypes:(NSArray*)types result:(FlutterResult)result {
  if (types == nil) {
    result([FlutterError errorWithCode:@"ERROR" message:@"types is required" details:nil]);
    return NO;
  }
  for (NSString* type in types) {
    if (![type isEqualToString:@"screen"] && ![type isEqualToString:@"window"]) {
      result([FlutterError errorWithCode:@"ERROR" message:@"Invalid type" details:nil]);
      return NO;
    }
  }
  if (types.count == 0) {
    result([FlutterError errorWithCode:@"ERROR"
                               message:@"At least one type is required"
                               details:nil]);
    return NO;
  }
  return YES;
}

// Lists the sources of [types], checked with checkDesktopSourceTypes. Runs on
// the desktop sources queue.
- (void)buildDesktopSourcesListWithTypes:(NSArray*)types forceReload:(BOOL)forceReload {
  BOOL captureWindow = [types containsObject:@"window"];
  BOOL captureScreen = [types containsObject:@"screen"];
  _captureSources = [NSMutableArray array];

  if (forceReload) {
    _screen = nil;
    _window = nil;
  }

  if (captureWindow) {
    if (!_window)
      _window = [[RTCDesktopMediaList alloc] initWithType:RTCDesktopSourceTypeWindow delegate:self];
    [_window UpdateSourceList:forceReload updateAllThumbnails:YES];
    NSArray<RTCDesktopSource*>* sources = [_window getSources];
    _captureSources = [_captureSources arrayByAddingObjectsFromArray:sources];
  }
  if (captureScreen) {
    if (!_screen)
      _screen = [[RTCDesktopMediaList alloc] initWithType:RTCDesktopSourceTypeScreen delegate:self];
    [_screen UpdateSourceList:forceReload updateAllThumbnails:YES];
    NSArray<RTCDesktopSource*>* sources = [_screen getSources];
    _captureSources = [_captureSources arrayByAddingObjectsFromArray:sources];
  }
  NSLog(@"captureSources: %lu", [_captureSources count]);
}

#pragma mark - RTCDesktopMediaListDelegate delegate

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)didDesktopSourceAdded:(RTC_OBJC_TYPE(RTCDesktopSource) *)source {
  // NSLog(@"didDesktopSourceAdded: %@, id %@", source.name, source.sourceId);
  if (self.eventSink) {
    // libwebrtc captures a new source's thumbnail itself and reports it with
    // didDesktopSourceThumbnailChanged; asking for another capture here only
    // makes the next listing wait longer.
    NSImage* image = [source thumbnail];
    NSData* data = [[NSData alloc] init];
    if (image != nil) {
      NSImage* resizedImg = [self resizeImage:image forSize:NSMakeSize(320, 180)];
      data = [resizedImg TIFFRepresentation];
    }
    postEvent(self.eventSink, @{
      @"event" : @"desktopSourceAdded",
      @"id" : source.sourceId,
      @"name" : source.name,
      @"thumbnailSize" : @{@"width" : @0, @"height" : @0},
      @"type" : source.sourceType == RTCDesktopSourceTypeScreen ? @"screen" : @"window",
      @"thumbnail" : data
    });
  }
}

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)didDesktopSourceRemoved:(RTC_OBJC_TYPE(RTCDesktopSource) *)source {
  // NSLog(@"didDesktopSourceRemoved: %@, id %@", source.name, source.sourceId);
  if (self.eventSink) {
    postEvent(self.eventSink, @{
      @"event" : @"desktopSourceRemoved",
      @"id" : source.sourceId,
    });
  }
}

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)didDesktopSourceNameChanged:(RTC_OBJC_TYPE(RTCDesktopSource) *)source {
  // NSLog(@"didDesktopSourceNameChanged: %@, id %@", source.name, source.sourceId);
  if (self.eventSink) {
    postEvent(self.eventSink, @{
      @"event" : @"desktopSourceNameChanged",
      @"id" : source.sourceId,
      @"name" : source.name,
    });
  }
}

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)didDesktopSourceThumbnailChanged:(RTC_OBJC_TYPE(RTCDesktopSource) *)source {
  // NSLog(@"didDesktopSourceThumbnailChanged: %@, id %@", source.name, source.sourceId);
  if (self.eventSink) {
    NSImage* resizedImg = [self resizeImage:[source thumbnail] forSize:NSMakeSize(320, 180)];
    NSData* data = [resizedImg TIFFRepresentation];
    postEvent(self.eventSink, @{
      @"event" : @"desktopSourceThumbnailChanged",
      @"id" : source.sourceId,
      @"thumbnail" : data
    });
  }
}

#pragma mark - RTCDesktopCapturerDelegate delegate

- (void)didSourceCaptureStart:(RTCDesktopCapturer*)capturer {
  NSLog(@"didSourceCaptureStart");
}

- (void)didSourceCapturePaused:(RTCDesktopCapturer*)capturer {
  NSLog(@"didSourceCapturePaused");
}

- (void)didSourceCaptureStop:(RTCDesktopCapturer*)capturer {
  NSLog(@"didSourceCaptureStop");
}

- (void)didSourceCaptureError:(RTCDesktopCapturer*)capturer {
  NSLog(@"didSourceCaptureError");
}

#endif

@end
