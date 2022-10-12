#import <Flutter/Flutter.h>
#import <WebRTC/WebRTC.h>

@interface MedeaFlutterWebrtcPlugin : NSObject<FlutterPlugin>
@end

bool libyuv_I420ToARGB(
  const uint8_t* src_y,
  int src_stride_y,
  const uint8_t* src_u,
  int src_stride_u,
  const uint8_t* src_v,
  int src_stride_v,
  uint8_t* dst_argb,
  int dst_stride_argb,
  int width,
  int height
);

void libyuv_I420Rotate(
  const uint8_t* srcY,
  int srcStrideY,
  const uint8_t* srcU,
  int srcStrideU,
  const uint8_t* srcV,
  int srcStrideV,
  uint8_t* dstY,
  int dstStrideY,
  uint8_t* dstU,
  int dstStrideU,
  uint8_t* dstV,
  int dstStrideV,
  int width,
  int height,
  RTCVideoRotation mode
);
