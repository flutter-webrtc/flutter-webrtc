package com.cloudwebrtc.webrtc;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.hardware.Camera.Parameters;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.util.Log;
import android.util.Range;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;
import com.cloudwebrtc.webrtc.utils.MediaConstraintsUtils;
import com.cloudwebrtc.webrtc.utils.ObjectType;
import com.cloudwebrtc.webrtc.utils.PermissionUtils;

import org.webrtc.AudioSource;
import org.webrtc.AudioTrack;
import org.webrtc.Camera1Capturer;
import org.webrtc.Camera1Enumerator;
import org.webrtc.Camera2Capturer;
import org.webrtc.Camera2Enumerator;
import org.webrtc.CameraEnumerationAndroid.CaptureFormat;
import org.webrtc.CameraEnumerator;
import org.webrtc.CameraVideoCapturer;
import org.webrtc.MediaConstraints;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.SurfaceTextureHelper;
import org.webrtc.VideoCapturer;
import org.webrtc.VideoSource;
import org.webrtc.VideoTrack;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;

import io.flutter.plugin.common.MethodChannel.Result;

/**
 * The implementation of {@code getUserMedia} extracted into a separate file in order to reduce
 * complexity and to (somewhat) separate concerns.
 */
class GetUserMediaImpl {

    private static final int DEFAULT_WIDTH = 1280;
    private static final int DEFAULT_HEIGHT = 720;
    private static final int DEFAULT_FPS = 30;

    private static final String PERMISSION_AUDIO = Manifest.permission.RECORD_AUDIO;
    private static final String PERMISSION_VIDEO = Manifest.permission.CAMERA;

    private static final String TAG = FlutterWebRTCPlugin.TAG;

    private final Map<String, VideoCapturerInfo> mVideoCapturers = new HashMap<>();

    private final StateProvider stateProvider;
    private final Context applicationContext;

    GetUserMediaImpl(StateProvider stateProvider, Context applicationContext) {
        this.stateProvider = stateProvider;
        this.applicationContext = applicationContext;
    }

    private static void resultError(String method, String error, @NonNull Result result) {
        String errorMsg = method + "(): " + error;
        result.error(method, errorMsg, null);
        Log.d(TAG, errorMsg);
    }

    /**
     * Includes default constraints set for the audio media type.
     *
     * @param audioConstraints <tt>MediaConstraints</tt> instance to be filled with the default
     *                         constraints for audio media type.
     */
    private void addDefaultAudioConstraints(@NonNull MediaConstraints audioConstraints) {
        audioConstraints.optional.add(
                new MediaConstraints.KeyValuePair("googNoiseSuppression", "true"));
        audioConstraints.optional.add(
                new MediaConstraints.KeyValuePair("googEchoCancellation", "true"));
        audioConstraints.optional.add(new MediaConstraints.KeyValuePair("echoCancellation", "true"));
        audioConstraints.optional.add(
                new MediaConstraints.KeyValuePair("googEchoCancellation2", "true"));
        audioConstraints.optional.add(
                new MediaConstraints.KeyValuePair("googDAEchoCancellation", "true"));
    }

    /**
     * Create video capturer via given facing mode
     *
     * @param enumerator a <tt>CameraEnumerator</tt> provided by webrtc it can be Camera1Enumerator or
     *                   Camera2Enumerator
     * @param isFacing   'user' mapped with 'front' is true (default) 'environment' mapped with 'back'
     *                   is false
     * @param sourceId   (String) use this sourceId and ignore facing mode if specified.
     * @return VideoCapturer can invoke with <tt>startCapture</tt>/<tt>stopCapture</tt> <tt>null</tt>
     * if not matched camera with specified facing mode.
     */
    @Nullable
    private VideoCapturer createVideoCapturer(
            @NonNull CameraEnumerator enumerator, boolean isFacing, @Nullable String sourceId) {
        VideoCapturer videoCapturer = null;

        // if sourceId given, use specified sourceId first
        final String[] deviceNames = enumerator.getDeviceNames();
        if (sourceId != null) {
            for (String name : deviceNames) {
                if (name.equals(sourceId)) {
                    videoCapturer = enumerator.createCapturer(name, new CameraEventsHandler());
                    if (videoCapturer != null) {
                        Log.d(TAG, "create user specified camera " + name + " succeeded");
                        return videoCapturer;
                    } else {
                        Log.d(TAG, "create user specified camera " + name + " failed");
                        break; // fallback to facing mode
                    }
                }
            }
        }

        // otherwise, use facing mode
        String facingStr = isFacing ? "front" : "back";
        for (String name : deviceNames) {
            if (enumerator.isFrontFacing(name) == isFacing) {
                videoCapturer = enumerator.createCapturer(name, new CameraEventsHandler());
                if (videoCapturer != null) {
                    Log.d(TAG, "Create " + facingStr + " camera " + name + " succeeded");
                    return videoCapturer;
                } else {
                    Log.e(TAG, "Create " + facingStr + " camera " + name + " failed");
                }
            }
        }

        // falling back to the first available camera
        if (videoCapturer == null && deviceNames.length > 0) {
            videoCapturer = enumerator.createCapturer(deviceNames[0], new CameraEventsHandler());
            Log.d(TAG, "Falling back to the first available camera");
        }

        return videoCapturer;
    }

