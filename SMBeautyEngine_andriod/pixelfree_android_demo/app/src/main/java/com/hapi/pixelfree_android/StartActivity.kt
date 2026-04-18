package com.hapi.pixelfree_android

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.util.Log

class StartActivity : AppCompatActivity() {
    companion object {
        private const val TAG = "StartActivity"
        private const val FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS"
        private const val REQUEST_CODE_PERMISSIONS = 10
        private val REQUIRED_PERMISSIONS = arrayOf(
            Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.RECORD_AUDIO
        )
    }

    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(
            baseContext, it
        ) == PackageManager.PERMISSION_GRANTED
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportActionBar?.hide()
        setContentView(R.layout.activity_start)
        
        // Request permissions
        if (!allPermissionsGranted()) {
            ActivityCompat.requestPermissions(
                this, REQUIRED_PERMISSIONS, REQUEST_CODE_PERMISSIONS
            )
        }
        
        // Camera Button
        findViewById<androidx.constraintlayout.widget.ConstraintLayout>(R.id.cameraButton).setOnClickListener {
            Log.d(TAG, "打开相机预览")
            startActivity(Intent(this, MainActivity::class.java))
        }

        // Image Button
        findViewById<androidx.constraintlayout.widget.ConstraintLayout>(R.id.imageButton).setOnClickListener {
            Log.d(TAG, "打开图片处理")
            startActivity(Intent(this, ImageActivity::class.java))
        }
    }
}