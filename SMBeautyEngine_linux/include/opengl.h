#ifndef OPENGL_H
#define OPENGL_H

#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <string>
#include <vector>
#include <functional>

namespace pixelfree {

class OpenGL {
public:
    OpenGL(int width, int height, const char* vertex_shader, const char* fragment_shader);
    ~OpenGL();

    void ProcessImage(GLuint texture_id);
    void ProcessImage(GLuint texture_id, const GLfloat* vertex_coordinate, const GLfloat* texture_coordinate);
    void ProcessImage(GLuint texture_id, const GLfloat* vertex_coordinate, const GLfloat* texture_coordinate, GLfloat* texture_matrix);
    void SetInt(const char* name, int value);
    void SetFloat(const char* name, float value);
    void SetFloatArray(const char* name, const float* value, int count);
    void SetMatrix(const char* name, const float* value);
    void ActiveProgram();

private:
    void CreateProgram(const char* vertex, const char* fragment);
    void CompileShader(const char* shader_string, GLuint shader);
    void Link();
    void RunOnDrawTasks();
    void OnDrawArrays();

    GLuint program_;
    int width_;
    int height_;
    std::vector<std::function<void()>> on_draw_tasks_;
};

} // namespace pixelfree

#endif // OPENGL_H 