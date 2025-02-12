/*
 * Copyright (C) 2019 Trinity. All rights reserved.
 * Copyright (C) 2019 Wang LianJie <wlanjie888@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

//
// Created by wlanjie on 2019/4/13.
//
#include <string>

#if __ANDROID__
#include <malloc.h>
#include "android_xlog.h"
#elif __APPLE__
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#define LOGE(format, ...) fprintf(stdout, format, __VA_ARGS__) // NOLINT
#define LOGI(format, ...) fprintf(stdout, format, __VA_ARGS__) // NOLINT
#endif

#include "opengl.h"
#include "gl.h"

namespace pixelfree {

OpenGL::OpenGL() {
    gl_observer_ = nullptr;
    type_ = TEXTURE_2D;
    width_ = 0;
    height_ = 0;
    program_ = 0;
    default_vertex_coordinates_ = new GLfloat[8];
    default_texture_coordinates_ = new GLfloat[8];
    InitCoordinates();
    CreateProgram(DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER);
}

OpenGL::OpenGL(int width, int height) {
    gl_observer_ = nullptr;
    type_ = TEXTURE_2D;
    width_ = width;
    height_ = height;
    program_ = 0;
    default_vertex_coordinates_ = new GLfloat[8];
    default_texture_coordinates_ = new GLfloat[8];
    InitCoordinates();
    CreateProgram(DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER);
}

OpenGL::OpenGL(const char *vertex, const char *fragment) {
    gl_observer_ = nullptr;
    type_ = TEXTURE_2D;
    width_ = 0;
    height_ = 0;
    program_ = 0;
    default_vertex_coordinates_ = new GLfloat[8];
    default_texture_coordinates_ = new GLfloat[8];
    InitCoordinates();
    CreateProgram(vertex, fragment);
}

OpenGL::OpenGL(int width, int height, const char *vertex, const char *fragment) {
    gl_observer_ = nullptr;
    type_ = TEXTURE_2D;
    this->width_ = width;
    this->height_ = height;
    program_ = 0;
    default_vertex_coordinates_ = new GLfloat[8];
    default_texture_coordinates_ = new GLfloat[8];
    InitCoordinates();
    CreateProgram(vertex, fragment);
}

OpenGL::~OpenGL() {
    LOGI("enter: %s program: %d", __func__, program_);
    if (program_ != 0) {
        glDeleteProgram(program_);
        program_ = 0;
    }
    if (nullptr != default_vertex_coordinates_) {
        delete[] default_vertex_coordinates_;
        default_vertex_coordinates_ = nullptr;
    }
    if (nullptr != default_texture_coordinates_) {
        delete[] default_texture_coordinates_;
        default_texture_coordinates_ = nullptr;
    }
    LOGI("leave: %s", __func__);
}

void OpenGL::InitCoordinates() {
    default_vertex_coordinates_[0] = -1.0F;
    default_vertex_coordinates_[1] = -1.0F;
    default_vertex_coordinates_[2] = 1.0F;
    default_vertex_coordinates_[3] = -1.0F;
    default_vertex_coordinates_[4] = -1.0F;
    default_vertex_coordinates_[5] = 1.0F;
    default_vertex_coordinates_[6] = 1.0F;
    default_vertex_coordinates_[7] = 1.0F;

    default_texture_coordinates_[0] = 0.0F;
    default_texture_coordinates_[1] = 1.0F;
    default_texture_coordinates_[2] = 1.0F;
    default_texture_coordinates_[3] = 1.0F;
    default_texture_coordinates_[4] = 0.0F;
    default_texture_coordinates_[5] = 0.0F;
    default_texture_coordinates_[6] = 1.0F;
    default_texture_coordinates_[7] = 0.0F;
}
    
void OpenGL::SetOnGLObserver(OnGLObserver *observer) {
    gl_observer_ = observer;
}    

void OpenGL::SetTextureType(pixelfree::TextureType type) {
    type_ = type;
}

void OpenGL::Init(const char* vertex, const char* fragment) {
    CreateProgram(vertex, fragment);
}

void OpenGL::SetFrame(int source_width, int source_height, int target_width, int target_height, RenderFrame frame_type) {
    LOGE("SetFrame source_width: %d source_height: %d target_width: %d target_height: %d", source_width, source_height, target_width, target_height);
    float target_ratio = target_width * 1.0F / target_height;
    float scale_width = 1.0F;
    float scale_height = 1.0F;
    if (frame_type == FIT) {
        float source_ratio = source_width * 1.0F / source_height;
        if (source_ratio > target_ratio) {
            scale_width = 1.0F;
            scale_height = target_ratio / source_ratio;
        } else {
            scale_width = source_ratio / target_ratio;
            scale_height = 1.0F;
        }
    } else if (frame_type == CROP) {
        float source_ratio = source_width * 1.0F / source_height;
        if (source_ratio > target_ratio) {
            scale_width = source_ratio / target_ratio;
            scale_height = 1.0F;
        } else {
            scale_width = 1.0F;
            scale_height = target_ratio / source_ratio;
        }
    }
    LOGE("scale_width: %f scale_height: %f", scale_width, scale_height);
    default_vertex_coordinates_[0] = -scale_width;
    default_vertex_coordinates_[1] = -scale_height;
    default_vertex_coordinates_[2] = scale_width;
    default_vertex_coordinates_[3] = -scale_height;
    default_vertex_coordinates_[4] = -scale_width;
    default_vertex_coordinates_[5] = scale_height;
    default_vertex_coordinates_[6] = scale_width;
    default_vertex_coordinates_[7] = scale_height;
}

void OpenGL::SetOutput(int width, int height) {
    this->width_ = width;
    this->height_ = height;
}

void OpenGL::SetInt(const char *name, int value) {
    GLint location = glGetUniformLocation(program_, name);
    glUniform1i(location, value);
}

void OpenGL::SetFloat(const char *name, float value) {
    GLint location = glGetUniformLocation(program_, name);
    glUniform1f(location, value);
}

void OpenGL::SetUniform4f(const char *name, float v0, float v1, float v2, float v3) {
    auto location = glGetUniformLocation(program_, name);
    glUniform4f(location, v0, v1, v2, v3);
}

void OpenGL::SetFloatVec2(const char *name, int size, const GLfloat *value) {
    GLint location = glGetUniformLocation(program_, name);
    glUniform2fv(location, size, value);
}

void OpenGL::SetFloatVec3(const char *name, int size, const GLfloat *value) {
    GLint location = glGetUniformLocation(program_, name);
    glUniform3fv(location, size, value);
}

void OpenGL::SetFloatVec4(const char *name, int size, const GLfloat *value) {
    GLint location = glGetUniformLocation(program_, name);
    glUniform4fv(location, size, value);
}

void OpenGL::SetUniformMatrix3f(const char *name, int size, const GLfloat *matrix) {
    GLint location = glGetUniformLocation(program_, name);
    glUniformMatrix3fv(location, size, GL_FALSE, matrix);
}

void OpenGL::SetUniformMatrix4f(const char *name, int size, const GLfloat *matrix) {
    GLint location = glGetUniformLocation(program_, name);
    glUniformMatrix4fv(location, size, GL_FALSE, matrix);
}

void OpenGL::ActiveProgram() {
    glUseProgram(program_);
}

void OpenGL::ProcessImage(GLuint texture_id) {
    ProcessImage(texture_id, default_vertex_coordinates_, default_texture_coordinates_);
}

void OpenGL::ProcessImage(GLuint texture_id, GLfloat *texture_matrix) {
    ProcessImage(texture_id, default_vertex_coordinates_, default_texture_coordinates_, texture_matrix);
}

void OpenGL::ProcessImage(GLuint texture_id, const GLfloat *vertex_coordinate, const GLfloat *texture_coordinate) {
    float texture_matrix[4 * 4];
    memset(reinterpret_cast<void*>(texture_matrix), 0, 16*sizeof(float));
    texture_matrix[0] = texture_matrix[5] = texture_matrix[10] = texture_matrix[15] = 1.0f;
    ProcessImage(texture_id, vertex_coordinate, texture_coordinate, texture_matrix);
}

void OpenGL::ProcessImage(GLuint texture_id, const GLfloat *vertex_coordinate, const GLfloat *texture_coordinate,
                          GLfloat *texture_matrix) {
    if (program_ == 0) {
        // create program failed.
        LOGE("program error: %d", program_);
        return;
    }
    glUseProgram(program_);
    if (width_ > 0 && height_ > 0) {
        glViewport(0, 0, width_, height_);
    }
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    if (nullptr != gl_observer_) {
        gl_observer_->OnGLParams();
    }
    RunOnDrawTasks();
    auto positionAttribute = static_cast<GLuint>(glGetAttribLocation(program_, "position"));
    glEnableVertexAttribArray(positionAttribute);
    glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), vertex_coordinate);
    auto textureCoordinateAttribute = static_cast<GLuint>(glGetAttribLocation(program_, "inputTextureCoordinate"));
    glEnableVertexAttribArray(textureCoordinateAttribute);
    glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), texture_coordinate);
    SetUniformMatrix4f("textureMatrix", 1, texture_matrix);

    glActiveTexture(GL_TEXTURE0);
#if __ANDROID__
    glBindTexture(type_ == TEXTURE_OES ? GL_TEXTURE_EXTERNAL_OES : GL_TEXTURE_2D, texture_id);
#elif __APPLE__
    glBindTexture(GL_TEXTURE_2D, texture_id);
#endif
    SetInt("inputImageTexture", 0);
    if (nullptr != gl_observer_) {
        gl_observer_->OnGLArrays();
    }
    OnDrawArrays();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(positionAttribute);
    glDisableVertexAttribArray(textureCoordinateAttribute);
#if __ANDROID__
    glBindTexture(type_ == TEXTURE_OES ? GL_TEXTURE_EXTERNAL_OES : GL_TEXTURE_2D, 0);
#elif __APPLE__
    glBindTexture(GL_TEXTURE_2D, 0);
#endif
}

void OpenGL::RunOnDrawTasks() {}

void OpenGL::OnDrawArrays() {}

void OpenGL::CreateProgram(const char *vertex, const char *fragment) {
    program_ = glCreateProgram();
    auto vertexShader = glCreateShader(GL_VERTEX_SHADER);
    auto fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    CompileShader(vertex, vertexShader);
    CompileShader(fragment, fragmentShader);
    glAttachShader(program_, vertexShader);
    glAttachShader(program_, fragmentShader);
    Link();
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
}

void OpenGL::CompileShader(const char *shader_string, GLuint shader) {
    glShaderSource(shader, 1, &shader_string, nullptr);
    glCompileShader(shader);
    GLint compiled = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    LOGI("%s", shader_string);
    if (!compiled) {
        GLint infoLen;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen) {
            auto *buf = reinterpret_cast<char*>(malloc((size_t) infoLen));
            if (buf) {
                LOGE("shader_string: %s", shader_string);
                glGetShaderInfoLog(shader, infoLen, nullptr, buf);
                LOGE("Could not compile %d:\n%s\n", shader, buf);
                free(buf);
            }
            glDeleteShader(shader);
        }}
}

void OpenGL::Link() {
    glLinkProgram(program_);
    GLint linkStatus = GL_FALSE;
    glGetProgramiv(program_, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLint infoLen;
        glGetProgramiv(program_, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen) {
            auto *buf = reinterpret_cast<char*>(malloc((size_t) infoLen));
            if (buf) {
                glGetProgramInfoLog(program_, infoLen, nullptr, buf);
                printf("%s", buf);
                free(buf);
            }
            glDeleteProgram(program_);
            program_ = 0;
        }
    }
}

}  // namespace trinity
