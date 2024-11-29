//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLBASEMODEL_H
#define EFFECTSHARMONY_GLBASEMODEL_H

#include "GLProgram.h"
#include <linux/mroute.h>
#include <string>

using namespace std;

namespace GLContextManager {
class GLBaseModel {
    public:
        GLBaseModel(string& name);
        GLBaseModel(string& name, int width, int height);
        virtual ~GLBaseModel();
        virtual void Draw() = 0;
        virtual void Draw(int width, int height) = 0;
        virtual GLuint Draw(uint8_t *pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels) = 0;
        virtual void Draw(GLuint inTex, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels) = 0;
        virtual void PreparedLoad() = 0;
        virtual void getOutData(void *outdata, int width, int height) = 0;
        void ChangeScreenSize(int width, int height);
        static void CreateTexture(uint8_t *data, int width, int height, GLenum type, GLuint *textureID);
        static void UpdateTexture(uint8_t *data, int xoffset, int yoffset, int updateWidth, int updateHeight, GLuint textureID);
    protected:
        virtual GLProgram* CreateProgram(string &vertexShader, string &fragmentShader) = 0;
        void UploadPixels(GLuint textureId);
        void DownloadPixels();
        void FinishDraw();
        void CreatePBOs(int imgByteSize);
        void ReleaseResource();
        void UpdateRotate(int rotate, GLuint vbo); 
        string& m_name;
        GLProgram *m_program{};
        GLuint m_width{};
        GLuint m_height{};
        GLuint m_windowWidth{};
        GLuint m_windowHeight{};
        //PBO
        GLuint m_UploadPboIds[2]{};
        GLuint m_DownloadPboIds[2]{};
        uint8_t *m_pixelBuffer{};
        GLuint m_FrameIndex{};
};
}


#endif //EFFECTSHARMONY_GLBASEMODEL_H
