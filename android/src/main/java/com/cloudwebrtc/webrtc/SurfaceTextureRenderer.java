package com.cloudwebrtc.webrtc;

import android.graphics.SurfaceTexture;
import android.util.Log;

import org.webrtc.EglBase;
import org.webrtc.EglRenderer;
import org.webrtc.GlRectDrawer;
import org.webrtc.RendererCommon;
import org.webrtc.ThreadUtils;
import org.webrtc.VideoFrame;

import java.util.concurrent.CountDownLatch;
import java.util.function.Function;

import com.cloudwebrtc.webrtc.utils.VideoFrameTransform;
import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.ExportFrame;


import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.BinaryMessenger;


/**
 * Display the video stream on a Surface.
 * renderFrame() is asynchronous to avoid blocking the calling thread.
 * This class is thread safe and handles access from potentially three different threads:
 * Interaction from the main app in init, release and setMirror.
 * Interaction from C++ rtc::VideoSinkInterface in renderFrame.
 * Interaction from SurfaceHolder lifecycle in surfaceCreated, surfaceChanged, and surfaceDestroyed.
 */
public class SurfaceTextureRenderer extends EglRenderer {
  // Callback for reporting renderer events. Read-only after initilization so no lock required.
  private RendererCommon.RendererEvents rendererEvents;
  private final Object layoutLock = new Object();
  private boolean isRenderingPaused;
  private boolean isFirstFrameRendered;
  private int rotatedFrameWidth;
  private int rotatedFrameHeight;
  private int frameRotation;
  private EventChannel.EventSink eventSink;
  private int id;
  private ExportFrame exportFrame;
  private int frameCount;

  /**
   * In order to render something, you must first call init().
   */
  public SurfaceTextureRenderer(String name) {
    super(name);
  }

  public void init(final EglBase.Context sharedContext,
                   RendererCommon.RendererEvents rendererEvents, ExportFrame exportFrame) {
    this.exportFrame = exportFrame;
    init(sharedContext, rendererEvents, EglBase.CONFIG_PLAIN, new GlRectDrawer());
  }

  /**
   * Initialize this class, sharing resources with |sharedContext|. The custom |drawer| will be used
   * for drawing frames on the EGLSurface. This class is responsible for calling release() on
   * |drawer|. It is allowed to call init() to reinitialize the renderer after a previous
   * init()/release() cycle.
   */
  public void init(final EglBase.Context sharedContext,
                   RendererCommon.RendererEvents rendererEvents, final int[] configAttributes,
                   RendererCommon.GlDrawer drawer) {
    ThreadUtils.checkIsOnMainThread();
    this.rendererEvents = rendererEvents;
    synchronized (layoutLock) {
      isFirstFrameRendered = false;
      rotatedFrameWidth = 0;
      rotatedFrameHeight = 0;
      frameRotation = -1;
    }
    super.init(sharedContext, configAttributes, drawer);
  }
  @Override
  public void init(final EglBase.Context sharedContext, final int[] configAttributes,
                   RendererCommon.GlDrawer drawer) {
    init(sharedContext, null /* rendererEvents */, configAttributes, drawer);
  }
  /**
   * Limit render framerate.
   *
   * @param fps Limit render framerate to this value, or use Float.POSITIVE_INFINITY to disable fps
   *            reduction.
   */
  @Override
  public void setFpsReduction(float fps) {
    synchronized (layoutLock) {
      isRenderingPaused = fps == 0f;
    }
    super.setFpsReduction(fps);
  }
  @Override
  public void disableFpsReduction() {
    synchronized (layoutLock) {
      isRenderingPaused = false;
    }
    super.disableFpsReduction();
  }
  @Override
  public void pauseVideo() {
    synchronized (layoutLock) {
      isRenderingPaused = true;
    }
    super.pauseVideo();
  }
  // VideoSink interface.
  @Override
  public void onFrame(VideoFrame frame) {
    updateFrameDimensionsAndReportEvents(frame);
    super.onFrame(frame);
    if(exportFrame.enabledExportFrame && eventSink != null) {
      // if exportFrame.frameCount == -1, keep callback
      // else only once frame caputure
      if(exportFrame.frameCount == -1) {
        onFrameCallback(frame);
      } else if(frameCount == exportFrame.frameCount) {
        onFrameCallback(frame);
      }
      frameCount++;
    }
  }

  private void onFrameCallback(VideoFrame frame) {
    VideoFrameTransform.PhotographFormat transformResult = VideoFrameTransform.transform(frame, exportFrame.format);
    ConstraintsMap params = new ConstraintsMap();
    params.putString("event", "onVideoFrame");
    params.putInt("id", id);
    params.putByte("data", transformResult.data);
    params.putInt("width", transformResult.width);
    params.putInt("height", transformResult.height);
    params.putString("format", transformResult.format.name());
    eventSink.success(params.toMap());
  }


  private SurfaceTexture texture;

  public void surfaceCreated(final SurfaceTexture texture) {
    ThreadUtils.checkIsOnMainThread();
    this.texture = texture;
    createEglSurface(texture);
  }

  public void setEventSink(EventChannel.EventSink sink, int id){
    this.eventSink = sink;
    this.id = id;
  }

  public void surfaceDestroyed() {
    ThreadUtils.checkIsOnMainThread();
    final CountDownLatch completionLatch = new CountDownLatch(1);
    releaseEglSurface(completionLatch::countDown);
    ThreadUtils.awaitUninterruptibly(completionLatch);
  }

  // Update frame dimensions and report any changes to |rendererEvents|.
  private void updateFrameDimensionsAndReportEvents(VideoFrame frame) {
    synchronized (layoutLock) {
      if (isRenderingPaused) {
        return;
      }
      if (!isFirstFrameRendered) {
        isFirstFrameRendered = true;
        if (rendererEvents != null) {
          rendererEvents.onFirstFrameRendered();
        }
      }
      if (rotatedFrameWidth != frame.getRotatedWidth()
              || rotatedFrameHeight != frame.getRotatedHeight()
              || frameRotation != frame.getRotation()) {
        if (rendererEvents != null) {
          rendererEvents.onFrameResolutionChanged(
                  frame.getBuffer().getWidth(), frame.getBuffer().getHeight(), frame.getRotation());
        }
        rotatedFrameWidth = frame.getRotatedWidth();
        rotatedFrameHeight = frame.getRotatedHeight();
        texture.setDefaultBufferSize(rotatedFrameWidth, rotatedFrameHeight);
        frameRotation = frame.getRotation();
      }
    }
  }
}
