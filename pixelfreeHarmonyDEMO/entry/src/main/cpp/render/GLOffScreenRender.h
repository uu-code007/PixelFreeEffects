//
// Created on 2024/4/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLOFFSCREENRENDER_H
#define EFFECTSHARMONY_GLOFFSCREENRENDER_H

#include "render/GLBaseModel.h"

namespace GLContextManager {
class GLOffScreenRender : public GLBaseModel{
    public:
        GLOffScreenRender(string& name);
        GLOffScreenRender(string& name, int width, int height);
        ~GLOffScreenRender();
        void Draw();
        void Draw(int width, int height);
        GLuint Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels);
        void Draw(GLuint inTex, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels);
        void DownloadPixeData(GLuint inTex, int width, int height);
        void getOutData(void* outdata, int width, int height);
        void PreparedLoad();
        GLuint getOffScreenTexture();
    private:
        GLProgram *CreateProgram(string &vertexShader, string &fragmentShader);
        bool CreateFrameBuffer();
        void ReleaseResource();
        GLuint m_VaoIds[1]{}; // Vertex Array Buffer(vertexs coordinates indexs)
        GLuint m_VboIds[3]{}; // 顶点坐标、纹理坐标、顶点索引
        GLuint m_FboId{};
        GLuint m_fboTextureId{};
        GLuint m_textureId{};
        GLuint m_Sampler{};
        GLuint m_rotate{};
        GLuint m_mirror{};
        int lastRotate;
};
}
#endif //EFFECTSHARMONY_GLOFFSCREENRENDER_H
