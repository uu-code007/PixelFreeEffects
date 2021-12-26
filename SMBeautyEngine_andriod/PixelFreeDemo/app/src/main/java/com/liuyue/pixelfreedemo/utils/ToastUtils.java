package com.liuyue.pixelfreedemo.utils;

import android.content.Context;
import android.widget.Toast;

public class ToastUtils {

    private static Toast sToast;

    static void init(Context context) {
        sToast = Toast.makeText(context, "", Toast.LENGTH_SHORT);
    }

    public static void showShortToast(String message) {
        showToast(message, Toast.LENGTH_SHORT);
    }

    public static void showLongToast(String message) {
        showToast(message, Toast.LENGTH_LONG);
    }

    public static void cancel() {
        if (sToast != null) {
            sToast.cancel();
        }
    }

    private static void showToast(String message, int duration) {
        ThreadUtils.runOnUiThread(() -> {
            if (sToast != null) {
                sToast.setText(message);
                sToast.setDuration(duration);
                sToast.show();
            }
        });
    }
}
