#import "FlutterRTCVideoPlatformViewFactory.h"
#import "FlutterRTCVideoPlatformViewController.h"

@implementation FlutterRTCVideoPlatformViewFactory {
}

@synthesize messenger = _messenger;

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
    self.renders = [NSMutableDictionary new];
  }

  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

#if TARGET_OS_IPHONE
- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
  FlutterRTCVideoPlatformViewController* render =
      [[FlutterRTCVideoPlatformViewController alloc] initWithMessenger:_messenger
                                                        viewIdentifier:viewId
                                                                 frame:frame];
  self.renders[@(viewId)] = render;
  return render;
}
#elif TARGET_OS_OSX
- (NSView*)createWithViewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
  FlutterRTCVideoPlatformViewController* render =
      [[FlutterRTCVideoPlatformViewController alloc] initWithMessenger:_messenger
                                                        viewIdentifier:viewId
                                                                 frame:NSZeroRect];
  self.renders[@(viewId)] = render;
  return [render view];
}
#endif

@end
