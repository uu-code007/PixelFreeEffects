package com.liuyue.pixelfreedemo.utils;

import static android.app.Activity.RESULT_OK;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.Settings;

import androidx.activity.ComponentActivity;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.List;

public class PermissionUtils {

    private static final int REQUEST_CODE_ASK_MULTIPLE_PERMISSIONS = 10000;

    public static void request(Activity activity, final String... permissions) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return;
        }

        List<String> permissionsNeeded = new ArrayList<String>();
        for (String permission : permissions) {
            if (!check(permission)) {
                permissionsNeeded.add(permission);
            }
        }
        if (permissionsNeeded.size() > 0) {
            activity.requestPermissions(permissionsNeeded.toArray(new String[permissionsNeeded.size()]), REQUEST_CODE_ASK_MULTIPLE_PERMISSIONS);
        }
    }

    public static void requestExternalStorageManager(ComponentActivity activity) {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.Q && !Environment.isExternalStorageManager()) {
            ActivityResultLauncher<Intent> mActivityResultLauncher = activity.registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() != RESULT_OK || result.getData() == null) {
                    ToastUtils.showShortToast("未获得全局存储权限");
                }
            });

            try {
                Intent intent = new Intent();
                intent.setAction(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
                intent.setData(uri);
                mActivityResultLauncher.launch(intent);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }
    }

    private static boolean check(String permission) {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || AppUtils.getApp().checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
    }
}
