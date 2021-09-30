package com.cloudwebrtc.webrtc.utils;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentTransaction;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.ResultReceiver;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import java.util.ArrayList;

/** Helper module for dealing with dynamic permissions, introduced in Android M (API level 23). */
public class PermissionUtils {
  /**
   * Constants for internal fields in the <tt>Bundle</tt> exchanged between the activity requesting
   * the permissions and the auxiliary activity we spawn for this purpose.
   */
  private static final String GRANT_RESULTS = "GRANT_RESULT";

  private static final String PERMISSIONS = "PERMISSION";
  private static final String REQUEST_CODE = "REQUEST_CODE";
  private static final String RESULT_RECEIVER = "RESULT_RECEIVER";

  /** Incrementing counter for permission requests. Each request must have a unique numeric code. */
  private static int requestCode;

  private static void requestPermissions(
          Context context, Activity activity, String[] permissions, ResultReceiver resultReceiver) {
    // Ask the Context whether we have already been granted the requested
    // permissions.
    int size = permissions.length;
    int[] grantResults = new int[size];
    boolean permissionsGranted = true;

    for (int i = 0; i < size; ++i) {
      int grantResult;
      // No need to ask for permission on pre-Marshmallow
      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M)
        grantResult = PackageManager.PERMISSION_GRANTED;
      else if (activity != null){
        grantResult = activity.checkSelfPermission(permissions[i]);
      } else {
        grantResult = ActivityCompat.checkSelfPermission(context, permissions[i]);
      }

      grantResults[i] = grantResult;
      if (grantResult != PackageManager.PERMISSION_GRANTED) {
        permissionsGranted = false;
      }
    }

    // Obviously, if the requested permissions have already been granted,
    // there is nothing to ask the user about. On the other hand, if there
    // is no Activity or the runtime permissions are not supported, there is
    // no way to ask the user to grant us the denied permissions.
    int requestCode = ++PermissionUtils.requestCode;

    if (permissionsGranted
        // Here we test for the target SDK version with which *the app*
        // was compiled. If we use Build.VERSION.SDK_INT that would give
        // us the API version of the device itself, not the version the
        // app was compiled for. When compiled for API level < 23 we
        // must still use old permissions model, regardless of the
        // Android version on the device.
        || Build.VERSION.SDK_INT < Build.VERSION_CODES.M
        || context.getApplicationInfo().targetSdkVersion < Build.VERSION_CODES.M) {
      send(resultReceiver, requestCode, permissions, grantResults);
      return;
    }

    Bundle args = new Bundle();
    args.putInt(REQUEST_CODE, requestCode);
    args.putParcelable(RESULT_RECEIVER, resultReceiver);
    args.putStringArray(PERMISSIONS, permissions);

    RequestPermissionsFragment fragment = new RequestPermissionsFragment();
    fragment.setArguments(args);

    if(activity != null){
      FragmentTransaction transaction =
              activity
                      .getFragmentManager()
                      .beginTransaction()
                      .add(fragment, fragment.getClass().getName() + "-" + requestCode);

      try {
        transaction.commit();
      } catch (IllegalStateException ise) {
        // Context is a Plugin, just send result back.
        send(resultReceiver, requestCode, permissions, grantResults);
      }
    }
  }

  public static void requestPermissions(
          final Context context,
          final Activity activity,
          final String[] permissions,
          final Callback callback) {
    requestPermissions(
        context,
        activity,
        permissions,
        new ResultReceiver(new Handler(Looper.getMainLooper())) {
          @Override
          protected void onReceiveResult(int resultCode, Bundle resultData) {
            callback.invoke(
                resultData.getStringArray(PERMISSIONS), resultData.getIntArray(GRANT_RESULTS));
          }
        });
  }

  private static void send(
      ResultReceiver resultReceiver, int requestCode, String[] permissions, int[] grantResults) {
    Bundle resultData = new Bundle();
    resultData.putStringArray(PERMISSIONS, permissions);
    resultData.putIntArray(GRANT_RESULTS, grantResults);

    resultReceiver.send(requestCode, resultData);
  }

  public interface Callback {
    void invoke(String[] permissions, int[] grantResults);
  }

  /**
   * Helper activity for requesting permissions. Android only allows requesting permissions from an
   * activity and the result is reported in the <tt>onRequestPermissionsResult</tt> method. Since
   * this package is a library we create an auxiliary activity and communicate back the results
   * using a <tt>ResultReceiver</tt>.
   */
  @RequiresApi(api = VERSION_CODES.M)
  public static class RequestPermissionsFragment extends Fragment {
    private void checkSelfPermissions(boolean requestPermissions) {
      // Figure out which of the requested permissions are actually denied
      // because we do not want to ask about the granted permissions
      // (which Android supports).
      Bundle args = getArguments();
      String[] permissions = args.getStringArray(PERMISSIONS);
      int size = permissions.length;
      Activity activity = getActivity();
      int[] grantResults = new int[size];
      ArrayList<String> deniedPermissions = new ArrayList<>();

      for (int i = 0; i < size; ++i) {
        String permission = permissions[i];
        int grantResult;
        // No need to ask for permission on pre-Marshmallow
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M)
          grantResult = PackageManager.PERMISSION_GRANTED;
        else grantResult = activity.checkSelfPermission(permission);

        grantResults[i] = grantResult;
        if (grantResult != PackageManager.PERMISSION_GRANTED) {
          deniedPermissions.add(permission);
        }
      }

      int requestCode = args.getInt(REQUEST_CODE, 0);

      if (deniedPermissions.isEmpty() || !requestPermissions) {
        // All permissions have already been granted or we cannot ask
        // the user about the denied ones.
        finish();
        send(args.getParcelable(RESULT_RECEIVER), requestCode, permissions, grantResults);
      } else {
        // Ask the user about the denied permissions.
        requestPermissions(
            deniedPermissions.toArray(new String[deniedPermissions.size()]), requestCode);
      }
    }

    private void finish() {
      Activity activity = getActivity();

      if (activity != null) {
        activity.getFragmentManager().beginTransaction().remove(this).commitAllowingStateLoss();
      }
    }

    @Override
    public void onRequestPermissionsResult(
        int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
      Bundle args = getArguments();

      if (args.getInt(REQUEST_CODE, 0) != requestCode) {
        return;
      }

      // XXX The super's documentation says: It is possible that the
      // permissions request interaction with the user is interrupted. In
      // this case you will receive empty permissions and results arrays
      // which should be treated as a cancellation.
      if (permissions.length == 0 || grantResults.length == 0) {
        // The getUserMedia algorithm does not define a way to cancel
        // the invocation so we have to redo the permission request.
        finish();
        PermissionUtils.requestPermissions(
                getContext(),
                getActivity(),
                args.getStringArray(PERMISSIONS),
                (ResultReceiver) args.getParcelable(RESULT_RECEIVER));
      } else {
        // We did not ask for all requested permissions, just the denied
        // ones. But when we send the result, we have to answer about
        // all requested permissions.
        checkSelfPermissions(/* requestPermissions */ false);
      }
    }

    @Override
    public void onResume() {
      super.onResume();

      checkSelfPermissions(/* requestPermissions */ true);
    }
  }
}
