package com.hapi.avcapture.screen

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.media.projection.MediaProjectionManager
import android.os.IBinder
import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.hapi.avcapture.screen.Constants.ERROR_CODE_NO_PERMISSION
import com.hapi.avcapture.screen.ScreenRecordService.ID_MEDIA_PROJECTION

object ScreenServicePlugin {
    private var serviceConnection: ServiceConnection? = null
    private var mediaProjectionService: ScreenRecordService? = null

    private fun stopService(context: Context) {
        if (mediaProjectionService != null) {
            mediaProjectionService!!.stop()
        }
        mediaProjectionService = null
        if (serviceConnection != null) {
            ScreenRecordService.unbindService(context, serviceConnection)
        }
        serviceConnection = null
    }

    private fun startRecordService(activity: FragmentActivity, callback: ScreenCaptureServiceCallBack) {
        val mediaProjectionManager =
            activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val fragment: RequestFragment =
            RequestFragmentHelper.getPermissionReqFragment(activity)
        val createVirtualDisplay: (requestCode: Int, resultCode: Int) -> Boolean =
            { requestCode: Int, resultCode: Int ->
                var isGet = true
                if (requestCode != ID_MEDIA_PROJECTION) {
                    callback.onError(ERROR_CODE_NO_PERMISSION, "no permission")
                    isGet = false
                }
                if (resultCode != Activity.RESULT_OK) {
                    callback.onError(ERROR_CODE_NO_PERMISSION, "no permission")
                    isGet = false
                }
                isGet
            }
        fragment.call = { requestCode: Int, resultCode: Int, data: Intent? ->
            if (createVirtualDisplay(requestCode, resultCode)) {
                // 绑定服务
                serviceConnection = object : ServiceConnection {
                    override fun onServiceConnected(name: ComponentName, service: IBinder) {
                        //  mediaProjectionService = new Messenger(service);
                        mediaProjectionService =
                            (service as ScreenRecordService.MediaProjectionBinder).getService()
                        mediaProjectionService?.start(resultCode, data)
                        callback.onStart()
                    }

                    override fun onServiceDisconnected(name: ComponentName) {
                        Log.d("ServiceConnection", "onServiceDisconnected ")
                    }

                    override fun onBindingDied(name: ComponentName) {
                        Log.d("ServiceConnection", "onBindingDied ")
                    }

                    override fun onNullBinding(name: ComponentName) {
                        Log.d("ServiceConnection", "onNullBinding ")
                    }
                }
                ScreenRecordService.bindService(activity, serviceConnection)
            }
        }
        fragment.startActivityForResult(
            mediaProjectionManager.createScreenCaptureIntent(),
            ID_MEDIA_PROJECTION
        )
    }

    fun addImageListener(
        activity: FragmentActivity,
        imageListener: ImageListener,
        callback: ScreenCaptureServiceCallBack
    ) {
        if (serviceConnection == null || mediaProjectionService == null) {
            startRecordService(activity, object : ScreenCaptureServiceCallBack {
                override fun onStart() {
                    mediaProjectionService?.mImageListeners?.add(imageListener)
                    callback.onStart()
                }

                override fun onError(code: Int, msg: String?) {
                    callback.onError(code, msg)
                }
            })
        } else {
            mediaProjectionService?.mImageListeners?.add(imageListener)
            callback.onStart()
        }
    }

    fun removeImageListener(context: Context, imageListener: ImageListener) {
        if (serviceConnection == null || mediaProjectionService == null) {
            return
        } else {
            mediaProjectionService?.mImageListeners?.remove(imageListener)
            if (mediaProjectionService?.mImageListeners?.size == 0) {
                stopService(context)
            }
        }
    }

    interface ScreenCaptureServiceCallBack {
        fun onStart()
        fun onError(code: Int, msg: String?)
    }
}