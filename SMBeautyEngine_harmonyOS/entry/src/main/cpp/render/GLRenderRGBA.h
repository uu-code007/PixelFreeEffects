//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLSQUARE_H
#define EFFECTSHARMONY_GLSQUARE_H
#include "GLBaseModel.h"
#include "GLOffScreenRender.h"

namespace GLContextManager {
class GLRenderRGBA : public GLBaseModel{
    public:
        GLRenderRGBA(string& name);
        GLRenderRGBA(string& name, int width, int height);
        ~GLRenderRGBA();
        void Draw();
        void Draw(int width, int height);
        GLuint Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels);
        void Draw(GLuint inTex, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels);
        void SimpleDraw(uint8_t* pixelData, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels);
        void SimpleDraw(GLuint inTex, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels);
        void getOutData(void* outdata, int width, int height);
        void PreparedLoad();
    protected:
        GLProgram *CreateProgram(string &vertexShader, string &fragmentShader);
        void ReleaseResource();
        GLuint m_VaoIds[1]{}; // Vertex Array Buffer(vertexs coordinates indexs)
        GLuint m_VboIds[3]{}; // 顶点坐标、纹理坐标、顶点索引
    private:
        void normalRender(GLuint textrue, int rotate, bool mirror);
        GLuint m_textureId{};
        GLuint m_Sampler{};
        GLuint m_rotate{};
        GLuint m_mirror{};
        int lastRotate{};
        GLOffScreenRender *m_osRender{};
};
}
#endif //EFFECTSHARMONY_GLSQUARE_H
