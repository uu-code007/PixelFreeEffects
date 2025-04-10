//
// Created on 2024/3/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLRENDERYUYV_H
#define EFFECTSHARMONY_GLRENDERYUYV_H

#include "GLRenderRGBA.h"

namespace GLContextManager {

class GLRenderYUYV : public GLRenderRGBA {
public:
    GLRenderYUYV(string &name);
    GLRenderYUYV(string &name, int width, int height);
    ~GLRenderYUYV();
    GLuint Draw(uint8_t *pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate);
    void getOutData(void *outdata, int width, int height){}
    void PreparedLoad();
protected:
    GLProgram *CreateProgram(string &vertexShader, string &fragmentShader);
    void ReleaseResource();
    void SurfaceDraw();
private:
    GLuint m_YUYV{};
    GLuint m_Sampler{};
    GLuint m_vec[3]{};
    GLuint m_min{};
    GLuint m_max{};
    GLuint m_YUYV_width{};
    unsigned char* m_buf{};
};
} // namespace GLContextManager

#endif //EFFECTSHARMONY_GLRENDERYUYV_H
