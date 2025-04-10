//
// Created on 2024/6/17.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLDRAWPOINTS_H
#define EFFECTSHARMONY_GLDRAWPOINTS_H

#include "GLBaseModel.h"

namespace GLContextManager {
class GLDrawPoints{
    public:
        GLDrawPoints(string& name);
        GLDrawPoints(string& name, int width, int height);
        ~GLDrawPoints();
        void Draw(int width, int height, float*points, int pointCount);
        void PreparedLoad();
        void ChangeScreenSize(int width, int height);
    protected:
        GLProgram *CreateProgram(string &vertexShader, string &fragmentShader);
        void ReleaseResource();
    private:
        string &m_name;
        GLProgram *m_program{};
        GLuint m_windowWidth{};
        GLuint m_windowHeight{};
};
} // namespace GLContextManager


#endif //EFFECTSHARMONY_GLDRAWPOINTS_H
