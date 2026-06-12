#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

/// Error domain used by FlutterRTCCustomVideoCapturer implementations to report
/// failures from handleCommand:args:error:.
FOUNDATION_EXPORT NSString* const FlutterRTCCustomVideoSourceErrorDomain;

/// Error code (in FlutterRTCCustomVideoSourceErrorDomain) a capturer must use when it
/// does not support the requested command. Mapped to the platform error code
/// "CustomVideoSourceCommandUnsupported" on the method channel.
FOUNDATION_EXPORT const NSInteger FlutterRTCCustomVideoSourceErrorUnsupportedCommand;

/// A capturer that produces externally composed video frames (e.g. an
/// ARKit/ARCore camera + overlay composition) for a custom video track.
/// Implementations push composed RTCVideoFrame instances (RTCCVPixelBuffer,
/// rotation=0, timeStampNs) to the frameSink passed to the factory.
@protocol FlutterRTCCustomVideoCapturer <NSObject>

- (void)startCaptureWithWidth:(int)width height:(int)height fps:(int)fps;

- (void)stopCapture;

/// Handles an app-defined command routed from the "customVideoSourceCommand"
/// method channel call. Returns an arbitrary plist/codec-safe value (map,
/// scalar or nil). For unsupported commands set *error to an NSError with
/// domain FlutterRTCCustomVideoSourceErrorDomain and code
/// FlutterRTCCustomVideoSourceErrorUnsupportedCommand.
- (nullable id)handleCommand:(NSString*)command
                        args:(nullable NSDictionary*)args
                       error:(NSError**)error;

@end

/// Creates a capturer for a custom video source. frameSink is the delegate
/// (a VideoProcessingAdapter wired to the RTCVideoSource) the capturer must
/// push frames into. options is the (optional) options map passed verbatim
/// from the "createCustomVideoTrack" method channel call.
typedef id<FlutterRTCCustomVideoCapturer> _Nonnull (^FlutterRTCCustomVideoCapturerFactory)(
    id<RTCVideoCapturerDelegate> _Nonnull frameSink,
    NSDictionary* _Nullable options);

/// Process-wide registry mapping sourceType names to capturer factories.
/// The host app registers factories (typically at startup) and Dart creates
/// tracks via CustomVideoSource.createStream(sourceType, ...).
@interface FlutterRTCCustomVideoSourceRegistry : NSObject

+ (void)registerFactory:(FlutterRTCCustomVideoCapturerFactory)factory
          forSourceType:(NSString*)sourceType;

+ (nullable FlutterRTCCustomVideoCapturerFactory)factoryForSourceType:(NSString*)sourceType;

@end

NS_ASSUME_NONNULL_END
