#import "FlutterRTCFrameCryptor.h"

#import <objc/runtime.h>

@implementation RTCFrameCryptor (Flutter)

- (FlutterEventSink)eventSink {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventSink:(FlutterEventSink)eventSink {
  objc_setAssociatedObject(self, @selector(eventSink), eventSink,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEventQueue:(NSArray<id>*)eventQueue {
  objc_setAssociatedObject(self, @selector(eventQueue), eventQueue,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventChannel*)eventChannel {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventChannel:(FlutterEventChannel*)eventChannel {
  objc_setAssociatedObject(self, @selector(eventChannel), eventChannel,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  self.eventSink = nil;
  return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
  self.eventSink = sink;
  return nil;
}
@end

@implementation FlutterWebRTCPlugin (FrameCryptor)

- (void)handleFrameCryptorMethodCall:(nonnull FlutterMethodCall*)call
                              result:(nonnull FlutterResult)result {
  NSDictionary* constraints = call.arguments;
  NSString* method = call.method;
  if ([method isEqualToString:@"frameCryptorFactoryCreateFrameCryptor"]) {
    [self frameCryptorFactoryCreateFrameCryptor:constraints result:result];
  } else if ([method isEqualToString:@"frameCryptorSetKeyIndex"]) {
    [self frameCryptorSetKeyIndex:constraints result:result];
  } else if ([method isEqualToString:@"frameCryptorGetKeyIndex"]) {
    [self frameCryptorGetKeyIndex:constraints result:result];
  } else if ([method isEqualToString:@"frameCryptorSetEnabled"]) {
    [self frameCryptorSetEnabled:constraints result:result];
  } else if ([method isEqualToString:@"frameCryptorGetEnabled"]) {
    [self frameCryptorGetEnabled:constraints result:result];
  } else if ([method isEqualToString:@"frameCryptorDispose"]) {
    [self frameCryptorDispose:constraints result:result];
  } else if ([method isEqualToString:@"frameCryptorFactoryCreateKeyManager"]) {
    [self frameCryptorFactoryCreateKeyManager:constraints result:result];
  } else if ([method isEqualToString:@"keyManagerSetKey"]) {
    [self keyManagerSetKey:constraints result:result];
  } else if ([method isEqualToString:@"keyManagerSetKeys"]) {
    [self keyManagerSetKeys:constraints result:result];
  } else if ([method isEqualToString:@"keyManagerGetKeys"]) {
    [self keyManagerGetKeys:constraints result:result];
  } else if ([method isEqualToString:@"keyManagerDispose"]) {
    [self keyManagerDispose:constraints result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (RTCCyrptorAlgorithm) getAlgorithm:(NSNumber*)algorithm {
  switch ([algorithm intValue]) {
    case 0:
      return RTCCyrptorAlgorithmAesGcm;
    case 1:
      return RTCCyrptorAlgorithmAesCbc;
    default:
      return RTCCyrptorAlgorithmAesGcm;
  }
}

- (void)frameCryptorFactoryCreateFrameCryptor:(nonnull NSDictionary*)constraints
                                       result:(nonnull FlutterResult)result {
  NSString* peerConnectionId = constraints[@"peerConnectionId"];
  RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
  if (peerConnection == nil) {
    result([FlutterError
        errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
              message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
              details:nil]);
    return;
  }

  NSNumber* algorithm = constraints[@"algorithm"];
  if (algorithm == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                               message:@"Invalid algorithm"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                               message:@"Invalid participantId"
                               details:nil]);
    return;
  }

  NSString* keyManagerId = constraints[@"keyManagerId"];
  if (keyManagerId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                               message:@"Invalid keyManagerId"
                               details:nil]);
    return;
  }

  RTCFrameCryptorKeyManager* keyManager = self.keyManagers[keyManagerId];
  if (keyManager == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                               message:@"Invalid keyManager"
                               details:nil]);
    return;
  }

  NSString* type = constraints[@"type"];
  NSString* rtpSenderId = constraints[@"rtpSenderId"];
  NSString* rtpReceiverId = constraints[@"rtpReceiverId"];

  if ([type isEqualToString:@"sender"]) {
    RTCRtpSender* sender = [self getRtpSenderById:peerConnection Id:rtpSenderId];
    if (sender == nil) {
      result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                                 message:[NSString stringWithFormat:@"Error: sender not found!"]
                                 details:nil]);
      return;
    }

    RTCFrameCryptor *frameCryptor = [[RTCFrameCryptor alloc] initWithRtpSender:sender
                                                        participantId:participantId
                                                            algorithm:[self getAlgorithm:algorithm]
                                                           keyManager:keyManager];
    NSString* frameCryptorId = [[NSUUID UUID] UUIDString];

    FlutterEventChannel* eventChannel = [FlutterEventChannel
        eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/frameCryptorEvent%@",
                                                        frameCryptorId]
             binaryMessenger:self.messenger];

    frameCryptor.eventChannel = eventChannel;
    [eventChannel setStreamHandler:frameCryptor];
    frameCryptor.delegate = self;

    self.frameCryptors[frameCryptorId] = frameCryptor;
    result(@{@"frameCryptorId" : frameCryptorId});
  } else if ([type isEqualToString:@"receiver"]) {
    RTCRtpReceiver* receiver = [self getRtpReceiverById:peerConnection Id:rtpReceiverId];
    if (receiver == nil) {
      result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                                 message:[NSString stringWithFormat:@"Error: receiver not found!"]
                                 details:nil]);
      return;
    }
    RTCFrameCryptor *frameCryptor = [[RTCFrameCryptor alloc] initWithRtpReceiver:receiver
                                                          participantId:participantId
                                                              algorithm:[self getAlgorithm:algorithm]
                                                             keyManager:keyManager];
    NSString* frameCryptorId = [[NSUUID UUID] UUIDString];
    FlutterEventChannel* eventChannel = [FlutterEventChannel
        eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/frameCryptorEvent%@",
                                                        frameCryptorId]
             binaryMessenger:self.messenger];

    frameCryptor.eventChannel = eventChannel;
    [eventChannel setStreamHandler:frameCryptor];
    frameCryptor.delegate = self;
    self.frameCryptors[frameCryptorId] = frameCryptor;
    result(@{@"frameCryptorId" : frameCryptorId});
  } else {
    result([FlutterError errorWithCode:@"InvalidArgument" message:@"Invalid type" details:nil]);
    return;
  }
}

