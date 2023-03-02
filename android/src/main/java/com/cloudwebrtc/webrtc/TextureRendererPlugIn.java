package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.SurfaceTexture;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.util.Log;

import org.webrtc.EglRenderer;
import org.webrtc.VideoFrame;
import org.webrtc.VideoTrack;

import java.util.Random;

public class TextureRendererPlugIn {

    private static TextureRendererPlugIn _instance;

    private static int unityTextureID = -1;

    private static String TAG = "FlutterRTCVideoRenderer";

    private Context mContext;

    private TextureRendererPlugIn(Activity unityActivity) {
        mContext = unityActivity;
    }

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
        else {
            bindExternalTexture(1);
        }
        return unityTextureID;
    }

    private VideoTrack videoTrack;
    public void setVideoTrack(VideoTrack videoTrack, long id) {
//        VideoTrack oldValue = this.videoTrack;
        if (id == 0) return;
//        if (videoTrack != null) {
//            unityTextureID = (int) id;
//        } else {
//            unityTextureID = -1;
//            Log.e(TAG, "FlutterRTCVideoRenderer" + " FlutterRTCVideoRenderer.setVideoTrack, set video track to null");
//        }
    }

    public void onRender(SurfaceTextureRenderer surfaceTextureRenderer, VideoFrame frame) {
        surfaceTextureRenderer.addFrameListener(new EglRenderer.FrameListener() {
            @Override
            public void onFrame(Bitmap bitmap) {
                Log.e("FlutterRTCVideoRenderer", "onFrameAvailable Current thread " + Thread.currentThread().getName());
                Log.e("RENDER", "onFrame bitmap");
//                Bitmap bitmap;
//                final BitmapFactory.Options options = new BitmapFactory.Options();
//                options.inScaled = false;   // No pre-scaling
//                options.inPreferredConfig = Bitmap.Config.ARGB_8888; //Unity will create texture in this format
//                mBitmap = BitmapFactory.decodeResource(mContext.getResources(), R.drawable.ic_launcher, options);
//                if (mBitmap == null) mBitmap = createTestBitmap(300, 300);
                if (mBitmap == null) mBitmap = bitmap;
            }
        }, 1);
    }

    public void onRender(VideoFrame.Buffer frame) {
        Log.e("FlutterRTCVideoRenderer", "onFrameAvailable Current thread " + Thread.currentThread().getName());
        Log.e("RENDER", "onFrame " + frame.toString());
    }

    Bitmap mBitmap;
    public int updateTexture() {
        if (mBitmap == null) return - 1;
        Log.e(TAG, "FlutterRTCVideoRenderer unityTextureID " + unityTextureID);

        checkGlError("begin_updateTexture()");
        //create new texture
        bindExternalTexture(unityTextureID);
        Log.d(TAG, "Loading image");

//        Bitmap bitmap;
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
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, mBitmap, 0);

        checkGlError("texImage");
        mBitmap.recycle();
        mBitmap = null;
        return unityTextureID;
    }

    private int bindExternalTexture(int textureId) {
        if (unityTextureID == -1) {
            int[] textures = new int[1];
            GLES20.glGenTextures(1, textures, 0);
            unityTextureID = textures[0];
        }
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D,
                unityTextureID);

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
