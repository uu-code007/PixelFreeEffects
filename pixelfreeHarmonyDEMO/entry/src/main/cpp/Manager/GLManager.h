//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLMANAGER_H
#define EFFECTSHARMONY_GLMANAGER_H
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include "../render/GLRender.h"
#include <string>
#include <unordered_map>

using namespace  std;

namespace GLContextManager {
class GLManager {
    public:
        ~GLManager();
        static GLManager* GetInstance(){
            return &GLManager::m_glManager;
        }
        static napi_value GetContext(napi_env env, napi_callback_info info);
        void SetNativeXComponent(std::string &id, OH_NativeXComponent *nativeXComponent);
        GLRender *GetRender(string& id);
        void Export(napi_env env, napi_value exports);

    private:
        static GLManager m_glManager;
        unordered_map<string, OH_NativeXComponent*> m_nativeXComponentMap;
        unordered_map<string, GLRender*> m_glRenderMap;
};
}


#endif //EFFECTSHARMONY_GLMANAGER_H
