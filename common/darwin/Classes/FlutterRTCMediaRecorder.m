#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import "FlutterRTCMediaRecorder.h"
#include "libyuv.h"

@import CoreFoundation;
@import CoreImage;
@import CoreVideo;
@import AVFoundation;

@implementation FlutterRTCMediaRecorder {
    RTCVideoTrack* _videoTrack;
//    RTCAudioTrack* _audioTrack;
    AVAssetWriter* _assetWriter;
    AVAssetWriterInput* _assetWriterInput;
    AVAssetWriterInputPixelBufferAdaptor* _pixelBufferAdaptor;
    dispatch_queue_t _queue;
    NSMutableArray* _queuedFrames;
    uint64_t _startTimestampNs;
    uint32_t _frameCount;
    NSString* _path;
    bool _sessionStarted;
}

- (nullable instancetype)initWithMediaAtPath:(nonnull NSString *) path
                                  videoTrack:(nonnull RTCVideoTrack *) videoTrack;
//                                  audioTrack:(nonnull RTCAudioTrack *) audioTrack;
{
    self = [super init];
    if (self) {
        dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
        dispatch_queue_t recordingQueue = dispatch_queue_create("FlutterRTCMediaRecorder.queue", qos);
        _queue = recordingQueue;
        
        _queuedFrames = [[NSMutableArray alloc] initWithCapacity:10];
        
        _frameCount = 0;
        _videoTrack = videoTrack;
//        _audioTrack = audioTrack;
        _path = path;
        _sessionStarted = false;
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_path];
        if (fileExists) {
            NSLog(@"Warning! File already exists at %@", _path);
        }
        
        NSLog(@"Creating AVAssetWriter for path %@", _path);
        NSURL* url = [NSURL fileURLWithPath:_path];
        
        NSError* err;
        _assetWriter = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:&err];
        
        // TODO: Specify compression size.
        NSDictionary *videoCompressionSettings = @{
            AVVideoCodecKey: AVVideoCodecTypeH264,
            AVVideoWidthKey: @640,
            AVVideoHeightKey: @480
        };
        
        // https://developer.apple.com/documentation/avfoundation/avassetwriterinput?language=objc
        _assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        
        // Attention! We are not using a pixel buffer pool here because the pool
        // can only allocate one size, but the frames may come in many sizes.
        _pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterInput sourcePixelBufferAttributes:nil];
        
        bool canAddInput = [_assetWriter canAddInput:_assetWriterInput];
        if (canAddInput) {
            [_assetWriter addInput:_assetWriterInput];
            NSLog(@"AssetWriterInput added");
        } else {
            NSLog(@"Could not add AssetWriterInput");
        }
    }
    return self;
}

- (bool)isComplete
{
    return _assetWriter.status == AVAssetWriterStatusCompleted || _assetWriter.status == AVAssetWriterStatusFailed || _assetWriter.status == AVAssetWriterStatusCancelled;
}

- (bool)startRecordingWithResult:(nonnull FlutterResult)result;
{
    bool started = [_assetWriter startWriting];
    if (!started) {
        NSLog(@"AVAssetWriter startWriting failed");
        NSLog(@"AVAssetWriter status %ld, error %@", (long)_assetWriter.status, _assetWriter.error);
        NSLog(@"Error code 3 may imply the file already exists");
        
        result([FlutterError errorWithCode:@"StartRecordingFailed"
                                   message:@"Failed: AVAssetWriter startWriting"
                                   details:nil]);
        return false;
    }
    
    [_assetWriterInput requestMediaDataWhenReadyOnQueue:_queue usingBlock:^{
        while (self->_queuedFrames.count != 0 && self->_assetWriterInput.readyForMoreMediaData) {
            RTCVideoFrame* frame = [self->_queuedFrames objectAtIndex:0];
            [self->_queuedFrames removeObjectAtIndex:0];
            
            [self appendFrame:frame];
        }
    }];
    
    // Attention! If you don't start at 0 source time, then there will be no thumbnail
    // on PCs.
    // https://developer.apple.com/documentation/coremedia/cmtime-u58?language=objc
    CMTime cmtimestamp = CMTimeMake(0, 1000000000);
    [_assetWriter startSessionAtSourceTime:cmtimestamp];
    
    NSLog(@"AVAssetWriter started");
    [_videoTrack addRenderer:self];
    
    result(nil);
    return true;
}

- (void)stopRecordingWithResult:(nonnull FlutterResult)result;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_videoTrack removeRenderer:self];
        [self->_assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"Asset writer finished writing; 2 is 'AVAssetWriterStatusCompleted'; %ld", self->_assetWriter.status);
            
            if (self->_assetWriter.status == AVAssetWriterStatusCompleted) {
                result(nil);
            } else {
                NSString* message = [
                    NSString
                    stringWithFormat:@"Failed: AVAssetWriter finishWritingWithCompletionHandler code %ld",
                    (long)self->_assetWriter.status];
                
                result([FlutterError errorWithCode:@"StopRecordingFailed"
                                           message:message
                                           details:nil]);
            }
        }];
    });
}

- (void)storeStartFrameInfo:(nonnull RTCVideoFrame*) frame;
{
    uint64_t frameTimestamp = frame.timeStampNs;
    _startTimestampNs = frameTimestamp;
}

- (void)queueFrame:(nonnull RTCVideoFrame*) frame
{
    dispatch_async(_queue, ^{
        [self->_queuedFrames addObject:frame];
    });
}

