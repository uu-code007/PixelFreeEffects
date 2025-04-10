//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include <bits/alltypes.h>
#include <cstdint>
#include <hilog/log.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <string>
#include "log.h"
#include "GLRender.h"

const int PARAM_0 = 0;
const int PARAM_1 = 0;
const int PARAM_2 = 0;
const int PARAM_3 = 0;

static const char *TAG = "GLRender";

GLContextManager::GLCore * glCore = nullptr;

namespace GLContextManager {
std::unordered_map<std::string, GLRender *> GLRender::m_instance;

#pragma SurfaceCallBack
void OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window) {
    LOGE(TAG,"OnSurfaceCreatedCB");
    if ((component == nullptr) || (window == nullptr)) {
        LOGE(TAG,"OnSurfaceCreatedCB: component or window is null");
        return;
    }

    //获取XComponent组件的Id
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGD(TAG,"OnSurfaceCreatedCB: Unable to get XComponent id");
        return;
    }
    
    std::string id(idStr);
    auto render = GLRender::GetInstance(id);
    uint64_t width;
    uint64_t height;
    //获取当前xComponentView的size
    int32_t xSize = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    if ((xSize == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) && (render != nullptr)) {
        if (render->m_eglCore->EglContextInit(window, width, height)) {
            
        }
    }
}

void OnSurfaceChangedCB(OH_NativeXComponent *component, void *window) {
    LOGD(TAG,"OnSurfaceChangedCB");
    if ((component == nullptr) || (window == nullptr)) {
        LOGE(TAG,"OnSurfaceChangedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGE(TAG,"OnSurfaceChangedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->OnSurfaceChanged(component, window);
        LOGI(TAG,"surface changed");
    }
}

void OnSurfaceDestroyedCB(OH_NativeXComponent *component, void *window) {
    LOGI(TAG,"OnSurfaceDestroyedCB");
    if ((component == nullptr) || (window == nullptr)) {
        LOGE(TAG,"OnSurfaceDestroyedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGE(TAG,"OnSurfaceDestroyedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    GLRender::Release(id);
}

void DispatchTouchEventCB(OH_NativeXComponent *component, void *window) {
    LOGE(TAG,"DispatchTouchEventCB");
    if ((component == nullptr) || (window == nullptr)) {
        LOGE(TAG,"DispatchTouchEventCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGE(TAG,"DispatchTouchEventCB: Unable to get XComponent id");
        return;
    }
    std::string id(idStr);
    GLRender *render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->OnTouchEvent(component, window);
    }
}

void DispatchMouseEventCB(OH_NativeXComponent *component, void *window) {
    LOGI(TAG,"DispatchMouseEventCB");
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    int32_t ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->OnMouseEvent(component, window);
    }
}

void DispatchHoverEventCB(OH_NativeXComponent *component, bool isHover) {
    LOGI(TAG,"DispatchHoverEventCB");
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    int32_t ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->OnHoverEvent(component, isHover);
    }
}

void OnFocusEventCB(OH_NativeXComponent *component, void *window) {
    LOGI(TAG,"OnFocusEventCB");
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    int32_t ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->OnFocusEvent(component, window);
    }
}

void OnBlurEventCB(OH_NativeXComponent *component, void *window) {
    LOGI(TAG,"OnBlurEventCB");
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    int32_t ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->OnBlurEvent(component, window);
    }
}

void OnKeyEventCB(OH_NativeXComponent *component, void *window) {
    LOGI(TAG,"OnKeyEventCB");
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    int32_t ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }
    std::string id(idStr);
    auto render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->OnKeyEvent(component, window);
    }
}

void GLRender::OnSurfaceChanged(OH_NativeXComponent *component, void *window) {
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGI(TAG,"OnSurfaceChanged: Unable to get XComponent id");
        return;
    }
    std::string id(idStr);
    GLRender *render = GLRender::GetInstance(id);
    double offsetX;
    double offsetY;
    OH_NativeXComponent_GetXComponentOffset(component, window, &offsetX, &offsetY);
    LOGI(TAG,"offsetX = %{public}lf, offsetY = %{public}lf", offsetX, offsetY);
    uint64_t width;
    uint64_t height;
    OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    if (render != nullptr) {
        render->m_eglCore->UpdateSize(width, height);
    }
}

void GLRender::Release(std::string &id) {
    LOGD(TAG,"GLRender Release");
    GLRender *render = GLRender::GetInstance(id);
    if (render != nullptr) {
        render->m_eglCore->Release();
        delete render->m_eglCore;
        render->m_eglCore = nullptr;
//         delete render;
//         render = nullptr;
        m_instance.erase(m_instance.find(id));
    }
}

