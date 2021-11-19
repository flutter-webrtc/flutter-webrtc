#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif


#import "FlutterRTCMediaRecorder.h"
#include "libyuv.h"

void interleavedcpy(uint8_t* dest, uint8_t const* srcA, uint8_t const* srcB, uint32_t size)
{
    for (int i = 0; i <= size; i++)
    {
        dest[i*2] = srcA[i];
        dest[i*2+1] = srcB[i];
    }
}


@import CoreFoundation;
@import CoreImage;
@import CoreVideo;
@import AVFoundation;

@implementation FlutterRTCMediaRecorder {
    RTCVideoTrack* _videoTrack;
    AVAssetWriter* _assetWriter;
    AVAssetWriterInput* _assetWriterInput;
    AVAssetWriterInputPixelBufferAdaptor* _pixelBufferAdaptor;
    dispatch_queue_t _queue;
    NSMutableArray* _queuedFrames;
    uint64_t _startTimestampNs;
    uint32_t _frameCount;
    NSString* _path;
    bool _sessionStarted;
    FlutterResult _result;
}

- (instancetype)initWithMediaAtPath:(NSString *)path videoTrack:(RTCVideoTrack *)track result:(FlutterResult)result
{
    self = [super init];
    if (self) {
        dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
        dispatch_queue_t recordingQueue = dispatch_queue_create("recordingQueue", qos);
        _queue = recordingQueue;
        
        _queuedFrames = [[NSMutableArray alloc] initWithCapacity:10];
        
        _frameCount = 0;
        _videoTrack = track;
        _path = path;
        _result = result;
        _sessionStarted = false;
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_path];
        if (fileExists) {
            NSLog(@"File already exists at %@", _path);
        }
        
        NSLog(@"Creating AVAssetWriter for path %@", _path);
        NSURL* url = [NSURL fileURLWithPath:_path];
        
        NSError* err;
        _assetWriter = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:&err];
        
//        NSNumber* frameWidth = [NSNumber numberWithInt:frame.width]; // 1280
//        NSNumber* frameHeight = [NSNumber numberWithInt:frame.height]; // 720
        NSDictionary *videoCompressionSettings = @{
            AVVideoCodecKey: AVVideoCodecTypeH264,
            AVVideoWidthKey: @640,
            AVVideoHeightKey: @480
        };
        
        // https://developer.apple.com/documentation/avfoundation/avassetwriterinput?language=objc
        _assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        
//        NSNumber* pixelType = [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
        NSDictionary *pixelAttributes = @{
            (NSString*)kCVPixelBufferCGImageCompatibilityKey: @YES,
            (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES,
        };
        
        _pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterInput sourcePixelBufferAttributes:pixelAttributes];
        
        bool canAddInput = [_assetWriter canAddInput:_assetWriterInput];
        if (canAddInput) {
            [_assetWriter addInput:_assetWriterInput];
            NSLog(@"AssetWriterInput added");
        } else {
            NSLog(@"Could not add AssetWriterInput");
            return false;
        }
        
        

    }
    return self;
}

- (void)setSize:(CGSize)size
{
}

+ (bool)createCVPixelBufferFromFrame:(RTCVideoFrame*)frame toBuffer:(CVPixelBufferRef*)pixelBufferRef fromPool:(nullable CVPixelBufferPoolRef) pool
{
    // NSLog(@"Converting frame to CVPixelBuffer.");
    int32_t frameHeight = frame.height;
    int32_t frameWidth = frame.width;
    
    NSDictionary *pixelAttributes = @{(NSString*)kCVPixelBufferCGImageCompatibilityKey: @YES, (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    
    if (pool == nil)
    {
        CVReturn createResult = CVPixelBufferCreate(kCFAllocatorDefault,
                                                    frameWidth,
                                                    frameHeight,
                                                    kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                                    (__bridge CFDictionaryRef)(pixelAttributes),
                                                    pixelBufferRef);
        
        if (createResult != kCVReturnSuccess) {
            NSLog(@"Unable to create cvpixelbuffer %d", createResult);
            return false;
        }
    } else {
        CVReturn createResult = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, pixelBufferRef);
        
        if (createResult != kCVReturnSuccess) {
            NSLog(@"Unable to create cvpixelbuffer from pool %d", createResult);
            return false;
        }
    }
    
    // https://wiki.videolan.org/YUV#I420
    RTCI420Buffer *buffer = [frame.buffer toI420];
    
    // The i420 buffer stores the data Planar
    // https://developer.apple.com/documentation/accelerate/conversion/understanding_ypcbcr_image_formats?language=objc
    // https://chromium.googlesource.com/external/webrtc/+/HEAD/api/video/i420_buffer.cc
    
    uint32_t strideY = [buffer strideY];
    uint32_t strideU = [buffer strideU];
    uint32_t strideV = [buffer strideV];
    
    uint32_t yPlaneSize = buffer.height * strideY;
    // These two must be the same size!
    // uint32_t uPlaneSize = ((buffer.height + 1) / 2) * strideU;
    uint32_t vPlaneSize = ((buffer.height + 1) / 2) * strideV;
    
    CVPixelBufferLockBaseAddress(*pixelBufferRef, 0);
    uint8_t* yDestPlane = CVPixelBufferGetBaseAddressOfPlane(*pixelBufferRef, 0);
    uint8_t const* ySrcPlane = [buffer dataY];
    memcpy(yDestPlane, ySrcPlane, yPlaneSize);
    
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

- (int)startRecording
{
    bool started = [_assetWriter startWriting];
    if (!started) {
        NSLog(@"AVAssetWriter startWriting failed");
        NSLog(@"AVAssetWriter status %ld, error %@", (long)_assetWriter.status, _assetWriter.error);
        NSLog(@"Error code 3 may imply the file already exists");
        return false;
    }
    
    [_assetWriterInput requestMediaDataWhenReadyOnQueue:_queue usingBlock:^{
        // NSLog(@"AVAssetWriterInput requestMediaDataWhenReady with %lu frames.", self->_queuedFrames.count);
        while (self->_queuedFrames.count != 0 && self->_assetWriterInput.readyForMoreMediaData) {
            RTCVideoFrame* frame = [self->_queuedFrames objectAtIndex:0];
            [self->_queuedFrames removeObjectAtIndex:0];
            
            [self appendFrame:frame];
        }
    }];
    
    NSLog(@"AVAssetWriter started");
    [_videoTrack addRenderer:self];
    
    return 1;
}

- (bool)stopRecording
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_videoTrack removeRenderer:self];
        [self->_assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"Asset writer finished writing; 2 is 'AVAssetWriterStatusCompleted'; %ld", self->_assetWriter.status);
        }];
    });
    
    return true;
}

