package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.util.Log;

import org.webrtc.EglRenderer;
import org.webrtc.VideoFrame;
import org.webrtc.VideoTrack;

import java.util.ArrayList;

public class TextureRendererPlugIn {

    private static TextureRendererPlugIn _instance;

    private static final ArrayList<TextureEntity> listUnityTexture = new ArrayList<>();

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

    public long getTextureId(String itemId) {
        if (itemId.equals("refreshView")) {
            for (TextureEntity data : listUnityTexture) {
                if (data.isCreatedExternalTexture()) {
                    updateTexture(data);
                }
            }
            return -1;
        }
        if (listUnityTexture.size() > 0) {
            for (TextureEntity data : listUnityTexture) {
                if (data.getItemId().equals(itemId)) {
                    if (data.isCreatedExternalTexture()) {
                        updateTexture(data);
                    } else {
                        bindExternalTexture(data);
                    }
                    return data.getExternalTextureId();
                }
            }
        }
        return -1;
    }

    public void setVideoTrack(VideoTrack videoTrack) {
        for (TextureEntity data : listUnityTexture) {
            if (data.getVideoTrackId().equals(videoTrack.id())) {
                return;
            }
        }
        TextureEntity newTextureEntity = new TextureEntity();
        newTextureEntity.setItemId("item-" + listUnityTexture.size());
        newTextureEntity.setBitmap(null);
        newTextureEntity.setVideoTrackId(videoTrack.id());
        newTextureEntity.setCreatedExternalTexture(false);
        newTextureEntity.setExternalTextureId(-1);
        listUnityTexture.add(newTextureEntity);
    }

    public void onRender(SurfaceTextureRenderer surfaceTextureRenderer, String textureId, VideoFrame frame) {
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
                for (TextureEntity data : listUnityTexture) {
                    if (data.getVideoTrackId().equals(textureId)) {
                        if (data.getBitmap() == null) data.setBitmap(bitmap);
                        return;
                    }
                }
            }
        }, 1);
    }

    public void updateTexture(TextureEntity textureEntity) {
        if (textureEntity.getBitmap() == null) return;

        checkGlError("begin_updateTexture()");
        //create new texture
        bindExternalTexture(textureEntity);
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
        GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, textureEntity.getBitmap(), 0);

        checkGlError("texImage");
        textureEntity.getBitmap().recycle();
        textureEntity.setBitmap(null);
    }

    private void bindExternalTexture(TextureEntity textureEntity) {
        if (!textureEntity.isCreatedExternalTexture()) {
            int[] textures = new int[1];
            GLES20.glGenTextures(1, textures, 0);
            textureEntity.setExternalTextureId(textures[0]);
            textureEntity.setCreatedExternalTexture(true);
        }
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D,
                textureEntity.getExternalTextureId());
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    }

//    public static Bitmap createTestBitmap(int w, int h) {
//        Bitmap bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
//        Canvas canvas = new Canvas(bitmap);
//
//        int colors[] = new int[] { Color.BLUE, Color.GREEN, Color.RED,
//                Color.YELLOW, Color.WHITE };
//        Random rgen = new Random();
//        int color = colors[rgen.nextInt(colors.length - 1)];
//
//        canvas.drawColor(color);
//        return bitmap;
//    }

    private void checkGlError(String op) {
        int error;
        while ((error = GLES20.glGetError()) != GLES20.GL_NO_ERROR) {
            Log.e(TAG, op + ": glError 0x" + Integer.toHexString(error));
        }
    }
}

class TextureEntity {
    private String itemId; // item-0, item-1
    private Bitmap bitmap; // Image bitmap for this texture
    private String videoTrackId;
    private boolean isCreatedExternalTexture;
    private int externalTextureId;

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public Bitmap getBitmap() {
        return bitmap;
    }

    public void setBitmap(Bitmap bitmap) {
        this.bitmap = bitmap;
    }

    public String getVideoTrackId() {
        return videoTrackId;
    }

    public void setVideoTrackId(String videoTrackId) {
        this.videoTrackId = videoTrackId;
    }

    public boolean isCreatedExternalTexture() {
        return isCreatedExternalTexture;
    }

    public void setCreatedExternalTexture(boolean createdExternalTexture) {
        isCreatedExternalTexture = createdExternalTexture;
    }

    public int getExternalTextureId() {
        return externalTextureId;
    }

    public void setExternalTextureId(int externalTextureId) {
        this.externalTextureId = externalTextureId;
    }
}
