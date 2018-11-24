package com.cloudwebrtc.webrtc;

import android.content.Context;
import android.content.res.Resources.NotFoundException;
import android.graphics.Matrix;
import android.graphics.Point;
import android.graphics.SurfaceTexture;
import android.opengl.GLES20;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import java.util.concurrent.CountDownLatch;

import org.webrtc.EglBase;
import org.webrtc.GlRectDrawer;
import org.webrtc.GlUtil;
import org.webrtc.Logging;
import org.webrtc.RendererCommon;
import org.webrtc.ThreadUtils;
import org.webrtc.VideoFrame;
import org.webrtc.VideoFrameDrawer;
import org.webrtc.VideoSink;

import java.nio.ByteBuffer;

import static org.webrtc.VideoFrame.TextureBuffer.Type.OES;

/**
 * Implements org.webrtc.VideoRenderer.Callbacks by displaying the video stream on a SurfaceTexture.
 * renderFrame() is asynchronous to avoid blocking the calling thread.
 * This class is thread safe and handles access from potentially four different threads:
 * Interaction from the main app in init, release, setMirror, and setScalingtype.
 * Interaction from C++ rtc::VideoSinkInterface in renderFrame.
 * Interaction from the Activity lifecycle in surfaceCreated, surfaceChanged, and surfaceDestroyed.
 * Interaction with the layout framework in onMeasure and onSizeChanged.
 */
public class SurfaceTextureRenderer implements VideoSink {
  private static final String TAG = "SurfaceTextureRenderer";

  private final SurfaceTexture texture;
  // Dedicated render thread.
  private HandlerThread renderThread;
  // |renderThreadHandler| is a handler for communicating with |renderThread|, and is synchronized
  // on |handlerLock|.
  private final Object handlerLock = new Object();
  private Handler renderThreadHandler;

  // EGL and GL resources for drawing YUV/OES textures. After initilization, these are only accessed
  // from the render thread.
  private EglBase eglBase;
  private final YuvUploader yuvUploader = new YuvUploader();
  private RendererCommon.GlDrawer drawer;
  // Texture ids for YUV frames. Allocated on first arrival of a YUV frame.
  private int[] yuvTextures = null;

  // Pending frame to render. Serves as a queue with size 1. Synchronized on |frameLock|.
  private final Object frameLock = new Object();
  private VideoFrame pendingFrame;

  // These variables are synchronized on |layoutLock|.
  private final Object layoutLock = new Object();

  // |layoutSize|/|surfaceSize| is the actual current layout/surface size. They are updated in
  // onLayout() and surfaceChanged() respectively.
  private final Point layoutSize = new Point();
  // TODO(magjed): Enable hardware scaler with SurfaceHolder.setFixedSize(). This will decouple
  // layout and surface size.
  private final Point surfaceSize = new Point();
  // |isSurfaceCreated| keeps track of the current status in surfaceCreated()/surfaceDestroyed().
  private boolean isSurfaceCreated;
  // Last rendered frame dimensions, or 0 if no frame has been rendered yet.
  private int frameWidth;
  private int frameHeight;
  private int frameRotation;

  // If true, mirrors the video stream horizontally.
  private boolean mirror;
  // Callback for reporting renderer events.
  private RendererCommon.RendererEvents rendererEvents;

  // These variables are synchronized on |statisticsLock|.
  private final Object statisticsLock = new Object();
  // Total number of video frames received in renderFrame() call.
  private int framesReceived;
  // Number of video frames dropped by renderFrame() because previous frame has not been rendered
  // yet.
  private int framesDropped;
  // Number of rendered video frames.
  private int framesRendered;
  // Time in ns when the first video frame was rendered.
  private long firstFrameTimeNs;
  // Time in ns spent in renderFrameOnRenderThread() function.
  private long renderTimeNs;

  /**
   * Helper class for uploading YUV bytebuffer frames to textures that handles stride > width. This
   * class keeps an internal ByteBuffer to avoid unnecessary allocations for intermediate copies.
   */
  public static class YuvUploader {
    // Intermediate copy buffer for uploading yuv frames that are not packed, i.e. stride > width.
    // TODO(magjed): Investigate when GL_UNPACK_ROW_LENGTH is available, or make a custom shader
    // that handles stride and compare performance with intermediate copy.
    private ByteBuffer copyBuffer;
    private int[] yuvTextures;

