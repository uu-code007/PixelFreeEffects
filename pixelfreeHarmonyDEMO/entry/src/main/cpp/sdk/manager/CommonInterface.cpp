//
// Created on 2024/3/18.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "CommonInterface.h"
#include "./log/ohos_log.h"
#include "render/GLCore.h"

#define DRAW_POINT 0
#define TOGGLE_COST_LOG 0

extern GLContextManager::GLCore *glCore;
static GLuint _inputTexture = 0;
static GLuint _outputTexture = 0;

static int32_t _lastWidth, _lastHeight = 0;

PixfreeManager *CommonInterface::pmanger;

struct PixelBuffer{
    uint8_t * data;
    int width;
    int height;
    int format;
};

void CommonInterface::DefinePropertiesExport(napi_env env, napi_value exports) {
    if ((env == nullptr) || (exports == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, "[CommonInterface]", "env or exports is null");
        return;
    }

    napi_property_descriptor desc[] = {
        {"setBeautyFilter", nullptr, CommonInterface::ndk_set_beauty_filter, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"streamDetectProcessAndRenderBuffer", nullptr, CommonInterface::napi_streamDetectProcessAndRenderBuffer, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"destroyPixelFree", nullptr, CommonInterface::ndk_destroy_PixelFree, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"initPixelFree", nullptr, CommonInterface::ndk_init_pixel_free, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautyStrength", nullptr, CommonInterface::ndk_set_beauty_strength, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautySticker", nullptr, CommonInterface::ndk_set_beauty_sticker, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setBeautyOnekeyFilter", nullptr, CommonInterface::ndk_set_beauty_onekey_filter, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        
    };
    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, "[CommonInterface]", "napi_define_properties failed");
        return;
    }
}


napi_value CommonInterface::ndk_init_pixel_free(napi_env env, napi_callback_info info){
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    size_t length;
    void *dataLic = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status status = napi_get_arraybuffer_info(env, args[0], &dataLic, &length);
    if (status != napi_ok) {
        LOGE("napi_get_arraybuffer_info error %d", status);
    }

    size_t outputLength;
    void *bundelData = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    status = napi_get_arraybuffer_info(env, args[1], &bundelData, &outputLength);
    if (status != napi_ok) {
        LOGE("napi_get_arraybuffer_info error %d", status);
    }
    
    pmanger = new PixfreeManager();
    pmanger->initPixfree(dataLic, length, bundelData, outputLength);
    
    napi_value st_result;
    napi_create_int32(env, 0, &st_result);
    return st_result;
}

napi_value CommonInterface::napi_streamDetectProcessAndRenderBuffer(napi_env env, napi_callback_info info) {
    glCore->drawFinish();
    napi_detectProcessAndRenderBuffer(env, info);
    napi_value funcResult;
    napi_create_int32(env, 0, &funcResult);
    return funcResult;
}


napi_value CommonInterface::ndk_destroy_PixelFree(napi_env env, napi_callback_info info) {
    delete CommonInterface::pmanger;
    if (_inputTexture || glIsTexture(_inputTexture)) {
        glDeleteTextures(1, &_inputTexture);
        _inputTexture = 0;
    }
    if (_outputTexture || glIsTexture(_outputTexture)) {
        glDeleteTextures(1, &_outputTexture);
        _outputTexture = 0;
    }

    napi_value funcResult;
    napi_create_int32(env, 0, &funcResult);
    return funcResult;
}

 napi_value CommonInterface::ndk_set_beauty_strength(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    uint32_t param = 0;
    napi_get_value_uint32(env, args[0], &param);

    double strength = 0;
    napi_get_value_double(env, args[1], &strength);

    if (pmanger) {
        pmanger->pixelFreeSetBeautyFiterParam((PFBeautyFiterType)param, strength);
    }
    napi_value st_result;
    napi_create_int32(env, 0, &st_result);
    return st_result;
    
 }

napi_value CommonInterface::ndk_set_beauty_sticker(napi_env env, napi_callback_info info){
        size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t length;
    void *dataSticker = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status status = napi_get_arraybuffer_info(env, args[0], &dataSticker, &length);
    if (status != napi_ok) {
        LOGE("napi_get_arraybuffer_info error %d", status);
    }
    
    pmanger->createBeautyItemFormBundle(dataSticker, length, PFSrcTypeStickerFile);
    
    napi_value st_result;
    napi_create_int32(env, 0, &st_result);
    return st_result;
    
        
}
napi_value CommonInterface::ndk_set_beauty_filter(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    char buf[256];
    size_t length;
    napi_status status = napi_get_value_string_utf8(env, args[0], buf, sizeof(buf), &length);
    
    double strength = 0;
    napi_get_value_double(env, args[1], &strength);

    if (pmanger) {
        pmanger->pixelFreeSetBeautyFiterNameAndValue(buf,strength);
    }
    napi_value st_result;
    napi_create_int32(env, 0, &st_result);
    return st_result;
}
napi_value CommonInterface::ndk_set_beauty_onekey_filter(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    uint32_t param = 0;
    napi_get_value_uint32(env, args[0], &param);

    if (pmanger) {
        pmanger->pixelFreeSetBeautyOnekey((PFBeautyTypeOneKey)param);
    }
    napi_value st_result;
    napi_create_int32(env, 0, &st_result);
    return st_result;
}


// napi_value CommonInterface::ndk_set_beauty_fiter_param(napi_env env, napi_callback_info info){
//     napi_value st_result;
//     napi_create_int32(env, 0, &st_result);
//     return st_result;
// }
// napi_value CommonInterface::ndk_create_beauty_item_bundle(napi_env env, napi_callback_info info){
//     napi_value st_result;
//     napi_create_int32(env, 0, &st_result);
//     return st_result;
// }


