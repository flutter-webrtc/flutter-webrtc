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
  } else if ([method isEqualToString:@"frameCryptorFactoryCreateKeyProvider"]) {
    [self frameCryptorFactoryCreateKeyProvider:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderSetSharedKey"]) {
    [self keyProviderSetSharedKey:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderRatchetSharedKey"]) {
    [self keyProviderRatchetSharedKey:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderExportSharedKey"]) {
    [self keyProviderExportSharedKey:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderSetKey"]) {
    [self keyProviderSetKey:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderRatchetKey"]) {
    [self keyProviderRatchetKey:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderExportKey"]) {
    [self keyProviderExportKey:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderSetSifTrailer"]) {
    [self keyProviderSetSifTrailer:constraints result:result];
  } else if ([method isEqualToString:@"keyProviderDispose"]) {
    [self keyProviderDispose:constraints result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (RTCCryptorAlgorithm)getAlgorithm:(NSNumber*)algorithm {
  switch ([algorithm intValue]) {
    case 0:
      return RTCCryptorAlgorithmAesGcm;
    default:
      return RTCCryptorAlgorithmAesGcm;
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

  NSString* keyProviderId = constraints[@"keyProviderId"];
  if (keyProviderId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                               message:@"Invalid keyProviderId"
                               details:nil]);
    return;
  }

  RTCFrameCryptorKeyProvider* keyProvider = self.keyProviders[keyProviderId];
  if (keyProvider == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateFrameCryptorFailed"
                               message:@"Invalid keyProvider"
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

    RTCFrameCryptor* frameCryptor =
        [[RTCFrameCryptor alloc] initWithFactory:self.peerConnectionFactory
                                         rtpSender:sender
                                     participantId:participantId
                                         algorithm:[self getAlgorithm:algorithm]
                                        keyProvider:keyProvider];
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
    RTCFrameCryptor* frameCryptor =
        [[RTCFrameCryptor alloc] initWithFactory:self.peerConnectionFactory
                                         rtpReceiver:receiver
                                       participantId:participantId
                                           algorithm:[self getAlgorithm:algorithm]
                                          keyProvider:keyProvider];
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
  NSString* frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetKeyIndexFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor* frameCryptor = self.frameCryptors[frameCryptorId];
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
  result(@{@"result" : @YES});
}

- (void)frameCryptorGetKeyIndex:(nonnull NSDictionary*)constraints
                         result:(nonnull FlutterResult)result {
  NSString* frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetKeyIndexFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor* frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetKeyIndexFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }
  result(@{@"keyIndex" : [NSNumber numberWithInt:frameCryptor.keyIndex]});
}

- (void)frameCryptorSetEnabled:(nonnull NSDictionary*)constraints
                        result:(nonnull FlutterResult)result {
  NSString* frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorSetEnabledFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor* frameCryptor = self.frameCryptors[frameCryptorId];
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
  result(@{@"result" : enabled});
}

- (void)frameCryptorGetEnabled:(nonnull NSDictionary*)constraints
                        result:(nonnull FlutterResult)result {
  NSString* frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetEnabledFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor* frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorGetEnabledFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }
  result(@{@"enabled" : [NSNumber numberWithBool:frameCryptor.enabled]});
}

- (void)frameCryptorDispose:(nonnull NSDictionary*)constraints
                     result:(nonnull FlutterResult)result {
  NSString* frameCryptorId = constraints[@"frameCryptorId"];
  if (frameCryptorId == nil) {
    result([FlutterError errorWithCode:@"frameCryptorDisposeFailed"
                               message:@"Invalid frameCryptorId"
                               details:nil]);
    return;
  }
  RTCFrameCryptor* frameCryptor = self.frameCryptors[frameCryptorId];
  if (frameCryptor == nil) {
    result([FlutterError errorWithCode:@"frameCryptorDisposeFailed"
                               message:@"Invalid frameCryptor"
                               details:nil]);
    return;
  }
  [self.frameCryptors removeObjectForKey:frameCryptorId];
  frameCryptor.enabled = NO;
  result(@{@"result" : @"success"});
}

- (void)frameCryptorFactoryCreateKeyProvider:(nonnull NSDictionary*)constraints
                                     result:(nonnull FlutterResult)result {
  NSString* keyProviderId = [[NSUUID UUID] UUIDString];

  id keyProviderOptions = constraints[@"keyProviderOptions"];
  if (keyProviderOptions == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateKeyProviderFailed"
                               message:@"Invalid keyProviderOptions"
                               details:nil]);
    return;
  }

  NSNumber* sharedKey = keyProviderOptions[@"sharedKey"];
  if (sharedKey == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateKeyProviderFailed"
                               message:@"Invalid sharedKey"
                               details:nil]);
    return;
  }

  FlutterStandardTypedData* ratchetSalt = keyProviderOptions[@"ratchetSalt"];
  if (ratchetSalt == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateKeyProviderFailed"
                               message:@"Invalid ratchetSalt"
                               details:nil]);
    return;
  }

  NSNumber* ratchetWindowSize = keyProviderOptions[@"ratchetWindowSize"];
  if (ratchetWindowSize == nil) {
    result([FlutterError errorWithCode:@"frameCryptorFactoryCreateKeyProviderFailed"
                               message:@"Invalid ratchetWindowSize"
                               details:nil]);
    return;
  }

  NSNumber* failureTolerance = keyProviderOptions[@"failureTolerance"];

  FlutterStandardTypedData* uncryptedMagicBytes = keyProviderOptions[@"uncryptedMagicBytes"];

  NSNumber* keyRingSize = keyProviderOptions[@"keyRingSize"];

  NSNumber* discardFrameWhenCryptorNotReady = keyProviderOptions[@"discardFrameWhenCryptorNotReady"];
  
  RTCFrameCryptorKeyProvider* keyProvider =
      [[RTCFrameCryptorKeyProvider alloc] initWithRatchetSalt:ratchetSalt.data
                                           ratchetWindowSize:[ratchetWindowSize intValue]
                                               sharedKeyMode:[sharedKey boolValue]
                                         uncryptedMagicBytes: uncryptedMagicBytes != nil ? uncryptedMagicBytes.data : nil
                                            failureTolerance:failureTolerance != nil ? [failureTolerance intValue] : -1
                                                 keyRingSize:keyRingSize != nil ? [keyRingSize intValue] : 0
                             discardFrameWhenCryptorNotReady:discardFrameWhenCryptorNotReady != nil ? [discardFrameWhenCryptorNotReady boolValue] : NO];
  self.keyProviders[keyProviderId] = keyProvider;
  result(@{@"keyProviderId" : keyProviderId});
}

-(nullable RTCFrameCryptorKeyProvider *) getKeyProviderForId:(NSString*)keyProviderId result:(nonnull FlutterResult)result {
  if (keyProviderId == nil) {
    result([FlutterError errorWithCode:@"getKeyProviderForIdFailed"
                               message:@"Invalid keyProviderId"
                               details:nil]);
    return nil;
  }
  RTCFrameCryptorKeyProvider* keyProvider = self.keyProviders[keyProviderId];
  if (keyProvider == nil) {
    result([FlutterError errorWithCode:@"getKeyProviderForIdFailed"
                               message:@"Invalid keyProvider"
                               details:nil]);
    return nil;
  }
  return keyProvider;
}

- (void)keyProviderSetSharedKey:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {

  RTCFrameCryptorKeyProvider * keyProvider = [self getKeyProviderForId:constraints[@"keyProviderId"] result:result];
  if(keyProvider == nil) {
    return;
  }
 
  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"keyProviderSetKeyFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  FlutterStandardTypedData* key = constraints[@"key"];
  if (key == nil) {
    result([FlutterError errorWithCode:@"keyProviderSetKeyFailed"
                               message:@"Invalid key"
                               details:nil]);
    return;
  }

  [keyProvider setSharedKey:key.data withIndex:[keyIndex intValue]];
  result(@{@"result" : @YES});
}

- (void)keyProviderRatchetSharedKey:(nonnull NSDictionary*)constraints
                      result:(nonnull FlutterResult)result {
  RTCFrameCryptorKeyProvider * keyProvider = [self getKeyProviderForId:constraints[@"keyProviderId"] result:result];
  if(keyProvider == nil) {
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"keyProviderRatchetSharedKeyFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  NSData* newKey = [keyProvider ratchetSharedKey:[keyIndex intValue]];
  result(@{@"result" : newKey});
}


- (void)keyProviderExportSharedKey:(nonnull NSDictionary*)constraints
                      result:(nonnull FlutterResult)result {
  RTCFrameCryptorKeyProvider * keyProvider = [self getKeyProviderForId:constraints[@"keyProviderId"] result:result];
  if(keyProvider == nil) {
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"keyProviderExportSharedKeyFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  NSData* key = [keyProvider exportSharedKey:[keyIndex intValue]];
  result(@{@"result" : key});
}

- (void)keyProviderSetKey:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {
  RTCFrameCryptorKeyProvider * keyProvider = [self getKeyProviderForId:constraints[@"keyProviderId"] result:result];
  if(keyProvider == nil) {
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"keyProviderSetKeyFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  FlutterStandardTypedData* key = constraints[@"key"];
  if (key == nil) {
    result([FlutterError errorWithCode:@"keyProviderSetKeyFailed"
                               message:@"Invalid key"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"keyProviderSetKeyFailed"
                               message:@"Invalid participantId"
                               details:nil]);
    return;
  }

  [keyProvider setKey:key.data withIndex:[keyIndex intValue] forParticipant:participantId];
  result(@{@"result" : @YES});
}

- (void)keyProviderRatchetKey:(nonnull NSDictionary*)constraints
                      result:(nonnull FlutterResult)result {
  RTCFrameCryptorKeyProvider * keyProvider = [self getKeyProviderForId:constraints[@"keyProviderId"] result:result];
  if(keyProvider == nil) {
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"keyProviderRatchetKeyFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"keyProviderRatchetKeyFailed"
                               message:@"Invalid participantId"
                               details:nil]);
    return;
  }

  NSData* newKey = [keyProvider ratchetKey:participantId withIndex:[keyIndex intValue]];
  result(@{@"result" : newKey});
}

- (void)keyProviderExportKey:(nonnull NSDictionary*)constraints
                      result:(nonnull FlutterResult)result {
  RTCFrameCryptorKeyProvider * keyProvider = [self getKeyProviderForId:constraints[@"keyProviderId"] result:result];
  if(keyProvider == nil) {
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"keyProviderExportKeyFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"keyProviderExportKeyFailed"
                               message:@"Invalid participantId"
                               details:nil]);
    return;
  }

  NSData* key = [keyProvider exportKey:participantId withIndex:[keyIndex intValue]];
  result(@{@"result" : key});
}

