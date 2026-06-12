package com.cloudwebrtc.webrtc.video.custom;

import androidx.annotation.Nullable;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Process-wide registry mapping a source type name to the factory that
 * creates its {@link CustomVideoCapturer}. The application registers its
 * factories (e.g. in Application.onCreate) before Dart calls
 * "createCustomVideoTrack".
 */
public final class CustomVideoSourceRegistry {
    private static final Map<String, CustomVideoCapturerFactory> factories =
            new ConcurrentHashMap<>();

    private CustomVideoSourceRegistry() {}

    public static void register(String sourceType, CustomVideoCapturerFactory factory) {
        factories.put(sourceType, factory);
    }

    @Nullable
    public static CustomVideoCapturerFactory get(String sourceType) {
        return factories.get(sourceType);
    }
}
