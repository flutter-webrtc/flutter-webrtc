package org.webrtc;

import android.media.MediaCodecInfo;
import android.media.MediaCodecList;

import androidx.annotation.Nullable;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import org.webrtc.EglBase.Context;

/**
 * 支持华为手机的H264编码
 *
 * @author zmh01@digibird.com.cn
 * @since 2022-4-2 17:27
 */
public class DgbVideoEncoderFactory extends DefaultVideoEncoderFactory {

    private final Context sharedContext;

    public DgbVideoEncoderFactory(Context eglContext, boolean enableIntelVp8Encoder, boolean enableH264HighProfile) {
        super(eglContext, enableIntelVp8Encoder, enableH264HighProfile);
        this.sharedContext = eglContext;
    }

    @Override
    public VideoCodecInfo[] getSupportedCodecs() {
        final List<VideoCodecInfo> supported = new ArrayList<>(Arrays.asList(super.getSupportedCodecs()));
        //是否存在h264编码器，存在立即返回
        boolean needAppendH264Encoder = true;
        for (VideoCodecInfo videoCodecInfo : supported) {
            if (videoCodecInfo.name.toUpperCase(Locale.ROOT).contains(VideoCodecMimeType.H264.name())) {
                needAppendH264Encoder = false;
            }
        }

        //搜索非官方支持的H264编码器
        if (needAppendH264Encoder) {
            MediaCodecInfo h264Codec = findH264Codec();
            if(h264Codec != null) {
                supported.add(new VideoCodecInfo(VideoCodecMimeType.H264.name(), H264Utils.getDefaultH264Params(false)));
            }
        }
        return supported.toArray(new VideoCodecInfo[0]);
    }

    /**
     * 寻找非SDK支持的H264编码器
     */
    private MediaCodecInfo findH264Codec(){
        int codecCount = MediaCodecList.getCodecCount();
        MediaCodecInfo codecInfoCache = null;
        for (int i = 0; i < codecCount; i++) {
            MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(i);
            if (codecInfo.isEncoder() && Arrays.asList(codecInfo.getSupportedTypes()).contains(VideoCodecMimeType.H264.mimeType())) {
                Logging.d(DgbVideoEncoderFactory.class.getSimpleName(), String.format("find h264 codec. %s", codecInfo.getName()));
                // 缓存第一个搜索到的编码器
                if (codecInfoCache != null) {
                    codecInfoCache = codecInfo;
                }
                // 优先使用OMX
                if (codecInfo.getName().contains("OMX")){
                    return codecInfo;
                }
            }
        }
        return codecInfoCache;
    }

    @Nullable
    public VideoEncoder createEncoder(VideoCodecInfo input) {
        VideoCodecMimeType type = VideoCodecMimeType.valueOf(input.getName());
        //如果是H264编码，为了调整GOP自己创建编码器
        if (type == VideoCodecMimeType.H264) {
            MediaCodecInfo info = findH264Codec();
            if (info != null) {
                int keyFrameIntervalSec = 20;
                //避免hisi解码器收到PLI造成编码卡死的问题
                if (info.getName().contains("hisi")){
                    keyFrameIntervalSec = 2;
                }
                Logging.d(DgbVideoEncoderFactory.class.getSimpleName(), String.format("use customize params create encoder by %s..............", info.getName()));
                String codecName = info.getName();
                String mime = type.mimeType();
                 if(!isSupportH264HighProfile(codecName)){
                    input.params.putAll(H264Utils.getDefaultH264Params(false));
                }
                Integer surfaceColorFormat = MediaCodecUtils.selectColorFormat(MediaCodecUtils.TEXTURE_COLOR_FORMATS, info.getCapabilitiesForType(mime));
                Integer yuvColorFormat = MediaCodecUtils.selectColorFormat(MediaCodecUtils.ENCODER_COLOR_FORMATS, info.getCapabilitiesForType(mime));
                return new HardwareVideoEncoder(new MediaCodecWrapperFactoryImpl(), codecName, type, surfaceColorFormat, yuvColorFormat, input.params,
                        keyFrameIntervalSec, 0, new BaseBitrateAdjuster(), (EglBase14.Context) this.sharedContext);
            }
        }
        return super.createEncoder(input);
    }

    private boolean isSupportH264HighProfile(String codecName){
        if(codecName.contains("OMX.amlogic")) {
            return false;
        }
        return true;
    }
}
