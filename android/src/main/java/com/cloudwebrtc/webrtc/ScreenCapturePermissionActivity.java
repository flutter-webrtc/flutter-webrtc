package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Intent;
import android.media.projection.MediaProjectionManager;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.content.IntentFilter;
import com.cloudwebrtc.webrtc.Constants;
import java.lang.Exception;
import android.os.ResultReceiver;


public class ScreenCapturePermissionActivity extends Activity {

    private static final int REQUEST_MEDIA_PROJECTION = 1;
    private MediaProjectionManager mediaProjectionManager;
    private ResultReceiver resultReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try {

            getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            );

            getWindow().getDecorView().setSystemUiVisibility(
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                        | WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN);
                        
            // Set activity layout to a transparent background
            getWindow().setBackgroundDrawableResource(android.R.color.transparent);

            // Set window parameters for floating behavior
            WindowManager.LayoutParams params = getWindow().getAttributes();
            params.gravity = Gravity.START | Gravity.TOP;
            params.x = 0;
            params.y = 0;
            params.width = WindowManager.LayoutParams.WRAP_CONTENT;
            params.height = WindowManager.LayoutParams.WRAP_CONTENT;
            getWindow().setAttributes(params);

            // Create a FrameLayout to hold child views
            FrameLayout layout = new FrameLayout(this);
            layout.setLayoutParams(new FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT));
            setContentView(layout);

            resultReceiver = getIntent().getParcelableExtra("resultReceiver");

            if(resultReceiver!=null) {
                mediaProjectionManager = (MediaProjectionManager) getSystemService(MEDIA_PROJECTION_SERVICE);
                requestScreenCapturePermission();
            } else{
                safeFinish();
            }
        }catch (Exception expection){

        }
    }

    private void requestScreenCapturePermission() {
       try{
           startActivityForResult(mediaProjectionManager.createScreenCaptureIntent(),
                   REQUEST_MEDIA_PROJECTION);
       }catch (Exception expection){

       }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        try {

            if (requestCode == REQUEST_MEDIA_PROJECTION) {
                if (resultReceiver != null) {
                    Bundle resultData = new Bundle();
                    resultData.putString(Constants.PERMISSIONS, Constants.PERMISSION_SCREEN);
                    resultData.putInt(Constants.GRANT_RESULTS, resultCode);
                    resultData.putParcelable(Constants.PROJECTION_DATA, data);
                    resultReceiver.send(requestCode, resultData);
                }
            }
            
            /*if (requestCode == REQUEST_MEDIA_PROJECTION && resultCode == RESULT_OK) {
                if(resultReceiver!=null) {
                    Bundle resultData = new Bundle();
                    resultData.putString(Constants.PERMISSIONS, Constants.PERMISSION_SCREEN);
                    resultData.putInt(Constants.GRANT_RESULTS, resultCode);
                    resultData.putParcelable(Constants.PROJECTION_DATA, data);
                    resultReceiver.send(requestCode, resultData);
                }
            } else {

            }*/
        }catch (Exception expection){

        }
        safeFinish();
    }

    private void safeFinish() {
        try {
            if (!isFinishing() && !isDestroyed()) {
                finish();
            } 
        } catch (Exception e) {

        }
    }
}
