//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLRENDER_H
#define EFFECTSHARMONY_GLRENDER_H

#include <ace/xcomponent/native_interface_xcomponent.h>
#include <string>
#include <unordered_map>
#include "GLCore.h"
#include "log.h"
#include "napi/native_api.h"

using namespace std;

namespace GLContextManager {
class GLRender {
public:
    explicit GLRender(string& id);
    ~GLRender();
    static GLRender *GetInstance(string& id);
    static void Release(std::string &id);
    static napi_value Draw(napi_env env, napi_callback_info info);
    void Export(napi_env env, napi_value exports);
    void OnSurfaceChanged(OH_NativeXComponent *component, void *window);
    void OnTouchEvent(OH_NativeXComponent *component, void *window);
    void OnMouseEvent(OH_NativeXComponent *component, void *window);
    void OnHoverEvent(OH_NativeXComponent *component, bool isHover);
    void OnFocusEvent(OH_NativeXComponent *component, void *window);
    void OnBlurEvent(OH_NativeXComponent *component, void *window);
    void OnKeyEvent(OH_NativeXComponent *component, void *window);
    void RegisterCallback(OH_NativeXComponent *nativeXComponent);

public:
    static std::unordered_map<std::string, GLRender *> m_instance;
    GLCore *m_eglCore;
    std::string m_id;
private:
    OH_NativeXComponent_Callback m_renderCallback;
    OH_NativeXComponent_MouseEvent_Callback m_mouseCallback;
};
}


#endif //EFFECTSHARMONY_GLRENDER_H
