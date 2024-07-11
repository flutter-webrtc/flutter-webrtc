package com.cloudwebrtc.webrtc;

import com.cloudwebrtc.webrtc.Processor;
import android.util.Log;

public class WebRTCService {

    private static final String TAG = "WebRTCService";
    private static WebRTCService instance;
    
    private Processor processor;

    // Private constructor to prevent instantiation from outside
    private WebRTCService() {
        Log.d(TAG, "WebRTCService instance created");
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
    public void setProcessor(Processor processor) {
        Log.d(TAG, "Processor Set successfully");
        this.processor = processor;
    }

    // Method to get the current VideoProcessor
    public Processor getProcessor() {
        return processor;
    }

    // Other methods related to WebRTC service can be added here
}
