#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "../../darwin/VideoProcessorSample.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)didInitializeImplicitFlutterEngine:(NSObject<FlutterImplicitEngineBridge>*)engineBridge {
  [GeneratedPluginRegistrant registerWithRegistry:engineBridge.pluginRegistry];
  [VideoProcessorSample
      registerWithRegistrar:[engineBridge.pluginRegistry registrarForPlugin:@"VideoProcessorSample"]];
}

@end
