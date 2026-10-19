#import "FlutterExternalMedia.h"
#if TARGET_OS_OSX
#import "FlutterWebRTCPlugin.h"
#import "LocalAudioTrack.h"
#import "LocalVideoTrack.h"
#import <AVFoundation/AVFoundation.h>
#import <stdatomic.h>

// A bounded 200ms capture queue accommodates ~100ms recorder bursts plus jitter.
// Input is supplied only by the caller. AVAudioEngine is output-only: never
// create/access its inputNode. The output callback owns the playout clock.
@interface FlutterExternalAudioDevice : NSObject <RTCAudioDevice> {
  NSLock *_lock;
  NSRecursiveLock *_control;
  NSMutableData *_capture, *_reference;
  NSThread *_thread;
  atomic_bool _stop, _recording, _playing, _referenceEnabled;
  AVAudioEngine *_engine;
  AVAudioSourceNode *_node;
  int16_t _playout[480];
  NSUInteger _playoutOffset;
  uint64_t _captureBlocks, _underflows, _captureDropped, _captureInactiveDropped, _captureOverflowDropped, _captureFlushed, _capturePeakBytes, _referenceDropped, _referenceSamples;
}
@property(nonatomic,strong) id<RTCAudioDeviceDelegate> delegate;
@property(nonatomic) BOOL isInitialized, isRecordingInitialized, isPlayoutInitialized;
- (void)render:(AVAudioFrameCount)frames stamp:(const AudioTimeStamp*)stamp output:(AudioBufferList*)output;
- (void)enqueue:(NSData*)data;
- (void)clear;
- (void)setReferenceEnabled:(BOOL)enabled;
- (NSDictionary*)takeReference;
- (NSDictionary*)stats;
@end
@implementation FlutterExternalAudioDevice
- (instancetype)init { if((self=[super init])) { _lock=[NSLock new];_control=[NSRecursiveLock new];_capture=[NSMutableData new];_reference=[NSMutableData new];atomic_init(&_stop,false);atomic_init(&_recording,false);atomic_init(&_playing,false);atomic_init(&_referenceEnabled,false);_playoutOffset=480; }return self; }
- (double)deviceInputSampleRate{return 48000;}
- (double)deviceOutputSampleRate{return 48000;}
- (NSTimeInterval)inputIOBufferDuration{return .01;}
- (NSTimeInterval)outputIOBufferDuration{return .01;}
- (NSInteger)inputNumberOfChannels{return 1;}
- (NSInteger)outputNumberOfChannels{return 1;}
- (NSTimeInterval)inputLatency{return .01;}
- (NSTimeInterval)outputLatency{return .01;}
- (BOOL)isRecording{return atomic_load(&_recording);}
- (BOOL)isPlaying{return atomic_load(&_playing);}
- (BOOL)initializeWithDelegate:(id<RTCAudioDeviceDelegate>)delegate {
 self.delegate=delegate;self.isInitialized=YES;atomic_store(&_stop,false);
 _thread=[[NSThread alloc]initWithTarget:self selector:@selector(pump) object:nil];[_thread start];return YES;
}
- (BOOL)initializeRecording{self.isRecordingInitialized=YES;return YES;}
- (BOOL)initializePlayout{self.isPlayoutInitialized=YES;return YES;}
- (BOOL)startRecording{atomic_store(&_recording,true);return YES;}
- (BOOL)stopRecording{atomic_store(&_recording,false);[self clear];return YES;}
- (BOOL)startPlayout {
 [_control lock];
 if(atomic_load(&_playing)){[_control unlock];return YES;}
 _engine=[AVAudioEngine new];AVAudioFormat *format=[[AVAudioFormat alloc]initStandardFormatWithSampleRate:48000 channels:1];
 __weak FlutterExternalAudioDevice *weakSelf=self;
 _node=[[AVAudioSourceNode alloc]initWithFormat:format renderBlock:^OSStatus(BOOL *silent,const AudioTimeStamp *stamp,AVAudioFrameCount frames,AudioBufferList *out){
   FlutterExternalAudioDevice *device=weakSelf;
   if(!device){for(UInt32 b=0;b<out->mNumberBuffers;++b)memset(out->mBuffers[b].mData,0,out->mBuffers[b].mDataByteSize);*silent=YES;return noErr;}
   [device render:frames stamp:stamp output:out];*silent=NO;return noErr;
 }];
 [_engine attachNode:_node];[_engine connect:_node to:_engine.mainMixerNode format:format];
 [_engine prepare];NSError *error=nil;BOOL ok=[_engine startAndReturnError:&error];
 atomic_store(&_playing,ok);[_control unlock];return ok;
}
- (void)render:(AVAudioFrameCount)frames stamp:(const AudioTimeStamp*)stamp output:(AudioBufferList*)output {
 for(AVAudioFrameCount f=0;f<frames;++f){
  if(_playoutOffset==480){
   memset(_playout,0,sizeof(_playout));AudioUnitRenderActionFlags flags=0;
   AudioBufferList pcm={.mNumberBuffers=1,.mBuffers={{.mNumberChannels=1,.mDataByteSize=sizeof(_playout),.mData=_playout}}};
   if(self.delegate && atomic_load(&_playing))self.delegate.getPlayoutData(&flags,stamp,0,480,&pcm);
   _playoutOffset=0;
   [_lock lock];_referenceSamples+=480;
   if(atomic_load(&_referenceEnabled)){
    if(_reference.length+960>9600){NSUInteger drop=_reference.length+960-9600;[_reference replaceBytesInRange:NSMakeRange(0,drop) withBytes:NULL length:0];_referenceDropped+=drop;}
    [_reference appendBytes:_playout length:960];
   }
   [_lock unlock];
  }
  const float value=_playout[_playoutOffset++]/32768.f;
  for(UInt32 b=0;b<output->mNumberBuffers;++b){float *data=output->mBuffers[b].mData;for(UInt32 c=0;c<output->mBuffers[b].mNumberChannels;++c)data[f*output->mBuffers[b].mNumberChannels+c]=value;}
 }
}
- (BOOL)stopPlayout{[_control lock];atomic_store(&_playing,false);[_engine stop];_node=nil;_engine=nil;_playoutOffset=480;[_control unlock];return YES;}
- (BOOL)terminateDevice {
 atomic_store(&_stop,true);atomic_store(&_recording,false);[self stopPlayout];
 if(_thread && NSThread.currentThread!=_thread){while(!_thread.isFinished)[NSThread sleepForTimeInterval:.001];}
 _thread=nil;self.delegate=nil;self.isInitialized=NO;[self clear];return YES;
}
- (void)clear{[_lock lock];_captureFlushed+=_capture.length;[_capture setLength:0];[_lock unlock];}
- (void)enqueue:(NSData*)data {
 [_lock lock];
 if(!atomic_load(&_recording)){_captureDropped+=data.length;_captureInactiveDropped+=data.length;[_lock unlock];return;}
 if(_capture.length+data.length>19200){NSUInteger drop=_capture.length+data.length-19200;[_capture replaceBytesInRange:NSMakeRange(0,drop) withBytes:NULL length:0];_captureDropped+=drop;_captureOverflowDropped+=drop;}
 [_capture appendData:data];_capturePeakBytes=MAX(_capturePeakBytes,_capture.length);[_lock unlock];
}
- (void)setReferenceEnabled:(BOOL)enabled{atomic_store(&_referenceEnabled,enabled);[_lock lock];[_reference setLength:0];[_lock unlock];}
- (NSDictionary*)takeReference{
 [_lock lock];NSData *data=[_reference copy];uint64_t index=_referenceSamples-data.length/2;[_reference setLength:0];uint64_t dropped=_referenceDropped;[_lock unlock];
 return @{ @"bytes":[FlutterStandardTypedData typedDataWithBytes:data], @"sampleIndex":@(index),@"sampleRate":@48000,@"channels":@1,@"droppedBytes":@(dropped) };
}
- (NSDictionary*)stats{[_lock lock];NSDictionary *s=@{@"audioBlocks":@(_captureBlocks),@"captureUnderflows":@(_underflows),@"captureDroppedBytes":@(_captureDropped),@"captureInactiveDroppedBytes":@(_captureInactiveDropped),@"captureOverflowDroppedBytes":@(_captureOverflowDropped),@"captureFlushedBytes":@(_captureFlushed),@"captureQueuedBytes":@(_capture.length),@"capturePeakQueuedBytes":@(_capturePeakBytes),@"captureQueueCapacityBytes":@19200,@"captureRecording":@(atomic_load(&_recording)),@"renderReferenceDroppedBytes":@(_referenceDropped),@"renderSamples":@(_referenceSamples),@"speakerRunning":@(atomic_load(&_playing))};[_lock unlock];return s;}
- (void)pump {
 @autoreleasepool {double next=NSProcessInfo.processInfo.systemUptime;
 while(!atomic_load(&_stop)){
  @autoreleasepool {
   if(atomic_load(&_recording)){
    int16_t pcm[480]={0};[_lock lock];if(_capture.length>=960){memcpy(pcm,_capture.bytes,960);[_capture replaceBytesInRange:NSMakeRange(0,960) withBytes:NULL length:0];}else{++_underflows;}uint64_t index=_captureBlocks++*480;[_lock unlock];
    AudioTimeStamp stamp={0};stamp.mFlags=kAudioTimeStampSampleTimeValid;stamp.mSampleTime=index;AudioUnitRenderActionFlags flags=0;
    AudioBufferList list={.mNumberBuffers=1,.mBuffers={{.mNumberChannels=1,.mDataByteSize=960,.mData=pcm}}};
    self.delegate.deliverRecordedData(&flags,&stamp,0,480,&list,NULL,nil);
   }
  }
  next+=.01;double wait=next-NSProcessInfo.processInfo.systemUptime;if(wait>0)[NSThread sleepForTimeInterval:wait];else if(wait<-.1)next=NSProcessInfo.processInfo.systemUptime;
 }
 }
}
@end

