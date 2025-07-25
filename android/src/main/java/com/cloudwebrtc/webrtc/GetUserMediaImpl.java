package com.cloudwebrtc.webrtc;

import android.Manifest;
import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Point;
import android.hardware.camera2.CameraManager;
import android.media.AudioDeviceInfo;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.net.Uri;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.ParcelFileDescriptor;
import android.os.ResultReceiver;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Pair;
import android.util.SparseArray;
import android.view.Display;
import android.view.WindowManager;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.cloudwebrtc.webrtc.audio.AudioSwitchManager;
import com.cloudwebrtc.webrtc.audio.AudioUtils;
import com.cloudwebrtc.webrtc.audio.LocalAudioTrack;
import com.cloudwebrtc.webrtc.record.AudioChannel;
import com.cloudwebrtc.webrtc.record.AudioSamplesInterceptor;
import com.cloudwebrtc.webrtc.record.MediaRecorderImpl;
import com.cloudwebrtc.webrtc.record.OutputAudioSamplesInterceptor;
import com.cloudwebrtc.webrtc.utils.Callback;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;
import com.cloudwebrtc.webrtc.utils.MediaConstraintsUtils;
import com.cloudwebrtc.webrtc.utils.ObjectType;
import com.cloudwebrtc.webrtc.utils.PermissionUtils;
import com.cloudwebrtc.webrtc.video.LocalVideoTrack;
import com.cloudwebrtc.webrtc.video.VideoCapturerInfo;

import org.webrtc.AudioSource;
import org.webrtc.AudioTrack;
import org.webrtc.Camera1Capturer;
import org.webrtc.Camera1Enumerator;
import org.webrtc.Camera1Helper;
import org.webrtc.Camera2Capturer;
import org.webrtc.Camera2Enumerator;
import org.webrtc.Camera2Helper;
import org.webrtc.CameraEnumerator;
import org.webrtc.CameraVideoCapturer;
import org.webrtc.MediaConstraints;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.Size;
import org.webrtc.SurfaceTextureHelper;
import org.webrtc.VideoCapturer;
import org.webrtc.VideoSource;
import org.webrtc.VideoTrack;
import org.webrtc.audio.JavaAudioDeviceModule;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;

/**
 * The implementation of {@code getUserMedia} extracted into a separate file in order to reduce
 * complexity and to (somewhat) separate concerns.
 */
public class GetUserMediaImpl {
    private static final int DEFAULT_WIDTH = 1280;
    private static final int DEFAULT_HEIGHT = 720;
    private static final int DEFAULT_FPS = 30;

    private static final String PERMISSION_AUDIO = Manifest.permission.RECORD_AUDIO;
    private static final String PERMISSION_VIDEO = Manifest.permission.CAMERA;
    private static final String PERMISSION_SCREEN = "android.permission.MediaProjection";
    private static final int CAPTURE_PERMISSION_REQUEST_CODE = 1;
    private static final String GRANT_RESULTS = "GRANT_RESULT";
    private static final String PERMISSIONS = "PERMISSION";
    private static final String PROJECTION_DATA = "PROJECTION_DATA";
    private static final String RESULT_RECEIVER = "RESULT_RECEIVER";
    private static final String REQUEST_CODE = "REQUEST_CODE";

    static final String TAG = FlutterWebRTCPlugin.TAG;

    private final Map<String, VideoCapturerInfoEx> mVideoCapturers = new HashMap<>();
    private final Map<String, SurfaceTextureHelper> mSurfaceTextureHelpers = new HashMap<>();
    private final StateProvider stateProvider;
    private final Context applicationContext;

    static final int minAPILevel = Build.VERSION_CODES.LOLLIPOP;

    final AudioSamplesInterceptor inputSamplesInterceptor = new AudioSamplesInterceptor();
    private OutputAudioSamplesInterceptor outputSamplesInterceptor = null;
    JavaAudioDeviceModule audioDeviceModule;
    private final SparseArray<MediaRecorderImpl> mediaRecorders = new SparseArray<>();
    private AudioDeviceInfo preferredInput = null;
    private boolean isTorchOn;
    private Intent mediaProjectionData = null;


