#import "FlutterRTCCustomVideoSource.h"

NSString* const FlutterRTCCustomVideoSourceErrorDomain = @"FlutterRTCCustomVideoSourceErrorDomain";
const NSInteger FlutterRTCCustomVideoSourceErrorUnsupportedCommand = 404;

@implementation FlutterRTCCustomVideoSourceRegistry

+ (NSMutableDictionary<NSString*, FlutterRTCCustomVideoCapturerFactory>*)factories {
  static NSMutableDictionary<NSString*, FlutterRTCCustomVideoCapturerFactory>* factories = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    factories = [NSMutableDictionary new];
  });
  return factories;
}

+ (void)registerFactory:(FlutterRTCCustomVideoCapturerFactory)factory
          forSourceType:(NSString*)sourceType {
  if (!factory || !sourceType) {
    return;
  }
  NSMutableDictionary<NSString*, FlutterRTCCustomVideoCapturerFactory>* factories = [self factories];
  @synchronized(factories) {
    factories[sourceType] = [factory copy];
  }
}

+ (FlutterRTCCustomVideoCapturerFactory)factoryForSourceType:(NSString*)sourceType {
  if (!sourceType) {
    return nil;
  }
  NSMutableDictionary<NSString*, FlutterRTCCustomVideoCapturerFactory>* factories = [self factories];
  @synchronized(factories) {
    return factories[sourceType];
  }
}

@end
