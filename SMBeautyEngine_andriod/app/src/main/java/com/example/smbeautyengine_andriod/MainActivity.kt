package com.example.smbeautyengine_andriod

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import java.lang.System.*
#include <jni.h>


extern "C"
JNIEXPORT __unused  jstring JNICALL
Java_com_example_smbeautyengine_1andriod_MainActivity_PF_Version(JNIEnv *env, jobject thiz) {
    // TODO: implement PF_Version()
    PF_Version();
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

class MainActivity : AppCompatActivity() {



    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Example of a call to a native method
        findViewById<TextView>(R.id.sample_text).text = PF_Version()
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    external fun stringFromJNI(): String

    external fun PF_Version(): String


    companion object {
        // Used to load the 'native-lib' library on application startup.
        init {
            loadLibrary("native-lib")
            loadLibrary("libPixelFree");
        }
    }
}