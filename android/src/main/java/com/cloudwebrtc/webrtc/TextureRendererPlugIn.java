package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.opengl.GLES11Ext;
import android.opengl.GLES30;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Surface;

import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;

import org.webrtc.EglBase;
import org.webrtc.RendererCommon;
import org.webrtc.VideoTrack;

import java.util.Random;

public class TextureRendererPlugIn implements SurfaceTexture.OnFrameAvailableListener {
    private static TextureRendererPlugIn _instance;
    private Activity mUnityActivity;
    private int mTextureWidth;
    private int mTextureHeight;
    private static String TAG = "FlutterRTCVideoRenderer";

    private static EGLContext unityContext = EGL14.EGL_NO_CONTEXT;
    private static EGLDisplay unityDisplay = EGL14.EGL_NO_DISPLAY;
    private static EGLSurface unityDrawSurface = EGL14.EGL_NO_SURFACE;
    private static EGLSurface unityReadSurface = EGL14.EGL_NO_SURFACE;

    private Surface mSurface;
    private SurfaceTexture mSurfaceTexture;
    private int unityTextureID;
    private int janusTextureID;

    private boolean mNewFrameAvailable;
    private Rect rec;
    private Paint p;
    private Random rnd;
    Handler hnd;

    private TextureRendererPlugIn(Activity unityActivity, int width, int height, int textureID) {
        Log.e(TAG, "FlutterRTCVideoRenderer TextureRendererPlugIn");

        this.surfaceTextureRenderer = new SurfaceTextureRenderer("");
        listenRendererEvents();

        mTextureWidth = width;
        mTextureHeight = height;
        unityTextureID = textureID;
        mNewFrameAvailable = false;

        initSurface();

        rec = new Rect(0, 0, width, height);
        p = new Paint();
        rnd = new Random();
        hnd = new Handler(Looper.getMainLooper());

//        drawRandomCirclesInSurface();
    }

    private void drawRandomCirclesInSurface() {
        Canvas c = mSurface.lockCanvas(rec);
        p.setColor(Color.argb(255, rnd.nextInt(255), rnd.nextInt(255), rnd.nextInt(255)));
        int radius = rnd.nextInt(100);
        c.drawCircle(rnd.nextInt(mTextureWidth), rnd.nextInt(mTextureHeight), radius, p);
//            c.drawColor(Color.WHITE);
//            c.drawBitmap(enemy1, enemy1X, enemy1Y, null);
//            Paint paint = new Paint();
//            paint.setColor(Color.RED);
//            c.drawText("XXXX", 200, 100, paint);
        mSurface.unlockCanvasAndPost(c);

        hnd.postDelayed(() -> {
            drawRandomCirclesInSurface();
        }, 1000);
    }

    private void initSurface() {
        Log.e(TAG, "FlutterRTCVideoRenderer janusTextureID " + janusTextureID);
        Log.e(TAG, "FlutterRTCVideoRenderer unityTextureID " + unityTextureID);

//        unityContext = EGL14.eglGetCurrentContext();
//        unityDisplay = EGL14.eglGetCurrentDisplay();
//        unityDrawSurface = EGL14.eglGetCurrentSurface(EGL14.EGL_DRAW);
//        unityReadSurface = EGL14.eglGetCurrentSurface(EGL14.EGL_READ);
//
//        if (unityContext == EGL14.EGL_NO_CONTEXT) {
//            Log.e(TAG, "FlutterRTCVideoRenderer UnityEGLContext is invalid -> Most probably wrong thread");
//        }
//
//        EGL14.eglMakeCurrent(unityDisplay, unityDrawSurface, unityReadSurface, unityContext);
//
//        GLES30.glActiveTexture(GLES30.GL_TEXTURE0);
//        GLES30.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, unityTextureID);
//        GLES30.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR);
//        GLES30.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR);
//        GLES30.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE);
//        GLES30.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE);

        mSurfaceTexture = new SurfaceTexture(unityTextureID);
        mSurfaceTexture.setDefaultBufferSize(mTextureWidth, mTextureHeight);
        mSurface = new Surface(mSurfaceTexture);
        mSurfaceTexture.setOnFrameAvailableListener(this);
    }

    public static TextureRendererPlugIn getInstance() {
        return _instance;
    }

    public static TextureRendererPlugIn Instance(Activity context, int viewPortWidth,
                                                 int viewPortHeight, int textureID) {
        if (_instance == null) {
            _instance = new TextureRendererPlugIn(context, viewPortWidth, viewPortHeight, textureID);
        }

        return _instance;
    }

