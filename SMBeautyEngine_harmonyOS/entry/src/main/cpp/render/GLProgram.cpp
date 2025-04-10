//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLProgram.h"
#include "log.h"
#include "../common/common.h"
#include <sys/stat.h>

static const char* TAG = "GLProgram";

namespace GLContextManager{
GLProgram::GLProgram(string &vs, string &fs):m_vs(vs),m_fs(fs){
    
}
GLProgram::~GLProgram() { 
    if(m_glProgram) glDeleteProgram(m_glProgram); 
}

GLuint GLProgram::InitProgram(){
    if (this->m_vs.length() <= 0 || this->m_fs.length() <= 0) {
        LOGE(TAG,"createProgram: vertexShader or fragShader is null");
        return PROGRAM_ERROR;
    }
    GLuint vertex = LoadShader(GL_VERTEX_SHADER, m_vs.c_str());
    if (vertex == PROGRAM_ERROR) {
        LOGE(TAG,"createProgram vertex error");
        return PROGRAM_ERROR;
    }
    GLuint fragment = LoadShader(GL_FRAGMENT_SHADER, m_fs.c_str());
    if (fragment == PROGRAM_ERROR) {
        LOGE(TAG,"createProgram fragment error");
        return PROGRAM_ERROR;
    }
    GLuint program = glCreateProgram();
    if (program == PROGRAM_ERROR) {
        LOGE(TAG,"createProgram program error");
        glDeleteShader(vertex);
        glDeleteShader(fragment);
        return PROGRAM_ERROR;
    }
    m_glProgram = program;
    // The gl function has no return value.
    glAttachShader(program, vertex);
    glAttachShader(program, fragment);
    glLinkProgram(program);

    GLint linked;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (linked != 0) {
        glDeleteShader(vertex);
        glDeleteShader(fragment);
        return program;
    }

    GLint infoLen = 0;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
    if (infoLen > 1) {
        char *infoLog = (char *)malloc(sizeof(char) * (infoLen + 1));
        memset(infoLog, 0, infoLen + 1);
        glGetProgramInfoLog(program, infoLen, nullptr, infoLog);
        LOGE(TAG,"glLinkProgram error = %s", infoLog);
        free(infoLog);
        infoLog = nullptr;
    }
    glDeleteShader(vertex);
    glDeleteShader(fragment);
    glDeleteProgram(program);
    return PROGRAM_ERROR;
}

GLuint GLProgram::LoadShader(GLenum type, const char* shaderSrc){
    if ((type <= 0) || (shaderSrc == nullptr)) {
        LOGE(TAG,"glCreateShader type or shaderSrc error");
        return PROGRAM_ERROR;
    }

    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        LOGE(TAG,"glCreateShader unable to load shader");
        return PROGRAM_ERROR;
    }

    // The gl function has no return value.
    glShaderSource(shader, 1, &shaderSrc, nullptr);
    glCompileShader(shader);

    GLint compiled;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (compiled != 0) {
        return shader;
    }

    GLint infoLen = 0;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
    if (infoLen <= 1) {
        glDeleteShader(shader);
        return PROGRAM_ERROR;
    }

    char *infoLog = (char *)malloc(sizeof(char) * (infoLen + 1));
    if (infoLog != nullptr) {
        memset(infoLog, 0, infoLen + 1);
        glGetShaderInfoLog(shader, infoLen, nullptr, infoLog);
        LOGE(TAG,"glCompileShader error = %{public}s", infoLog);
        free(infoLog);
        infoLog = nullptr;
    }
    glDeleteShader(shader);
    return PROGRAM_ERROR;
}

GLuint GLProgram::UseProgram(){
    if (m_glProgram <= 0) {
        LOGE(TAG,"There is no glProgram");
        return PROGRAM_ERROR;
    }
    glUseProgram(m_glProgram);
    return OK;
}

GLuint GLProgram::GetAttribute(string attribtue){
    if (m_glProgram <= 0) {
        LOGE(TAG,"There is no glProgram");
        return PROGRAM_ERROR;
    }
    return glGetAttribLocation(m_glProgram, attribtue.c_str());
}

GLuint GLProgram::GetUniform(string uniform){
    if (m_glProgram <= 0) {
        LOGE(TAG,"There is no glProgram");
        return PROGRAM_ERROR;
    }
    return glGetUniformLocation(m_glProgram, uniform.c_str());
}

GLuint GLProgram::GetProgram(){
    return m_glProgram;
}
};