    /**
     * Retrieves "facingMode" constraint value.
     *
     * @param mediaConstraints a <tt>ConstraintsMap</tt> which represents "GUM" constraints argument.
     * @return String value of "facingMode" constraints in "GUM" or <tt>null</tt> if not specified.
     */
    @Nullable
    private String getFacingMode(@Nullable ConstraintsMap mediaConstraints) {
        return mediaConstraints == null ? null : mediaConstraints.getString("facingMode");
    }

    /**
     * Retrieves "sourceId" constraint value.
     *
     * @param mediaConstraints a <tt>ConstraintsMap</tt> which represents "GUM" constraints argument
     * @return String value of "sourceId" optional "GUM" constraint or <tt>null</tt> if not specified.
     */
    @Nullable
    private String getSourceIdConstraint(@Nullable ConstraintsMap mediaConstraints) {
        if (mediaConstraints != null
                && mediaConstraints.hasKey("optional")
                && mediaConstraints.getType("optional") == ObjectType.Array) {
            ConstraintsArray optional = mediaConstraints.getArray("optional");

            for (int i = 0, size = optional.size(); i < size; i++) {
                if (optional.getType(i) == ObjectType.Map) {
                    ConstraintsMap option = optional.getMap(i);

                    if (option.hasKey("sourceId") && option.getType("sourceId") == ObjectType.String) {
                        return option.getString("sourceId");
                    }
                }
            }
        }

        return null;
    }

    private AudioTrack getUserAudio(@NonNull ConstraintsMap constraints) {
        MediaConstraints audioConstraints;
        if (constraints.getType("audio") == ObjectType.Boolean) {
            audioConstraints = new MediaConstraints();
            addDefaultAudioConstraints(audioConstraints);
        } else {
            audioConstraints = MediaConstraintsUtils.parseMediaConstraints(constraints.getMap("audio"));
        }

        Log.i(TAG, "getUserMedia(audio): " + audioConstraints);

        String trackId = stateProvider.getNextTrackUUID();
        PeerConnectionFactory pcFactory = stateProvider.getPeerConnectionFactory();
        AudioSource audioSource = pcFactory.createAudioSource(audioConstraints);

        return pcFactory.createAudioTrack(trackId, audioSource);
    }