@interface FlutterExternalMedia()
@property(nonatomic,weak) FlutterWebRTCPlugin *plugin;
@property(nonatomic,strong) FlutterExternalAudioDevice *device;
@property(nonatomic,strong) RTCMediaStream *stream;
@property(nonatomic,strong) RTCVideoSource *video;
@property(nonatomic,strong) RTCVideoCapturer *capturer;
@property(nonatomic,strong) FlutterEventChannel *channel;
@property(nonatomic,copy) FlutterEventSink sink;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic) int64_t videoTimestamp;
@property(nonatomic) uint64_t videoFrames;
@end
@implementation FlutterExternalMedia
- (instancetype)initWithPlugin:(FlutterWebRTCPlugin*)plugin messenger:(id<FlutterBinaryMessenger>)messenger {
 if((self=[super init])){self.plugin=plugin;self.device=[FlutterExternalAudioDevice new];self.channel=[FlutterEventChannel eventChannelWithName:@"FlutterWebRTC.ExternalMediaEvents" binaryMessenger:messenger];[self.channel setStreamHandler:self];self.videoTimestamp=-1;}return self;
}
- (id<RTCAudioDevice>)audioDevice{return self.device;}
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)sink{
 self.sink=sink;[self.device setReferenceEnabled:YES];__weak FlutterExternalMedia *weakSelf=self;
 self.timer=[NSTimer scheduledTimerWithTimeInterval:.01 repeats:YES block:^(NSTimer *timer){FlutterExternalMedia *s=weakSelf;if(!s)return;NSDictionary *data=[s.device takeReference];FlutterStandardTypedData *bytes=data[@"bytes"];if(bytes.data.length && s.sink)s.sink(data);}];return nil;
}
- (FlutterError*)onCancelWithArguments:(id)arguments{[self.timer invalidate];self.timer=nil;self.sink=nil;[self.device setReferenceEnabled:NO];return nil;}
- (void)disposeSource {
 for(RTCMediaStreamTrack *t in self.stream.audioTracks){t.isEnabled=NO;[self.plugin.localTracks removeObjectForKey:t.trackId];}
 for(RTCMediaStreamTrack *t in self.stream.videoTracks){t.isEnabled=NO;[self.plugin.localTracks removeObjectForKey:t.trackId];}
 if(self.stream)[self.plugin.localStreams removeObjectForKey:self.stream.streamId];self.stream=nil;self.video=nil;self.capturer=nil;[self.device clear];
}
- (void)close{[self onCancelWithArguments:nil];[self disposeSource];[self.device terminateDevice];[self.channel setStreamHandler:nil];}
- (void)handleCall:(FlutterMethodCall*)call result:(FlutterResult)result {
 NSDictionary *a=[call.arguments isKindOfClass:NSDictionary.class]?call.arguments:@{};
 if([call.method isEqual:@"externalMediaCreate"]){
  if(self.stream){result([FlutterError errorWithCode:@"external_media_limit" message:@"One external stream per factory is supported" details:nil]);return;}
  BOOL audio=[a[@"audio"]boolValue],video=[a[@"video"]boolValue];if(!audio&&!video){result([FlutterError errorWithCode:@"external_media_arguments" message:@"At least one track required" details:nil]);return;}
  NSString *identifier=NSUUID.UUID.UUIDString;RTCPeerConnectionFactory *f=self.plugin.peerConnectionFactory;self.stream=[f mediaStreamWithStreamId:identifier];NSMutableArray *at=[NSMutableArray new],*vt=[NSMutableArray new];
  if(audio){BOOL processing=[a[@"audioProcessing"]boolValue];NSString *on=processing?@"true":@"false";RTCMediaConstraints *c=[[RTCMediaConstraints alloc]initWithMandatoryConstraints:@{@"googEchoCancellation":on,@"googAutoGainControl":on,@"googNoiseSuppression":on,@"googHighpassFilter":on} optionalConstraints:nil];RTCAudioTrack *t=[f audioTrackWithSource:[f audioSourceWithConstraints:c] trackId:[identifier stringByAppendingString:@"-audio"]];[self.stream addAudioTrack:t];self.plugin.localTracks[t.trackId]=[[LocalAudioTrack alloc]initWithTrack:t];[at addObject:@{@"id":t.trackId,@"label":@"external",@"kind":@"audio",@"enabled":@YES,@"settings":@{}}];}
  if(video){self.video=[f videoSource];self.capturer=[[RTCVideoCapturer alloc]initWithDelegate:self.video];RTCVideoTrack *t=[f videoTrackWithSource:self.video trackId:[identifier stringByAppendingString:@"-video"]];[self.stream addVideoTrack:t];self.plugin.localTracks[t.trackId]=[[LocalVideoTrack alloc]initWithTrack:t];[vt addObject:@{@"id":t.trackId,@"label":@"external",@"kind":@"video",@"enabled":@YES,@"settings":@{}}];}
  self.plugin.localStreams[identifier]=self.stream;self.videoTimestamp=-1;self.videoFrames=0;result(@{@"streamId":identifier,@"ownerTag":@"local",@"audioTracks":at,@"videoTracks":vt,@"renderReference":@YES,@"videoTimestampSource":@"caller"});return;
 }
 if([call.method isEqual:@"externalMediaDispose"]){if(self.stream && ![a[@"streamId"]isEqual:self.stream.streamId]){result([FlutterError errorWithCode:@"external_media_closed" message:@"Unknown stream" details:nil]);return;}[self disposeSource];result(nil);return;}
 if(!self.stream||![a[@"streamId"]isEqual:self.stream.streamId]){result([FlutterError errorWithCode:@"external_media_closed" message:@"Unknown external stream" details:nil]);return;}
 if([call.method isEqual:@"externalMediaFlush"]){[self.device clear];result(nil);return;}
 if([call.method isEqual:@"externalMediaStats"]){NSMutableDictionary *stats=[[self.device stats]mutableCopy];stats[@"videoFrames"]=@(self.videoFrames);result(stats);return;}
 FlutterStandardTypedData *data=a[@"bytes"];if(![data isKindOfClass:FlutterStandardTypedData.class]){result([FlutterError errorWithCode:@"external_media_arguments" message:@"Expected bytes" details:nil]);return;}
 if([call.method isEqual:@"externalMediaAudio"]){if(!self.stream.audioTracks.count||data.data.length!=960){result([FlutterError errorWithCode:@"external_media_audio" message:@"Expected480 mono48k PCM16 samples" details:nil]);return;}[self.device enqueue:data.data];result(nil);return;}
 if([call.method isEqual:@"externalMediaVideo"]){
  int w=[a[@"width"]intValue],h=[a[@"height"]intValue];int64_t t=[a[@"timestampUs"]longLongValue];if(!self.video||w<=0||h<=0||w>1920||h>1080||data.data.length!=(NSUInteger)w*h*4||t<0||t>INT64_MAX/1000||t<=self.videoTimestamp){result([FlutterError errorWithCode:@"external_media_video" message:@"Expected packed BGRA and increasing timestamp" details:nil]);return;}
  CVPixelBufferRef pixel=NULL;CVReturn code=CVPixelBufferCreate(kCFAllocatorDefault,w,h,kCVPixelFormatType_32BGRA,(__bridge CFDictionaryRef)@{(id)kCVPixelBufferIOSurfacePropertiesKey:@{}},&pixel);if(code!=kCVReturnSuccess){result([FlutterError errorWithCode:@"external_media_video" message:@"Pixel buffer allocation failed" details:nil]);return;}
  CVPixelBufferLockBaseAddress(pixel,0);uint8_t *dst=CVPixelBufferGetBaseAddress(pixel);const uint8_t *src=data.data.bytes;for(int y=0;y<h;++y)memcpy(dst+y*CVPixelBufferGetBytesPerRow(pixel),src+y*w*4,w*4);CVPixelBufferUnlockBaseAddress(pixel,0);
  RTCCVPixelBuffer *buffer=[[RTCCVPixelBuffer alloc]initWithPixelBuffer:pixel];RTCVideoFrame *frame=[[RTCVideoFrame alloc]initWithBuffer:buffer rotation:RTCVideoRotation_0 timeStampNs:t*1000];[self.capturer.delegate capturer:self.capturer didCaptureVideoFrame:frame];CVPixelBufferRelease(pixel);self.videoTimestamp=t;++self.videoFrames;result(nil);return;
 }
 result(FlutterMethodNotImplemented);
}
@end
#endif
