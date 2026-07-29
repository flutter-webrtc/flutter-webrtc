//
//  FlutterBroadcastScreenCapturer.m
//  RCTWebRTC
//
//  Created by Alex-Dan Bumbu on 06/01/2021.
//

#import "FlutterBroadcastScreenCapturer.h"
#import "FlutterSocketConnection.h"
#import "FlutterSocketConnectionFrameReader.h"

NSString* const kRTCScreensharingSocketFD = @"rtc_SSFD";
NSString* const kRTCAppGroupIdentifier = @"RTCAppGroupIdentifier";
NSString* const kRTCScreenSharingExtension = @"RTCScreenSharingExtension";

@interface FlutterBroadcastScreenCapturer ()

@property(nonatomic, retain) FlutterSocketConnectionFrameReader* capturer;

@end

@interface FlutterBroadcastScreenCapturer (Private)

@property(nonatomic, readonly) NSString* appGroupIdentifier;

@end

@implementation FlutterBroadcastScreenCapturer

- (void)startCapture {
  if (!self.appGroupIdentifier) {
    return;
  }

  NSString* socketFilePath = [self filePathForApplicationGroupIdentifier:self.appGroupIdentifier];
  FlutterSocketConnectionFrameReader* frameReader =
      [[FlutterSocketConnectionFrameReader alloc] initWithDelegate:self.delegate];
  FlutterSocketConnection* connection =
      [[FlutterSocketConnection alloc] initWithFilePath:socketFilePath];
  self.capturer = frameReader;
  [self.capturer startCaptureWithConnection:connection];
}

- (void)stopCapture {
  [self.capturer stopCapture];
}
- (void)stopCaptureWithCompletionHandler:(nullable void (^)(void))completionHandler {
  [self stopCapture];
  if (completionHandler != nil) {
    completionHandler();
  }
}
// MARK: Private Methods

- (NSString*)appGroupIdentifier {
  NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
  return infoDictionary[kRTCAppGroupIdentifier];
}

- (NSString*)filePathForApplicationGroupIdentifier:(nonnull NSString*)identifier {
  NSURL* sharedContainer =
      [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:identifier];
  NSString* socketFilePath =
      [[sharedContainer URLByAppendingPathComponent:kRTCScreensharingSocketFD] path];

  return socketFilePath;
}

@end