    /**
     * Implements {@code getUserMedia} without knowledge whether the necessary permissions have
     * already been granted. If the necessary permissions have not been granted yet, they will be
     * requested.
     */
    void getUserMedia(
            @NonNull final ConstraintsMap constraints, @NonNull final Result result, @NonNull final MediaStream mediaStream) {

        // TODO: change getUserMedia constraints format to support new syntax
        //   constraint format seems changed, and there is no mandatory any more.
        //   and has a new syntax/attrs to specify resolution
        //   should change `parseConstraints()` according
        //   see: https://www.w3.org/TR/mediacapture-streams/#idl-def-MediaTrackConstraints

        final ArrayList<String> requestPermissions = new ArrayList<>();

        if (constraints.hasKey("audio")) {
            switch (constraints.getType("audio")) {
                case Boolean:
                    if (constraints.getBoolean("audio")) {
                        requestPermissions.add(PERMISSION_AUDIO);
                    }
                    break;
                case Map:
                    requestPermissions.add(PERMISSION_AUDIO);
                    break;
                default:
                    break;
            }
        }

        if (constraints.hasKey("video")) {
            switch (constraints.getType("video")) {
                case Boolean:
                    if (constraints.getBoolean("video")) {
                        requestPermissions.add(PERMISSION_VIDEO);
                    }
                    break;
                case Map:
                    requestPermissions.add(PERMISSION_VIDEO);
                    break;
                default:
                    break;
            }
        }

        // According to step 2 of the getUserMedia() algorithm,
        // requestedMediaTypes is the set of media types in constraints with
        // either a dictionary value or a value of "true".
        // According to step 3 of the getUserMedia() algorithm, if
        // requestedMediaTypes is the empty set, the method invocation fails
        // with a TypeError.
        if (requestPermissions.isEmpty()) {
            resultError("getUserMedia", "TypeError, constraints requests no media types", result);
            return;
        }

        /// Only systems pre-M, no additional permission request is needed.
        if (VERSION.SDK_INT < VERSION_CODES.M) {
            getUserMedia(constraints, result, mediaStream, requestPermissions);
            return;
        }

        requestPermissions(
                requestPermissions,
                success -> getUserMedia(constraints, result, mediaStream, success),
                error -> {
                    // According to step 10 Permission Failure of the
                    // getUserMedia() algorithm, if the user has denied
                    // permission, fail "with a new DOMException object whose
                    // name attribute has the value NotAllowedError."
                    resultError("getUserMedia", "DOMException, NotAllowedError", result);
                });
    }

    /**
     * Implements {@code getUserMedia} with the knowledge that the necessary permissions have already
     * been granted. If the necessary permissions have not been granted yet, they will NOT be
     * requested.
     */
    private void getUserMedia(
            @NonNull ConstraintsMap constraints,
            @NonNull Result result,
            @NonNull MediaStream mediaStream,
            @NonNull List<String> grantedPermissions) {
        MediaStreamTrack[] tracks = new MediaStreamTrack[2];

        // If we fail to create either, destroy the other one and fail.
        if ((grantedPermissions.contains(PERMISSION_AUDIO)
                && (tracks[0] = getUserAudio(constraints)) == null)
                || (grantedPermissions.contains(PERMISSION_VIDEO)
                && (tracks[1] = getUserVideo(constraints)) == null)) {
            for (MediaStreamTrack track : tracks) {
                if (track != null) {
                    track.dispose();
                }
            }

            // XXX The following does not follow the getUserMedia() algorithm
            // specified by
            // https://www.w3.org/TR/mediacapture-streams/#dom-mediadevices-getusermedia
            // with respect to distinguishing the various causes of failure.
            resultError("getUserMedia", "Failed to create new track.", result);
            return;
        }

        ConstraintsArray audioTracks = new ConstraintsArray();
        ConstraintsArray videoTracks = new ConstraintsArray();
        ConstraintsMap successResult = new ConstraintsMap();

        for (MediaStreamTrack track : tracks) {
            if (track == null) {
                continue;
            }

            String id = track.id();

            if (track instanceof AudioTrack) {
                mediaStream.addTrack((AudioTrack) track);
            } else {
                mediaStream.addTrack((VideoTrack) track);
            }

            ConstraintsMap track_ = new ConstraintsMap();
            String kind = track.kind();

            track_.putBoolean("enabled", track.enabled());
            track_.putString("id", id);
            track_.putString("kind", kind);
            track_.putString("label", kind);
            track_.putString("readyState", track.state().toString());
            track_.putBoolean("remote", false);

            if (track instanceof AudioTrack) {
                audioTracks.pushMap(track_);
            } else {
                videoTracks.pushMap(track_);
            }
        }

        String streamId = mediaStream.getId();

        Log.d(TAG, "MediaStream id: " + streamId);
        stateProvider.getLocalStreams().put(streamId, mediaStream);

        successResult.putString("streamId", streamId);
        successResult.putArray("audioTracks", audioTracks.toArrayList());
        successResult.putArray("videoTracks", videoTracks.toArrayList());
        result.success(successResult.toMap());
    }

    private boolean isFacing = true;

