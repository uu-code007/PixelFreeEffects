//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLBaseModel.h"
#include "render/GLProgram.h"
#include "log.h"

static const char *TAG = "GLContextManager";

namespace GLContextManager {

GLBaseModel::GLBaseModel(string &name):m_name(name){
    
}

GLBaseModel::GLBaseModel(string& name, int width, int height):m_name(name),m_windowWidth(width),m_windowHeight(height){
    
}

GLBaseModel::~GLBaseModel(){
    LOGD(TAG, "GLBaseModel disContructor");
    if (m_program) 
        delete m_program;
   if (m_pixelBuffer != nullptr)
       delete[] m_pixelBuffer;
    ReleaseResource();
}

void GLBaseModel::UploadPixels(GLuint textureId) {
   int dataSize = m_width * m_height << 2;
   int index = m_FrameIndex % 2;
   int nextIndex = (index + 1) % 2;
   LOGE(TAG,"PBO --> texture");
   glBindTexture(GL_TEXTURE_2D, textureId);
   glBindBuffer(GL_PIXEL_UNPACK_BUFFER, m_UploadPboIds[index]);
   glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width, m_height, GL_RGBA, GL_UNSIGNED_BYTE, 0);
   glBindBuffer(GL_PIXEL_UNPACK_BUFFER, m_UploadPboIds[nextIndex]);
   glBufferData(GL_PIXEL_UNPACK_BUFFER, dataSize, nullptr, GL_STREAM_DRAW);
   GLubyte *bufPtr = (GLubyte *)glMapBufferRange(GL_PIXEL_UNPACK_BUFFER, 0, dataSize,
                                                 GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
   if (bufPtr) {
       memcpy(bufPtr, m_pixelBuffer, static_cast<size_t>(dataSize));
       glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER);
   }
   glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);
   LOGE(TAG,"PBO --> texture error %{public}d", glGetError());
}

void GLBaseModel::DownloadPixels() {
    int dataSize = m_width * m_height << 2;
    int index = m_FrameIndex % 2;
    int nextIndex = (index + 1) % 2;
    glBindBuffer(GL_PIXEL_PACK_BUFFER, m_UploadPboIds[index]);
    glReadPixels(0, 0, m_width, m_height, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
    glBindBuffer(GL_PIXEL_PACK_BUFFER, m_UploadPboIds[nextIndex]);
    GLubyte *bufPtr = static_cast<GLubyte *>(glMapBufferRange(GL_PIXEL_PACK_BUFFER, 0, dataSize, GL_MAP_READ_BIT));
    if (bufPtr) {
       memcpy(m_pixelBuffer, bufPtr, static_cast<size_t>(dataSize));
       glUnmapBuffer(GL_PIXEL_PACK_BUFFER);
    }
    glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
    m_FrameIndex++;
}

void GLBaseModel::CreateTexture(uint8_t *data, int width, int height, GLenum type, GLuint *textureID){
   glGenTextures(1, textureID);
   glBindTexture(GL_TEXTURE_2D, *textureID);
   glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
   glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   glTexImage2D(GL_TEXTURE_2D, 0, type, width, height, 0, type, GL_UNSIGNED_BYTE, data);
   glBindTexture(GL_TEXTURE_2D, GL_NONE);
}

void GLBaseModel::UpdateTexture(uint8_t *data, int xoffset, int yoffset, int updateWidth, int updateHeight, GLuint textureID) {
   glBindTexture(GL_TEXTURE_2D, textureID);
   glTexSubImage2D(GL_TEXTURE_2D, 0, xoffset, yoffset, updateWidth, updateHeight, GL_RGBA, GL_UNSIGNED_BYTE, data);
   glBindTexture(GL_TEXTURE_2D, 0);
}

void GLBaseModel::CreatePBOs(int imgByteSize){
   glGenBuffers(2, m_UploadPboIds);
   // Pixel Buffer Objec 0
   glBindBuffer(GL_PIXEL_UNPACK_BUFFER, m_UploadPboIds[0]);
   glBufferData(GL_PIXEL_UNPACK_BUFFER, imgByteSize, 0, GL_STREAM_DRAW);
   glBindBuffer(GL_PIXEL_UNPACK_BUFFER, m_UploadPboIds[1]);
   glBufferData(GL_PIXEL_UNPACK_BUFFER, imgByteSize, 0, GL_STREAM_DRAW);
   glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);
   LOGE(TAG,"Create PBO-0 error %{public}d", glGetError());
   // Pixel Buffer Objec 1
   glGenBuffers(2, m_DownloadPboIds);
   glBindBuffer(GL_PIXEL_PACK_BUFFER, m_DownloadPboIds[0]);
   glBufferData(GL_PIXEL_PACK_BUFFER, imgByteSize, 0, GL_STREAM_READ);
   glBindBuffer(GL_PIXEL_PACK_BUFFER, m_DownloadPboIds[1]);
   glBufferData(GL_PIXEL_PACK_BUFFER, imgByteSize, 0, GL_STREAM_READ);
   glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
   LOGE(TAG,"Create PBO-1 error %{public}d", glGetError());
}

void GLBaseModel::ChangeScreenSize(int width, int height) {
   this->m_windowWidth = width;
   this->m_windowHeight = height;
}

void GLBaseModel::FinishDraw() {
   glFlush();
   glFinish();
}

void GLBaseModel::ReleaseResource(){
   if (m_UploadPboIds[0])
       glDeleteBuffers(2, m_UploadPboIds);
   if (m_DownloadPboIds[0])
       glDeleteBuffers(2, m_DownloadPboIds);
}


void GLBaseModel::UpdateRotate(int rotate, GLuint vbo) {
   if (rotate == 0) { // 0°
       GLfloat vTexCoors[] = {
           0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
       };
       glBindBuffer(GL_ARRAY_BUFFER, vbo);
       glBufferData(GL_ARRAY_BUFFER, sizeof(vTexCoors), vTexCoors, GL_STATIC_DRAW);
   } else if (rotate == 1) { // 90°
       GLfloat vTexCoors[] = {
           0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f,
       };
       glBindBuffer(GL_ARRAY_BUFFER, vbo);
       glBufferData(GL_ARRAY_BUFFER, sizeof(vTexCoors), vTexCoors, GL_STATIC_DRAW);
   } else if (rotate == 2) { // 180°
       GLfloat vTexCoors[] = {
           1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
       };
       glBindBuffer(GL_ARRAY_BUFFER, vbo);
       glBufferData(GL_ARRAY_BUFFER, sizeof(vTexCoors), vTexCoors, GL_STATIC_DRAW);
   } else if (rotate == 3) { // 270°
       GLfloat vTexCoors[] = {
           1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f,
       };
       glBindBuffer(GL_ARRAY_BUFFER, vbo);
       glBufferData(GL_ARRAY_BUFFER, sizeof(vTexCoors), vTexCoors, GL_STATIC_DRAW);
   } else {
       GLfloat vTexCoors[] = {
           0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
       };
       glBindBuffer(GL_ARRAY_BUFFER, vbo);
       glBufferData(GL_ARRAY_BUFFER, sizeof(vTexCoors), vTexCoors, GL_STATIC_DRAW);
   }
}
}
