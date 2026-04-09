#import "FlutterDataPacketCryptor.h"
#import "FlutterRTCFrameCryptor.h"

#include <WebRTC/WebRTC.h>
#import <objc/runtime.h>

@implementation FlutterWebRTCPlugin (DataPacketCryptor)

- (void)handleDataPacketCryptorMethodCall:(nonnull FlutterMethodCall*)call
                                   result:(nonnull FlutterResult)result {
  NSDictionary* constraints = call.arguments;
  NSString* method = call.method;
  if ([method isEqualToString:@"createDataPacketCryptor"]) {
    [self createDataPacketCryptor:constraints result:result];
  } else if ([method isEqualToString:@"dataPacketCryptorEncrypt"]) {
    [self dataPacketCryptorEncrypt:constraints result:result];
  } else if ([method isEqualToString:@"dataPacketCryptorDecrypt"]) {
    [self dataPacketCryptorDecrypt:constraints result:result];
  } else if ([method isEqualToString:@"dataPacketCryptorDispose"]) {
    [self dataPacketCryptorDispose:constraints result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)createDataPacketCryptor:(nonnull NSDictionary*)constraints
                         result:(nonnull FlutterResult)result {
  NSNumber* algorithm = constraints[@"algorithm"];
  if (algorithm == nil) {
    result([FlutterError errorWithCode:@"createDataPacketCryptorFailed"
                               message:@"Invalid algorithm"
                               details:nil]);
    return;
  }

  NSString* keyProviderId = constraints[@"keyProviderId"];
  if (keyProviderId == nil) {
    result([FlutterError errorWithCode:@"createDataPacketCryptorFailed"
                               message:@"Invalid keyProviderId"
                               details:nil]);
    return;
  }

  RTCFrameCryptorKeyProvider* keyProvider = self.keyProviders[keyProviderId];
  if (keyProvider == nil) {
    result([FlutterError errorWithCode:@"createDataPacketCryptorFailed"
                               message:@"Invalid keyProvider"
                               details:nil]);
    return;
  }

  RTCDataPacketCryptor* dataPacketCryptor =
      [[RTCDataPacketCryptor alloc] initWithAlgorithm:[self getAlgorithm:algorithm]
                                          keyProvider:keyProvider];
  NSString* dataCryptorId = [[NSUUID UUID] UUIDString];
  self.dataCryptors[dataCryptorId] = dataPacketCryptor;

  result(@{@"dataCryptorId" : dataCryptorId});
}

- (void)dataPacketCryptorDispose:(nonnull NSDictionary*)constraints
                          result:(nonnull FlutterResult)result {
  NSString* dataCryptorId = constraints[@"dataCryptorId"];
  if (dataCryptorId == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDisposeFailed"
                               message:@"Invalid dataCryptorId"
                               details:nil]);
    return;
  }

  RTCDataPacketCryptor* dataPacketCryptor = self.dataCryptors[dataCryptorId];
  if (dataPacketCryptor == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDisposeFailed"
                               message:@"Invalid dataCryptor"
                               details:nil]);
    return;
  }

  [self.dataCryptors removeObjectForKey:dataCryptorId];
  result(nil);
}

- (void)dataPacketCryptorEncrypt:(nonnull NSDictionary*)constraints
                          result:(nonnull FlutterResult)result {
  NSString* dataCryptorId = constraints[@"dataCryptorId"];
  if (dataCryptorId == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorEncryptFailed"
                               message:@"Invalid dataCryptorId"
                               details:nil]);
    return;
  }

  FlutterStandardTypedData* data = constraints[@"data"];
  if (data == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorEncryptFailed"
                               message:@"Invalid data"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorEncryptFailed"
                               message:@"Invalid iv"
                               details:nil]);
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorEncryptFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  RTCDataPacketCryptor* dataPacketCryptor = self.dataCryptors[dataCryptorId];
  if (dataPacketCryptor == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorEncryptFailed"
                               message:@"Invalid dataCryptor"
                               details:nil]);
    return;
  }

  RTC_OBJC_TYPE(RTCEncryptedPacket)* encryptedData =
      [dataPacketCryptor encrypt:participantId keyIndex:keyIndex.unsignedIntValue data:data.data];
  if (encryptedData == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorEncryptFailed"
                               message:@"Encrypt failed"
                               details:nil]);
    return;
  }

  result(@{
    @"data" : encryptedData.data,
    @"iv" : encryptedData.iv,
    @"keyIndex" : @(encryptedData.keyIndex)
  });
}

- (void)dataPacketCryptorDecrypt:(nonnull NSDictionary*)constraints
                          result:(nonnull FlutterResult)result {
  NSString* dataCryptorId = constraints[@"dataCryptorId"];
  if (dataCryptorId == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDecryptFailed"
                               message:@"Invalid dataCryptorId"
                               details:nil]);
    return;
  }

  RTCDataPacketCryptor* dataPacketCryptor = self.dataCryptors[dataCryptorId];
  if (dataPacketCryptor == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDecryptFailed"
                               message:@"Invalid dataCryptor"
                               details:nil]);
    return;
  }

  FlutterStandardTypedData* data = constraints[@"data"];
  if (data == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDecryptFailed"
                               message:@"Invalid data"
                               details:nil]);
    return;
  }

  FlutterStandardTypedData* iv = constraints[@"iv"];
  if (iv == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDecryptFailed"
                               message:@"Invalid iv"
                               details:nil]);
    return;
  }

  NSNumber* keyIndex = constraints[@"keyIndex"];
  if (keyIndex == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDecryptFailed"
                               message:@"Invalid keyIndex"
                               details:nil]);
    return;
  }

  NSString* participantId = constraints[@"participantId"];
  if (participantId == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDecryptFailed"
                               message:@"Invalid participantId"
                               details:nil]);
    return;
  }

  RTCEncryptedPacket* encryptedPacket =
      [[RTCEncryptedPacket alloc] initWithData:data.data
                                            iv:iv.data
                                      keyIndex:keyIndex.unsignedIntValue];
  NSData* decryptedData = [dataPacketCryptor decrypt:participantId encryptedPacket:encryptedPacket];
  if (decryptedData == nil) {
    result([FlutterError errorWithCode:@"dataPacketCryptorDecryptFailed"
                               message:@"Decrypt failed"
                               details:nil]);
    return;
  }

  result(@{@"data" : decryptedData});
}

@end
