#include "opengl.h"
#include <iostream>

namespace pixelfree {

OpenGL::OpenGL()
    : gl_observer_(nullptr),
      type_(TEXTURE_2D),
      program_(0),
      width_(0),
      height_(0),
      default_vertex_coordinates_(nullptr),
      default_texture_coordinates_(nullptr) {
    InitCoordinates();
}

OpenGL::OpenGL(int width, int height)
    : gl_observer_(nullptr),
      type_(TEXTURE_2D),
      program_(0),
      width_(width),
      height_(height),
      default_vertex_coordinates_(nullptr),
      default_texture_coordinates_(nullptr) {
    InitCoordinates();
}

OpenGL::OpenGL(const char* vertex, const char* fragment)
    : gl_observer_(nullptr),
      type_(TEXTURE_2D),
      program_(0),
      width_(0),
      height_(0),
      default_vertex_coordinates_(nullptr),
      default_texture_coordinates_(nullptr) {
    InitCoordinates();
    Init(vertex, fragment);
}

OpenGL::OpenGL(int width, int height, const char* vertex, const char* fragment)
    : gl_observer_(nullptr),
      type_(TEXTURE_2D),
      program_(0),
      width_(width),
      height_(height),
      default_vertex_coordinates_(nullptr),
      default_texture_coordinates_(nullptr) {
    InitCoordinates();
    Init(vertex, fragment);
}

OpenGL::~OpenGL() {
    if (default_vertex_coordinates_ != nullptr) {
        delete[] default_vertex_coordinates_;
        default_vertex_coordinates_ = nullptr;
    }
    if (default_texture_coordinates_ != nullptr) {
        delete[] default_texture_coordinates_;
        default_texture_coordinates_ = nullptr;
    }
    if (program_ != 0) {
        glDeleteProgram(program_);
        program_ = 0;
    }
}

void OpenGL::InitCoordinates() {
    if (default_vertex_coordinates_ == nullptr) {
        default_vertex_coordinates_ = new GLfloat[8];
    }
    default_vertex_coordinates_[0] = -1.0F;
    default_vertex_coordinates_[1] = -1.0F;
    default_vertex_coordinates_[2] = 1.0F;
    default_vertex_coordinates_[3] = -1.0F;
    default_vertex_coordinates_[4] = -1.0F;
    default_vertex_coordinates_[5] = 1.0F;
    default_vertex_coordinates_[6] = 1.0F;
    default_vertex_coordinates_[7] = 1.0F;

    if (default_texture_coordinates_ == nullptr) {
        default_texture_coordinates_ = new GLfloat[8];
    }
    default_texture_coordinates_[0] = 0.0F;
    default_texture_coordinates_[1] = 0.0F;
    default_texture_coordinates_[2] = 1.0F;
    default_texture_coordinates_[3] = 0.0F;
    default_texture_coordinates_[4] = 0.0F;
    default_texture_coordinates_[5] = 1.0F;
    default_texture_coordinates_[6] = 1.0F;
    default_texture_coordinates_[7] = 1.0F;
}

void OpenGL::SetOnGLObserver(OnGLObserver* observer) {
    gl_observer_ = observer;
}

void OpenGL::SetTextureType(TextureType type) {
    type_ = type;
}

void OpenGL::Init(const char* vertex, const char* fragment) {
    CreateProgram(vertex, fragment);
}

void OpenGL::SetFrame(int source_width, int source_height, int target_width, int target_height, RenderFrame frame_type) {
    float target_ratio = target_width * 1.0F / target_height;
    float scale_width = 1.0F;
    float scale_height = 1.0F;
    if (frame_type == FIT) {
        float source_ratio = source_width * 1.0F / source_height;
        if (source_ratio > target_ratio) {
            scale_height = target_ratio / source_ratio;
        } else {
            scale_width = source_ratio / target_ratio;
        }
    } else if (frame_type == CROP) {
        float source_ratio = source_width * 1.0F / source_height;
        if (source_ratio > target_ratio) {
            scale_width = source_ratio / target_ratio;
        } else {
            scale_height = target_ratio / source_ratio;
        }
    }
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
    width_ = width;
    height_ = height;
}

void OpenGL::ActiveProgram() {
    glUseProgram(program_);
}

void OpenGL::ProcessImage(GLuint texture_id) {
    ProcessImage(texture_id, default_vertex_coordinates_, default_texture_coordinates_);
}

void OpenGL::ProcessImage(GLuint texture_id, GLfloat* texture_matrix) {
    ProcessImage(texture_id, default_vertex_coordinates_, default_texture_coordinates_, texture_matrix);
}

void OpenGL::ProcessImage(GLuint texture_id, const GLfloat* vertex_coordinate, const GLfloat* texture_coordinate) {
    glUseProgram(program_);
    glViewport(0, 0, width_, height_);
    glClearColor(0.0F, 0.0F, 0.0F, 1.0F);
    glClear(GL_COLOR_BUFFER_BIT);
    if (gl_observer_ != nullptr) {
        gl_observer_->OnDrawFrame();
    }
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
    if (gl_observer_ != nullptr) {
        gl_observer_->OnDrawFrame();
    }
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

void OpenGL::SetUniform4f(const char* name, float v0, float v1, float v2, float v3) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniform4f(location, v0, v1, v2, v3);
    glUseProgram(0);
}

void OpenGL::SetFloatVec2(const char* name, int size, const GLfloat* value) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniform2fv(location, size, value);
    glUseProgram(0);
}

void OpenGL::SetFloatVec3(const char* name, int size, const GLfloat* value) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniform3fv(location, size, value);
    glUseProgram(0);
}

void OpenGL::SetFloatVec4(const char* name, int size, const GLfloat* value) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniform4fv(location, size, value);
    glUseProgram(0);
}

void OpenGL::SetUniformMatrix3f(const char* name, int size, const GLfloat* matrix) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniformMatrix3fv(location, size, GL_FALSE, matrix);
    glUseProgram(0);
}

void OpenGL::SetUniformMatrix4f(const char* name, int size, const GLfloat* matrix) {
    glUseProgram(program_);
    GLint location = glGetUniformLocation(program_, name);
    glUniformMatrix4fv(location, size, GL_FALSE, matrix);
    glUseProgram(0);
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

}  // namespace pixelfree 