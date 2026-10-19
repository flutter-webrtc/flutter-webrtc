#import "FlutterWebRTCPlugin.h"

@interface RTCDataChannel (Flutter) <FlutterStreamHandler>
@property(nonatomic, strong, nonnull) NSString* peerConnectionId;
@property(nonatomic, strong, nonnull) NSString* flutterChannelId;
@property(nonatomic, strong, nullable) FlutterEventSink eventSink;
@property(nonatomic, strong, nullable) FlutterEventChannel* eventChannel;
@property(nonatomic, strong, nullable) NSArray<id>* eventQueue;
/// Handle Dart uses to reach this channel through FFI. See
/// FlutterRTCDataChannelRegisterFFI.
@property(nonatomic, strong, nullable) NSNumber* ffiHandle;
/// Dart port the channel's events are posted to once Dart attaches through
/// FFI. ILLEGAL_PORT (0) after Dart detached: events are dropped from then on.
@property(nonatomic, strong, nullable) NSNumber* dartPort;
@end

/// Registers |dataChannel| for FFI access and returns its handle.
NSNumber* _Nonnull FlutterRTCDataChannelRegisterFFI(RTCDataChannel* _Nonnull dataChannel);

/// Addresses of the data channel FFI entry points, keyed by name, for the
/// dataChannelFfiFunctions method call.
NSDictionary<NSString*, NSNumber*>* _Nonnull FlutterRTCDataChannelFFIFunctions(void);

@interface FlutterWebRTCPlugin (RTCDataChannel) <RTCDataChannelDelegate>

- (void)createDataChannel:(nonnull NSString*)peerConnectionId
                    label:(nonnull NSString*)label
                   config:(nonnull RTCDataChannelConfiguration*)config
                messenger:(nonnull NSObject<FlutterBinaryMessenger>*)messenger
                   result:(nonnull FlutterResult)result;

- (void)dataChannelClose:(nonnull NSString*)peerConnectionId
           dataChannelId:(nonnull NSString*)dataChannelId;

- (void)dataChannelSend:(nonnull NSString*)peerConnectionId
          dataChannelId:(nonnull NSString*)dataChannelId
                   data:(nonnull NSString*)data
                   type:(nonnull NSString*)type;

- (void)dataChannelGetBufferedAmount:(nonnull NSString*)peerConnectionId
          dataChannelId:(nonnull NSString*)dataChannelId 
                result:(nonnull FlutterResult)result;
@end
