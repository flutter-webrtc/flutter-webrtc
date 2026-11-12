#import "FlutterRTCDataChannel.h"
#import <WebRTC/RTCDataChannelConfiguration.h>
#import <objc/runtime.h>
#import <os/lock.h>
#import <stdatomic.h>
#import "FlutterRTCPeerConnection.h"
#import "dart_native_api.h"

#pragma mark - FFI

// Data channel events are built once as "raw" dictionaries: received messages
// carry their payload as NSData. EventForSink converts one for the event
// channel, PostEventToDart sends one to a Dart port. Dart picks the transport
// when it attaches; FFI is preferred whenever the function table is available.

typedef bool (*FlutterRTCPostCObjectFn)(Dart_Port port, Dart_CObject* message);

static _Atomic(FlutterRTCPostCObjectFn) gPostCObject = NULL;

// Handles are never reused. Values are weak: the channel's owner is its peer
// connection's dataChannels dictionary, and a released channel simply stops
// resolving.
static os_unfair_lock gRegistryLock = OS_UNFAIR_LOCK_INIT;
static NSMapTable<NSNumber*, RTCDataChannel*>* gRegistry;
static int64_t gNextHandle = 1;

// Payloads up to this size are copied into the Dart message. Larger ones are
// handed over as external typed data, which skips the copy but costs a
// finalizer.
static const NSUInteger kExternalTypedDataThreshold = 4096;

enum {
  kDartEventStateChanged = 0,
  kDartEventMessage = 1,
  kDartEventBufferedAmount = 2,
};

NSNumber* FlutterRTCDataChannelRegisterFFI(RTCDataChannel* dataChannel) {
  os_unfair_lock_lock(&gRegistryLock);
  if (gRegistry == nil) {
    gRegistry = [NSMapTable strongToWeakObjectsMapTable];
  }
  NSNumber* handle = @(gNextHandle++);
  [gRegistry setObject:dataChannel forKey:handle];
  os_unfair_lock_unlock(&gRegistryLock);
  dataChannel.ffiHandle = handle;
  return handle;
}

static RTCDataChannel* LookupDataChannel(int64_t handle) {
  os_unfair_lock_lock(&gRegistryLock);
  RTCDataChannel* dataChannel = [gRegistry objectForKey:@(handle)];
  os_unfair_lock_unlock(&gRegistryLock);
  return dataChannel;
}

static id EventForSink(NSDictionary* event) {
  if (![event[@"event"] isEqualToString:@"dataChannelReceiveMessage"]) {
    return event;
  }
  NSData* bytes = event[@"data"];
  id data;
  if ([event[@"type"] isEqualToString:@"binary"]) {
    data = [FlutterStandardTypedData typedDataWithBytes:bytes];
  } else {
    data = [[NSString alloc] initWithData:bytes encoding:NSUTF8StringEncoding];
  }
  NSMutableDictionary* converted = [event mutableCopy];
  converted[@"data"] = data ?: [NSNull null];
  return converted;
}

static void ReleaseExternalData(void* isolate_callback_data, void* peer) {
  CFRelease(peer);
}

static int32_t StateCode(NSString* state) {
  if ([state isEqualToString:@"connecting"]) return 0;
  if ([state isEqualToString:@"open"]) return 1;
  if ([state isEqualToString:@"closing"]) return 2;
  return 3;
}