- (bool)appendFrame:(nonnull RTCVideoFrame *)frame
{
    // Attention! We are not using a pixel buffer pool here because the pool
    // can only allocate one size, but the frames may come in many sizes.
    CVPixelBufferRef pixelBuffer = nil;
    bool converted = [FlutterRTCMediaRecorder
                      createCVPixelBufferFromFrame:frame
                      toBuffer:&pixelBuffer
                      fromPool:nil];
    
    if (converted) {
        uint64_t frameTimestampNs = frame.timeStampNs;
        uint64_t timestampRelativeToStart = frameTimestampNs - _startTimestampNs;
        
        // https://developer.apple.com/documentation/coremedia/cmtime-u58?language=objc
        // value / timescale = seconds
        CMTime cmtimestamp = CMTimeMake(timestampRelativeToStart, 1000000000);
        
        // https://developer.apple.com/documentation/avfoundation/avassetwriterinputpixelbufferadaptor?language=objc
        // The pixel buffer’s presentation time. The time you specify is relative to the time you called startSessionAtSourceTime: with.
        bool appended = [self->_pixelBufferAdaptor
                         appendPixelBuffer:pixelBuffer
                         withPresentationTime:cmtimestamp];
        
        CVPixelBufferRelease(pixelBuffer);
        
        if (appended) {
            _frameCount += 1;
            if (_frameCount % 10 == 0) {
                NSLog(@"%d frames appended", _frameCount);
            }
            
            return true;
        } else {
            NSLog(@"Warning! Could not append frame");
        }
    } else {
        NSLog(@"Warning! Failed to convert frame to CVPixelBuffer!");
    }
    
    return false;
}

// Inherited
- (void)setSize:(CGSize)size
{
}

// Inherited
- (void)renderFrame:(nullable RTCVideoFrame *)frame
{
    if (frame == nil) return;
    
    if (!_sessionStarted){
        NSLog(@"Starting Session");
        
        [self storeStartFrameInfo:frame];
        
        _sessionStarted = true;
    }
    
    [self queueFrame:frame];
}


+ (bool)createCVPixelBufferFromFrame:(nonnull RTCVideoFrame*)frame
                            toBuffer:(CVPixelBufferRef _Nullable * _Nonnull)pixelBufferRef
                            fromPool:(CVPixelBufferPoolRef _Nullable) pool;
{
    int32_t frameHeight = frame.height;
    int32_t frameWidth = frame.width;
    
    NSDictionary *pixelAttributes = @{
        (NSString*)kCVPixelBufferCGImageCompatibilityKey: @YES,
        (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES
    };
    
    CVReturn createResult;
    if (pool == nil)
    {
        createResult = CVPixelBufferCreate(kCFAllocatorDefault,
                                           frameWidth,
                                           frameHeight,
                                           kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                           (__bridge CFDictionaryRef)(pixelAttributes),
                                           pixelBufferRef);
    } else {
        // Attention!
        // Originally, I was specifying the pixel buffer pool attributes based on the first frame.
        // However, I noticed that frames sometimes came in with different sizes.
        // If the first frame is smaller than the incoming frame, then this will give segfault.
        // Additionally, this will always return a pixel buffer of the same size, which, when added
        // to the input, will result a small image on a green screen.
        createResult = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, pixelBufferRef);
    }
    
    if (createResult != kCVReturnSuccess) {
        NSLog(@"Unable to create cvpixelbuffer from pool %d", createResult);
        return false;
    }
    
    // https://chromium.googlesource.com/external/webrtc/+/refs/heads/main/sdk/objc/base/RTCVideoFrameBuffer.h
    // This guarantees the buffer will be RTCI420Buffer
    RTCI420Buffer *buffer = [frame.buffer toI420];
    
    // https://wiki.videolan.org/YUV#I420
    // The i420 buffer stores the data Planar YYYYYYYY U V.
    // https://developer.apple.com/documentation/accelerate/conversion/understanding_ypcbcr_image_formats?language=objc
    // https://chromium.googlesource.com/external/webrtc/+/HEAD/api/video/i420_buffer.cc
    // U and V planes must be the same Size!
    uint32_t strideY = [buffer strideY];
    uint32_t strideV = [buffer strideV];
    
    uint32_t yPlaneSize = buffer.height * strideY;
    uint32_t vPlaneSize = ((buffer.height + 1) / 2) * strideV;
    
    CVPixelBufferLockBaseAddress(*pixelBufferRef, 0);
    uint8_t* yDestPlane = CVPixelBufferGetBaseAddressOfPlane(*pixelBufferRef, 0);
    uint8_t const* ySrcPlane = [buffer dataY];
    memcpy(yDestPlane, ySrcPlane, yPlaneSize);
    
    // Interleave the UVPlane
    // YYYYYYYY UV
    uint8_t *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(*pixelBufferRef, 1);
    uint8_t const* uSrcPlane = [buffer dataU];
    uint8_t const* vSrcPlane = [buffer dataV];
    for (int i = 0; i <= vPlaneSize; i++)
    {
        uvDestPlane[i*2] = uSrcPlane[i];
        uvDestPlane[i*2+1] = vSrcPlane[i];
    }
    
    CVPixelBufferUnlockBaseAddress(*pixelBufferRef, 0);
    
    return true;
}


@end