int convertAndRender(uint8_t *inputData, int width, int height, int rotate,
                     uint8_t *outputData) {
    if (_inputTexture == 0 || !glIsTexture(_inputTexture) || _lastWidth != width || _lastHeight != height) {
        if (glIsTexture(_inputTexture)) {
            glDeleteTextures(1, &_inputTexture);
        }
        glCore->createTexture(NULL, 0, width, height, GL_RGBA, &_inputTexture);
    }

    if (CommonInterface::pmanger) {
       CommonInterface::pmanger->render(PFFORMAT_IMAGE_YUV_NV21,inputData, _inputTexture, width, height); 
    }

    _outputTexture = _inputTexture;
    return 0;
}

int renderRgbaTexture(uint8_t *inputData, int width, int height, int rotate,
                      uint8_t *outputData) {
    if (!glIsTexture(_outputTexture)) {
        _lastWidth = width;
        _lastHeight = height;
        glCore->createTexture(NULL, 0, _lastWidth, _lastHeight, GL_RGBA, &_outputTexture);
    }
    if (_lastWidth != width || _lastHeight != height) {
        _lastWidth = width;
        _lastHeight = height;
        if (glIsTexture(_outputTexture))
            glDeleteTextures(1, &_outputTexture);
        glCore->createTexture(NULL, 0, _lastWidth, _lastHeight, GL_RGBA, &_outputTexture);
    }
   
    return 0;
}


void solvePadding(void *inputData, int oldWidth, int newWidth, int bitPerPixel, int height, uint8_t *outputData) {
    if (inputData == nullptr || oldWidth <= 0 || newWidth <= 0 || height <= 0 || outputData == nullptr) {
        return;
    }
    memset(outputData, 0, newWidth * height);
    for (int i = 0; i < height; i++) {
        memcpy(outputData + i * newWidth * bitPerPixel, (uint8_t *)inputData + i * oldWidth * bitPerPixel,
               sizeof(uint8_t) * newWidth * bitPerPixel);
    }
}


void  CommonInterface::napi_detectProcessAndRenderBuffer(napi_env env, napi_callback_info info) {
    size_t argc = 10;
    napi_value args[10] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t inputBufferLength;
    void *inputBuffer = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    napi_status status = napi_get_arraybuffer_info(env, args[0], &inputBuffer, &inputBufferLength);
    if (status != napi_ok) {
        LOGD("napi_get_arraybuffer_info error is: %d ", status);
    }

    int32_t format = 0;
    napi_get_value_int32(env, args[1], &format);
    int32_t curFormat = format == 0 ? 6 : format;

    int32_t inputWidth = 0;
    napi_get_value_int32(env, args[2], &inputWidth);

    int32_t inputHeight = 0;
    napi_get_value_int32(env, args[3], &inputHeight);

    int stride = 0;
    napi_get_value_int32(env, args[4], &stride);

    int rotate = 0;
    napi_get_value_int32(env, args[5], &rotate);

    int mirror = 0;
    napi_get_value_int32(env, args[6], &mirror);

    size_t outLength;
    void *outData = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    status = napi_get_arraybuffer_info(env, args[7], &outData, &outLength);
    if (status != napi_ok) {
        LOGD("napi_get_arraybuffer_info  error: %d ", status);
    }

    bool isRecording = false;
    napi_get_value_bool(env, args[9], &isRecording);
    
    glCore->SetCurrentContext();

    int width = inputWidth;
    int height = inputHeight;
    bool needPadding = false;
    if (stride != height) {
        needPadding = true;
        height = stride;
    }
    
    if (format == 0) { // rgba
        if (needPadding) {
            int newSize = width * height * 4;
            uint8_t *data = new uint8_t[newSize];
            solvePadding(inputBuffer, inputWidth, width, 4, height, data);

            renderRgbaTexture(data, width, height, rotate, (uint8_t *)outData);
            delete[] data;
        } else {
            renderRgbaTexture((uint8_t *)inputBuffer, width, height, rotate,  (uint8_t *)outData);
        }
    } else { // nv21
        if (needPadding) {
            int ySize = inputWidth * inputHeight;
            int uvSize = ySize / 2;
            uint8_t *y_buf = new uint8_t[ySize];
            uint8_t *uv_buf = new uint8_t[uvSize];
            memcpy(y_buf, inputBuffer, ySize);
            memcpy(uv_buf, (uint8_t *)inputBuffer + ySize, uvSize);

            // new data
            int newYSize = width * height;
            int newUVSize = newYSize / 2;
            uint8_t *fullData = new uint8_t[newYSize * 3 / 2];
            uint8_t *yData = new uint8_t[newYSize];
            uint8_t *uvData = new uint8_t[newUVSize];

            solvePadding(y_buf, inputWidth, width, 1, height, yData);
            solvePadding(uv_buf, inputWidth, width, 1, height / 2, uvData);
            memcpy(fullData, yData, newYSize);
            memcpy(fullData + newYSize, uvData, newUVSize);
            convertAndRender(fullData, width, height, rotate, (uint8_t *)outData);

            delete[] y_buf;
            delete[] uv_buf;
            delete[] fullData;
            delete[] yData;
            delete[] uvData;
        } else {
            convertAndRender((uint8_t *)inputBuffer, width, height, rotate,  (uint8_t *)outData);
        }
    }
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glCore->Draw(_outputTexture, 0, width * height << 2, width, height, rotate, mirror, isRecording);

    if (isRecording) glCore->getOutData(outData, 0, width, height);
}


