#import "FlutterRTCVideoPlatformViewFactory.h"
#import "FlutterRTCVideoPlatformViewController.h"

@implementation FLutterRTCVideoPlatformViewFactory {
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

@end
