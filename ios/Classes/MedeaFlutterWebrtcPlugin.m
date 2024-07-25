#import "MedeaFlutterWebrtcPlugin.h"
#if __has_include(<medea_flutter_webrtc/medea_flutter_webrtc-Swift.h>)
#import <medea_flutter_webrtc/medea_flutter_webrtc-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "medea_flutter_webrtc-Swift.h"
#endif

@implementation MedeaFlutterWebrtcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMedeaFlutterWebrtcPlugin registerWithRegistrar:registrar];
}
@end

