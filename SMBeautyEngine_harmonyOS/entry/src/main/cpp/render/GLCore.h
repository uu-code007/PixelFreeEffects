//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLCORE_H
#define EFFECTSHARMONY_GLCORE_H

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <string>
#include "GLRenderYUV.h"
#include "GLRenderYUYV.h"
#include "GLRenderNV21.h"
#include "render/GLDrawPoints.h"

using namespace std;

namespace GLContextManager {

typedef enum PixelForamt{
    RGBA = 0,
    NV21,
}PixelForamt;

class GLCore {
    public:
        explicit GLCore(string& id) {this->m_id = id;}
        ~GLCore();
        bool EglContextInit(void* window, int width, int height);
        void Release();
        void Draw();
        void Draw(int width, int height);
        void Draw(uint8_t* data, int type, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels);
        void Draw(GLuint inTex,  int type, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels);
        void SimpleDraw(uint8_t* pixelData, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels);
        void SimpleDraw(GLuint inTex, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels);
        void DrawPoints(int width, int height, float* points, int pointCount);
        void getOutData(void* data, int type, int width, int height);
        void UpdateSize(int width, int height);
        EGLContext GetCurrentContext();
        bool SetCurrentContext();
        void createTexture(unsigned char* data, int length, int width, int height, int type, GLuint *texId);
        void updateTextrue(unsigned char *data, int width, int height, int type, GLuint texId);
        void drawFinish();
    private:
        bool CreateEnvironment(int width, int height);
        string m_id;
        EGLNativeWindowType m_eglWindow;
        EGLDisplay m_eglDisplay = EGL_NO_DISPLAY;
        EGLConfig m_eglConfig = EGL_NO_CONFIG_KHR;
        EGLSurface m_eglSurface = EGL_NO_SURFACE;
        EGLContext m_eglContext = EGL_NO_CONTEXT;
        GLBaseModel* m_curRender{};
        GLBaseModel* m_render{};
        GLBaseModel* m_nv21Render{};
        GLDrawPoints* m_pointsRender{};
};
}

#endif //EFFECTSHARMONY_GLCORE_H
