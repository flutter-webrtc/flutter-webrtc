package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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
import android.opengl.GLES20;
import android.opengl.GLES30;
import android.opengl.GLUtils;
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

//import java.util.Random;

public class TextureRendererPlugIn {
//        implements SurfaceTexture.OnFrameAvailableListener {

    private static TextureRendererPlugIn _instance;

    private static int unityTextureID = -1;

    private static String TAG = "FlutterRTCVideoRenderer";

    private Context mContext;

//    private Surface mSurface;
//    private SurfaceTexture mSurfaceTexture;
//
//    private boolean mNewFrameAvailable;
//    private Rect rec;
//    private Paint p;
//    private Random rnd;
//    Handler hnd;

    private TextureRendererPlugIn(Activity unityActivity) {

        mContext = unityActivity;

//        this.surfaceTextureRenderer = new SurfaceTextureRenderer("");
//        listenRendererEvents();
//
//        mNewFrameAvailable = false;

//        initSurface();

//        rec = new Rect(0, 0, mTextureWidth, mTextureHeight);
//        p = new Paint();
//        rnd = new Random();
//        hnd = new Handler(Looper.getMainLooper());

//        drawRandomCirclesInSurface();
    }

//    private void drawRandomCirclesInSurface() {
//        Log.e("FlutterRTCVideoRenderer", "drawRandomCirclesInSurface Current thread " + Thread.currentThread().getName());
//        Canvas c = mSurface.lockCanvas(rec);
//        p.setColor(Color.argb(255, rnd.nextInt(255), rnd.nextInt(255), rnd.nextInt(255)));
//        int radius = rnd.nextInt(100);
//        c.drawCircle(rnd.nextInt(1080), rnd.nextInt(1920), radius, p);
//        mSurface.unlockCanvasAndPost(c);
//        updateSurfaceTexture();
//
//        hnd.postDelayed(() -> {
//            drawRandomCirclesInSurface();
//        }, 1000);
//    }

//    private void initSurface() {
//        openGlCorrect();
//
//        mSurfaceTexture = new SurfaceTexture(unityTextureID);
//        mSurfaceTexture.setDefaultBufferSize(mTextureWidth, mTextureHeight);
//        mSurface = new Surface(mSurfaceTexture);
//        mSurfaceTexture.setOnFrameAvailableListener(this);
//    }

//    private void openGlCorrect() {
//        Log.e(TAG, "FlutterRTCVideoRenderer unityTextureID " + unityTextureID);
//
//        EGLContext unityContext = EGL14.eglGetCurrentContext();
//        EGLDisplay unityDisplay = EGL14.eglGetCurrentDisplay();
//        EGLSurface unityDrawSurface = EGL14.eglGetCurrentSurface(EGL14.EGL_DRAW);
//        EGLSurface unityReadSurface = EGL14.eglGetCurrentSurface(EGL14.EGL_READ);
//
//        if (unityContext == EGL14.EGL_NO_CONTEXT) {
//            Log.e(TAG, "FlutterRTCVideoRenderer UnityEGLContext is invalid -> Most probably wrong thread");
//        }
//
//        EGL14.eglMakeCurrent(unityDisplay, unityDrawSurface, unityReadSurface, unityContext);
//
//        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
//        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, (int) unityTextureID);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
//        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
//
//        Log.e(TAG, "FlutterRTCVideoRenderer checked connect");
//    }

    public static TextureRendererPlugIn getInstance() {
        return _instance;
    }

    public static TextureRendererPlugIn Instance(Activity context) {
        if (_instance == null) {
            _instance = new TextureRendererPlugIn(context);
        }
        return _instance;
    }

    public long getTextureId() {
        if (unityTextureID != -1) updateTexture();
        return unityTextureID;
    }

//    public void updateSurfaceTexture() {
//        if (mNewFrameAvailable) {
////            if (!Thread.currentThread().getName().equals("UnityMain"))
////                Log.e(TAG, "FlutterRTCVideoRenderer Not called from render thread and hence update texture will fail");
//            Log.e("FlutterRTCVideoRenderer", "updateSurfaceTexture Current thread " + Thread.currentThread().getName());
//            openGlCorrect();
//            try {
//                if (mSurfaceTexture != null) {
//                    mSurfaceTexture.updateTexImage();
//                }
//            } catch (RuntimeException e) {
//                e.printStackTrace();
//            }
//            mNewFrameAvailable = false;
//        }
//    }

//    SurfaceTextureRenderer surfaceTextureRenderer;
//
//    @Override
//    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
//        Log.e("FlutterRTCVideoRenderer", "onFrameAvailable Current thread " + Thread.currentThread().getName());
//        mNewFrameAvailable = true;
////        updateSurfaceTexture();
//    }

