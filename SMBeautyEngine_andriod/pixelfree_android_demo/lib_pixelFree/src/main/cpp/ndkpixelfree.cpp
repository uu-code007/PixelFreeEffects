#include <jni.h>
#include <string>
#include <android/log.h>

extern "C"
{
#include "pixelFree_c.hpp"
}

extern "C"
JNIEXPORT jlong JNICALL
Java_com_hapi_pixelfree_PixelFree_native_1create(JNIEnv *env, jobject thiz) {
    PFPixelFree *px;
    px = PF_NewPixelFree();
    return reinterpret_cast<jlong>(px);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_pixelfree_PixelFree_native_1release(JNIEnv *env, jobject thiz, jlong handler) {
    __android_log_print(ANDROID_LOG_INFO, "mjl", "native_1release-----");
    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    __android_log_print(ANDROID_LOG_INFO, "mjl", "native_3release-----");
    PF_DeletePixelFree(px);
    __android_log_print(ANDROID_LOG_INFO, "mjl", "native_2release-----");

}
#define PFLOG(fmt, ...) __android_log_print(ANDROID_LOG_INFO, QNVTLOG_TAG, fmt, ##__VA_ARGS__);
extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_pixelfree_PixelFree_native_1processWithBuffer(JNIEnv *env, jobject thiz,
                                                                jlong handler, jint texture_id,
                                                                jint wigth, jint height,
                                                                jbyteArray p__data0, jbyteArray p__data1,
                                                                jbyteArray p__data2,
                                                                jint stride__0, jint stride__1,
                                                                jint stride__2, jint format,
                                                                jint rotation_mode) {


    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    jbyte *c_array_p_data0 = env->GetByteArrayElements(p__data0, 0);
    int len_arr_r = env->GetArrayLength(p__data0);

    jbyte *c_array_p_data1 = env->GetByteArrayElements(p__data1, 0);
    int len_arr_p_y = env->GetArrayLength(p__data1);

    jbyte *c_array_p_data2 = env->GetByteArrayElements(p__data2, 0);
    int len_arr_p_cb_cr = env->GetArrayLength(p__data2);

    static PFIamgeInput input;
    input.textureID = texture_id;
    input.wigth = wigth;
    input.height = height;
    input.p_data0 = reinterpret_cast<uint8_t *>(c_array_p_data0);
    input.p_data1 = reinterpret_cast<uint8_t *>(c_array_p_data1);
    input.p_data2 = reinterpret_cast<uint8_t *>(c_array_p_data2);

    input.stride_0 = stride__0;
    input.stride_1 = stride__1;
    input.stride_2 = stride__2;

    input.format = static_cast<PFDetectFormat>(format);
    input.rotationMode = static_cast<PFRotationMode>(rotation_mode);

    PF_processWithBuffer(px, input);

    env->ReleaseByteArrayElements(p__data0, c_array_p_data0, 0);
    env->ReleaseByteArrayElements(p__data1, c_array_p_data1, 0);
    env->ReleaseByteArrayElements(p__data2, c_array_p_data2, 0);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_pixelfree_PixelFree_native_1pixelFreeSetBeautyFiterParam(JNIEnv *env,
                                                                           jobject thiz,
                                                                           jlong handler, jint type,
                                                                           jfloat value) {
    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    PF_pixelFreeSetBeautyFiterParam(px, static_cast<PFBeautyFiterType>(type), &value);
}



extern "C"
JNIEXPORT void JNICALL
Java_com_hapi_pixelfree_PixelFree_native_1createBeautyItemFormBundle(JNIEnv *env, jobject thiz,
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
Java_com_hapi_pixelfree_PixelFree_native_1pixelFreeSetFiterParam(JNIEnv *env, jobject thiz,
                                                                     jlong handler,
                                                                     jstring filter_name,
                                                                     jfloat value) {
    auto *px = reinterpret_cast<PFPixelFree *>(handler);
    const char* str;
    jboolean isCopy;
    str = env->GetStringUTFChars(filter_name, &isCopy);
    PF_pixelFreeSetBeautyFiterParam(px, PFBeautyFiterName, (void *)str);
    PF_pixelFreeSetBeautyFiterParam(px, PFBeautyFiterStrength, &value);
    env->ReleaseStringUTFChars( filter_name, str);
}