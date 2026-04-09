#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <WebRTC/WebRTC.h>

#import "FlutterWebRTCPlugin.h"

@interface RTCFrameCryptor (Flutter) <FlutterStreamHandler>
@property(nonatomic, strong, nullable) FlutterEventSink eventSink;
@property(nonatomic, strong, nullable) FlutterEventChannel* eventChannel;
@end


@interface FlutterWebRTCPlugin (FrameCryptor) <RTCFrameCryptorDelegate>

- (BOOL)handleFrameCryptorMethodCall:(nonnull FlutterMethodCall*)call result:(nonnull FlutterResult)result;

- (void)frameCryptorFactoryCreateFrameCryptor:(nonnull NSDictionary*)constraints
                                       result:(nonnull FlutterResult)result;

- (void)frameCryptorSetKeyIndex:(nonnull NSDictionary*)constraints
                        result:(nonnull FlutterResult)result;

- (void)frameCryptorGetKeyIndex:(nonnull NSDictionary*)constraints
                        result:(nonnull FlutterResult)result;

- (void)frameCryptorSetEnabled:(nonnull NSDictionary*)constraints
                          result:(nonnull FlutterResult)result; 

- (void)frameCryptorGetEnabled:(nonnull NSDictionary*)constraints
                            result:(nonnull FlutterResult)result;   

- (void)frameCryptorDispose:(nonnull NSDictionary*)constraints
                            result:(nonnull FlutterResult)result;

- (void)frameCryptorFactoryCreateKeyProvider:(nonnull NSDictionary*)constraints
                            result:(nonnull FlutterResult)result;

- (void)keyProviderSetKey:(nonnull NSDictionary*)constraints
                            result:(nonnull FlutterResult)result;

- (void)keyProviderRatchetKey:(nonnull NSDictionary*)constraints
                            result:(nonnull FlutterResult)result;

- (void)keyProviderDispose:(nonnull NSDictionary*)constraints
                            result:(nonnull FlutterResult)result;

- (RTCCryptorAlgorithm)getAlgorithm:(nonnull NSNumber*)algorithm;

@end