- (bool)initializeRecording:(RTCVideoFrame*) frame
{
    NSNumber* frameWidth = [NSNumber numberWithInt:frame.width]; // 1280
    NSNumber* frameHeight = [NSNumber numberWithInt:frame.height]; // 720
    NSDictionary *videoCompressionSettings = @{
        AVVideoCodecKey: AVVideoCodecTypeH264,
        AVVideoWidthKey: @640,
        AVVideoHeightKey: @480
    };
    
    // https://developer.apple.com/documentation/avfoundation/avassetwriterinput?language=objc
    _assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
    
    NSNumber* pixelType = [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
    NSDictionary *pixelAttributes = @{
        (NSString*)kCVPixelBufferCGImageCompatibilityKey: @YES,
        (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES,
    };
    
    _pixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterInput sourcePixelBufferAttributes:pixelAttributes];
    
    bool canAddInput = [_assetWriter canAddInput:_assetWriterInput];
    if (canAddInput) {
        [_assetWriter addInput:_assetWriterInput];
        NSLog(@"AssetWriterInput added");
    } else {
        NSLog(@"Could not add AssetWriterInput");
        return false;
    }
    
    bool started = [_assetWriter startWriting];
    if (!started) {
        NSLog(@"AVAssetWriter startWriting failed");
        NSLog(@"AVAssetWriter status %ld, error %@", (long)_assetWriter.status, _assetWriter.error);
        NSLog(@"Error code 3 may imply the file already exists");
        return false;
    }
    
    [_assetWriterInput requestMediaDataWhenReadyOnQueue:_queue usingBlock:^{
        // NSLog(@"AVAssetWriterInput requestMediaDataWhenReady with %lu frames.", self->_queuedFrames.count);
        while (self->_queuedFrames.count != 0 && self->_assetWriterInput.readyForMoreMediaData) {
            RTCVideoFrame* frame = [self->_queuedFrames objectAtIndex:0];
            [self->_queuedFrames removeObjectAtIndex:0];
            
            [self appendFrame:frame];
        }
    }];
    
    
    return true;
}

- (void)queueFrame:(RTCVideoFrame*) frame
{
    dispatch_async(_queue, ^{
        [self->_queuedFrames addObject:frame];
    });
}

- (bool)appendFrame:(RTCVideoFrame *)frame
{
    CVPixelBufferRef pixelBuffer = nil;
    bool converted = [FlutterRTCMediaRecorder createCVPixelBufferFromFrame:frame toBuffer:&pixelBuffer fromPool:nil];
    
    if (converted) {
        uint64_t frameTimestamp = frame.timeStampNs;
        uint64_t timestampRelativeToStart = frameTimestamp - _startTimestampNs;
        // https://developer.apple.com/documentation/coremedia/cmtime-u58?language=objc
        // value/timescale = seconds
        CMTime cmtimestamp = CMTimeMake(timestampRelativeToStart, 1000000000);
        
        //https://developer.apple.com/documentation/avfoundation/avassetwriterinputpixelbufferadaptor?language=objc
        
        // The pixel buffer’s presentation time. The time you specify is relative to the time you called startSessionAtSourceTime: with.
        
        bool appended = [self->_pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:cmtimestamp];
        
        CVPixelBufferRelease(pixelBuffer);
        
        if (!appended) {
            NSLog(@"Could not append frame");
        } else {
            // NSLog(@"Frame appended");
            _frameCount += 1;
            if (_frameCount % 10 == 0) {
                NSLog(@"%d frames appended", _frameCount);
            }
            return true;
        }
    } else {
        NSLog(@"Failed to convert frame to CVPixelBuffer!");
    }
    
    return false;
}

- (void)renderFrame:(nullable RTCVideoFrame *)frame
{
    if (frame == nil) return;
#if TARGET_OS_IPHONE
    //    if (_assetWriter.status != AVAssetWriterStatusWriting) {
    if (!_sessionStarted){
        NSLog(@"Starting Session");
//        [self initializeRecording:frame];
        
        _sessionStarted = true;
        uint64_t frameTimestamp = frame.timeStampNs;
        _startTimestampNs = frameTimestamp;
        
        // https://developer.apple.com/documentation/coremedia/cmtime-u58?language=objc
        CMTime cmtimestamp = CMTimeMake(frameTimestamp, 1000000000);
        [_assetWriter startSessionAtSourceTime:cmtimestamp];
    }
    
    [self queueFrame:frame];
    
#endif
}



@end