    public void updateJanusTextureId(int janusTextureId) {
        this.janusTextureID = janusTextureId;
        copyDataBetweenTwoTexture();
    }

    private void copyDataBetweenTwoTexture() {

        Log.e(TAG, "FlutterRTCVideoRenderer janusTextureID " + janusTextureID);
        Log.e(TAG, "FlutterRTCVideoRenderer unityTextureID " + unityTextureID);

//        SurfaceTexture mSurfaceTexture = new SurfaceTexture(janusTextureID);
//        mSurfaceTexture.setDefaultBufferSize(1000, 1000);
//        ByteBuffer pixelBuf = ByteBuffer.allocateDirect(1000 * 1000 * 8);
//        GLES30.glReadPixels(0, 0, 1000, 1000, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, pixelBuf);
//        Log.e(TAG, "pixelBuf " + pixelBuf.toString());
    }

    public void updateSurfaceTexture() {
        if (mNewFrameAvailable) {
            if (!Thread.currentThread().getName().equals("UnityMain"))
                Log.e(TAG, "FlutterRTCVideoRenderer Not called from render thread and hence update texture will fail");
            mSurfaceTexture.updateTexImage();
            mNewFrameAvailable = false;
        }
    }

    SurfaceTextureRenderer surfaceTextureRenderer;
    private RendererCommon.RendererEvents rendererEvents;

    private void listenRendererEvents() {
        rendererEvents = new RendererCommon.RendererEvents() {
            private int _rotation = -1;
            private int _width = 0, _height = 0;

            @Override
            public void onFirstFrameRendered() {
                ConstraintsMap params = new ConstraintsMap();
                params.putString("event", "didFirstFrameRendered");
                params.putInt("id", -1);
                Log.e(TAG, "FlutterRTCVideoRenderer" + params.toMap().toString());
            }

            @Override
            public void onFrameResolutionChanged(
                    int videoWidth, int videoHeight,
                    int rotation) {

                if (_width != videoWidth || _height != videoHeight) {
                    ConstraintsMap params = new ConstraintsMap();
                    params.putString("event", "didTextureChangeVideoSize");
                    params.putInt("id", -1);
                    params.putDouble("width", (double) videoWidth);
                    params.putDouble("height", (double) videoHeight);
                    _width = videoWidth;
                    _height = videoHeight;
                    Log.e(TAG, "FlutterRTCVideoRenderer" + params.toMap().toString());
                }

                if (_rotation != rotation) {
                    ConstraintsMap params2 = new ConstraintsMap();
                    params2.putString("event", "didTextureChangeRotation");
                    params2.putInt("id", -1);
                    params2.putInt("rotation", rotation);
                    _rotation = rotation;
                    Log.e(TAG, "FlutterRTCVideoRenderer" + params2.toMap().toString());
                }
            }
        };
    }

    @Override
    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
        mNewFrameAvailable = true;
    }

    private VideoTrack videoTrack;
    public void setVideoTrack(VideoTrack videoTrack) {
        VideoTrack oldValue = this.videoTrack;

        if (oldValue != videoTrack) {
            if (oldValue != null) {
                removeRendererFromVideoTrack();
            }

            this.videoTrack = videoTrack;

            if (videoTrack != null) {
                try {
                    Log.w(TAG, "FlutterRTCVideoRenderer" + " FlutterRTCVideoRenderer.setVideoTrack, set video track to " + videoTrack.id());
                    tryAddRendererToVideoTrack();
                } catch (Exception e) {
                    Log.e(TAG, "FlutterRTCVideoRenderer" + " tryAddRendererToVideoTrack " + e);
                }
            } else {
                Log.w(TAG, "FlutterRTCVideoRenderer" + " FlutterRTCVideoRenderer.setVideoTrack, set video track to null");
            }
        }
    }

    private void removeRendererFromVideoTrack() {
        videoTrack.removeSink(surfaceTextureRenderer);
    }

    private void tryAddRendererToVideoTrack() throws Exception {
        if (videoTrack != null) {
            EglBase.Context sharedContext = EglUtils.getRootEglBaseContext();

            if (sharedContext == null) {
                // If SurfaceViewRenderer#init() is invoked, it will throw a
                // RuntimeException which will very likely kill the application.
                Log.e(TAG, "FlutterRTCVideoRenderer" + "Failed to render a VideoTrack!");
                return;
            }

            surfaceTextureRenderer.release();
            listenRendererEvents();
            surfaceTextureRenderer.init(sharedContext, rendererEvents);
            surfaceTextureRenderer.surfaceCreated(mSurfaceTexture);

            videoTrack.addSink(surfaceTextureRenderer);
        }
    }

}
