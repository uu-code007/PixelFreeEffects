package com.liuyue.pixelfreedemo;

import android.app.Application;

import com.liuyue.pixelfreedemo.utils.AppUtils;
import com.liuyue.pixelfreedemo.utils.ToastUtils;

public class MyApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        AppUtils.init(this);
    }
}