- (void)keyProviderSetSifTrailer:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {
  RTCFrameCryptorKeyProvider * keyProvider = [self getKeyProviderForId:constraints[@"keyProviderId"] result:result];
  if(keyProvider == nil) {
    return;
  }

  FlutterStandardTypedData* sifTrailer = constraints[@"sifTrailer"];
  if (sifTrailer == nil) {
    result([FlutterError errorWithCode:@"keyProviderSetSifTrailerFailed"
                               message:@"Invalid key"
                               details:nil]);
    return;
  }

  [keyProvider setSifTrailer:sifTrailer.data];
  result(nil);
}

- (void)keyProviderDispose:(nonnull NSDictionary*)constraints result:(nonnull FlutterResult)result {
  NSString* keyProviderId = constraints[@"keyProviderId"];
  if (keyProviderId == nil) {
    result([FlutterError errorWithCode:@"getKeyProviderForIdFailed"
                               message:@"Invalid keyProviderId"
                               details:nil]);
    return;
  }
  [self.keyProviders removeObjectForKey:keyProviderId];
  result(@{@"result" : @"success"});
}

- (NSString*)stringFromState:(RTCFrameCryptorState)state {
  switch (state) {
    case RTCFrameCryptorStateNew:
      return @"new";
    case RTCFrameCryptorStateOk:
      return @"ok";
    case RTCFrameCryptorStateEncryptionFailed:
      return @"encryptionFailed";
    case RTCFrameCryptorStateDecryptionFailed:
      return @"decryptionFailed";
    case RTCFrameCryptorStateMissingKey:
      return @"missingKey";
    case RTCFrameCryptorStateKeyRatcheted:
      return @"keyRatcheted";
    case RTCFrameCryptorStateInternalError:
      return @"internalError";
    default:
      return @"unknown";
  }
}

#pragma mark - RTCFrameCryptorDelegate methods

- (void)frameCryptor:(RTC_OBJC_TYPE(RTCFrameCryptor) *)frameCryptor
    didStateChangeWithParticipantId:(NSString*)participantId
                          withState:(RTCFrameCryptorState)stateChanged {
  if (frameCryptor.eventSink) {
    postEvent(frameCryptor.eventSink, @{
      @"event" : @"frameCryptionStateChanged",
      @"participantId" : participantId,
      @"state" : [self stringFromState:stateChanged]
    });
  }
}

@end