    public void screenRequestPermissions(ResultReceiver resultReceiver) {
        mediaProjectionData = null;
        final Activity activity = stateProvider.getActivity();
        if (activity == null) {
            // Activity went away, nothing we can do.
            return;
        }

        Bundle args = new Bundle();
        args.putParcelable(RESULT_RECEIVER, resultReceiver);
        args.putInt(REQUEST_CODE, CAPTURE_PERMISSION_REQUEST_CODE);

        ScreenRequestPermissionsFragment fragment = new ScreenRequestPermissionsFragment();
        fragment.setArguments(args);

        FragmentTransaction transaction =
                activity
                        .getFragmentManager()
                        .beginTransaction()
                        .add(fragment, fragment.getClass().getName());

        try {
            transaction.commit();
        } catch (IllegalStateException ise) {

        }
    }

    public void requestCapturePermission(final Result result) {
        screenRequestPermissions(
                new ResultReceiver(new Handler(Looper.getMainLooper())) {
                    @Override
                    protected void onReceiveResult(int requestCode, Bundle resultData) {
                        int resultCode = resultData.getInt(GRANT_RESULTS);
                        if (resultCode == Activity.RESULT_OK) {
                            mediaProjectionData = resultData.getParcelable(PROJECTION_DATA);
                            result.success(true);
                        } else {
                            result.success(false);
                        }
                    }
                });
    }

    public static class ScreenRequestPermissionsFragment extends Fragment {

        private ResultReceiver resultReceiver = null;
        private int requestCode = 0;
        private final int resultCode = 0;

        private void checkSelfPermissions(boolean requestPermissions) {
            if (resultCode != Activity.RESULT_OK) {
                Activity activity = this.getActivity();
                Bundle args = getArguments();
                resultReceiver = args.getParcelable(RESULT_RECEIVER);
                requestCode = args.getInt(REQUEST_CODE);
                requestStart(activity, requestCode);
            }
        }

        public void requestStart(Activity activity, int requestCode) {
            if (android.os.Build.VERSION.SDK_INT < minAPILevel) {
                Log.w(
                        TAG,
                        "Can't run requestStart() due to a low API level. API level 21 or higher is required.");
                return;
            } else {
                MediaProjectionManager mediaProjectionManager =
                        (MediaProjectionManager) activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE);

                // call for the projection manager
                this.startActivityForResult(
                        mediaProjectionManager.createScreenCaptureIntent(), requestCode);
            }
        }

        @Override
        public void onActivityResult(int requestCode, int resultCode, Intent data) {
            super.onActivityResult(requestCode, resultCode, data);
            resultCode = resultCode;
            String[] permissions;
            if (resultCode != Activity.RESULT_OK) {
                finish();
                Bundle resultData = new Bundle();
                resultData.putString(PERMISSIONS, PERMISSION_SCREEN);
                resultData.putInt(GRANT_RESULTS, resultCode);
                resultReceiver.send(requestCode, resultData);
                return;
            }
            Bundle resultData = new Bundle();
            resultData.putString(PERMISSIONS, PERMISSION_SCREEN);
            resultData.putInt(GRANT_RESULTS, resultCode);
            resultData.putParcelable(PROJECTION_DATA, data);
            resultReceiver.send(requestCode, resultData);
            finish();
        }

        private void finish() {
            Activity activity = getActivity();
            if (activity != null) {
                activity.getFragmentManager().beginTransaction().remove(this).commitAllowingStateLoss();
            }
        }

