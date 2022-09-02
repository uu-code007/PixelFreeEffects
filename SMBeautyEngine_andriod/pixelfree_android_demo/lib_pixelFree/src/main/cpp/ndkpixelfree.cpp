#include <jni.h>
#include <string>
#include <android/log.h>

extern "C"
{
#include "pixelFree_c.hpp"
}

extern "C"
JNIEXPORT jlong JNICALL
Java_com_byteflow_pixelfree_PixelFree_native_1create(JNIEnv *env, jobject thiz) {
    PFPixelFree *px;
    px = PF_NewPixelFree();
    return reinterpret_cast<jlong>(px);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_byteflow_pixelfree_PixelFree_native_1release(JNIEnv *env, jobject thiz, jlong handler) {
    __android_log_print(ANDROID_LOG_INFO, "mjl", "native_1release-----");
    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    __android_log_print(ANDROID_LOG_INFO, "mjl", "native_3release-----");
    PF_DeletePixelFree(px);
    __android_log_print(ANDROID_LOG_INFO, "mjl", "native_2release-----");

}
#define PFLOG(fmt, ...) __android_log_print(ANDROID_LOG_INFO, QNVTLOG_TAG, fmt, ##__VA_ARGS__);
extern "C"
JNIEXPORT void JNICALL
Java_com_byteflow_pixelfree_PixelFree_native_1processWithBuffer(JNIEnv *env, jobject thiz,
                                                                jlong handler, jint texture_id,
                                                                jint wigth, jint height,
                                                                jbyteArray p__bgra, jbyteArray p__y,
                                                                jbyteArray p__cb_cr,
                                                                jint stride__bgra, jint stride__y,
                                                                jint stride__cb_cr, jint format,
                                                                jint rotation_mode) {


    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    jbyte *c_array_p_bgra = env->GetByteArrayElements(p__bgra, 0);
    int len_arr_r = env->GetArrayLength(p__bgra);

    jbyte *c_array_p_y = env->GetByteArrayElements(p__y, 0);
    int len_arr_p_y = env->GetArrayLength(p__y);

    jbyte *c_array_p_cb_cr = env->GetByteArrayElements(p__cb_cr, 0);
    int len_arr_p_cb_cr = env->GetArrayLength(p__cb_cr);

    static PFIamgeInput input;
    input.textureID = texture_id;
    input.wigth = wigth;
    input.height = height;
    input.p_BGRA = reinterpret_cast<uint8_t *>(c_array_p_bgra);
    input.p_Y = reinterpret_cast<uint8_t *>(c_array_p_y);
    input.p_CbCr = reinterpret_cast<uint8_t *>(c_array_p_cb_cr);

    input.stride_BGRA = stride__bgra;
    input.stride_Y = stride__y;
    input.stride_CbCr = stride__cb_cr;

    input.format = static_cast<PFDetectFormat>(format);
    input.rotationMode = static_cast<PFRotationMode>(rotation_mode);

    __android_log_print(ANDROID_LOG_INFO, "aaa", "sunmu-----%d %d", input.format,len_arr_r);
    PF_processWithBuffer(px, input);

    env->ReleaseByteArrayElements(p__bgra, c_array_p_bgra, 0);
    env->ReleaseByteArrayElements(p__y, c_array_p_y, 0);
    env->ReleaseByteArrayElements(p__cb_cr, c_array_p_cb_cr, 0);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_byteflow_pixelfree_PixelFree_native_1pixelFreeSetBeautyFiterParam(JNIEnv *env,
                                                                           jobject thiz,
                                                                           jlong handler, jint type,
                                                                           jfloat value) {
    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    PF_pixelFreeSetBeautyFiterParam(px, static_cast<PFBeautyFiterType>(type), &value);
}



extern "C"
JNIEXPORT void JNICALL
Java_com_byteflow_pixelfree_PixelFree_native_1createBeautyItemFormBundle(JNIEnv *env, jobject thiz,
                                                                         jlong handler,
                                                                         jbyteArray data, jint size,
                                                                         jint type) {
    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    jbyte *c_array = env->GetByteArrayElements(data, 0);
    int len_arr = env->GetArrayLength(data);
    PF_createBeautyItemFormBundle(px, reinterpret_cast<uint8_t *>(c_array), size,
                                  static_cast<PFSrcType>(type));
}
extern "C"
JNIEXPORT void JNICALL
Java_com_byteflow_pixelfree_PixelFree_native_1pixelFreeSetFiterParam(JNIEnv *env, jobject thiz,
                                                                     jlong handler,
                                                                     jstring filter_name,
                                                                     jfloat value) {
    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    const char* str;
    jboolean isCopy;
    str = env->GetStringUTFChars(filter_name, &isCopy);
    __android_log_print(ANDROID_LOG_INFO, "aaa", "sunmu-----%s %f", str,value);
    PF_pixelFreeSetBeautyFiterParam(px, PFBeautyFiterName, &str);
    PF_pixelFreeSetBeautyFiterParam(px, PFBeautyFiterStrength, &value);
    env->ReleaseStringUTFChars( filter_name, str);
}