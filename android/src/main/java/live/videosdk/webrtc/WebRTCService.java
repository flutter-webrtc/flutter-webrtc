package live.videosdk.webrtc;

import live.videosdk.webrtc.VideoProcessor;
import android.util.Log;

public class WebRTCService {

    private static final String TAG = "WebRTCService";
    private static WebRTCService instance;
    
    private VideoProcessor videoProcessor;

    // Private constructor to prevent instantiation from outside
    private WebRTCService() {
        // Initialization logic if any
    }

    // Static method to get the singleton instance
    public static synchronized WebRTCService getInstance() {
        if (instance == null) {
            instance = new WebRTCService();
        }
        return instance;
    }

    // Method to set the VideoProcessor
    public void setVideoProcessor(VideoProcessor videoProcessor) {
        this.videoProcessor = videoProcessor;
    }

    // Method to get the current VideoProcessor
    public VideoProcessor getVideoProcessor() {
        return videoProcessor;
    }

    // Other methods related to WebRTC service can be added here
}
