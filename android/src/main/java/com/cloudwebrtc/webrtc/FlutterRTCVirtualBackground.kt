package com.cloudwebrtc.webrtc

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.opengl.GLES20
import android.opengl.GLUtils
import android.util.Log
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.segmentation.Segmentation
import com.google.mlkit.vision.segmentation.SegmentationMask
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions
import org.webrtc.EglBase
import org.webrtc.SurfaceTextureHelper
import org.webrtc.TextureBufferImpl
import org.webrtc.VideoFrame
import org.webrtc.VideoProcessor
import org.webrtc.VideoSink
import org.webrtc.VideoSource
import org.webrtc.YuvConverter
import org.webrtc.YuvHelper
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.util.Arrays
import kotlin.math.max

class FlutterRTCVirtualBackground {
    val TAG = FlutterWebRTCPlugin.TAG

    private var videoSource: VideoSource? = null
    private var textureHelper: SurfaceTextureHelper? = null
    private var backgroundBitmap: Bitmap? = null
    private var expectConfidence = 0.7
    private val segmentOptions = SelfieSegmenterOptions.Builder()
        .setDetectorMode(SelfieSegmenterOptions.STREAM_MODE)
        .enableRawSizeMask()
        .setStreamModeSmoothingRatio(1.0f)
        .build()
    private val segmenter = Segmentation.getClient(segmentOptions)

    // MARK: Public functions

    /**
     * Initialize the VirtualBackgroundManager with the given VideoSource.
     *
     * @param videoSource The VideoSource to be used for video capturing.
     */
    fun initialize(videoSource: VideoSource) {
        this.videoSource = videoSource
        setVirtualBackground()
    }

    /**
     * Dispose of the VirtualBackgroundManager, clearing its references and configurations.
     */
    fun dispose() {
        this.videoSource = null
        this.expectConfidence = 0.7
        setBackgroundIsNull()
    }

    fun setBackgroundIsNull() {
        this.backgroundBitmap = null
    }

    /**
     * Configure the virtual background by setting the background bitmap and the desired confidence level.
     *
     * @param bgBitmap The background bitmap to be used for virtual background replacement.
     * @param confidence The confidence level (0 to 1) for selecting the foreground in the segmentation mask.
     */
    fun configurationVirtualBackground(bgBitmap: Bitmap, confidence: Double) {
        backgroundBitmap = bgBitmap
        expectConfidence = confidence
    }

    /**
     * Set up the virtual background processing by attaching a VideoProcessor to the VideoSource.
     * The VideoProcessor will handle capturing video frames, performing segmentation, and replacing the background.
     */
    private fun setVirtualBackground() {
        // Create an instance of EglBase
        val eglBase = EglBase.create()
        textureHelper = SurfaceTextureHelper.create("SurfaceTextureThread", eglBase.eglBaseContext)

        // Attach a VideoProcessor to the VideoSource to process captured video frames
        videoSource!!.setVideoProcessor(object : VideoProcessor {
            private var sink: VideoSink? = null

            override fun onCapturerStarted(success: Boolean) {
                // Handle video capture start event
            }

            override fun onCapturerStopped() {
                // Handle video capture stop event
            }

            override fun onFrameCaptured(frame: VideoFrame) {
                if (sink != null) {
                    if (backgroundBitmap == null) {
                        // If no background is set, pass the original frame to the sink
                        sink!!.onFrame(frame)
                    } else {
                        // Otherwise, perform segmentation on the captured frame and replace the background
                        val inputFrameBitmap: Bitmap? = videoFrameToBitmap(frame)
                        if (inputFrameBitmap != null) {
                            runSegmentationInBackground(inputFrameBitmap, frame, sink!!)
                        } else {
                            Log.d(TAG, "Convert video frame to bitmap failure")
                        }
                    }
                }
            }

            override fun setSink(sink: VideoSink?) {
                // Store the VideoSink to send the processed frame back to WebRTC
                // The sink will be used after segmentation processing
                this.sink = sink
            }
        })
    }

