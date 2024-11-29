//
// Created on 2024/3/8.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLRENDERYUV_H
#define EFFECTSHARMONY_GLRENDERYUV_H

#include "GLRenderRGBA.h"

namespace GLContextManager{

class GLRenderYUV : public GLContextManager::GLRenderRGBA {
    public:
        GLRenderYUV(string& name);
        GLRenderYUV(string& name, int width, int height);
        ~GLRenderYUV();
        GLuint Draw(uint8_t *pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate);
        void getOutData(void *outdata, int width, int height) {}
        void PreparedLoad();
    protected:
        GLProgram *CreateProgram(string &vertexShader, string &fragmentShader);
        void ReleaseResource();
        void SurfaceDraw();
    private:
        bool ReadYuvFile(int width, int height);
        GLuint m_YUV[3]{};
        unsigned char* m_buf[3]{};
        GLuint m_YUVUniform[3]{};
};
}


#endif //EFFECTSHARMONY_GLRENDERYUV_H