- (void)frameCryptorSetKeyIndex:(nonnull NSDictionary*)constraints
                         result:(nonnull FlutterResult)result {
  NSString *frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetKeyIndexFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor *frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetKeyIndexFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetKeyIndexFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }
  [frameCryptor setKeyIndex:[keyIndex intValue]];
  result(@{@"result": @YES});
}

- (void)frameCryptorGetKeyIndex:(nonnull NSDictionary*)constraints
                         result:(nonnull FlutterResult)result {
  NSString *frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetKeyIndexFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor *frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetKeyIndexFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }
  result(@{@"keyIndex": [NSNumber numberWithInt:frameCryptor.keyIndex]});
}

- (void)frameCryptorSetEnabled:(nonnull NSDictionary*)constraints
                        result:(nonnull FlutterResult)result {
  NSString *frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetEnabledFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor *frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetEnabledFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }

  NSNumber* enabled = constraints[@"enabled"];
  if (enabled == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetEnabledFailed"
                               message:@"Invalid enabled"
                               details:nil]);
    return;
  }
  frameCryptor.enabled = [enabled boolValue];
  result(@{@"result": enabled});
}

- (void)frameCryptorGetEnabled:(nonnull NSDictionary*)constraints
                        result:(nonnull FlutterResult)result {
  NSString *frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetEnabledFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor *frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetEnabledFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }
  result(@{@"enabled": [NSNumber numberWithBool:frameCryptor.enabled]});
}

- (void)frameCryptorDispose:(nonnull NSDictionary*)constraints
                     result:(nonnull FlutterResult)result {
  NSString *frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorDisposeFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor *frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorDisposeFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }
  [self.frameCryptors removeObjectForKey:frameCryptorId];
  frameCryptor.enabled = NO;
  result(@{@"result": @"success"});
}

- (void)frameCryptorFactoryCreateKeyManager:(nonnull NSDictionary*)constraints
                                     result:(nonnull FlutterResult)result {
  NSString *keyManagerId = [[NSUUID UUID] UUIDString];
  RTCFrameCryptorKeyManager *keyManager = [[RTCFrameCryptorKeyManager alloc] init];
  self.keyManagers[keyManagerId] = keyManager;
  result(@{@"keyManagerId": keyManagerId});
}

- (void)keyManagerSetKey:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {
 NSString *keyManagerId = constraints[@"keyManagerId"];
  if (keyManagerId == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeyFailed"
                               message:@"Invalid keyManagerId"
                               details:nil]);
    return;
  }
  RTCFrameCryptorKeyManager *keyManager = self.keyManagers[keyManagerId];
  if (keyManager == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeyFailed"
                               message:@"Invalid keyManager"
                               details:nil]);
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeyFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  FlutterStandardTypedData* key = constraints[@"key"];
  if (key == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeyFailed"
                               message:@"Invalid key"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeyFailed"
                               message:@"Invalid participantId"
                               details:nil]);
    return;
  }

  [keyManager setKey:key.data withIndex:[keyIndex intValue] forParticipant:participantId];
  result(@{@"result": @YES});
}

