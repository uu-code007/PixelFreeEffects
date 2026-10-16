package com.hapi.camerax_texture

import android.Manifest
import android.media.MediaScannerConnection
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.view.Surface
import android.widget.Button
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import com.hapi.pixelfreeuikit.PixeBeautyDialog
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : AppCompatActivity() {
    companion object {
        private const val TAG = "CameraXTextureMain"
    }

    private lateinit var previewView: TextureBeautyView
    private lateinit var btnStartRecord: Button
    private lateinit var btnStopRecord: Button
    private var currentRecordFile: File? = null

    private val beautyDialog by lazy {
        PixeBeautyDialog(previewView.pixelFree)
    }

    private val cameraPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) {
                bindCamera()
            } else {
                Toast.makeText(this, "需要相机权限才能预览", Toast.LENGTH_SHORT).show()
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        previewView = findViewById(R.id.texturePreview)
        btnStartRecord = findViewById(R.id.btnStartRecord)
        btnStopRecord = findViewById(R.id.btnStopRecord)
        beautyDialog.setOnCompButtonStateListener(object : PixeBeautyDialog.OnCompButtonStateListener {
            override fun onCompButtonPressed(isPressed: Boolean) {
                previewView.setCompareOriginalEnabled(isPressed)
            }
        })

        previewView.onPixelFreeReady = {
            runOnUiThread {
                if (!beautyDialog.isAdded) {
                    beautyDialog.show(supportFragmentManager, "beauty")
                }
            }
        }

        findViewById<Button>(R.id.btnBeauty).setOnClickListener {
            if (!beautyDialog.isAdded) {
                beautyDialog.show(supportFragmentManager, "beauty")
            }
        }
        btnStartRecord.setOnClickListener { startRecord() }
        btnStopRecord.setOnClickListener { stopRecord() }

        cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
    }

    private fun bindCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            val preview = Preview.Builder()
                .setTargetRotation(windowManager.defaultDisplay.rotation)
                .build()
                .also { it.setSurfaceProvider(previewView.surfaceProvider) }

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    this,
                    CameraSelector.DEFAULT_FRONT_CAMERA,
                    preview
                )
            } catch (e: Exception) {
                Toast.makeText(this, "CameraX 绑定失败: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun startRecord() {
        val file = createRecordFile()
        val started = previewView.startRecording(file) { error ->
            runOnUiThread {
                currentRecordFile = null
                btnStartRecord.isEnabled = true
                btnStopRecord.isEnabled = false
                Log.e(TAG, "Record start failed", error)
                Toast.makeText(this, "录制启动失败: ${error.message}", Toast.LENGTH_LONG).show()
            }
        }
        if (started) {
            currentRecordFile = file
            btnStartRecord.isEnabled = false
            btnStopRecord.isEnabled = true
            Toast.makeText(this, "开始录制", Toast.LENGTH_SHORT).show()
        } else {
            currentRecordFile = null
            Toast.makeText(this, "预览尚未就绪，请稍后再试", Toast.LENGTH_SHORT).show()
        }
    }

    private fun stopRecord() {
        previewView.stopRecording { error ->
            val file = currentRecordFile
            currentRecordFile = null
            runOnUiThread {
                btnStartRecord.isEnabled = true
                btnStopRecord.isEnabled = false
                if (error != null) {
                    Log.e(TAG, "Record stop failed", error)
                    Toast.makeText(this, "录制保存失败: ${error.message}", Toast.LENGTH_LONG).show()
                } else if (file != null && file.exists() && file.length() > 0L) {
                    MediaScannerConnection.scanFile(
                        this,
                        arrayOf(file.absolutePath),
                        arrayOf("video/mp4"),
                        null
                    )
                    Toast.makeText(this, "已保存: ${file.absolutePath}", Toast.LENGTH_LONG).show()
                } else {
                    Toast.makeText(this, "录制文件为空，请重新录制", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private fun createRecordFile(): File {
        val dir = File(getExternalFilesDir(Environment.DIRECTORY_MOVIES), "beauty_texture")
        if (!dir.exists()) {
            dir.mkdirs()
        }
        val name = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        return File(dir, "beauty_$name.mp4")
    }

    override fun onDestroy() {
        previewView.release()
        super.onDestroy()
    }
}