    /**
     * Perform segmentation on the input bitmap in the background thread.
     * After segmentation, the background is replaced with the configured virtual background.
     *
     * @param inputFrameBitmap The input frame bitmap to be segmented.
     * @param frame The original VideoFrame metadata for the input bitmap.
     * @param sink The VideoSink to send the processed frame back to WebRTC.
     */
    private fun runSegmentationInBackground(
        inputFrameBitmap: Bitmap,
        frame: VideoFrame,
        sink: VideoSink
    ) {
        Thread {
            // Perform segmentation in the background thread
            processSegmentation(inputFrameBitmap, frame, sink)
        }.start()
    }

    /**
     * Convert a VideoFrame to a Bitmap for further processing.
     *
     * @param videoFrame The input VideoFrame to be converted.
     * @return The corresponding Bitmap representation of the VideoFrame.
     */
    private fun videoFrameToBitmap(videoFrame: VideoFrame): Bitmap? {
        // Retain the VideoFrame to prevent it from being garbage collected
        videoFrame.retain()

        // Convert the VideoFrame to I420 format
        val buffer = videoFrame.buffer
        val i420Buffer = buffer.toI420()
        val y = i420Buffer!!.dataY
        val u = i420Buffer.dataU
        val v = i420Buffer.dataV
        val width = i420Buffer.width
        val height = i420Buffer.height
        val strides = intArrayOf(
            i420Buffer.strideY,
            i420Buffer.strideU,
            i420Buffer.strideV
        )
        // Convert I420 format to NV12 format as required by YuvImage
        val chromaWidth = (width + 1) / 2
        val chromaHeight = (height + 1) / 2
        val minSize = width * height + chromaWidth * chromaHeight * 2
        val yuvBuffer = ByteBuffer.allocateDirect(minSize)
        YuvHelper.I420ToNV12(
            y,
            strides[0],
            v,
            strides[2],
            u,
            strides[1],
            yuvBuffer,
            width,
            height
        )
        // Remove leading 0 from the ByteBuffer
        val cleanedArray =
            Arrays.copyOfRange(yuvBuffer.array(), yuvBuffer.arrayOffset(), minSize)
        val yuvImage = YuvImage(
            cleanedArray,
            ImageFormat.NV21,
            width,
            height,
            null
        )
        i420Buffer.release()
        videoFrame.release()

        // Convert YuvImage to byte array
        val outputStream = ByteArrayOutputStream()
        yuvImage.compressToJpeg(
            Rect(0, 0, yuvImage.width, yuvImage.height),
            100,
            outputStream
        )
        val jpegData = outputStream.toByteArray()

        // Convert byte array to Bitmap
        return BitmapFactory.decodeByteArray(jpegData, 0, jpegData.size)
    }

