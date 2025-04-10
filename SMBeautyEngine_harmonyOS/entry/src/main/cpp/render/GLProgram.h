//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_GLPROGRAM_H
#define EFFECTSHARMONY_GLPROGRAM_H

#include <GLES3/gl3.h>
#include <string>


using namespace std;

namespace GLContextManager {
class GLProgram {
    public:
        explicit GLProgram(string& vs, string& fs);
        ~GLProgram();
        GLuint InitProgram();
        GLuint UseProgram();
        GLuint GetAttribute(string attribtue);
        GLuint GetUniform(string uniform);
        GLuint GetProgram();
    private:
        GLuint LoadShader(GLenum type, const char* shaderSrc);
        GLuint m_glProgram{};
        string& m_vs;
        string& m_fs;
};
}


#endif //EFFECTSHARMONY_GLPROGRAM_H