void GLRender::OnTouchEvent(OH_NativeXComponent *component, void *window) {
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGI(TAG,"DispatchTouchEventCB: Unable to get XComponent id");
        return;
    }
    OH_NativeXComponent_TouchEvent touchEvent;
    OH_NativeXComponent_GetTouchEvent(component, window, &touchEvent);
    std::string id(idStr);
    GLRender *render = GLRender::GetInstance(id);
    if (render != nullptr && touchEvent.type == OH_NativeXComponent_TouchEventType::OH_NATIVEXCOMPONENT_UP) {
        //render->m_eglCore->ChangeColor(m_hasChangeColor);
    }
    float tiltX = 0.0f;
    float tiltY = 0.0f;
    OH_NativeXComponent_TouchPointToolType toolType =
        OH_NativeXComponent_TouchPointToolType::OH_NATIVEXCOMPONENT_TOOL_TYPE_UNKNOWN;
    OH_NativeXComponent_GetTouchPointToolType(component, 0, &toolType);
    OH_NativeXComponent_GetTouchPointTiltX(component, 0, &tiltX);
    OH_NativeXComponent_GetTouchPointTiltY(component, 0, &tiltY);
    LOGI(TAG,"touch info: toolType = %{public}d, tiltX = %{public}lf, tiltY = %{public}lf", toolType, tiltX, tiltY);
}

void GLRender::RegisterCallback(OH_NativeXComponent *nativeXComponent) {
    m_renderCallback.OnSurfaceCreated = OnSurfaceCreatedCB;
    m_renderCallback.OnSurfaceChanged = OnSurfaceChangedCB;
    m_renderCallback.OnSurfaceDestroyed = OnSurfaceDestroyedCB;
    m_renderCallback.DispatchTouchEvent = DispatchTouchEventCB;
    OH_NativeXComponent_RegisterCallback(nativeXComponent, &m_renderCallback);

    m_mouseCallback.DispatchMouseEvent = DispatchMouseEventCB;
    m_mouseCallback.DispatchHoverEvent = DispatchHoverEventCB;
    OH_NativeXComponent_RegisterMouseEventCallback(nativeXComponent, &m_mouseCallback);

    OH_NativeXComponent_RegisterFocusEventCallback(nativeXComponent, OnFocusEventCB);
    OH_NativeXComponent_RegisterKeyEventCallback(nativeXComponent, OnKeyEventCB);
    OH_NativeXComponent_RegisterBlurEventCallback(nativeXComponent, OnBlurEventCB);
}

void GLRender::OnMouseEvent(OH_NativeXComponent *component, void *window) {
    LOGI(TAG,"OnMouseEvent");
    OH_NativeXComponent_MouseEvent mouseEvent;
    int32_t ret = OH_NativeXComponent_GetMouseEvent(component, window, &mouseEvent);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGI(TAG,"MouseEvent Info: x = %{public}f, y = %{public}f, action = %{public}d, button = %{public}d",
             mouseEvent.x, mouseEvent.y, mouseEvent.action, mouseEvent.button);
    } else {
        LOGE(TAG,"GetMouseEvent error");
    }
}

void GLRender::OnHoverEvent(OH_NativeXComponent *component, bool isHover) {
    LOGI(TAG,"OnHoverEvent isHover_ = %{public}d", isHover);
}

void GLRender::OnFocusEvent(OH_NativeXComponent *component, void *window) { LOGI(TAG,"OnFocusEvent"); }

void GLRender::OnBlurEvent(OH_NativeXComponent *component, void *window) { LOGI(TAG,"OnBlurEvent"); }

void GLRender::OnKeyEvent(OH_NativeXComponent *component, void *window) {
    LOGI(TAG,"OnKeyEvent");

    OH_NativeXComponent_KeyEvent *keyEvent = nullptr;
    if (OH_NativeXComponent_GetKeyEvent(component, &keyEvent) >= 0) {
        OH_NativeXComponent_KeyAction action;
        OH_NativeXComponent_GetKeyEventAction(keyEvent, &action);
        OH_NativeXComponent_KeyCode code;
        OH_NativeXComponent_GetKeyEventCode(keyEvent, &code);
        OH_NativeXComponent_EventSourceType sourceType;
        OH_NativeXComponent_GetKeyEventSourceType(keyEvent, &sourceType);
        int64_t deviceId;
        OH_NativeXComponent_GetKeyEventDeviceId(keyEvent, &deviceId);
        int64_t timeStamp;
        OH_NativeXComponent_GetKeyEventTimestamp(keyEvent, &timeStamp);
        LOGI(TAG,"KeyEvent Info: action=%{public}d, code=%{public}d, sourceType=%{public}d, deviceId=%{public}ld, "
             "timeStamp=%{public}ld",
             action, code, sourceType, deviceId, timeStamp);
    } else {
        LOGE(TAG,"GetKeyEvent error");
    }
}