    /**
     * Process the segmentation of the input bitmap using the AI segmenter.
     * The resulting segmented bitmap is then combined with the provided background bitmap,
     * and the final output frame is sent to the video sink.
     *
     * @param bitmap The input bitmap to be segmented.
     * @param original The original video frame for metadata reference (rotation, timestamp, etc.).
     * @param sink The VideoSink to receive the processed video frame.
     */
    private fun processSegmentation(bitmap: Bitmap, original: VideoFrame, sink: VideoSink) {
        // Create an InputImage from the input bitmap
        val inputImage = InputImage.fromBitmap(bitmap, 0)

        // Perform segmentation using the AI segmenter
        val result = segmenter.process(inputImage)
        result.addOnCompleteListener { task: Task<SegmentationMask> ->
            if (task.isSuccessful) {
                // Segmentation process successful
                val segmentationMask = task.result
                val mask = segmentationMask.buffer
                val maskWidth = segmentationMask.width
                val maskHeight = segmentationMask.height
                mask.rewind()

                // Convert the buffer to an array of colors
                val colors = maskColorsFromByteBuffer(
                    mask,
                    maskWidth,
                    maskHeight,
                    bitmap,
                    bitmap.width,
                    bitmap.height
                )

                // Create a segmented bitmap from the array of colors
                val segmentedBitmap =
                    createBitmapFromColors(colors, bitmap.width, bitmap.height)


                if (backgroundBitmap == null) {
                    return@addOnCompleteListener
                }

                // Draw the segmented bitmap on top of the background
                val outputBitmap =
                    drawSegmentedBackground(segmentedBitmap, backgroundBitmap)

                // Create a new VideoFrame from the processed bitmap
                val yuvConverter = YuvConverter()
                if (textureHelper != null && textureHelper!!.handler != null) {
                    textureHelper!!.handler.post {
                        val textures = IntArray(1)
                        GLES20.glGenTextures(1, textures, 0)
                        GLES20.glBindTexture(
                            GLES20.GL_TEXTURE_2D,
                            textures[0]
                        )
                        GLES20.glTexParameteri(
                            GLES20.GL_TEXTURE_2D,
                            GLES20.GL_TEXTURE_MIN_FILTER,
                            GLES20.GL_NEAREST
                        )
                        GLES20.glTexParameteri(
                            GLES20.GL_TEXTURE_2D,
                            GLES20.GL_TEXTURE_MAG_FILTER,
                            GLES20.GL_NEAREST
                        )
                        GLUtils.texImage2D(
                            GLES20.GL_TEXTURE_2D,
                            0,
                            outputBitmap,
                            0
                        )
                        val buffer = TextureBufferImpl(
                            outputBitmap!!.width,
                            outputBitmap.height,
                            VideoFrame.TextureBuffer.Type.RGB,
                            textures[0],
                            Matrix(),
                            textureHelper!!.handler,
                            yuvConverter,
                            null
                        )
                        val i420Buf = yuvConverter.convert(buffer)
                        if (i420Buf != null) {
                            val outputVideoFrame = VideoFrame(
                                i420Buf,
                                original.rotation,
                                original.timestampNs
                            )
                            sink.onFrame(outputVideoFrame)
                        }
                    }
                }
            } else {
                // Handle segmentation error
                val error = task.exception
                // Log error information
                Log.d(TAG, "Segmentation error: " + error.toString())
            }
        }
    }

    /**
     * Convert the mask buffer to an array of colors representing the segmented regions.
     *
     * @param mask The mask buffer obtained from the AI segmenter.
     * @param maskWidth The width of the mask.
     * @param maskHeight The height of the mask.
     * @param originalBitmap The original input bitmap used for color extraction.
     * @param scaledWidth The width of the scaled bitmap.
     * @param scaledHeight The height of the scaled bitmap.
     * @return An array of colors representing the segmented regions.
     */
    private fun maskColorsFromByteBuffer(
        mask: ByteBuffer,
        maskWidth: Int,
        maskHeight: Int,
        originalBitmap: Bitmap,
        scaledWidth: Int,
        scaledHeight: Int
    ): IntArray {
        val colors = IntArray(scaledWidth * scaledHeight)
        var count = 0
        val scaleX = scaledWidth.toFloat() / maskWidth
        val scaleY = scaledHeight.toFloat() / maskHeight
        for (y in 0 until scaledHeight) {
            for (x in 0 until scaledWidth) {
                val maskX: Int = (x / scaleX).toInt()
                val maskY: Int = (y / scaleY).toInt()
                if (maskX in 0 until maskWidth && maskY >= 0 && maskY < maskHeight) {
                    val position = (maskY * maskWidth + maskX) * 4
                    mask.position(position)

                    // Get the confidence of the (x,y) pixel in the mask being in the foreground.
                    val foregroundConfidence = mask.float
                    val pixelColor = originalBitmap.getPixel(x, y)

                    // Extract the color channels from the original pixel
                    val alpha = Color.alpha(pixelColor)
                    val red = Color.red(pixelColor)
                    val green = Color.green(pixelColor)
                    val blue = Color.blue(pixelColor)

                    // Calculate the new alpha and color for the foreground and background
                    var newAlpha: Int
                    var newRed: Int
                    var newGreen: Int
                    var newBlue: Int
                    if (foregroundConfidence >= expectConfidence) {
                        // Foreground uses color from the original bitmap
                        newAlpha = alpha
                        newRed = red
                        newGreen = green
                        newBlue = blue
                    } else {
                        // Background is black with alpha 0
                        newAlpha = 0
                        newRed = 0
                        newGreen = 0
                        newBlue = 0
                    }

                    // Create a new color with the adjusted alpha and RGB channels
                    val newColor = Color.argb(newAlpha, newRed, newGreen, newBlue)
                    colors[count] = newColor
                } else {
                    // Pixels outside the original mask size are considered background (black with alpha 0)
                    colors[count] = Color.argb(0, 0, 0, 0)
                }
                count++
            }
        }
        return colors
    }

