//
// Created on 2024/3/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLRENDERNV21_H
#define EFFECTSHARMONY_GLRENDERNV21_H
#include "GLRenderRGBA.h"

namespace GLContextManager {

class GLRenderNV21 : public GLBaseModel {
public:
    GLRenderNV21(string &name);
    GLRenderNV21(string &name, int width, int height);
    ~GLRenderNV21();
    void Draw();
    void Draw(int width, int height);
    GLuint Draw(uint8_t *pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels);
    void Draw(GLuint inTex, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels);
    void getOutData(void *outdata, int width, int height) {}
    void PreparedLoad();
protected:
    GLProgram *CreateProgram(string &vertexShader, string &fragmentShader);
    void ReleaseResource();
private:
    GLuint m_VaoIds[1]{}; // Vertex Array Buffer(vertexs coordinates indexs)
    GLuint m_VboIds[3]{}; // 顶点坐标、纹理坐标、顶点索引
    GLuint m_YUV[2]{};
    unsigned char *m_buf[2]{};
    GLuint m_YUVUniform[2]{};
    GLuint m_mirror{};
    int lastRotate;
};

} 
#endif //EFFECTSHARMONY_GLRENDERNV21_H