    @Nullable
    private VideoTrack getUserVideo(@NonNull ConstraintsMap constraints) {
        ConstraintsMap videoConstraintsMap = null;
        ConstraintsMap videoConstraintsMandatory = null;
        if (constraints.getType("video") == ObjectType.Map) {
            videoConstraintsMap = constraints.getMap("video");
            if (videoConstraintsMap.hasKey("mandatory")
                    && videoConstraintsMap.getType("mandatory") == ObjectType.Map) {
                videoConstraintsMandatory = videoConstraintsMap.getMap("mandatory");
            }
        }

        Log.i(TAG, "getUserMedia(video): " + videoConstraintsMap);

        // NOTE: to support Camera2, the device should:
        //   1. Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP
        //   2. all camera support level should greater than LEGACY
        //   see:
        // https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics.html#INFO_SUPPORTED_HARDWARE_LEVEL
        // TODO Enable camera2 enumerator
        CameraEnumerator cameraEnumerator;

        if (Camera2Enumerator.isSupported(applicationContext)) {
            Log.d(TAG, "Creating video capturer using Camera2 API.");
            cameraEnumerator = new Camera2Enumerator(applicationContext);
        } else {
            Log.d(TAG, "Creating video capturer using Camera1 API.");
            cameraEnumerator = new Camera1Enumerator(false);
        }

        String facingMode = getFacingMode(videoConstraintsMap);
        isFacing = !"environment".equals(facingMode);
        String sourceId = getSourceIdConstraint(videoConstraintsMap);

        VideoCapturer videoCapturer = createVideoCapturer(cameraEnumerator, isFacing, sourceId);

        if (videoCapturer == null) {
            return null;
        }

        PeerConnectionFactory pcFactory = stateProvider.getPeerConnectionFactory();
        VideoSource videoSource = pcFactory.createVideoSource(false);
        String threadName = Thread.currentThread().getName();
        SurfaceTextureHelper surfaceTextureHelper =
                SurfaceTextureHelper.create(threadName, EglUtils.getRootEglBaseContext());
        videoCapturer.initialize(
                surfaceTextureHelper, applicationContext, videoSource.getCapturerObserver());

        VideoCapturerInfo info = new VideoCapturerInfo();
        info.width =
                videoConstraintsMandatory != null && videoConstraintsMandatory.hasKey("minWidth")
                        ? videoConstraintsMandatory.getInt("minWidth")
                        : DEFAULT_WIDTH;
        info.height =
                videoConstraintsMandatory != null && videoConstraintsMandatory.hasKey("minHeight")
                        ? videoConstraintsMandatory.getInt("minHeight")
                        : DEFAULT_HEIGHT;
        info.fps =
                videoConstraintsMandatory != null && videoConstraintsMandatory.hasKey("minFrameRate")
                        ? videoConstraintsMandatory.getInt("minFrameRate")
                        : DEFAULT_FPS;
        info.capturer = videoCapturer;
        videoCapturer.startCapture(info.width, info.height, info.fps);

        String trackId = stateProvider.getNextTrackUUID();
        mVideoCapturers.put(trackId, info);

        Log.d(TAG, "changeCaptureFormat: " + info.width + "x" + info.height + "@" + info.fps);
        videoSource.adaptOutputFormat(info.width, info.height, info.fps);

        return pcFactory.createVideoTrack(trackId, videoSource);
    }

    void removeVideoCapturer(String id) {
        VideoCapturerInfo info = mVideoCapturers.get(id);
        if (info != null) {
            try {
                info.capturer.stopCapture();
            } catch (InterruptedException e) {
                Log.e(TAG, "removeVideoCapturer() Failed to stop video capturer");
            } finally {
                info.capturer.dispose();
                mVideoCapturers.remove(id);
            }
        }
    }

