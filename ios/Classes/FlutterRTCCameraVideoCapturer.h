#import <WebRTC/WebRTC.h>

@interface FlutterRTCCameraVideoCapturer: RTCCameraVideoCapturer

- (void)captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;

- (void)setLandscapeMode:(BOOL)landscapeMode;

- (void)setCameraPosition:(AVCaptureDevicePosition)position;

@end