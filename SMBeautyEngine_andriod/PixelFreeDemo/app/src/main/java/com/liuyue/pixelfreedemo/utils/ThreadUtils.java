package com.liuyue.pixelfreedemo.utils;

import android.os.Handler;
import android.os.Looper;

import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ThreadUtils {

    private static final int FIX_THREAD_NUMBER = 3;
    private static final String FIX_THREAD_NAME = "固定线程";
    private static final String SINGLE_THREAD_NAME = "单线程";
    private static final String SCHEDULED_THREAD_NAME = "周期线程";

    private static final Handler HANDLER = new Handler(Looper.getMainLooper());
    private static ExecutorService mFixedThreadPool = null;
    private static ExecutorService mSingleThreadExecutor = null;
    private static ScheduledExecutorService mScheduledExecutorService = null;

    public static boolean checkIsOnUiThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }

    public static void runOnUiThread(final Runnable runnable) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            runnable.run();
        } else {
            HANDLER.post(runnable);
        }
    }

    public static void runOnUiThreadDelayed(final Runnable runnable, long delayMillis) {
        HANDLER.postDelayed(runnable, delayMillis);
    }

    public static ExecutorService getFixedThreadPool() {
        if (mFixedThreadPool == null) {
            mFixedThreadPool = new ThreadPoolExecutor(FIX_THREAD_NUMBER, FIX_THREAD_NUMBER, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>(), new ThreadFactory() {
                @Override
                public Thread newThread(Runnable runnable) {
                    return new Thread(runnable, getRandomName(FIX_THREAD_NAME));
                }
            });
        }
        return mFixedThreadPool;
    }

    public static ExecutorService getSingleThreadExecutor() {
        if (mSingleThreadExecutor == null) {
            mSingleThreadExecutor = new ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>(), new ThreadFactory() {
                @Override
                public Thread newThread(Runnable runnable) {
                    return new Thread(runnable, getRandomName(SINGLE_THREAD_NAME));
                }
            });
        }
        return mSingleThreadExecutor;
    }

    public static ScheduledExecutorService getScheduledExecutorService() {
        if (mScheduledExecutorService == null) {
            mScheduledExecutorService = Executors.newScheduledThreadPool(FIX_THREAD_NUMBER, new ThreadFactory() {
                @Override
                public Thread newThread(Runnable runnable) {
                    return new Thread(runnable, getRandomName(SCHEDULED_THREAD_NAME));
                }
            });
        }
        return mScheduledExecutorService;
    }

    private static String getRandomName(String baseName) {
        Random random = new Random(System.currentTimeMillis());
        int number = random.nextInt(777);
        return baseName + "-" + number;
    }
}