    /**
     * Draws the segmentedBitmap on top of the backgroundBitmap with the background resized and centered
     * to fit the dimensions of the segmentedBitmap. The output is a new bitmap containing the combined
     * result.
     *
     * @param segmentedBitmap The bitmap representing the segmented foreground with transparency.
     * @param backgroundBitmap The bitmap representing the background image to be used as the base.
     * @return The resulting bitmap with the segmented foreground overlaid on the background.
     *         Returns null if either of the input bitmaps is null.
     */
    private fun drawSegmentedBackground(
        segmentedBitmap: Bitmap?,
        backgroundBitmap: Bitmap?
    ): Bitmap? {
        if (segmentedBitmap == null || backgroundBitmap == null) {
            // Handle invalid bitmaps
            return null
        }

        val segmentedWidth = segmentedBitmap.width
        val segmentedHeight = segmentedBitmap.height

        // Create a new bitmap with dimensions matching the segmentedBitmap
        val outputBitmap =
            Bitmap.createBitmap(segmentedWidth, segmentedHeight, Bitmap.Config.ARGB_8888)

        // Create a canvas to draw on the outputBitmap
        val canvas = Canvas(outputBitmap)

        // Calculate the scale factor for the backgroundBitmap to be larger or equal to the segmentedBitmap
        val scaleX = segmentedWidth.toFloat() / backgroundBitmap.width
        val scaleY = segmentedHeight.toFloat() / backgroundBitmap.height
        val scale = max(scaleX, scaleY)

        // Calculate the new dimensions of the backgroundBitmap after scaling
        val newBackgroundWidth = (backgroundBitmap.width * scale).toInt()
        val newBackgroundHeight = (backgroundBitmap.height * scale).toInt()

        // Calculate the offset to center the backgroundBitmap in the outputBitmap
        val offsetX = (segmentedWidth - newBackgroundWidth) / 2
        val offsetY = (segmentedHeight - newBackgroundHeight) / 2

        // Create a transformation matrix to scale and center the backgroundBitmap
        val matrix = Matrix()
        matrix.postScale(scale, scale)
        matrix.postTranslate(offsetX.toFloat(), offsetY.toFloat())

        // Draw the backgroundBitmap on the canvas with the specified scale and centering
        canvas.drawBitmap(backgroundBitmap, matrix, null)

        // Draw the segmentedBitmap on the canvas
        canvas.drawBitmap(segmentedBitmap, 0f, 0f, null)

        return outputBitmap
    }

    /**
     * Creates a bitmap from an array of colors with the specified width and height.
     *
     * @param colors The array of colors representing the pixel values of the bitmap.
     * @param width The width of the bitmap.
     * @param height The height of the bitmap.
     * @return The resulting bitmap created from the array of colors.
     */
    private fun createBitmapFromColors(colors: IntArray, width: Int, height: Int): Bitmap {
        return Bitmap.createBitmap(colors, width, height, Bitmap.Config.ARGB_8888)
    }
}