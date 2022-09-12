#include <jni.h>
#include <android/log.h>
#include "include/pixelFree_c.hpp"

#define LOG_TAG "PixelFreeJni"
#define LOGGABLE 0
#define LOGI(...) if(LOGGABLE) __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)

#define CLASS_NAME_EFFECT_PROCESSOR "com/liuyue/pixelfreedemo/core/EffectProcessor"

#ifdef __cplusplus
extern "C" {
#endif

PFPixelFree *mInstance = nullptr;

JNIEXPORT jboolean JNICALL
create(JNIEnv *env, jobject instance) {
    if (mInstance == nullptr) {
        mInstance = PF_NewPixelFree();
    }
    if (mInstance == nullptr) {
        LOGE("Create effect sdk fail!");
        return false;
    } else {
        return true;
    }
}

JNIEXPORT jboolean JNICALL
destroy(JNIEnv *env, jobject instance) {
    PF_DeletePixelFree(mInstance);
    PF_DeletePixelFree(mInstance);
    mInstance = nullptr;
    return true;
}

JNIEXPORT void JNICALL
process(JNIEnv *env, jobject instance, jobject inputImage) {
    PFIamgeInput PFImageInput;
    jclass inputImageClass = env->GetObjectClass(inputImage);

    jfieldID fieldTextureID = env->GetFieldID(inputImageClass, "textureID", "I");
    int textureID = env->GetIntField(inputImage, fieldTextureID);
    PFImageInput.textureID = textureID;

    jfieldID fieldWidth = env->GetFieldID(inputImageClass, "width", "I");
    int width = env->GetIntField(inputImage, fieldWidth);
    PFImageInput.wigth = width;

    jfieldID fieldHeight = env->GetFieldID(inputImageClass, "height", "I");
    int height = env->GetIntField(inputImage, fieldHeight);
    PFImageInput.height = height;

    jfieldID fieldBGRA = env->GetFieldID(inputImageClass, "BGRA", "[B");
    jbyteArray BGRA = reinterpret_cast<jbyteArray>(env->GetObjectField(inputImage, fieldBGRA));
    PFImageInput.p_BGRA = env->GetByteArrayElements(BGRA, nullptr);

    jfieldID fieldY = env->GetFieldID(inputImageClass, "Y", "[B");
    jbyteArray Y = reinterpret_cast<jbyteArray>(env->GetObjectField(inputImage, fieldY));
    PFImageInput.p_Y = env->GetByteArrayElements(Y, nullptr);

    jfieldID fieldCbCr = env->GetFieldID(inputImageClass, "CbCr", "[B");
    jbyteArray CbCr = reinterpret_cast<jbyteArray>(env->GetObjectField(inputImage, fieldCbCr));
    PFImageInput.p_CbCr = env->GetByteArrayElements(CbCr, nullptr);

    jfieldID fieldBGRAStride = env->GetFieldID(inputImageClass, "BGRAStride", "I");
    int BGRAStride = env->GetIntField(inputImage, fieldBGRAStride);
    PFImageInput.stride_BGRA = BGRAStride;

    jfieldID fieldYStride = env->GetFieldID(inputImageClass, "YStride", "I");
    int YStride = env->GetIntField(inputImage, fieldYStride);
    PFImageInput.stride_Y = YStride;

    jfieldID fieldCbCrStride = env->GetFieldID(inputImageClass, "CbCrStride", "I");
    int CbCrStride = env->GetIntField(inputImage, fieldCbCrStride);
    PFImageInput.stride_CbCr = CbCrStride;

    jfieldID fieldFormat = env->GetFieldID(inputImageClass, "format", "Ljava/lang/Object");
    jobject format = env->GetObjectField(inputImage, fieldFormat);
    jclass formatClass = env->GetObjectClass(format);
    jfieldID fieldFormatValue = env->GetFieldID(formatClass, "value", "I");
    PFImageInput.format = static_cast<PFDetectFormat>(env->GetIntField(format, fieldFormatValue));

    jfieldID fieldRotation = env->GetFieldID(inputImageClass, "rotation", "Ljava/lang/Object");
    jobject rotation = env->GetObjectField(inputImage, fieldRotation);
    jclass rotationClass = env->GetObjectClass(rotation);
    jfieldID fieldRotationValue = env->GetFieldID(rotationClass, "value", "I");
    PFImageInput.format = static_cast<PFDetectFormat>(env->GetIntField(rotation,fieldRotationValue));

    PF_processWithBuffer(mInstance, PFImageInput);
}

JNIEXPORT void JNICALL
setBeauty(JNIEnv *env, jobject instance, jint type, jobject value) {
    PF_pixelFreeSetBeautyFiterParam(mInstance, static_cast<PFBeautyFiterType>(type), &value);
}


JNIEXPORT void JNICALL
createBeautyItem(JNIEnv *env, jobject instance, jobject data, jint size, jint type) {
    PF_createBeautyItemFormBundle(mInstance, data, size, static_cast<PFSrcType>(type));
}


#ifdef __cplusplus
}
#endif

static JNINativeMethod methods[] = {
        {"create",           "()Z",                                           (void *) create},
        {"destroy",          "()Z",                                           (void *) destroy},
        {"process",          "(Lcom/liuyue/pixelfreedemo/core/ImageInput;)V", (void *) process},
        {"setBeauty",        "(ILjava/lang/Object;)V",                        (void *) setBeauty},
        {"createBeautyItem", "(Ljava/lang/Object;II)V",                       (void *) createBeautyItem}
};

static int
RegisterNativeMethods(JNIEnv *env, const char *className, JNINativeMethod *methods, int methodNum) {
    LOGI("RegisterNativeMethods");
    jclass clazz = env->FindClass(className);
    if (clazz == NULL) {
        LOGE("RegisterNativeMethods fail. clazz == NULL");
        return JNI_FALSE;
    }
    if (env->RegisterNatives(clazz, methods, methodNum) < 0) {
        LOGE("RegisterNativeMethods fail");
        return JNI_FALSE;
    }
    return JNI_TRUE;
}

static void UnregisterNativeMethods(JNIEnv *env, const char *className) {
    LOGI("UnregisterNativeMethods");
    jclass clazz = env->FindClass(className);
    if (clazz == NULL) {
        LOGE("UnregisterNativeMethods fail. clazz == NULL");
        return;
    }
    if (env != NULL) {
        env->UnregisterNatives(clazz);
    }
}

extern "C" jint JNI_OnLoad(JavaVM *jvm, void *p) {
    LOGI("========== OnLoad ==========");
    jint jniRet = JNI_ERR;
    JNIEnv *env = NULL;
    if (jvm->GetEnv((void **) (&env), JNI_VERSION_1_6) != JNI_OK) {
        return jniRet;
    }

    jint regRet = RegisterNativeMethods(env, CLASS_NAME_EFFECT_PROCESSOR, methods,
                                        sizeof(methods) / sizeof(methods[0]));
    if (regRet != JNI_TRUE) {
        LOGE("Register native methods fail!");
        return JNI_ERR;
    }
    return JNI_VERSION_1_6;
}

extern "C" void JNI_OnUnload(JavaVM *jvm, void *p) {
    JNIEnv *env = NULL;
    if (jvm->GetEnv((void **) (&env), JNI_VERSION_1_6) != JNI_OK) {
        return;
    }

    UnregisterNativeMethods(env, CLASS_NAME_EFFECT_PROCESSOR);
}
