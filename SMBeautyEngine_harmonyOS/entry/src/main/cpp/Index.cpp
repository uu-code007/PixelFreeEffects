#include "napi/native_api.h"
#include "log.h"
#include "napi/native_api.h"
#include "Manager/GLManager.h"
#include "sdk/manager/CommonInterface.h"

namespace GLContextManager {
    EXTERN_C_START
    static napi_value Init(napi_env env, napi_value exports) {
        if ((env == nullptr) || (exports == nullptr)) {
            LOGE("INDEX", "env or exports is null");
            return nullptr;
        }
        napi_property_descriptor desc[] = {
            {"getContext", nullptr, GLManager::GetContext, nullptr, nullptr, nullptr, napi_default, nullptr},
        };
        if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
            LOGE("INDEX", "napi_define_properties failed");
            return nullptr;
        }
        GLManager::GetInstance()->Export(env, exports);
        CommonInterface::DefinePropertiesExport(env, exports);
        return exports;
    }
    EXTERN_C_END

    static napi_module demoModule = {
        .nm_version = 1,
        .nm_flags = 0,
        .nm_filename = nullptr,
        .nm_register_func = Init,
        .nm_modname = "entry",
        .nm_priv = ((void *)0),
        .reserved = {0},
    };

    extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
} // namespace GLContextManager
