package com.cloudwebrtc.webrtc.utils;

import android.os.Build;

import org.webrtc.EglBase;

public class EglUtils {
    /**
     * The root {@link EglBase} instance shared by the entire application for
     * the sake of reducing the utilization of system resources (such as EGL
     * contexts).
     */
    private static EglBase rootEglBase;

    /**
     * Lazily creates and returns the one and only {@link EglBase} which will
     * serve as the root for all contexts that are needed.
     */
    public static synchronized EglBase getRootEglBase() {
        if (rootEglBase == null) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP)
                rootEglBase = EglBase.createEgl10(EglBase.CONFIG_PLAIN);
            else
                rootEglBase = EglBase.create();
        }

        return rootEglBase;
    }

    public static EglBase.Context getRootEglBaseContext() {
        EglBase eglBase = getRootEglBase();

        return eglBase == null ? null : eglBase.getEglBaseContext();
    }
}