    @RequiresApi(api = VERSION_CODES.M)
    private void requestPermissions(
            @NonNull final ArrayList<String> permissions,
            @NonNull final Consumer<List<String>> successCallback,
            @NonNull final Consumer<List<String>> errorCallback) {
        PermissionUtils.Callback callback =
                (permissions_, grantResults) -> {
                    List<String> grantedPermissions = new ArrayList<>();
                    List<String> deniedPermissions = new ArrayList<>();

                    for (int i = 0; i < permissions_.length; ++i) {
                        String permission = permissions_[i];
                        int grantResult = grantResults[i];

                        if (grantResult == PackageManager.PERMISSION_GRANTED) {
                            grantedPermissions.add(permission);
                        } else {
                            deniedPermissions.add(permission);
                        }
                    }

                    // Success means that all requested permissions were granted.
                    for (String p : permissions) {
                        if (!grantedPermissions.contains(p)) {
                            // According to step 6 of the getUserMedia() algorithm
                            // "if the result is denied, jump to the step Permission
                            // Failure."
                            errorCallback.accept(deniedPermissions);
                            return;
                        }
                    }
                    successCallback.accept(grantedPermissions);
                };

        final Activity activity = stateProvider.getActivity();
        final Context context = stateProvider.getApplicationContext();
        PermissionUtils.requestPermissions(
                context,
                activity,
                permissions.toArray(new String[0]), callback);
    }

    void switchCamera(String id, @NonNull Result result) {
        VideoCapturer videoCapturer = mVideoCapturers.get(id).capturer;
        if (videoCapturer == null) {
            resultError("switchCamera", "Video capturer not found for id: " + id, result);
            return;
        }

        CameraEnumerator cameraEnumerator;

        if (Camera2Enumerator.isSupported(applicationContext)) {
            Log.d(TAG, "Creating video capturer using Camera2 API.");
            cameraEnumerator = new Camera2Enumerator(applicationContext);
        } else {
            Log.d(TAG, "Creating video capturer using Camera1 API.");
            cameraEnumerator = new Camera1Enumerator(false);
        }
        // if sourceId given, use specified sourceId first
        final String[] deviceNames = cameraEnumerator.getDeviceNames();
        for (String name : deviceNames) {
            if (cameraEnumerator.isFrontFacing(name) == !isFacing) {
                CameraVideoCapturer cameraVideoCapturer = (CameraVideoCapturer) videoCapturer;
                cameraVideoCapturer.switchCamera(
                        new CameraVideoCapturer.CameraSwitchHandler() {
                            @Override
                            public void onCameraSwitchDone(boolean b) {
                                isFacing = !isFacing;
                                result.success(b);
                            }

                            @Override
                            public void onCameraSwitchError(String s) {
                                resultError("switchCamera", "Switching camera failed: " + id, result);
                            }
                        }, name);
                return;
            }
        }
        resultError("switchCamera", "Switching camera failed: " + id, result);
    }

