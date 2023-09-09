#include <jni.h>
#include <string>

#include <GLES3/gl3.h>
#include <GLES3/gl3ext.h>

#include "Include/pixelFree_c.hpp"

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_smbeautyengine_1andriod_MainActivity_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Hello from C++";

    return env->NewStringUTF(hello.c_str());
}
