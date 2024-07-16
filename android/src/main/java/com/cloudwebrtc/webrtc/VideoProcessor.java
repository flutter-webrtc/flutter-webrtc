package live.videosdk.webrtc;
import org.webrtc.VideoFrame;
public interface VideoProcessor {
    VideoFrame onFrameReceived(VideoFrame frame);
}