    /**
     * Upload |planes| into OpenGL textures, taking stride into consideration.
     *
     * @return Array of three texture indices corresponding to Y-, U-, and V-plane respectively.
     */
    public int[] uploadYuvData(int width, int height, int[] strides, ByteBuffer[] planes) {
      final int[] planeWidths = new int[] {width, width / 2, width / 2};
      final int[] planeHeights = new int[] {height, height / 2, height / 2};
      // Make a first pass to see if we need a temporary copy buffer.
      int copyCapacityNeeded = 0;
      for (int i = 0; i < 3; ++i) {
        if (strides[i] > planeWidths[i]) {
          copyCapacityNeeded = Math.max(copyCapacityNeeded, planeWidths[i] * planeHeights[i]);
        }
      }
      // Allocate copy buffer if necessary.
      if (copyCapacityNeeded > 0
          && (copyBuffer == null || copyBuffer.capacity() < copyCapacityNeeded)) {
        copyBuffer = ByteBuffer.allocateDirect(copyCapacityNeeded);
      }
      // Make sure YUV textures are allocated.
      if (yuvTextures == null) {
        yuvTextures = new int[3];
        for (int i = 0; i < 3; i++) {
          yuvTextures[i] = GlUtil.generateTexture(GLES20.GL_TEXTURE_2D);
        }
      }
      // Upload each plane.
      for (int i = 0; i < 3; ++i) {
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + i);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, yuvTextures[i]);
        // GLES only accepts packed data, i.e. stride == planeWidth.
        final ByteBuffer packedByteBuffer;
        if (strides[i] == planeWidths[i]) {
          // Input is packed already.
          packedByteBuffer = planes[i];
        } else {
          Log.e(TAG, "Unpacked YUV buffer found");
          throw new RuntimeException();
        }
        GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, planeWidths[i],
            planeHeights[i], 0, GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, packedByteBuffer);
      }
      return yuvTextures;
    }

    /**
     * Releases cached resources. Uploader can still be used and the resources will be reallocated
     * on first use.
     */
    public void release() {
      copyBuffer = null;
      if (yuvTextures != null) {
        GLES20.glDeleteTextures(3, yuvTextures, 0);
        yuvTextures = null;
      }
    }
  }


  // Runnable for posting frames to render thread.
  private final Runnable renderFrameRunnable = new Runnable() {
    @Override public void run() {
      renderFrameOnRenderThread();
    }
  };
  // Runnable for clearing Surface to black.
  private final Runnable makeBlackRunnable = new Runnable() {
    @Override public void run() {
      makeBlack();
    }
  };

  public SurfaceTextureRenderer(Context context, SurfaceTexture texture) {
    this.texture = texture;
    synchronized (layoutLock) {
      isSurfaceCreated = true;
    }
    tryCreateEglSurface();
  }

  /**
   * Initialize this class, sharing resources with |sharedContext|. It is allowed to call init() to
   * reinitialize the renderer after a previous init()/release() cycle.
   */
  public void init(
      EglBase.Context sharedContext, RendererCommon.RendererEvents rendererEvents) {
    init(sharedContext, rendererEvents, EglBase.CONFIG_PLAIN, new GlRectDrawer());
  }

  /**
   * Initialize this class, sharing resources with |sharedContext|. The custom |drawer| will be used
   * for drawing frames on the EGLSurface. This class is responsible for calling release() on
   * |drawer|. It is allowed to call init() to reinitialize the renderer after a previous
   * init()/release() cycle.
   */
  public void init(
      final EglBase.Context sharedContext, RendererCommon.RendererEvents rendererEvents,
      final int[] configAttributes, RendererCommon.GlDrawer drawer) {
    synchronized (handlerLock) {
      if (renderThreadHandler != null) {
        throw new IllegalStateException(getResourceName() + "Already initialized");
      }
      Logging.d(TAG, getResourceName() + "Initializing.");
      this.rendererEvents = rendererEvents;
      this.drawer = drawer;
      renderThread = new HandlerThread(TAG);
      renderThread.start();
      renderThreadHandler = new Handler(renderThread.getLooper());
      // Create EGL context on the newly created render thread. It should be possibly to create the
      // context on this thread and make it current on the render thread, but this causes failure on
      // some Marvel based JB devices. https://bugs.chromium.org/p/webrtc/issues/detail?id=6350.
      ThreadUtils.invokeAtFrontUninterruptibly(renderThreadHandler, new Runnable() {
        @Override
        public void run() {
          eglBase = EglBase.create(sharedContext, configAttributes);
        }
      });
    }
    tryCreateEglSurface();
  }

  /**
   * Create and make an EGLSurface current if both init() and surfaceCreated() have been called.
   */
  public void tryCreateEglSurface() {
    // |renderThreadHandler| is only created after |eglBase| is created in init(), so the
    // following code will only execute if eglBase != null.
    runOnRenderThread(new Runnable() {
      @Override
      public void run() {
        synchronized (layoutLock) {
          if (texture != null && eglBase != null && isSurfaceCreated && !eglBase.hasSurface()) {
            eglBase.createSurface(texture);
            eglBase.makeCurrent();
            // Necessary for YUV frames with odd width.
            GLES20.glPixelStorei(GLES20.GL_UNPACK_ALIGNMENT, 1);
          }
        }

        // XXX by Saúl Ibarra Corretgé <saghul@gmail.com>: Until an actual frame
        // is available to render, draw black; otherwise, this SurfaceView will
        // appear transparent.
        makeBlack();
      }
    });
  }

  /**
   * Block until any pending frame is returned and all GL resources released, even if an interrupt
   * occurs. If an interrupt occurs during release(), the interrupt flag will be set. This function
   * should be called before the Activity is destroyed and the EGLContext is still valid. If you
   * don't call this function, the GL resources might leak.
   */
  public void release() {
    final CountDownLatch eglCleanupBarrier = new CountDownLatch(1);
    synchronized (handlerLock) {
      if (renderThreadHandler == null) {
        Logging.d(TAG, getResourceName() + "Already released");
        return;
      }
      // Release EGL and GL resources on render thread.
      // TODO(magjed): This might not be necessary - all OpenGL resources are automatically deleted
      // when the EGL context is lost. It might be dangerous to delete them manually in
      // Activity.onDestroy().
      renderThreadHandler.postAtFrontOfQueue(new Runnable() {
        @Override public void run() {
          drawer.release();
          drawer = null;
          if (yuvTextures != null) {
            GLES20.glDeleteTextures(3, yuvTextures, 0);
            yuvTextures = null;
          }
          // Clear last rendered image to black.
          makeBlack();
          eglBase.release();
          eglBase = null;
          eglCleanupBarrier.countDown();
        }
      });
      // Don't accept any more frames or messages to the render thread.
      renderThreadHandler = null;
    }
    // Make sure the EGL/GL cleanup posted above is executed.
    ThreadUtils.awaitUninterruptibly(eglCleanupBarrier);
    renderThread.quit();
    synchronized (frameLock) {
      if (pendingFrame != null) {
        pendingFrame.release();
        pendingFrame = null;
      }
    }
    // The |renderThread| cleanup is not safe to cancel and we need to wait until it's done.
    ThreadUtils.joinUninterruptibly(renderThread);
    renderThread = null;
    // Reset statistics and event reporting.
    synchronized (layoutLock) {
      frameWidth = 0;
      frameHeight = 0;
      frameRotation = 0;
      rendererEvents = null;
    }
    resetStatistics();
  }

  /**
   * Reset statistics. This will reset the logged statistics in logStatistics(), and
   * RendererEvents.onFirstFrameRendered() will be called for the next frame.
   */
  public void resetStatistics() {
    synchronized (statisticsLock) {
      framesReceived = 0;
      framesDropped = 0;
      framesRendered = 0;
      firstFrameTimeNs = 0;
      renderTimeNs = 0;
    }
  }

  /**
   * Set if the video stream should be mirrored or not.
   */
  public void setMirror(final boolean mirror) {
    synchronized (layoutLock) {
      this.mirror = mirror;
    }
  }

  // VideoSink interface.
  @Override
  public void onFrame(VideoFrame frame) {
    synchronized (statisticsLock) {
      ++framesReceived;
    }
    synchronized (handlerLock) {
      if (renderThreadHandler == null) {
        Logging.d(TAG, getResourceName()
            + "Dropping frame - Not initialized or already released.");
        frame.release();
        return;
      }
      synchronized (frameLock) {
        if (pendingFrame != null) {
          // Drop old frame.
          synchronized (statisticsLock) {
            ++framesDropped;
          }
          pendingFrame.release();
        }
        pendingFrame = frame;
        renderThreadHandler.post(renderFrameRunnable);
      }
    }
  }

  public void surfaceDestroyed() {
    Logging.d(TAG, getResourceName() + "Surface destroyed.");
    synchronized (layoutLock) {
      isSurfaceCreated = false;
      surfaceSize.x = 0;
      surfaceSize.y = 0;
    }
    runOnRenderThread(new Runnable() {
      @Override
      public void run() {
        if (eglBase != null) {
          eglBase.detachCurrent();
          eglBase.releaseSurface();
        }
      }
    });
  }

  public void surfaceChanged(int width, int height) {
    Logging.d(TAG, getResourceName() + "Surface changed: " + width + "x" + height);
    synchronized (layoutLock) {
      surfaceSize.x = width;
      surfaceSize.y = height;
      layoutSize.x = width;
      layoutSize.y = height;
    }
    // Might have a pending frame waiting for a surface of correct size.
    runOnRenderThread(renderFrameRunnable);
  }

  /**
   * Private helper function to post tasks safely.
   */
  private void runOnRenderThread(Runnable runnable) {
    synchronized (handlerLock) {
      if (renderThreadHandler != null) {
        renderThreadHandler.post(runnable);
      }
    }
  }

  private String getResourceName() {
    try {
      return "SurfaceTextureRenderer: ";
    } catch (NotFoundException e) {
      return "";
    }
  }

  private void makeBlack() {
    if (Thread.currentThread() != renderThread) {
      throw new IllegalStateException(getResourceName() + "Wrong thread.");
    }
    if (eglBase != null && eglBase.hasSurface()) {
      GLES20.glClearColor(0, 0, 0, 0);
      GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
      eglBase.swapBuffers();
    }
  }

  /**
   * Requests new layout if necessary. Returns true if layout and surface size are consistent.
   */
  private boolean checkConsistentLayout() {
    if (Thread.currentThread() != renderThread) {
      throw new IllegalStateException(getResourceName() + "Wrong thread.");
    }
    synchronized (layoutLock) {
      return surfaceSize.equals(layoutSize);
    }
  }

  /**
   * Renders and releases |pendingFrame|.
   */
  private void renderFrameOnRenderThread() {
    if (Thread.currentThread() != renderThread) {
      throw new IllegalStateException(getResourceName() + "Wrong thread.");
    }
    // Fetch and render |pendingFrame|.
    final VideoFrame frame;
    synchronized (frameLock) {
      if (pendingFrame == null) {
        return;
      }
      frame = pendingFrame;
      pendingFrame = null;
    }
    updateFrameDimensionsAndReportEvents(frame);
    if (eglBase == null || !eglBase.hasSurface()) {
      Logging.d(TAG, getResourceName() + "No surface to draw on");
      frame.release();
      return;
    }
    if (!checkConsistentLayout()) {
      // Output intermediate black frames while the layout is updated.
      //makeBlack();
      //VideoRenderer.renderFrameDone(frame);
      return;
    }
    // After a surface size change, the EGLSurface might still have a buffer of the old size in the
    // pipeline. Querying the EGLSurface will show if the underlying buffer dimensions haven't yet
    // changed. Such a buffer will be rendered incorrectly, so flush it with a black frame.
    synchronized (layoutLock) {
      if (eglBase.surfaceWidth() != surfaceSize.x || eglBase.surfaceHeight() != surfaceSize.y) {
        makeBlack();
      }
    }

    final long startTimeNs = System.nanoTime();
    //FIXME
    final float[] texMatrix = {
        1.0f , 0.0f , 0.0f , 0.0f,
        0.0f, 1.0f, 0.0f , 0.0f ,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    };
//    synchronized (layoutLock) {
//      final float[] rotatedSamplingMatrix =
//          RendererCommon.rotateTextureMatrix(frame.samplingMatrix, frame.rotationDegree);
//      final float[] layoutMatrix = RendererCommon.getLayoutMatrix(
//          mirror, frameAspectRatio(), (float) layoutSize.x / layoutSize.y);
//      texMatrix = RendererCommon.multiplyMatrices(rotatedSamplingMatrix, layoutMatrix);
//    }

    VideoFrame.Buffer buffer = frame.getBuffer();
    if (buffer instanceof VideoFrame.I420Buffer) {
      VideoFrame.I420Buffer yuvBuffer = (VideoFrame.I420Buffer) buffer;
      // Make sure YUV textures are allocated.
      if (yuvTextures == null) {
        yuvTextures = new int[3];
        for (int i = 0; i < 3; i++)  {
          yuvTextures[i] = GlUtil.generateTexture(GLES20.GL_TEXTURE_2D);
        }
      }
      final int[] yuvStrides = new int[] {
        yuvBuffer.getStrideY(),
        yuvBuffer.getStrideU(),
        yuvBuffer.getStrideV(),
      };
      final ByteBuffer[] yuvPlanes = new ByteBuffer[] {
        yuvBuffer.getDataY(),
        yuvBuffer.getDataU(),
        yuvBuffer.getDataV()
      };
      yuvTextures = yuvUploader.uploadYuvData(
          frame.getRotatedWidth(), frame.getRotatedHeight(), yuvStrides, yuvPlanes);
      drawer.drawYuv(yuvTextures, texMatrix, frame.getRotatedWidth(), frame.getRotatedHeight(),
          0, 0, surfaceSize.x, surfaceSize.y);
    } else if (buffer instanceof VideoFrame.TextureBuffer) {
      VideoFrame.TextureBuffer textureBuffer = (VideoFrame.TextureBuffer) buffer;
      Matrix finalMatrix = new Matrix(textureBuffer.getTransformMatrix());
//      finalMatrix.preConcat(texMatrix);
      float[] finalGlMatrix = RendererCommon.convertMatrixFromAndroidGraphicsMatrix(finalMatrix);
      switch(textureBuffer.getType()) {
        case OES:
          drawer.drawOes(textureBuffer.getTextureId(), finalGlMatrix, frameWidth, frameHeight, 0, 0, frameWidth, frameHeight);
          break;
        case RGB:
          drawer.drawRgb(textureBuffer.getTextureId(), finalGlMatrix, frameWidth, frameHeight, 0, 0, frameWidth, frameHeight);
          break;
        default:
          throw new RuntimeException("Unknown texture type.");
      }
    } else {
      throw new RuntimeException("Received unknown buffer type");
    }

    eglBase.swapBuffers();
    frame.release();
    synchronized (statisticsLock) {
      if (framesRendered == 0) {
        firstFrameTimeNs = startTimeNs;
        synchronized (layoutLock) {
          Logging.d(TAG, getResourceName() + "Reporting first rendered frame.");
          if (rendererEvents != null) {
            rendererEvents.onFirstFrameRendered();
          }
        }
      }
      ++framesRendered;
      renderTimeNs += (System.nanoTime() - startTimeNs);
      if (framesRendered % 300 == 0) {
        logStatistics();
      }
    }
  }

  // Return current frame aspect ratio, taking rotation into account.
  private float frameAspectRatio() {
    synchronized (layoutLock) {
      if (frameWidth == 0 || frameHeight == 0) {
        return 0.0f;
      }
      return (frameRotation % 180 == 0) ? (float) frameWidth / frameHeight
                                        : (float) frameHeight / frameWidth;
    }
  }

  // Update frame dimensions and report any changes to |rendererEvents|.
  private void updateFrameDimensionsAndReportEvents(VideoFrame frame) {
    synchronized (layoutLock) {
      if (frameWidth != frame.getRotatedWidth() || frameHeight != frame.getRotatedHeight() || frameRotation != frame.getRotation()) {
        Logging.d(TAG, getResourceName() + "Reporting frame resolution changed to "
            + frame.getRotatedWidth() + "x" + frame.getRotatedHeight() + " with rotation " + frame.getRotation());
        if (rendererEvents != null) {
          rendererEvents.onFrameResolutionChanged(frame.getRotatedWidth(), frame.getRotatedHeight(), frame.getRotation());
        }
        frameWidth = frame.getRotatedWidth();
        frameHeight = frame.getRotatedHeight();
        frameRotation = frame.getRotation();
        texture.setDefaultBufferSize(frameWidth, frameHeight);
        surfaceChanged(frameWidth, frameHeight);
      }
    }
  }

  private void logStatistics() {
    synchronized (statisticsLock) {
      Logging.d(TAG, getResourceName() + "Frames received: "
          + framesReceived + ". Dropped: " + framesDropped + ". Rendered: " + framesRendered);
      if (framesReceived > 0 && framesRendered > 0) {
        final long timeSinceFirstFrameNs = System.nanoTime() - firstFrameTimeNs;
        Logging.d(TAG, getResourceName() + "Duration: " + (int) (timeSinceFirstFrameNs / 1e6) +
            " ms. FPS: " + framesRendered * 1e9 / timeSinceFirstFrameNs);
        Logging.d(TAG, getResourceName() + "Average render time: "
            + (int) (renderTimeNs / (1000 * framesRendered)) + " us.");
      }
    }
  }
}