        @Override
        public void onResume() {
            super.onResume();
            checkSelfPermissions(/* requestPermissions */ true);
        }
    }

    GetUserMediaImpl(StateProvider stateProvider, Context applicationContext) {
        this.stateProvider = stateProvider;
        this.applicationContext = applicationContext;
    }

    static private void resultError(String method, String error, Result result) {
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
    private void addDefaultAudioConstraints(MediaConstraints audioConstraints) {
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
     * @return Pair of deviceName to VideoCapturer. Can invoke with <tt>startCapture</tt>/<tt>stopCapture</tt> <tt>null</tt>
     * if not matched camera with specified facing mode.
     */
    private Pair<String, VideoCapturer> createVideoCapturer(
            CameraEnumerator enumerator, boolean isFacing, String sourceId, CameraEventsHandler cameraEventsHandler) {
        VideoCapturer videoCapturer;
        // if sourceId given, use specified sourceId first
        final String[] deviceNames = enumerator.getDeviceNames();
        if (sourceId != null && !sourceId.equals("")) {
            for (String name : deviceNames) {
                if (name.equals(sourceId)) {
                    videoCapturer = enumerator.createCapturer(name, cameraEventsHandler);
                    if (videoCapturer != null) {
                        Log.d(TAG, "create user specified camera " + name + " succeeded");
                        return new Pair<>(name, videoCapturer);
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
                videoCapturer = enumerator.createCapturer(name, cameraEventsHandler);
                if (videoCapturer != null) {
                    Log.d(TAG, "Create " + facingStr + " camera " + name + " succeeded");

                    return new Pair<>(name, videoCapturer);
                } else {
                    Log.e(TAG, "Create " + facingStr + " camera " + name + " failed");
                }
            }
        }

        // falling back to the first available camera
        if (deviceNames.length > 0) {
            videoCapturer = enumerator.createCapturer(deviceNames[0], cameraEventsHandler);
            Log.d(TAG, "Falling back to the first available camera");
            return new Pair<>(deviceNames[0], videoCapturer);
        }

        return null;
    }

    /**
     * Retrieves "facingMode" constraint value.
     *
     * @param mediaConstraints a <tt>ConstraintsMap</tt> which represents "GUM" constraints argument.
     * @return String value of "facingMode" constraints in "GUM" or <tt>null</tt> if not specified.
     */
    private String getFacingMode(ConstraintsMap mediaConstraints) {
        return mediaConstraints == null ? null : mediaConstraints.getString("facingMode");
    }

    /**
     * Retrieves "sourceId" constraint value.
     *
     * @param mediaConstraints a <tt>ConstraintsMap</tt> which represents "GUM" constraints argument
     * @return String value of "sourceId" optional "GUM" constraint or <tt>null</tt> if not specified.
     */
    private String getSourceIdConstraint(ConstraintsMap mediaConstraints) {
        if (mediaConstraints != null
                && mediaConstraints.hasKey("deviceId")) {
            return mediaConstraints.getString("deviceId");
        }
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

    private ConstraintsMap getUserAudio(ConstraintsMap constraints, MediaStream stream) {
        AudioSwitchManager.instance.start();
        MediaConstraints audioConstraints = new MediaConstraints();
        String deviceId = null;
        if (constraints.getType("audio") == ObjectType.Boolean) {
            addDefaultAudioConstraints(audioConstraints);
        } else {
            audioConstraints = MediaConstraintsUtils.parseMediaConstraints(constraints.getMap("audio"));
            deviceId = getSourceIdConstraint(constraints.getMap("audio"));
        }

        Log.i(TAG, "getUserMedia(audio): " + audioConstraints);

        String trackId = stateProvider.getNextTrackUUID();
        PeerConnectionFactory pcFactory = stateProvider.getPeerConnectionFactory();
        AudioSource audioSource = pcFactory.createAudioSource(audioConstraints);
        AudioTrack track = pcFactory.createAudioTrack(trackId, audioSource);
        stream.addTrack(track);

        stateProvider.putLocalTrack(track.id(), new LocalAudioTrack(track));

        ConstraintsMap trackParams = new ConstraintsMap();
        trackParams.putBoolean("enabled", track.enabled());
        trackParams.putString("id", track.id());
        trackParams.putString("kind", "audio");
        trackParams.putString("label", track.id());
        trackParams.putString("readyState", track.state().toString());
        trackParams.putBoolean("remote", false);

        if (deviceId == null) {
            if (VERSION.SDK_INT >= VERSION_CODES.M) {
                deviceId = "" + getPreferredInputDevice(preferredInput);
            }
        }

        ConstraintsMap settings = new ConstraintsMap();
        settings.putString("deviceId", deviceId);
        settings.putString("kind", "audioinput");
        settings.putBoolean("autoGainControl", true);
        settings.putBoolean("echoCancellation", true);
        settings.putBoolean("noiseSuppression", true);
        settings.putInt("channelCount", 1);
        settings.putInt("latency", 0);
        trackParams.putMap("settings", settings.toMap());

        return trackParams;
    }

    /**
     * Implements {@code getUserMedia} without knowledge whether the necessary permissions have
     * already been granted. If the necessary permissions have not been granted yet, they will be
     * requested.
     */
    void getUserMedia(
            final ConstraintsMap constraints, final Result result, final MediaStream mediaStream) {

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
                /* successCallback */ new Callback() {
                    @Override
                    public void invoke(Object... args) {
                        List<String> grantedPermissions = (List<String>) args[0];

                        getUserMedia(constraints, result, mediaStream, grantedPermissions);
                    }
                },
                /* errorCallback */ new Callback() {
                    @Override
                    public void invoke(Object... args) {
                        // According to step 10 Permission Failure of the
                        // getUserMedia() algorithm, if the user has denied
                        // permission, fail "with a new DOMException object whose
                        // name attribute has the value NotAllowedError."
                        resultError("getUserMedia", "DOMException, NotAllowedError", result);
                    }
                });
    }

    void getDisplayMedia(
            final ConstraintsMap constraints, final Result result, final MediaStream mediaStream) {
        if (mediaProjectionData == null) {
            screenRequestPermissions(
                    new ResultReceiver(new Handler(Looper.getMainLooper())) {
                        @Override
                        protected void onReceiveResult(int requestCode, Bundle resultData) {
                            Intent mediaProjectionData = resultData.getParcelable(PROJECTION_DATA);
                            int resultCode = resultData.getInt(GRANT_RESULTS);

                            if (resultCode != Activity.RESULT_OK) {
                                resultError("screenRequestPermissions", "User didn't give permission to capture the screen.", result);
                                return;
                            }
                            getDisplayMedia(result, mediaStream, mediaProjectionData);
                        }
                    });
        } else {
            getDisplayMedia(result, mediaStream, mediaProjectionData);
        }
    }

    private void getDisplayMedia(final Result result, final MediaStream mediaStream, final Intent mediaProjectionData) {
        /* Create ScreenCapture */
        VideoTrack displayTrack = null;
        VideoCapturer videoCapturer = null;
        videoCapturer =
                new OrientationAwareScreenCapturer(
                        mediaProjectionData,
                        new MediaProjection.Callback() {
                            @Override
                            public void onStop() {
                                super.onStop();
                                // After Huawei P30 and Android 10 version test, the onstop method is called, which will not affect the next process,
                                // and there is no need to call the resulterror method
                                //resultError("MediaProjection.Callback()", "User revoked permission to capture the screen.", result);
                            }
                        });
        if (videoCapturer == null) {
            resultError("screenRequestPermissions", "GetDisplayMediaFailed, User revoked permission to capture the screen.", result);
            return;
        }

        PeerConnectionFactory pcFactory = stateProvider.getPeerConnectionFactory();
        VideoSource videoSource = pcFactory.createVideoSource(true);

        String threadName = Thread.currentThread().getName() + "_texture_screen_thread";
        SurfaceTextureHelper surfaceTextureHelper =
                SurfaceTextureHelper.create(threadName, EglUtils.getRootEglBaseContext());
        videoCapturer.initialize(
                surfaceTextureHelper, applicationContext, videoSource.getCapturerObserver());

        WindowManager wm =
                (WindowManager) applicationContext.getSystemService(Context.WINDOW_SERVICE);

        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getRealSize(size);

        VideoCapturerInfoEx info = new VideoCapturerInfoEx();
        info.width = size.x;
        info.height = size.y;
        info.fps = DEFAULT_FPS;
        info.isScreenCapture = true;
        info.capturer = videoCapturer;

        videoCapturer.startCapture(info.width, info.height, info.fps);
        Log.d(TAG, "OrientationAwareScreenCapturer.startCapture: " + info.width + "x" + info.height + "@" + info.fps);

        String trackId = stateProvider.getNextTrackUUID();
        mVideoCapturers.put(trackId, info);

        displayTrack = pcFactory.createVideoTrack(trackId, videoSource);

        ConstraintsArray audioTracks = new ConstraintsArray();
        ConstraintsArray videoTracks = new ConstraintsArray();
        ConstraintsMap successResult = new ConstraintsMap();

        if (displayTrack  != null) {
            String id = displayTrack.id();

            LocalVideoTrack displayLocalVideoTrack = new LocalVideoTrack(displayTrack);
            videoSource.setVideoProcessor(displayLocalVideoTrack);

            stateProvider.putLocalTrack(id, displayLocalVideoTrack);

            ConstraintsMap track_ = new ConstraintsMap();
            String kind = displayTrack.kind();

            track_.putBoolean("enabled", displayTrack.enabled());
            track_.putString("id", id);
            track_.putString("kind", kind);
            track_.putString("label", kind);
            track_.putString("readyState", displayTrack.state().toString());
            track_.putBoolean("remote", false);

            videoTracks.pushMap(track_);
            mediaStream.addTrack(displayTrack);
        }

        String streamId = mediaStream.getId();

        Log.d(TAG, "MediaStream id: " + streamId);
        stateProvider.putLocalStream(streamId, mediaStream);
        successResult.putString("streamId", streamId);
        successResult.putArray("audioTracks", audioTracks.toArrayList());
        successResult.putArray("videoTracks", videoTracks.toArrayList());
        result.success(successResult.toMap());
    }

    /**
     * Implements {@code getUserMedia} with the knowledge that the necessary permissions have already
     * been granted. If the necessary permissions have not been granted yet, they will NOT be
     * requested.
     */
    private void getUserMedia(
            ConstraintsMap constraints,
            Result result,
            MediaStream mediaStream,
            List<String> grantedPermissions) {
        ConstraintsMap[] trackParams = new ConstraintsMap[2];

        // If we fail to create either, destroy the other one and fail.
        if ((grantedPermissions.contains(PERMISSION_AUDIO)
                && (trackParams[0] = getUserAudio(constraints, mediaStream)) == null)
                || (grantedPermissions.contains(PERMISSION_VIDEO)
                && (trackParams[1] = getUserVideo(constraints, mediaStream)) == null)) {
            for (MediaStreamTrack track : mediaStream.audioTracks) {
                if (track != null) {
                    track.dispose();
                }
            }
            for (MediaStreamTrack track : mediaStream.videoTracks) {
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

        for (ConstraintsMap trackParam : trackParams) {
            if (trackParam == null) {
                continue;
            }
            if (trackParam.getString("kind").equals("audio")) {
                audioTracks.pushMap(trackParam);
            } else {
                videoTracks.pushMap(trackParam);
            }
        }

        String streamId = mediaStream.getId();
        Log.d(TAG, "MediaStream id: " + streamId);
        stateProvider.putLocalStream(streamId, mediaStream);

        successResult.putString("streamId", streamId);
        successResult.putArray("audioTracks", audioTracks.toArrayList());
        successResult.putArray("videoTracks", videoTracks.toArrayList());
        result.success(successResult.toMap());
    }

    private boolean isFacing = true;

    /**
     * @return Returns the integer at the key, or the `ideal` property if it is a map.
     */
    @Nullable
    private Integer getConstrainInt(@Nullable ConstraintsMap constraintsMap, String key) {
        if (constraintsMap == null) {
            return null;
        }

        if (constraintsMap.getType(key) == ObjectType.Number) {
            try {
                return constraintsMap.getInt(key);
            } catch (Exception e) {
                // Could be a double instead
                return (int) Math.round(constraintsMap.getDouble(key));
            }
        }

        if (constraintsMap.getType(key) == ObjectType.String) {
            try {
                return Integer.parseInt(constraintsMap.getString(key));
            } catch (Exception e) {
                // Could be a double instead
                return (int) Math.round(Double.parseDouble(constraintsMap.getString(key)));
            }
        }

        if (constraintsMap.getType(key) == ObjectType.Map) {
            ConstraintsMap innerMap = constraintsMap.getMap(key);
            if (constraintsMap.getType("ideal") == ObjectType.Number) {
                return innerMap.getInt("ideal");
            }
        }

        return null;
    }

    private ConstraintsMap getUserVideo(ConstraintsMap constraints, MediaStream mediaStream) {
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
        isFacing = facingMode == null || !facingMode.equals("environment");
        String deviceId = getSourceIdConstraint(videoConstraintsMap);
        CameraEventsHandler cameraEventsHandler = new CameraEventsHandler();
        Pair<String, VideoCapturer> result = createVideoCapturer(cameraEnumerator, isFacing, deviceId, cameraEventsHandler);

        if (result == null) {
            return null;
        }

        deviceId = result.first;
        VideoCapturer videoCapturer = result.second;

        if (facingMode == null && cameraEnumerator.isFrontFacing(deviceId)) {
            facingMode = "user";
        } else if (facingMode == null && cameraEnumerator.isBackFacing(deviceId)) {
            facingMode = "environment";
        }
        // else, leave facingMode as it was

        PeerConnectionFactory pcFactory = stateProvider.getPeerConnectionFactory();
        VideoSource videoSource = pcFactory.createVideoSource(false);
        String threadName = Thread.currentThread().getName() + "_texture_camera_thread";
        SurfaceTextureHelper surfaceTextureHelper =
                SurfaceTextureHelper.create(threadName, EglUtils.getRootEglBaseContext());

        if (surfaceTextureHelper == null) {
            Log.e(TAG, "surfaceTextureHelper is null");
            return null;
        }

        videoCapturer.initialize(
                surfaceTextureHelper, applicationContext, videoSource.getCapturerObserver());

        VideoCapturerInfoEx info = new VideoCapturerInfoEx();

        Integer videoWidth = getConstrainInt(videoConstraintsMap, "width");
        int targetWidth = videoWidth != null
                ? videoWidth
                : videoConstraintsMandatory != null && videoConstraintsMandatory.hasKey("minWidth")
                ? videoConstraintsMandatory.getInt("minWidth")
                : DEFAULT_WIDTH;

        Integer videoHeight = getConstrainInt(videoConstraintsMap, "height");
        int targetHeight = videoHeight != null
                ? videoHeight
                : videoConstraintsMandatory != null && videoConstraintsMandatory.hasKey("minHeight")
                ? videoConstraintsMandatory.getInt("minHeight")
                : DEFAULT_HEIGHT;

        Integer videoFrameRate = getConstrainInt(videoConstraintsMap, "frameRate");
        int targetFps = videoFrameRate != null
                ? videoFrameRate
                : videoConstraintsMandatory != null && videoConstraintsMandatory.hasKey("minFrameRate")
                ? videoConstraintsMandatory.getInt("minFrameRate")
                : DEFAULT_FPS;

        info.width = targetWidth;
        info.height = targetHeight;
        info.fps = targetFps;
        info.capturer = videoCapturer;
        info.cameraName = deviceId;

        // Find actual capture format.
        Size actualSize = null;
        if (videoCapturer instanceof Camera1Capturer) {
            int cameraId = Camera1Helper.getCameraId(deviceId);
            actualSize = Camera1Helper.findClosestCaptureFormat(cameraId, targetWidth, targetHeight);
        } else if (videoCapturer instanceof Camera2Capturer) {
            CameraManager cameraManager = (CameraManager) applicationContext.getSystemService(Context.CAMERA_SERVICE);
            actualSize = Camera2Helper.findClosestCaptureFormat(cameraManager, deviceId, targetWidth, targetHeight);
        }

        if (actualSize != null) {
            info.width = actualSize.width;
            info.height = actualSize.height;
        }

        info.cameraEventsHandler = cameraEventsHandler;
        videoCapturer.startCapture(targetWidth, targetHeight, targetFps);

        cameraEventsHandler.waitForCameraOpen();


        String trackId = stateProvider.getNextTrackUUID();
        mVideoCapturers.put(trackId, info);
        mSurfaceTextureHelpers.put(trackId, surfaceTextureHelper);

        Log.d(TAG, "Target: " + targetWidth + "x" + targetHeight + "@" + targetFps + ", Actual: " + info.width + "x" + info.height + "@" + info.fps);

        VideoTrack track = pcFactory.createVideoTrack(trackId, videoSource);
        mediaStream.addTrack(track);

        LocalVideoTrack localVideoTrack = new LocalVideoTrack(track);
        videoSource.setVideoProcessor(localVideoTrack);

        stateProvider.putLocalTrack(track.id(),localVideoTrack);

        ConstraintsMap trackParams = new ConstraintsMap();

        trackParams.putBoolean("enabled", track.enabled());
        trackParams.putString("id", track.id());
        trackParams.putString("kind", "video");
        trackParams.putString("label", track.id());
        trackParams.putString("readyState", track.state().toString());
        trackParams.putBoolean("remote", false);

        ConstraintsMap settings = new ConstraintsMap();
        settings.putString("deviceId", deviceId);
        settings.putString("kind", "videoinput");
        settings.putInt("width", info.width);
        settings.putInt("height", info.height);
        settings.putInt("frameRate", info.fps);
        if (facingMode != null) settings.putString("facingMode", facingMode);
        trackParams.putMap("settings", settings.toMap());

        return trackParams;
    }

    void removeVideoCapturer(String id) {
        VideoCapturerInfoEx info = mVideoCapturers.get(id);
        if (info != null) {
            try {
                info.capturer.stopCapture();
                if (info.cameraEventsHandler != null) {
                    info.cameraEventsHandler.waitForCameraClosed();
                }
            } catch (InterruptedException e) {
                Log.e(TAG, "removeVideoCapturer() Failed to stop video capturer");
            } finally {
                info.capturer.dispose();
                mVideoCapturers.remove(id);
                SurfaceTextureHelper helper = mSurfaceTextureHelpers.get(id);
                if (helper != null) {
                    helper.stopListening();
                    helper.dispose();
                    mSurfaceTextureHelpers.remove(id);
                }
            }
        }
    }

    @RequiresApi(api = VERSION_CODES.M)
    private void requestPermissions(
            final ArrayList<String> permissions,
            final Callback successCallback,
            final Callback errorCallback) {
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
                            errorCallback.invoke(deniedPermissions);
                            return;
                        }
                    }
                    successCallback.invoke(grantedPermissions);
                };

        final Activity activity = stateProvider.getActivity();
        final Context context = stateProvider.getApplicationContext();
        PermissionUtils.requestPermissions(
                context,
                activity,
                permissions.toArray(new String[permissions.size()]), callback);
    }

    void switchCamera(String id, Result result) {
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

    /**
     * Creates and starts recording of local stream to file
     *
     * @param path         to the file for record
     * @param videoTrack   to record or null if only audio needed
     * @param audioChannel channel for recording or null
     * @throws Exception lot of different exceptions, pass back to dart layer to print them at least
     */
    void startRecordingToFile(
            String path, Integer id, @Nullable VideoTrack videoTrack, @Nullable AudioChannel audioChannel)
            throws Exception {
        AudioSamplesInterceptor interceptor = null;
        if (audioChannel == AudioChannel.INPUT) {
            interceptor = inputSamplesInterceptor;
        } else if (audioChannel == AudioChannel.OUTPUT) {
            if (outputSamplesInterceptor == null) {
                outputSamplesInterceptor = new OutputAudioSamplesInterceptor(audioDeviceModule);
            }
            interceptor = outputSamplesInterceptor;
        }
        MediaRecorderImpl mediaRecorder = new MediaRecorderImpl(id, videoTrack, interceptor);
        mediaRecorder.startRecording(new File(path));
        mediaRecorders.append(id, mediaRecorder);
    }

    void stopRecording(Integer id, String albumName,  Runnable onFinished) {
       MediaRecorderImpl mediaRecorder = mediaRecorders.get(id);
       if (mediaRecorder != null) {
            mediaRecorder.stopRecording(() -> {
                mediaRecorders.remove(id);
                onFinished.run();
            });
        }
    }



    public void reStartCamera(IsCameraEnabled getCameraId) {
        for (Map.Entry<String, VideoCapturerInfoEx> item : mVideoCapturers.entrySet()) {
            if (!item.getValue().isScreenCapture && getCameraId.isEnabled(item.getKey())) {
                item.getValue().capturer.startCapture(
                        item.getValue().width,
                        item.getValue().height,
                        item.getValue().fps
                );
            }
        }
    }

    public interface IsCameraEnabled {
        boolean isEnabled(String id);
    }

    public static class VideoCapturerInfoEx extends VideoCapturerInfo  {
        public CameraEventsHandler cameraEventsHandler;
    }

    public VideoCapturerInfoEx getCapturerInfo(String trackId) {
        return mVideoCapturers.get(trackId);
    }

    @RequiresApi(api = VERSION_CODES.M)
    void setPreferredInputDevice(String deviceId) {
        android.media.AudioManager audioManager = ((android.media.AudioManager) applicationContext.getSystemService(Context.AUDIO_SERVICE));
        final AudioDeviceInfo[] devices = audioManager.getDevices(android.media.AudioManager.GET_DEVICES_INPUTS);
        if (devices.length > 0) {
            for (int i = 0; i < devices.length; i++) {
                AudioDeviceInfo device = devices[i];
                if(deviceId.equals(AudioUtils.getAudioDeviceId(device))) {
                    preferredInput = device;
                    audioDeviceModule.setPreferredInputDevice(preferredInput);
                    return;
                }
            }
        }
    }

    @RequiresApi(api = VERSION_CODES.M)
    int getPreferredInputDevice(AudioDeviceInfo deviceInfo) {
        if (deviceInfo == null) {
            return -1;
        }
        android.media.AudioManager audioManager = ((android.media.AudioManager) applicationContext.getSystemService(Context.AUDIO_SERVICE));
        final AudioDeviceInfo[] devices = audioManager.getDevices(android.media.AudioManager.GET_DEVICES_INPUTS);
        for (int i = 0; i < devices.length; i++) {
            if (devices[i].getId() == deviceInfo.getId()) {
                return i;
            }
        }
        return -1;
    }
}
