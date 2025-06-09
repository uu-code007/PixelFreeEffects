#include "opengl.h"
#include <iostream>

namespace pixelfree {

OpenGL::OpenGL(int width, int height, const char* vertex_shader, const char* fragment_shader)
    : width_(width), height_(height), program_(0) {
    CreateProgram(vertex_shader, fragment_shader);
}

OpenGL::~OpenGL() {
    if (program_ != 0) {
        glDeleteProgram(program_);
    }
}

void OpenGL::ProcessImage(GLuint texture_id) {
    static const GLfloat vertex_coordinate[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f, 1.0f,
        1.0f, 1.0f
    };
    
    static const GLfloat texture_coordinate[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f
    };
    
    ProcessImage(texture_id, vertex_coordinate, texture_coordinate);
}

void OpenGL::ProcessImage(GLuint texture_id, const GLfloat* vertex_coordinate, const GLfloat* texture_coordinate) {
    glUseProgram(program_);
    glViewport(0, 0, width_, height_);
    glClearColor(0.0F, 0.0F, 0.0F, 1.0F);
    glClear(GL_COLOR_BUFFER_BIT);
    
    RunOnDrawTasks();
    
    GLint position_location = glGetAttribLocation(program_, "position");
    GLint texture_coordinate_location = glGetAttribLocation(program_, "inputTextureCoordinate");
    GLint texture_location = glGetUniformLocation(program_, "inputImageTexture");
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture_id);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glUniform1i(texture_location, 0);
    
    glVertexAttribPointer(position_location, 2, GL_FLOAT, false, 0, vertex_coordinate);
    glEnableVertexAttribArray(position_location);
    glVertexAttribPointer(texture_coordinate_location, 2, GL_FLOAT, false, 0, texture_coordinate);
    glEnableVertexAttribArray(texture_coordinate_location);
    
    OnDrawArrays();
    
    glDisableVertexAttribArray(position_location);
    glDisableVertexAttribArray(texture_coordinate_location);
    glBindTexture(GL_TEXTURE_2D, 0);
    glUseProgram(0);
}

void OpenGL::ProcessImage(GLuint texture_id, const GLfloat* vertex_coordinate, const GLfloat* texture_coordinate, GLfloat* texture_matrix) {
    glUseProgram(program_);
    glViewport(0, 0, width_, height_);
    glClearColor(0.0F, 0.0F, 0.0F, 1.0F);
    glClear(GL_COLOR_BUFFER_BIT);
    
    RunOnDrawTasks();
    
    GLint position_location = glGetAttribLocation(program_, "position");
    GLint texture_coordinate_location = glGetAttribLocation(program_, "inputTextureCoordinate");
    GLint texture_location = glGetUniformLocation(program_, "inputImageTexture");
    GLint texture_matrix_location = glGetUniformLocation(program_, "textureMatrix");
    
    if (texture_matrix_location != -1) {
        glUniformMatrix4fv(texture_matrix_location, 1, false, texture_matrix);
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture_id);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glUniform1i(texture_location, 0);
    
    glVertexAttribPointer(position_location, 2, GL_FLOAT, false, 0, vertex_coordinate);
    glEnableVertexAttribArray(position_location);
    glVertexAttribPointer(texture_coordinate_location, 2, GL_FLOAT, false, 0, texture_coordinate);
    glEnableVertexAttribArray(texture_coordinate_location);
    
    OnDrawArrays();
    
    glDisableVertexAttribArray(position_location);
    glDisableVertexAttribArray(texture_coordinate_location);
    glBindTexture(GL_TEXTURE_2D, 0);
    glUseProgram(0);
}

void OpenGL::SetInt(const char* name, int value) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniform1i(location, value);
    glUseProgram(0);
}

void OpenGL::SetFloat(const char* name, float value) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniform1f(location, value);
    glUseProgram(0);
}

void OpenGL::SetFloatArray(const char* name, const float* value, int count) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniform1fv(location, count, value);
    glUseProgram(0);
}

void OpenGL::SetMatrix(const char* name, const float* value) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniformMatrix4fv(location, 1, false, value);
    glUseProgram(0);
}

void OpenGL::ActiveProgram() {
    glUseProgram(program_);
}

void OpenGL::CreateProgram(const char* vertex, const char* fragment) {
    if (program_ != 0) {
        glDeleteProgram(program_);
    }
    program_ = glCreateProgram();
    GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER);
    GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
    CompileShader(vertex, vertex_shader);
    CompileShader(fragment, fragment_shader);
    glAttachShader(program_, vertex_shader);
    glAttachShader(program_, fragment_shader);
    Link();
    glDeleteShader(vertex_shader);
    glDeleteShader(fragment_shader);
}

void OpenGL::CompileShader(const char* shader_string, GLuint shader) {
    glShaderSource(shader, 1, &shader_string, nullptr);
    glCompileShader(shader);
    GLint compile_status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compile_status);
    if (compile_status != GL_TRUE) {
        GLint info_length;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &info_length);
        if (info_length > 1) {
            GLchar* info_log = new GLchar[info_length];
            glGetShaderInfoLog(shader, info_length, nullptr, info_log);
            std::cout << "Error compiling shader:" << info_log << std::endl;
            delete[] info_log;
        }
        glDeleteShader(shader);
    }
}

void OpenGL::Link() {
    glLinkProgram(program_);
    GLint link_status;
    glGetProgramiv(program_, GL_LINK_STATUS, &link_status);
    if (link_status != GL_TRUE) {
        GLint buf_length;
        glGetProgramiv(program_, GL_INFO_LOG_LENGTH, &buf_length);
        if (buf_length > 1) {
            GLchar* info_log = new GLchar[buf_length];
            glGetProgramInfoLog(program_, buf_length, nullptr, info_log);
            std::cout << "Error link program:" << info_log << std::endl;
            delete[] info_log;
        }
        glDeleteProgram(program_);
        program_ = 0;
    }
}

void OpenGL::RunOnDrawTasks() {
    // 子类可以重写此方法
}

void OpenGL::OnDrawArrays() {
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

} // namespace pixelfree 