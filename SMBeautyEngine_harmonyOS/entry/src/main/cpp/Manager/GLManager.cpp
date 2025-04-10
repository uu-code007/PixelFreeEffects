//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLManager.h"
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <cstdint>
#include <hilog/log.h>
#include <string>
#include <stdio.h>
#include "../render/GLRender.h"
#include "log.h"

const char *TAG = "GLManager";

namespace GLContextManager {

GLManager GLManager::m_glManager;

GLManager::~GLManager(){
    //delete Maps values
    for (auto iter = m_nativeXComponentMap.begin(); iter != m_nativeXComponentMap.end(); ++iter) {
        if (iter->second != nullptr) {
            delete iter->second;
            iter->second = nullptr;
        }
    }
    m_nativeXComponentMap.clear();

    for (auto iter = m_glRenderMap.begin(); iter != m_glRenderMap.end(); ++iter) {
        if (iter->second != nullptr) {
            delete iter->second;
            iter->second = nullptr;
        }
    }
    m_glRenderMap.clear();
}

napi_value GLManager::GetContext(napi_env env, napi_callback_info info) {
    if ((env == nullptr) || (info == nullptr)) {
        LOGE(TAG,"GetContext env or info is null");
        return nullptr;
    }

    size_t argCnt = 1;
    napi_value args[1] = {nullptr};
    if (napi_get_cb_info(env, info, &argCnt, args, nullptr, nullptr) != napi_ok) {
        LOGE(TAG,"GetContext napi_get_cb_info failed");
    }

    if (argCnt != 1) {
        napi_throw_type_error(env, NULL, "Wrong number of arguments");
        return nullptr;
    }

    napi_valuetype valuetype;
    if (napi_typeof(env, args[0], &valuetype) != napi_ok) {
        napi_throw_type_error(env, NULL, "napi_typeof failed");
        return nullptr;
    }

    if (valuetype != napi_number) {
        napi_throw_type_error(env, NULL, "Wrong type of arguments");
        return nullptr;
    }

    int64_t value;
    if (napi_get_value_int64(env, args[0], &value) != napi_ok) {
        napi_throw_type_error(env, NULL, "napi_get_value_int64 failed");
        return nullptr;
    }

    napi_value exports;
    if (napi_create_object(env, &exports) != napi_ok) {
        napi_throw_type_error(env, NULL, "napi_create_object failed");
        return nullptr;
    }

    return exports;
}

void GLManager::Export(napi_env env, napi_value exports){
    if ((env == nullptr) || (exports == nullptr)) {
        LOGE(TAG,"Export: env or exports is null");
        return;
    }
    //获取TS单例对象
    napi_value exportInstance = nullptr;
    if (napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        LOGE(TAG,"Export: napi_get_named_property fail");
        return;
    }
    //把TS对象->C++对象
    OH_NativeXComponent* nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        LOGE(TAG,"Export: napi_unwrap fail");
        return;
    }
    //获取XComponentID
    char idStr[OH_XCOMPONENT_ID_LEN_MAX+1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGE(TAG,"Export: OH_NativeXComponent_GetXComponentId fail");
        return;
    }
    string id(idStr);
    auto context = GLManager::GetInstance();
    if ((context != nullptr) && (nativeXComponent != nullptr)) {
        context->SetNativeXComponent(id, nativeXComponent);
        auto render = context->GetRender(id);
        if (render != nullptr) {
            render->RegisterCallback(nativeXComponent);
            render->Export(env, exports);
        }
    }
}

void GLManager::SetNativeXComponent(std::string &id, OH_NativeXComponent *nativeXComponent){
    if (nativeXComponent == nullptr) {
        return;
    }
    if (m_nativeXComponentMap.find(id) == m_nativeXComponentMap.end()) {
        m_nativeXComponentMap[id] = nativeXComponent;
        return;
    }
    if (m_nativeXComponentMap[id] != nativeXComponent) {
        //这里会导致野指针
//         OH_NativeXComponent* temp = m_nativeXComponentMap[id];
//         delete temp;
//         temp = nullptr;
        m_nativeXComponentMap[id] = nativeXComponent;
    }
}

GLRender* GLManager::GetRender(std::string& id){
    if (m_glRenderMap.find(id) == m_glRenderMap.end()) {
        GLRender *instance = GLRender::GetInstance(id);
        m_glRenderMap[id] = instance;
        return instance;
    }
    return m_glRenderMap[id];
}
}