GLRender::GLRender(std::string &id) {
    this->m_id = id;
    this->m_eglCore = new GLCore(id);
}

GLRender::~GLRender() {
    LOGD(TAG, "GLRender disContructor");
    if (m_eglCore != nullptr) {
        m_eglCore->Release();
        delete m_eglCore;
        m_eglCore = nullptr;
    }
}

//有可能很多XComponent都使用这Native代码
GLRender *GLRender::GetInstance(std::string &id) {
    LOGI(TAG,"xxx GetInstance");
    if (m_instance.find(id) == m_instance.end()) {
        GLRender *instance = new GLRender(id);
        m_instance[id] = instance;
        glCore = m_instance[id]->m_eglCore;
        return instance;
    } else {
        glCore = m_instance[id]->m_eglCore;
        return m_instance[id];
    }
}

void GLRender::Export(napi_env env, napi_value exports) {
    if ((env == nullptr) || (exports == nullptr)) {
        LOGE(TAG,"Export: env or exports is null");
        return;
    }
    napi_property_descriptor desc[] = {
        {"draw", nullptr, GLRender::Draw, nullptr, nullptr, nullptr, napi_default, nullptr}};
    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
        LOGE(TAG,"Export: napi_define_properties failed");
    }
}

// NAPI registration method type napi_callback. If no value is returned, nullptr is returned.
napi_value GLRender::Draw(napi_env env, napi_callback_info info) {
    if ((nullptr == env) || (nullptr == info)) {
        LOGE(TAG,"NapiLoadYuv: env or info is null");
        return nullptr;
    }

    size_t argc = 5;                // Number of parameters.
    napi_value args[5] = {nullptr}; // A napi array that stores parameters.
    if (napi_ok != napi_get_cb_info(env, info, &argc, args, nullptr, nullptr)) {
        LOGE(TAG,"NapiLoadYuv: napi_get_cb_info fail");
        return nullptr;
    }

    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    size_t length;        // The length of the underlying data buffer used to obtain the arraybuffer.
    int32_t num1;
    int32_t num2;
    int32_t num3;
    int32_t num4;
    // Get buffer width height.
    if (napi_ok != napi_get_arraybuffer_info(env, args[0], &data, &length) ||
        napi_ok != napi_get_value_int32(env, args[1], &num1) ||
        napi_ok != napi_get_value_int32(env, args[2], &num2) ||
        napi_ok != napi_get_value_int32(env, args[3], &num3) ||
        napi_ok != napi_get_value_int32(env, args[4], &num4)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ObjectType",
                     "napi_get_value_string_utf8 or napi_get_value_int32 failed");
        return nullptr;
    }

    napi_value thisArg;
    if (napi_get_cb_info(env, info, nullptr, nullptr, &thisArg, nullptr) != napi_ok) {
        LOGE(TAG,"NapiDrawPattern: napi_get_cb_info fail");
        return nullptr;
    }
    
    napi_value exportInstance;
    if (napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        LOGE(TAG,"NapiDrawPattern: napi_get_named_property fail");
        return nullptr;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        LOGE(TAG,"NapiDrawPattern: napi_unwrap fail");
        return nullptr;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGE(TAG,"NapiDrawPattern: Unable to get XComponent id");
        return nullptr;
    }

    std::string id(idStr);
    GLRender *render = GLRender::GetInstance(id);
    if (render) {
        render->m_eglCore->Draw((uint8_t*)data, length, num1, num2, 0, num3, num4, false);
    }
//     napi_value ret;
//     napi_value width, height;
//     napi_finalize finalize_cb;
//     if (napi_ok != napi_create_external_arraybuffer(env, data, length, finalize_cb, nullptr, &ret) ||
//         napi_ok != napi_create_int32(env, num1, &width) || 
//         napi_ok != napi_create_int32(env, num2, &height)) {
//          LOGE(TAG,"napi_create_string_utf8 or napi_create_int32 failed");
//         return nullptr;
//     }
    // Construct an object type.
//     napi_value obj;
//     if (napi_ok != napi_create_object(env, &obj)) {
//         LOGE(TAG,"napi_create_object failed");
//         return nullptr;
//     }
//     // Set and assign values to the name and age attributes.
//     if (napi_ok != napi_set_named_property(env, obj, "buffer", ret) ||
//         napi_ok != napi_set_named_property(env, obj, "width", width) ||
//         napi_ok != napi_set_named_property(env, obj, "height", height)) {
//         LOGE(TAG,"napi_set_named_property or napi_set_named_property failed");
//         return nullptr;
//     }
    return nullptr;
}
}