    void hasTorch(String trackId, @NonNull Result result) {
        VideoCapturerInfo info = mVideoCapturers.get(trackId);
        if (info == null) {
            resultError("hasTorch", "Video capturer not found for id: " + trackId, result);
            return;
        }

        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP && info.capturer instanceof Camera2Capturer) {
            CameraManager manager;
            CameraDevice cameraDevice;

            try {
                Object session =
                        getPrivateProperty(
                                Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
                manager =
                        (CameraManager)
                                getPrivateProperty(Camera2Capturer.class, info.capturer, "cameraManager");
                cameraDevice =
                        (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
            } catch (NoSuchFieldWithNameException e) {
                // Most likely the upstream Camera2Capturer class have changed
                resultError("hasTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
                return;
            }

            boolean flashIsAvailable;
            try {
                CameraCharacteristics characteristics =
                        manager.getCameraCharacteristics(cameraDevice.getId());
                flashIsAvailable = characteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE);
            } catch (CameraAccessException e) {
                // Should never happen since we are already accessing the camera
                throw new RuntimeException(e);
            }

            result.success(flashIsAvailable);
            return;
        }

        if (info.capturer instanceof Camera1Capturer) {
            Camera camera;

            try {
                Object session =
                        getPrivateProperty(
                                Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
                camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
            } catch (NoSuchFieldWithNameException e) {
                // Most likely the upstream Camera1Capturer class have changed
                resultError("hasTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
                return;
            }

            Parameters params = camera.getParameters();
            List<String> supportedModes = params.getSupportedFlashModes();

            result.success(
                    (supportedModes != null) && supportedModes.contains(Parameters.FLASH_MODE_TORCH));
            return;
        }

        resultError("hasTorch", "[TORCH] Video capturer not compatible", result);
    }

    @RequiresApi(api = VERSION_CODES.LOLLIPOP)
    void setTorch(String trackId, boolean torch, @NonNull Result result) {
        VideoCapturerInfo info = mVideoCapturers.get(trackId);
        if (info == null) {
            resultError("setTorch", "Video capturer not found for id: " + trackId, result);
            return;
        }

        if (info.capturer instanceof Camera2Capturer) {
            CameraCaptureSession captureSession;
            CameraDevice cameraDevice;
            CaptureFormat captureFormat;
            int fpsUnitFactor;
            Surface surface;
            Handler cameraThreadHandler;

            try {
                Object session =
                        getPrivateProperty(
                                Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
                captureSession =
                        (CameraCaptureSession)
                                getPrivateProperty(session.getClass(), session, "captureSession");
                cameraDevice =
                        (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
                captureFormat =
                        (CaptureFormat) getPrivateProperty(session.getClass(), session, "captureFormat");
                fpsUnitFactor = (int) getPrivateProperty(session.getClass(), session, "fpsUnitFactor");
                surface = (Surface) getPrivateProperty(session.getClass(), session, "surface");
                cameraThreadHandler =
                        (Handler) getPrivateProperty(session.getClass(), session, "cameraThreadHandler");
            } catch (NoSuchFieldWithNameException e) {
                // Most likely the upstream Camera2Capturer class have changed
                resultError("setTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
                return;
            }

            try {
                final CaptureRequest.Builder captureRequestBuilder =
                        cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
                captureRequestBuilder.set(
                        CaptureRequest.FLASH_MODE,
                        torch ? CaptureRequest.FLASH_MODE_TORCH : CaptureRequest.FLASH_MODE_OFF);
                captureRequestBuilder.set(
                        CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
                        new Range<>(
                                captureFormat.framerate.min / fpsUnitFactor,
                                captureFormat.framerate.max / fpsUnitFactor));
                captureRequestBuilder.set(
                        CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
                captureRequestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
                captureRequestBuilder.addTarget(surface);
                captureSession.setRepeatingRequest(
                        captureRequestBuilder.build(), null, cameraThreadHandler);
            } catch (CameraAccessException e) {
                // Should never happen since we are already accessing the camera
                throw new RuntimeException(e);
            }

            result.success(null);
            return;
        }

        if (info.capturer instanceof Camera1Capturer) {
            Camera camera;
            try {
                Object session =
                        getPrivateProperty(
                                Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
                camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
            } catch (NoSuchFieldWithNameException e) {
                // Most likely the upstream Camera1Capturer class have changed
                resultError("setTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
                return;
            }

            Camera.Parameters params = camera.getParameters();
            params.setFlashMode(
                    torch ? Camera.Parameters.FLASH_MODE_TORCH : Camera.Parameters.FLASH_MODE_OFF);
            camera.setParameters(params);

            result.success(null);
            return;
        }
        resultError("setTorch", "[TORCH] Video capturer not compatible", result);
    }

    @Nullable
    private Object getPrivateProperty(@NonNull Class<?> klass, Object object, @NonNull String fieldName)
            throws NoSuchFieldWithNameException {
        try {
            Field field = klass.getDeclaredField(fieldName);
            field.setAccessible(true);
            return field.get(object);
        } catch (NoSuchFieldException e) {
            throw new NoSuchFieldWithNameException(klass.getName(), fieldName, e);
        } catch (IllegalAccessException e) {
            // Should never happen since we are calling `setAccessible(true)`
            throw new RuntimeException(e);
        }
    }

    private static class NoSuchFieldWithNameException extends NoSuchFieldException {

        final String className;
        final String fieldName;

        NoSuchFieldWithNameException(String className, String fieldName, @NonNull NoSuchFieldException e) {
            super(e.getMessage());
            this.className = className;
            this.fieldName = fieldName;
        }
    }

    public void reStartCamera(@NonNull IsCameraEnabled getCameraId) {
        for (Map.Entry<String, VideoCapturerInfo> item : mVideoCapturers.entrySet()) {
            if (!item.getValue().isScreenCapture && getCameraId.isEnabled(item.getKey())) {
                item.getValue().capturer.startCapture(
                        item.getValue().width,
                        item.getValue().height,
                        item.getValue().fps
                );
            }
        }
    }

    @FunctionalInterface
    public interface IsCameraEnabled {
        boolean isEnabled(String id);
    }

    public class VideoCapturerInfo {
        @Nullable
        VideoCapturer capturer;
        int width;
        int height;
        int fps;
        boolean isScreenCapture;
    }
}
