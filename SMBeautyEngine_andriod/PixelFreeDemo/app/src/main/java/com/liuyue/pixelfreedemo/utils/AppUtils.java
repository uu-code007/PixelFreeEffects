package com.liuyue.pixelfreedemo.utils;

import android.annotation.SuppressLint;
import android.content.Context;

public class AppUtils {

    @SuppressLint("StaticFieldLeak")
    private static Context sContext;

    public static void init(Context context){
        sContext = context;
        ToastUtils.init(context);
    }

    public static Context getApp(){
        return sContext;
    }
}