- (void)keyManagerSetKeys:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {
 NSString *keyManagerId = constraints[@"keyManagerId"];
  if (keyManagerId == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeysFailed"
                               message:@"Invalid keyManagerId"
                               details:nil]);
    return;
  }
  RTCFrameCryptorKeyManager *keyManager = self.keyManagers[keyManagerId];
  if (keyManager == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeysFailed"
                               message:@"Invalid keyManager"
                               details:nil]);
    return;
  }


  NSArray<FlutterStandardTypedData*> *keys = constraints[@"keys"];
  if (keys == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeysFailed"
                               message:@"Invalid keys"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"keyManagerSetKeysFailed"
                               message:@"Invalid participantId"
                               details:nil]);
    return;
  }
  NSMutableArray<NSData*>* keysData = [NSMutableArray array];
  NSEnumerator* enumerator = [keys objectEnumerator];
  FlutterStandardTypedData* object;
  while ((object = enumerator.nextObject) != nil) {
    [keysData addObject:object.data];
  }

  [keyManager setKeys:keysData forParticipant:participantId];
  result(@{@"result": @YES});
}

- (void)keyManagerGetKeys:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {
  NSString *keyManagerId = constraints[@"keyManagerId"];
    if (keyManagerId == nil) {
      result([FlutterError errorWithCode:@"keyManagerGetKeysFailed"
                                message:@"Invalid keyManagerId"
                                details:nil]);
      return;
    }
    RTCFrameCryptorKeyManager *keyManager = self.keyManagers[keyManagerId];
    if (keyManager == nil) {
      result([FlutterError errorWithCode:@"keyManagerGetKeysFailed"
                                message:@"Invalid keyManager"
                                details:nil]);
      return;
    }
  
    NSString* participantId = constraints[@"participantId"];
    if (participantId == nil) {
      result([FlutterError errorWithCode:@"keyManagerGetKeysFailed"
                                message:@"Invalid participantId"
                                details:nil]);
      return;
    }
  
    NSArray<NSData*>* keys = [keyManager getKeys:participantId];
    NSMutableArray<FlutterStandardTypedData*>* keysData = [NSMutableArray array];
    NSEnumerator* enumerator = [keys objectEnumerator];
    NSData* object;
    while ((object = enumerator.nextObject) != nil) {
      [keysData addObject:[FlutterStandardTypedData typedDataWithBytes:object]];
    }
  
    result(@{@"keys": keysData});
}

- (void)keyManagerDispose:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {
  NSString *keyManagerId = constraints[@"keyManagerId"];
  if (keyManagerId == nil) {
    result([FlutterError errorWithCode:@"keyManagerDisposeFailed"
                               message:@"Invalid keyManagerId"
                               details:nil]);
    return;
  }
  RTCFrameCryptorKeyManager *keyManager = self.keyManagers[keyManagerId];
  if (keyManager == nil) {
    result([FlutterError errorWithCode:@"keyManagerDisposeFailed"
                               message:@"Invalid keyManager"
                               details:nil]);
    return;
  }
  [self.keyManagers removeObjectForKey:keyManagerId];
  result(@{@"result": @"success"});
}

- (NSString*) stringFromState:(RTCFrameCryptorErrorState)state {
  switch (state) {
    case RTCFrameCryptorErrorStateNew:
      return @"new";
    case RTCFrameCryptorErrorStateOk:
      return @"ok";
    case RTCFrameCryptorErrorStateEncryptionFailed:
      return @"encryptionFailed";
    case RTCFrameCryptorErrorStateDecryptionFailed:
      return @"decryptionFailed";
    case RTCFrameCryptorErrorStateMissingKey:
      return @"missingKey";
    case RTCFrameCryptorErrorStateInternalError:
      return @"internalError";
    default:
      return @"unknown";
  }
}

#pragma mark - RTCFrameCryptorDelegate methods

- (void)frameCryptor
    : (RTC_OBJC_TYPE(RTCFrameCryptor) *)frameCryptor didStateChangeWithParticipantId
    : (NSString *)participantId withState : (RTCFrameCryptorErrorState)stateChanged {

      if(frameCryptor.eventSink) {
        frameCryptor.eventSink(@{
          @"event": @"stateChanged",
          @"participantId": participantId,
          @"state": [self stringFromState:stateChanged]
        });
      }
    }

@end
