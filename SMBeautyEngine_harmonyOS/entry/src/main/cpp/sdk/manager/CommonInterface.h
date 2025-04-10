//
// Created on 2024/3/18.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_COMMONINTERFACE_H
#define EFFECTSHARMONY_COMMONINTERFACE_H

#include "common/common.h"
#include "sdk/include/pixelFree_c.hpp"
#include "sdk/manager/PixfreeManager.h"

class CommonInterface {
public:
    static void DefinePropertiesExport(napi_env env, napi_value exports);
    
    static PixfreeManager *pmanger;

    
private:
    static void napi_detectProcessAndRenderBuffer(napi_env env, napi_callback_info info);
    static napi_value napi_streamDetectProcessAndRenderBuffer(napi_env env, napi_callback_info info);
    static napi_value ndk_init_pixel_free(napi_env env, napi_callback_info info);
    
    static napi_value ndk_destroy_PixelFree(napi_env env, napi_callback_info info);
    
    static napi_value ndk_set_beauty_strength(napi_env env, napi_callback_info info);
    static napi_value ndk_set_beauty_sticker(napi_env env, napi_callback_info info);
    static napi_value ndk_set_beauty_filter(napi_env env, napi_callback_info info);
    static napi_value ndk_set_beauty_onekey_filter(napi_env env, napi_callback_info info);
    
};

#endif // EFFECTSHARMONY_COMMONINTERFACE_H
