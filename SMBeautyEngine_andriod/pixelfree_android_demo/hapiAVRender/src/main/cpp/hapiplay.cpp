#include <jni.h>
#include <string>

#include "VideoGLRender.h"
#include "OpenSLRender.h"
#include "libyuv.h"

extern "C" JNIEXPORT jstring JNICALL
Java_com_hapi_avrender_NativeLib_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1onFrame(JNIEnv *env, jobject thiz,
                                                    jlong render_handler,
                                                    jint textureID,
                                                    jint width, jint height,
                                                    jint format, jbyteArray data,
                                                    jint rotation_degrees,
                                                    jint pixel_stride,
                                                    jint row_padding) {
    auto *videoGlRender = reinterpret_cast<VideoGLRender *>(render_handler);

    jbyte *c_array = env->GetByteArrayElements(data, 0);
    int len_arr = env->GetArrayLength(data);
    NativeImage videoFrame;
    videoFrame.textureID = textureID;
    videoFrame.rotationDegrees = rotation_degrees;
    videoFrame.width = width;
    videoFrame.height = height;
    videoFrame.format = format;
    videoFrame.ppPlane[0] = reinterpret_cast<uint8_t *>(c_array);
    videoFrame.pLineSize[0] = len_arr;
    videoFrame.pixelStride = pixel_stride;
    videoFrame.rowPadding = row_padding;
    videoGlRender->RenderVideoFrame(&videoFrame);
    videoFrame.ppPlane[0] = nullptr;
    env->ReleaseByteArrayElements(data, c_array, 0);
}

extern "C"
JNIEXPORT jlong JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1create(JNIEnv *env, jobject thiz) {
    auto videoGlRender = new VideoGLRender();
    return reinterpret_cast<jlong>(videoGlRender);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1OnSurfaceCreated(JNIEnv *env,
                                                             jobject thiz,
                                                             jlong render_handler) {
    auto videoGlRender = reinterpret_cast<VideoGLRender *>(render_handler);
    videoGlRender->OnSurfaceCreated();

}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1OnSurfaceChanged(JNIEnv *env,
                                                             jobject thiz,
                                                             jlong render_handler,
                                                             jint width,
                                                             jint height) {
    auto videoGlRender = reinterpret_cast<VideoGLRender *>(render_handler);
    videoGlRender->OnSurfaceChanged(width, height);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1OnDrawFrame(JNIEnv *env,
                                                        jobject thiz,
                                                        jlong render_handler) {
    auto videoGlRender = reinterpret_cast<VideoGLRender *>(render_handler);
    videoGlRender->OnDrawFrame();
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1SetGesture(JNIEnv *env, jobject thiz,
                                                       jlong render_handler,
                                                       jint x_rotate_angle,
                                                       jint y_rotate_angle,
                                                       jfloat scale) {
    auto videoGlRender = reinterpret_cast<VideoGLRender *>(render_handler);
    videoGlRender->UpdateMVPMatrix(x_rotate_angle, y_rotate_angle, scale, scale);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1SetTouchLoc(JNIEnv *env,
                                                        jobject thiz,
                                                        jlong render_handler,
                                                        jfloat touch_x,
                                                        jfloat touch_y) {
    auto videoGlRender = reinterpret_cast<VideoGLRender *>(render_handler);
    videoGlRender->SetTouchLoc(touch_x, touch_y);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenGLRender_native_1release(JNIEnv *env, jobject thiz,
                                                    jlong render_handler) {

    auto videoGlRender = reinterpret_cast<VideoGLRender *>(render_handler);
    videoGlRender->UnInit();
    delete videoGlRender;
}
extern "C"
JNIEXPORT jlong JNICALL
Java_com_hapi_avrender_OpenSLRender_native_1native_1create(JNIEnv *env, jobject thiz) {
    auto openslRender = new OpenSLRender();
    openslRender->init();
    return reinterpret_cast<jlong>(openslRender);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenSLRender_native_1native_1release(JNIEnv *env, jobject thiz,
                                                            jlong native_handler) {

    auto openslRender = reinterpret_cast<OpenSLRender *>(native_handler);
    delete openslRender;
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_avrender_OpenSLRender_native_1native_1audio_1frame(JNIEnv *env, jobject thiz,
                                                                 jlong native_handler,
                                                                 jbyteArray data,
                                                                 jint sample_fmt,
                                                                 jint audio_channel_layout,
                                                                 jint audio_sample_rate
) {
    jbyte *c_array = env->GetByteArrayElements(data, 0);
    int len_arr = env->GetArrayLength(data);
    auto openslRender = reinterpret_cast<OpenSLRender *>(native_handler);
    AudioFrame audioFrame;
    audioFrame.data = reinterpret_cast<uint8_t *>(c_array);
    audioFrame.dataSize = len_arr;
    audioFrame.out_sample_fmt = AVSampleFormat(sample_fmt);
    audioFrame.audioSampleRate = audio_sample_rate;
    audioFrame.audioChannelLayout = (audio_channel_layout);
    openslRender->RenderAudioFrame(&audioFrame);
    env->ReleaseByteArrayElements(data, c_array, 0);
    audioFrame.data = nullptr;
}