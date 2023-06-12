#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RTCVideoFrameFormat) {
    KI420,
    KRGBA,
    KMJPEG
};

@interface PhotographFormat : NSObject

@property (nonatomic, strong)NSData *data;
@property (nonatomic, assign)NSInteger width;
@property (nonatomic, assign)NSInteger height;
@property (nonatomic, strong)NSString* format;

- (instancetype)initWidthData:(NSData *)data
                        width:(NSInteger)width
                       height:(NSInteger)height
                       format:(RTCVideoFrameFormat)format;
+ (NSString *)getFormatString:(RTCVideoFrameFormat)format;

@end

@interface RTCVideoFrameTransform : NSObject

+ (PhotographFormat *)transform:(RTCVideoFrame *)frame format:(RTCVideoFrameFormat)format;

@end

NS_ASSUME_NONNULL_END