// Posts |event| to |port| as [kind, id, ...]. Returns NO when the port is gone,
// for example after a hot restart.
static BOOL PostEventToDart(Dart_Port port, NSDictionary* event) {
  FlutterRTCPostCObjectFn post = atomic_load(&gPostCObject);
  if (post == NULL) {
    return NO;
  }
  NSString* name = event[@"event"];
  Dart_CObject values[4];
  Dart_CObject* items[4] = {&values[0], &values[1], &values[2], &values[3]};
  values[1].type = Dart_CObject_kInt64;
  values[1].value.as_int64 = [event[@"id"] longLongValue];
  intptr_t length = 3;
  void* externalPeer = NULL;

  values[0].type = Dart_CObject_kInt32;
  if ([name isEqualToString:@"dataChannelReceiveMessage"]) {
    NSData* bytes = event[@"data"];
    values[0].value.as_int32 = kDartEventMessage;
    values[2].type = Dart_CObject_kBool;
    values[2].value.as_bool = [event[@"type"] isEqualToString:@"binary"];
    if (bytes.length > kExternalTypedDataThreshold) {
      externalPeer = (void*)CFBridgingRetain(bytes);
      values[3].type = Dart_CObject_kExternalTypedData;
      values[3].value.as_external_typed_data.type = Dart_TypedData_kUint8;
      values[3].value.as_external_typed_data.length = (intptr_t)bytes.length;
      values[3].value.as_external_typed_data.data = (uint8_t*)bytes.bytes;
      values[3].value.as_external_typed_data.peer = externalPeer;
      values[3].value.as_external_typed_data.callback = ReleaseExternalData;
    } else {
      values[3].type = Dart_CObject_kTypedData;
      values[3].value.as_typed_data.type = Dart_TypedData_kUint8;
      values[3].value.as_typed_data.length = (intptr_t)bytes.length;
      values[3].value.as_typed_data.values = (const uint8_t*)bytes.bytes;
    }
    length = 4;
  } else if ([name isEqualToString:@"dataChannelStateChanged"]) {
    values[0].value.as_int32 = kDartEventStateChanged;
    values[2].type = Dart_CObject_kInt32;
    values[2].value.as_int32 = StateCode(event[@"state"]);
  } else {
    values[0].value.as_int32 = kDartEventBufferedAmount;
    values[2].type = Dart_CObject_kInt64;
    values[2].value.as_int64 = [event[@"bufferedAmount"] longLongValue];
    values[3].type = Dart_CObject_kInt64;
    values[3].value.as_int64 = [event[@"changedAmount"] longLongValue];
    length = 4;
  }

  Dart_CObject message;
  message.type = Dart_CObject_kArray;
  message.value.as_array.length = length;
  message.value.as_array.values = items;
  BOOL posted = post(port, &message);
  if (!posted && externalPeer != NULL) {
    // Ownership of external data only moves to Dart when the post succeeds.
    CFRelease(externalPeer);
  }
  return posted;
}

static void FFIInitialize(void* postCObject) {
  atomic_store(&gPostCObject, (FlutterRTCPostCObjectFn)postCObject);
}

// Routes the channel's events to |port|, starting with the ones queued while
// nobody listened. Returns 0 when the handle does not resolve.
static int32_t FFIAttach(int64_t handle, int64_t port) {
  RTCDataChannel* dataChannel = LookupDataChannel(handle);
  if (dataChannel == nil) {
    return 0;
  }
  @synchronized(dataChannel) {
    dataChannel.dartPort = @(port);
    NSArray* queued = dataChannel.eventQueue;
    dataChannel.eventQueue = nil;
    for (NSDictionary* event in queued) {
      if (!PostEventToDart(port, event)) {
        dataChannel.dartPort = @(ILLEGAL_PORT);
        break;
      }
    }
  }
  return 1;
}

static void FFIDetach(int64_t handle) {
  RTCDataChannel* dataChannel = LookupDataChannel(handle);
  if (dataChannel == nil) {
    return;
  }
  @synchronized(dataChannel) {
    dataChannel.dartPort = @(ILLEGAL_PORT);
    dataChannel.eventQueue = nil;
  }
}

// Returns 1 when sent, 0 when the channel refused the data, -1 when the handle
// does not resolve. RTCDataBuffer copies |data|, so it only has to stay valid
// for the duration of the call.
static int32_t FFISend(int64_t handle, const uint8_t* data, int64_t length, int32_t binary) {
  @autoreleasepool {
    RTCDataChannel* dataChannel = LookupDataChannel(handle);
    if (dataChannel == nil) {
      return -1;
    }
    NSData* bytes = [NSData dataWithBytesNoCopy:(void*)data
                                         length:(NSUInteger)length
                                   freeWhenDone:NO];
    RTCDataBuffer* buffer = [[RTCDataBuffer alloc] initWithData:bytes isBinary:binary != 0];
    return [dataChannel sendData:buffer] ? 1 : 0;
  }
}

// Returns -1 when the handle does not resolve.
static int64_t FFIBufferedAmount(int64_t handle) {
  RTCDataChannel* dataChannel = LookupDataChannel(handle);
  return dataChannel == nil ? -1 : (int64_t)dataChannel.bufferedAmount;
}

