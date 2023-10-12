#import <AVFoundation/AVFoundation.h>
#import <FlutterMacOS/FlutterMacOS.h>

// Converts the provided `Frame` to the ARGB format and places into the provided
// `buffer` pointer.
extern void get_argb_bytes(void* frame, int argb_stride, uint8_t* buffer);

// Drops the provided `Frame`.
extern void drop_frame(void* frame);

// Video frame.
typedef struct Frame {
    size_t height;
    size_t width;
    int32_t rotation;
    size_t buffer_size;
    uint8_t* frame;
} Frame;

// Texture video renderer definition for macOS.
@interface TextureVideoRenderer
    : NSObject <FlutterTexture, FlutterStreamHandler>

// `FlutterEventChannel` of this `TextureVideoRenderer`.
@property(nonatomic, strong, nullable) FlutterEventChannel* eventChannel;

// `FlutterTextureRegistry` of this `TextureVideoRenderer`.
@property(nonatomic, weak) id<FlutterTextureRegistry> registry;

// ID of this `TextureVideoRenderer`.
@property(nonatomic, strong, nullable) NSNumber* textureId;

// ID of the `FlutterTexture` registered in the `FlutterTextureRegistry`.
@property(nonatomic) int64_t tid;

// `CVPixelBuffer` onto which `Frame`s will be rendered by this
// `TextureVideoRenderer`.
@property(nonatomic) CVPixelBufferRef pixelBufferRef;

// Buffer size of the last rendered `Frame` by this `TextureVideoRenderer`.
@property(nonatomic) size_t bufferSize;


- (instancetype)init:(id<FlutterTextureRegistry>)registry
           messenger:(id<FlutterBinaryMessenger>)messenger;
- (void)resetRenderer;
- (void)onFrame:(Frame)frame;
- (NSNumber*)textureId;
@end

@interface VideoRendererManager : NSObject
// `FlutterTextureRegistry` of this `VideoRendererManager`.
@property(nonatomic, strong, nullable) id<FlutterTextureRegistry> registry;

// `FlutterBinaryMessenger` of this `VideoRendererManager`.
@property(nonatomic, strong, nullable) id<FlutterBinaryMessenger> messenger;

// All the `TextureVideoRenderer`s created by this `VideoRendererManager`.
@property(nonatomic, strong, nullable)
    NSMutableDictionary<NSNumber*, TextureVideoRenderer*>* renderers;

- (VideoRendererManager*)init:(id<FlutterTextureRegistry>)registry
                    messenger:(id<FlutterBinaryMessenger>)messenger;
- (void)createVideoRendererTexture:(FlutterResult)result;
- (void)videoRendererDispose:(FlutterMethodCall*)methodCall
                      result:(FlutterResult)result;
- (void)createFrameHandler:(FlutterMethodCall*)methodCall
                    result:(FlutterResult)result;
@end