    private VideoTrack videoTrack;
    public void setVideoTrack(VideoTrack videoTrack, long id) {
        VideoTrack oldValue = this.videoTrack;
        unityTextureID = (int) id;

//        if (oldValue != videoTrack) {
//            if (oldValue != null) {
//                removeRendererFromVideoTrack();
//            }
//            this.videoTrack = videoTrack;
//            if (videoTrack != null) {
//                try {
//                    Log.e(TAG, "FlutterRTCVideoRenderer" + " FlutterRTCVideoRenderer.setVideoTrack, set video track to " + videoTrack.id());
//                    tryAddRendererToVideoTrack();
//                } catch (Exception e) {
//                    Log.e(TAG, "FlutterRTCVideoRenderer" + " tryAddRendererToVideoTrack " + e);
//                }
//            } else {
//                Log.e(TAG, "FlutterRTCVideoRenderer" + " FlutterRTCVideoRenderer.setVideoTrack, set video track to null");
//            }
//        }
    }

//    /**
//     * For video call
//     */
//    private void removeRendererFromVideoTrack() {
//        videoTrack.removeSink(surfaceTextureRenderer);
//    }
//
//    private void tryAddRendererToVideoTrack() throws Exception {
//        if (videoTrack != null) {
//            Log.e(TAG, "FlutterRTCVideoRenderer apply new video track");
//
////            openGlCorrect();
//
//            EglBase.Context sharedContext = EglUtils.getRootEglBaseContext();
//            if (sharedContext == null) {
//                // If SurfaceViewRenderer#init() is invoked, it will throw a
//                // RuntimeException which will very likely kill the application.
//                Log.e(TAG, "FlutterRTCVideoRenderer" + "Failed to render a VideoTrack!");
//                return;
//            }
//
//            surfaceTextureRenderer.release();
////            openGlCorrect();
//
////            int[] textures = new int[1];
////            GLES20.glGenTextures(1, textures, 0);
////            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textures[0]);
////            GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
////            GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
////            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
////            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
////            unityTextureID = textures[0];
//////            videoTex = new SurfaceTexture(texture_in);
////
//            mSurfaceTexture = new SurfaceTexture((int) unityTextureID);
//            mSurfaceTexture.setDefaultBufferSize(1080, 1920);
//            mSurface = new Surface(mSurfaceTexture);
//            mSurfaceTexture.setOnFrameAvailableListener(this);
//
//            listenRendererEvents();
////
////            rec = new Rect(0, 0, 1080, 1920);
////            p = new Paint();
////            rnd = new Random();
////            hnd = new Handler(Looper.getMainLooper());
////
////            drawRandomCirclesInSurface();
//
//            surfaceTextureRenderer.init(sharedContext, rendererEvents);
//            surfaceTextureRenderer.surfaceCreated(mSurfaceTexture);
//
////            videoTrack.addSink(surfaceTextureRenderer);
//            Log.e("FlutterRTCVideoRenderer", "tryAddRendererToVideoTrack Current thread " + Thread.currentThread().getName());
//        }
//    }
//
//    private RendererCommon.RendererEvents rendererEvents;
//    private void listenRendererEvents() {
//        rendererEvents = new RendererCommon.RendererEvents() {
//            private int _rotation = -1;
//            private int _width = 0, _height = 0;
//
//            @Override
//            public void onFirstFrameRendered() {
//                ConstraintsMap params = new ConstraintsMap();
//                params.putString("event", "didFirstFrameRendered");
//                params.putInt("id", -1);
//                Log.e(TAG, "FlutterRTCVideoRenderer" + params.toMap().toString());
//            }
//
//            @Override
//            public void onFrameResolutionChanged(
//                    int videoWidth, int videoHeight,
//                    int rotation) {
//
//                if (_width != videoWidth || _height != videoHeight) {
//                    ConstraintsMap params = new ConstraintsMap();
//                    params.putString("event", "didTextureChangeVideoSize");
//                    params.putInt("id", -1);
//                    params.putDouble("width", (double) videoWidth);
//                    params.putDouble("height", (double) videoHeight);
//                    _width = videoWidth;
//                    _height = videoHeight;
//                    Log.e(TAG, "FlutterRTCVideoRenderer" + params.toMap().toString());
//                }
//
//                if (_rotation != rotation) {
//                    ConstraintsMap params2 = new ConstraintsMap();
//                    params2.putString("event", "didTextureChangeRotation");
//                    params2.putInt("id", -1);
//                    params2.putInt("rotation", rotation);
//                    _rotation = rotation;
//                    Log.e(TAG, "FlutterRTCVideoRenderer" + params2.toMap().toString());
//                }
//            }
//        };
//    }

    public int updateTexture() {
        checkGlError("begin_updateTexture()");
        //create new texture
        createExternalTexture(unityTextureID);
        Log.d(TAG, "Loading image");

        final Bitmap bitmap = createTestBitmap(200, 200);
//        final BitmapFactory.Options options = new BitmapFactory.Options();
//        options.inScaled = false;   // No pre-scaling
//        options.inPreferredConfig = Bitmap.Config.ARGB_8888; //Unity will create texture in this format

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
        checkGlError("activeTexture");
        // Read in the resource
//        bitmap = BitmapFactory.decodeResource(mContext.getResources(), R.drawable.ic_launcher, options);
        checkGlError("bindTexture");
        // Set filtering
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_NEAREST);

        // Load the bitmap into the bound texture.
        checkGlError("beforeTexImage");
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0);
        checkGlError("texImage");
        bitmap.recycle();
        return unityTextureID;
    }

    private int createExternalTexture(int textureId) {
//        int[] textureIdContainer = new int[1];
//        GLES20.glGenTextures(1, textureIdContainer, 0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D,
                textureId);

        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);

        return textureId;
    }

    public static Bitmap createTestBitmap(int w, int h) {
        Bitmap bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        int colors[] = new int[] { Color.BLUE, Color.GREEN, Color.RED,
                Color.YELLOW, Color.WHITE };
        Random rgen = new Random();
        int color = colors[rgen.nextInt(colors.length - 1)];

        canvas.drawColor(color);
        return bitmap;
    }


    private void checkGlError(String op) {
        int error;
        while ((error = GLES20.glGetError()) != GLES20.GL_NO_ERROR) {
            Log.e(TAG, op + ": glError 0x" + Integer.toHexString(error));
        }
    }
}
