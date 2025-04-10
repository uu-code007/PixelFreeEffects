//
// Created on 2024/6/17.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLDrawPoints.h"
#include "common/common.h"
#include "log.h"

static const char *TAG = "GLDrawPoints";

namespace GLContextManager {

GLDrawPoints::GLDrawPoints(string &name) : m_name(name) {}

GLDrawPoints::GLDrawPoints(string& name, int width, int height) : m_name(name), m_windowWidth(width), m_windowHeight(height) {}

GLDrawPoints::~GLDrawPoints() {
}

void GLDrawPoints::Draw(int width, int height, float *points, int pointCount){
    if (points == nullptr || pointCount <= 0 || width <= 0 || height <= 0) {
        LOGE(TAG, " error");
    }
    glViewport(0, 0, m_windowWidth, m_windowHeight);
    m_program->UseProgram();
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, points);
    glEnableVertexAttribArray(0);
    glDrawArrays(GL_POINTS, 0, pointCount);
}

GLProgram *GLDrawPoints::CreateProgram(string &vertexShader, string &fragmentShader) {
    GLProgram *program = new GLProgram(vertexShader, fragmentShader);
    return program;
}

void GLDrawPoints::PreparedLoad(){
    if (!m_program) {
        string vShaderString = string(DRAW_POINT_VERTEX_SHADER);
        string fShaderString = string(DRAW_POINT_FRAGMENT_SHADER);
        m_program = CreateProgram(vShaderString, fShaderString);
        m_program->InitProgram();
    }
}


void GLDrawPoints::ChangeScreenSize(int width, int height) {
    this->m_windowWidth = width;
    this->m_windowHeight = height;
}
}