static void* FFIAlloc(int64_t size) {
  return malloc((size_t)size);
}

static void FFIFree(void* pointer) {
  free(pointer);
}

NSDictionary<NSString*, NSNumber*>* FlutterRTCDataChannelFFIFunctions(void) {
  return @{
    @"version" : @1,
    @"initialize" : @((int64_t)(intptr_t)&FFIInitialize),
    @"attach" : @((int64_t)(intptr_t)&FFIAttach),
    @"detach" : @((int64_t)(intptr_t)&FFIDetach),
    @"send" : @((int64_t)(intptr_t)&FFISend),
    @"bufferedAmount" : @((int64_t)(intptr_t)&FFIBufferedAmount),
    @"alloc" : @((int64_t)(intptr_t)&FFIAlloc),
    @"free" : @((int64_t)(intptr_t)&FFIFree),
  };
}

@implementation RTCDataChannel (Flutter)

- (NSString*)peerConnectionId {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setPeerConnectionId:(NSString*)peerConnectionId {
  objc_setAssociatedObject(self, @selector(peerConnectionId), peerConnectionId,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventSink)eventSink {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventSink:(FlutterEventSink)eventSink {
  objc_setAssociatedObject(self, @selector(eventSink), eventSink,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<id>*)eventQueue {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventQueue:(NSArray<id>*)eventQueue {
  objc_setAssociatedObject(self, @selector(eventQueue), eventQueue,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)flutterChannelId {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlutterChannelId:(NSNumber*)flutterChannelId {
  objc_setAssociatedObject(self, @selector(flutterChannelId), flutterChannelId,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventChannel*)eventChannel {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventChannel:(FlutterEventChannel*)eventChannel {
  objc_setAssociatedObject(self, @selector(eventChannel), eventChannel,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)ffiHandle {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setFfiHandle:(NSNumber*)ffiHandle {
  objc_setAssociatedObject(self, @selector(ffiHandle), ffiHandle,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)dartPort {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setDartPort:(NSNumber*)dartPort {
  objc_setAssociatedObject(self, @selector(dartPort), dartPort,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  @synchronized(self) {
    self.eventSink = nil;
  }
  return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
  @synchronized(self) {
    self.eventSink = sink;
    for (id event in self.eventQueue) {
      postEvent(sink, EventForSink(event));
    }
    self.eventQueue = nil;
  }
  return nil;
}
@end

@implementation FlutterWebRTCPlugin (RTCDataChannel)

- (void)createDataChannel:(nonnull NSString*)peerConnectionId
                    label:(NSString*)label
                   config:(RTCDataChannelConfiguration*)config
                messenger:(NSObject<FlutterBinaryMessenger>*)messenger
                   result:(nonnull FlutterResult)result {
  RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
  RTCDataChannel* dataChannel = [peerConnection dataChannelForLabel:label configuration:config];

  if (nil != dataChannel) {
    dataChannel.peerConnectionId = peerConnectionId;
    NSString* flutterId = [[NSUUID UUID] UUIDString];
    peerConnection.dataChannels[flutterId] = dataChannel;
    dataChannel.flutterChannelId = flutterId;
    dataChannel.eventQueue = nil;
    dataChannel.delegate = self;

    FlutterEventChannel* eventChannel = [FlutterEventChannel
        eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/dataChannelEvent%1$@%2$@",
                                                        peerConnectionId, flutterId]
             binaryMessenger:messenger];

    dataChannel.eventChannel = eventChannel;
    [eventChannel setStreamHandler:dataChannel];

    result(@{
      @"label" : label,
      @"id" : [NSNumber numberWithInt:dataChannel.channelId],
      @"flutterId" : flutterId,
      @"ffiHandle" : FlutterRTCDataChannelRegisterFFI(dataChannel)
    });
  }
}

- (void)dataChannelClose:(nonnull NSString*)peerConnectionId
           dataChannelId:(nonnull NSString*)dataChannelId {
  RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
  NSMutableDictionary* dataChannels = peerConnection.dataChannels;
  RTCDataChannel* dataChannel = dataChannels[dataChannelId];
  if (dataChannel) {
    FlutterEventChannel* eventChannel = dataChannel.eventChannel;
    [dataChannel close];
    [dataChannels removeObjectForKey:dataChannelId];
    [eventChannel setStreamHandler:nil];
    dataChannel.eventChannel = nil;
  }
}

- (void)dataChannelGetBufferedAmount:(nonnull NSString*)peerConnectionId
          dataChannelId:(nonnull NSString*)dataChannelId 
                result:(nonnull FlutterResult)result {
  RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
  RTCDataChannel* dataChannel = peerConnection.dataChannels[dataChannelId];
  if(dataChannel == NULL || dataChannel.readyState != RTCDataChannelStateOpen) {
    result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", @"dataChannelGetBufferedAmount"]
                message:[NSString stringWithFormat:@"Error: dataChannel not found or not opened!"]
                details:nil]);
  } else {
    result(@{@"bufferedAmount": @(dataChannel.bufferedAmount)});
  }
}

- (void)dataChannelSend:(nonnull NSString*)peerConnectionId
          dataChannelId:(nonnull NSString*)dataChannelId
                   data:(id)data
                   type:(NSString*)type {
  RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
  RTCDataChannel* dataChannel = peerConnection.dataChannels[dataChannelId];

  NSData* bytes = [type isEqualToString:@"binary"] ? ((FlutterStandardTypedData*)data).data
                                                   : [data dataUsingEncoding:NSUTF8StringEncoding];

  RTCDataBuffer* buffer = [[RTCDataBuffer alloc] initWithData:bytes
                                                     isBinary:[type isEqualToString:@"binary"]];
  [dataChannel sendData:buffer];
}

- (NSString*)stringForDataChannelState:(RTCDataChannelState)state {
  switch (state) {
    case RTCDataChannelStateConnecting:
      return @"connecting";
    case RTCDataChannelStateOpen:
      return @"open";
    case RTCDataChannelStateClosing:
      return @"closing";
    case RTCDataChannelStateClosed:
      return @"closed";
  }
  return nil;
}

- (void)sendEvent:(id)event withChannel:(RTCDataChannel*)channel {
  @synchronized(channel) {
    NSNumber* dartPort = channel.dartPort;
    if (dartPort != nil) {
      // Attached through FFI. A dead port means Dart is gone: drop the event.
      Dart_Port port = dartPort.longLongValue;
      if (port != ILLEGAL_PORT && !PostEventToDart(port, event)) {
        channel.dartPort = @(ILLEGAL_PORT);
      }
      return;
    }
    FlutterEventSink eventSink = channel.eventSink;
    if (eventSink) {
      postEvent(eventSink, EventForSink(event));
    } else {
      NSArray<id>* eventQueue = channel.eventQueue;
      channel.eventQueue = eventQueue ? [eventQueue arrayByAddingObject:event] : @[ event ];
    }
  }
}

#pragma mark - RTCDataChannelDelegate methods

// Called when the data channel state has changed.
- (void)dataChannelDidChangeState:(RTCDataChannel*)channel {
  [self sendEvent:@{
    @"event" : @"dataChannelStateChanged",
    @"id" : [NSNumber numberWithInt:channel.channelId],
    @"state" : [self stringForDataChannelState:channel.readyState]
  }
      withChannel:channel];
}

// Called when a data buffer was successfully received.
- (void)dataChannel:(RTCDataChannel*)channel didReceiveMessageWithBuffer:(RTCDataBuffer*)buffer {
  // The payload stays NSData here; EventForSink and PostEventToDart convert
  // it for whichever transport delivers the event.
  [self sendEvent:@{
    @"event" : @"dataChannelReceiveMessage",
    @"id" : [NSNumber numberWithInt:channel.channelId],
    @"type" : buffer.isBinary ? @"binary" : @"text",
    @"data" : buffer.data ?: [NSData data]
  }
      withChannel:channel];
}

- (void)dataChannel:(RTCDataChannel*)channel didChangeBufferedAmount:(uint64_t)amount {
  [self sendEvent:@{
    @"event" : @"dataChannelBufferedAmountChange",
    @"id" : [NSNumber numberWithInt:channel.channelId],
    @"bufferedAmount" : [NSNumber numberWithLongLong:channel.bufferedAmount],
    @"changedAmount" : [NSNumber numberWithLongLong:amount]
  }
      withChannel:channel];
}

@end
