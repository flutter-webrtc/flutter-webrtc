package com.cloudwebrtc.webrtc.video;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertThrows;

import org.junit.Test;
import org.webrtc.Size;
import org.webrtc.VideoFrame;
import org.webrtc.VideoProcessor.FrameAdaptationParameters;

public final class NormalizedCameraVideoTrackTest {
    // A buffer records the exact rectangle the real processor will give WebRTC.
    private static final class Buffer implements VideoFrame.Buffer {
        final int width, height;
        int[] crop;
        int refs = 1;
        Buffer cropped;
        Buffer(int width, int height) { this.width = width; this.height = height; }
        public int getWidth() { return width; }
        public int getHeight() { return height; }
        public void retain() { refs++; }
        public void release() { refs--; }
        public VideoFrame.I420Buffer toI420() { throw new AssertionError("Unnecessary pixel copy"); }
        public VideoFrame.Buffer cropAndScale(int x, int y, int w, int h, int targetW, int targetH) {
            crop = new int[] {x, y, w, h, targetW, targetH};
            return cropped = new Buffer(targetW, targetH);
        }
    }

    private static void crop(int width, int height, int rotation, Size target, int... expected) {
        Buffer source = new Buffer(width, height);
        NormalizedCameraVideoTrack track = new NormalizedCameraVideoTrack(null, target);
        VideoFrame.Buffer cropped = track.prepareBuffer(source, rotation);
        assertArrayEquals(expected, source.crop);
        cropped.release();
        assertEquals(0, source.cropped.refs);
        assertEquals(1, source.refs);
        source.release();
    }

    @Test
    public void sharedCameraRequiresCompatibleNormalizationAndCanvas() {
        Size wide = new Size(800, 480);
        Size tall = new Size(480, 800);
        LocalVideoTrack plain = new LocalVideoTrack(null);
        LocalVideoTrack fixed = new NormalizedCameraVideoTrack(null, wide);
        LocalVideoTrack natural = new NormalizedCameraVideoTrack(null, null);

        NormalizedCameraVideoTrack.requireCompatibleOutput(null, false, null);
        assertThrows(NormalizedCameraVideoTrack.CameraLayoutConflict.class,
                () -> NormalizedCameraVideoTrack.requireCompatibleOutput(null, true, wide));
        NormalizedCameraVideoTrack.requireCompatibleOutput(plain, false, null);
        assertThrows(NormalizedCameraVideoTrack.CameraLayoutConflict.class,
                () -> NormalizedCameraVideoTrack.requireCompatibleOutput(plain, true, null));
        NormalizedCameraVideoTrack.requireCompatibleOutput(natural, true, null);
        assertThrows(NormalizedCameraVideoTrack.CameraLayoutConflict.class,
                () -> NormalizedCameraVideoTrack.requireCompatibleOutput(natural, false, null));

        LocalVideoTrack shared = NormalizedCameraVideoTrack.forSharedCamera(null, fixed);
        NormalizedCameraVideoTrack.requireCompatibleOutput(shared, true, new Size(800, 480));
        assertThrows(NormalizedCameraVideoTrack.CameraLayoutConflict.class,
                () -> NormalizedCameraVideoTrack.requireCompatibleOutput(shared, true, tall));
        assertThrows(NormalizedCameraVideoTrack.CameraLayoutConflict.class,
                () -> NormalizedCameraVideoTrack.requireCompatibleOutput(shared, true, null));
    }

    @Test
    public void fillsTheRequested1280By720FrameFrom640By480() {
        NormalizedCameraVideoTrack track = new NormalizedCameraVideoTrack(null, new Size(1280, 720));
        Buffer source = new Buffer(640, 480);
        VideoFrame input = new VideoFrame(source, 0, 111);
        int[] delivered = {0};
        track.setSink(frame -> {
            assertEquals(0, frame.getRotation());
            assertEquals(1280, frame.getBuffer().getWidth());
            assertEquals(720, frame.getBuffer().getHeight());
            assertEquals(111, frame.getTimestampNs());
            delivered[0]++;
        });
        track.onFrameCaptured(input);
        assertEquals(1, delivered[0]);
        assertArrayEquals(new int[]{0, 60, 640, 360, 1280, 720}, source.crop);
        input.release();
    }

    @Test
    public void preservesTheWholeBufferWhenItsRotatedSizeAlreadyMatches() {
        Buffer source = new Buffer(641, 479);
        for (int rotation : new int[]{0, 90, 180, 270}) {
            Size target = rotation % 180 == 0 ? new Size(641, 479) : new Size(479, 641);
            NormalizedCameraVideoTrack track = new NormalizedCameraVideoTrack(null, target);
            VideoFrame.Buffer prepared = track.prepareBuffer(source, rotation);
            assertSame(source, prepared);
            prepared.release();
        }
        assertEquals(1, source.refs);
        source.release();
    }

    @Test
    public void cropsTheOriginalFieldOfViewToTheRequestedCanvas() {
        Size wide = new Size(800, 480);
        crop(640, 480, 0, wide,   0, 48, 640, 384, 800, 480);
        crop(640, 480, 90, wide,  176, 0, 288, 480, 480, 800);
        crop(800, 480, 270, wide, 256, 0, 288, 480, 480, 800);
        crop(645, 487, 0, wide,   0, 50, 644, 386, 800, 480);
        crop(640, 480, 90, new Size(240, 320), 0, 0, 640, 480, 320, 240);
    }

    @Test
    public void naturalOutputKeepsSourcePixelsWithoutCroppingOrRescaling() {
        NormalizedCameraVideoTrack track = new NormalizedCameraVideoTrack(null, null);
        Buffer source = new Buffer(641, 479);
        for (int rotation : new int[]{0, 90, 180, 270}) {
            VideoFrame.Buffer retained = track.prepareBuffer(source, rotation);
            assertSame(source, retained);
            retained.release();
        }
        assertEquals(1, source.refs);
        source.release();
    }

    @Test
    public void respectsNativeFrameDropsAndTimestampsWithAnOptInCanvas() {
        NormalizedCameraVideoTrack track = new NormalizedCameraVideoTrack(null, new Size(320, 240));
        Buffer source = new Buffer(1280, 720);
        VideoFrame frame = new VideoFrame(source, 0, 111);
        int[] received = {0};
        track.setSink(output -> {
            assertEquals(0, output.getRotation());
            assertEquals(320, output.getRotatedWidth());
            assertEquals(240, output.getRotatedHeight());
            assertEquals(222, output.getTimestampNs());
            received[0]++;
        });
        track.onFrameCaptured(frame, new FrameAdaptationParameters(12, 34, 320, 240, 160, 120, 222, true));
        assertEquals(0, received[0]);
        track.onFrameCaptured(frame, new FrameAdaptationParameters(12, 34, 320, 240, 160, 120, 222, false));
        assertEquals(1, received[0]);
        assertArrayEquals(new int[]{160, 0, 960, 720, 320, 240}, source.crop);
        assertEquals(1, source.refs);
        assertEquals(0, source.cropped.refs);
        frame.release();
    }
}
