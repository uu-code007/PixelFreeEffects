package com.liuyue.pixelfreedemo.utils;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Build;

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

    private static boolean check(String permission) {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || AppUtils.getApp().checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
    }
}
