//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLCore.h"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <EGL/eglplatform.h>
#include "log.h"
#include <EGL/eglplatform.h>
#include "../common/common.h"

static const char *TAG = "GLCore";
namespace GLContextManager {

GLCore::~GLCore(){
    LOGD(TAG,"GLCore disContructor");
    if (m_render) {
        delete m_render;
        m_render = nullptr;
    }
    if(m_nv21Render){
        delete m_nv21Render;
        m_nv21Render = nullptr;
    }
    if(m_pointsRender){
        delete m_pointsRender;
        m_pointsRender = nullptr;
    }
}

//初始化EAGLContext
bool GLCore::EglContextInit(void *window, int width, int height){
    LOGI(TAG,"EglContextInit");
    if ((window == nullptr) || (width <= 0) || (height <= 0)) {
        LOGE(TAG,"EglContextInit: param error");
        return false;
    }
    
    m_eglWindow = static_cast<EGLNativeWindowType>(window);

    // Init display.
    m_eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (m_eglDisplay == EGL_NO_DISPLAY) {
        LOGE(TAG,"eglGetDisplay: unable to get EGL display");
        return false;
    }

    EGLint majorVersion;
    EGLint minorVersion;
    if (!eglInitialize(m_eglDisplay, &majorVersion, &minorVersion)) {
        LOGE(TAG,"eglInitialize: unable to get initialize EGL display");
        return false;
    }

    // Select configuration.
    const EGLint maxConfigSize = 1;
    EGLint numConfigs;
    if (!eglChooseConfig(m_eglDisplay, ATTRIB_LIST, &m_eglConfig, maxConfigSize, &numConfigs)) {
        LOGE(TAG,"eglChooseConfig: unable to choose configs");
        return false;
    }

    return CreateEnvironment(width, height);
}

bool GLCore::CreateEnvironment(int width, int height){
    LOGI(TAG,"CreateEnvironment");
    // Create surface.
    if (m_eglWindow == nullptr) {
        LOGE(TAG,"eglWindow_ is null");
        return false;
    }
    m_eglSurface = eglCreateWindowSurface(m_eglDisplay, m_eglConfig, m_eglWindow, NULL);
    if (m_eglSurface == nullptr) {
        LOGE(TAG,"eglCreateWindowSurface: unable to create surface");
        return false;
    }
    // Create context.
    m_eglContext = eglCreateContext(m_eglDisplay, m_eglConfig, EGL_NO_CONTEXT, CONTEXT_ATTRIBS);
    if (!eglMakeCurrent(m_eglDisplay, m_eglSurface, m_eglSurface, m_eglContext)) {
        LOGE(TAG,"eglMakeCurrent failed");
        return false;
    }
    //这里可以添加需要 render Object
    string name = "Square";
    m_render = new GLRenderRGBA(name, width, height);
    m_render->PreparedLoad();
    string nv21Name = "nv21Name";
    m_nv21Render = new GLRenderNV21(nv21Name, width, height);
    m_nv21Render->PreparedLoad();
    string pointsRender = "pointsRender";
    m_pointsRender = new GLDrawPoints(pointsRender, width, height);
    m_pointsRender->PreparedLoad();
    
    
    return true;
}

void GLCore::Release(){
    if ((m_eglDisplay == nullptr) || (m_eglSurface == nullptr) ||
        (!eglDestroySurface(m_eglDisplay, m_eglSurface))) {
        LOGE(TAG,"Release eglDestroySurface failed");
    }

    if ((m_eglDisplay == nullptr) || (m_eglContext == nullptr) ||
        (!eglDestroyContext(m_eglDisplay, m_eglContext))) {
        LOGE(TAG,"Release eglDestroyContext failed");
    }

    if ((m_eglDisplay == nullptr) || (!eglTerminate(m_eglDisplay))) {
        LOGE(TAG,"Release eglTerminate failed");
    }
}

void GLCore::Draw(){
    
}

void GLCore::Draw(int width, int height){
    
}

void GLCore::Draw(uint8_t *data, int type, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels){
    m_curRender = type == RGBA ? m_render : m_nv21Render; 
    if (m_curRender == nullptr) {
        LOGI(TAG,"GLCore::Draw");
        return;
    }
    m_curRender->Draw(data, dataSize, width, height, rotate, mirror, needDownloadPixels);
}

void GLCore::Draw(GLuint inTex,  int type, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels) {
    m_curRender = type == RGBA ? m_render : m_nv21Render;
    if (m_curRender == nullptr) {
        LOGI(TAG, "GLCore::Draw");
        return;
    }
    m_curRender->Draw(inTex, dataSize, width, height, rotate, mirror, needDownloadPixels);
}

void GLCore::SimpleDraw(uint8_t* pixelData,  int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels){
    GLRenderRGBA *rgbRender = (GLRenderRGBA*)m_render;
    rgbRender->SimpleDraw(pixelData, pixelWidth, pixelHeight, rotate, mirror, needDownloadPixels);
}

void GLCore::SimpleDraw(GLuint inTex, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels){
    GLRenderRGBA *rgbRender = (GLRenderRGBA*)m_render;
    rgbRender->SimpleDraw(inTex, pixelWidth, pixelHeight, rotate, mirror, needDownloadPixels);
}

void GLCore::DrawPoints(int width, int height, float *points, int pointCount){
    m_pointsRender->Draw(width, height, points, pointCount);
}

void GLCore::drawFinish(){
    glFlush();
    eglSwapBuffers(m_eglDisplay, m_eglSurface);
}

void GLCore::getOutData(void* data, int type, int width, int height){
    m_curRender = type == RGBA ? m_render : m_nv21Render;
    if (m_curRender == nullptr || data == nullptr) {
        LOGI(TAG, "getOutData error");
        return;
    }
    m_curRender->getOutData(data, width, height);
}

void GLCore::UpdateSize(int width, int height){
    if(m_render != nullptr){
        m_render->ChangeScreenSize(width, height);
    }
    if (m_nv21Render != nullptr) {
        m_nv21Render->ChangeScreenSize(width, height);
    }
    if (m_pointsRender != nullptr) {
        m_pointsRender->ChangeScreenSize(width, height);
    }
}

EGLContext GLCore::GetCurrentContext(){
    return m_eglContext;
}

bool GLCore::SetCurrentContext(){
    if (!eglMakeCurrent(m_eglDisplay, m_eglSurface, m_eglSurface, m_eglContext)) {
        LOGE(TAG, "eglMakeCurrent failed");
        return false;
    }
    return true;
}

void GLCore::createTexture(unsigned char *data, int length, int width, int height, int type, GLuint* texId){
    if (width <= 0 || height <=  0) {
        return;
    }
    GLBaseModel::CreateTexture(data, width, height, type, texId);
}

void GLCore::updateTextrue(unsigned char *data, int width, int height, int type, GLuint texId) {
    if (width <= 0 || height <= 0) {
        return;
    }
    GLBaseModel::UpdateTexture(data, 0, 0, width, height, texId);
}
}