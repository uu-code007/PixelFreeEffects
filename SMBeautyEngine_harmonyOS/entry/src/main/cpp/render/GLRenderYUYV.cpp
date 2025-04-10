//
// Created on 2024/3/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLRenderYUYV.h"
#include "log.h"
#include "../common/common.h"
#include <sys/stat.h>

const int VERTEX_POS_INDX = 0;
const int TEXTURE_POS_INDX = 1;

const char *YUYV_TEX = "tex_yuyv";
const char *YUYV_COLOR_VEC0 = "color_vec0";
const char *YUYV_COLOR_VEC1 = "color_vec1";
const char *YUYV_COLOR_VEC2 = "color_vec2";
const char *YUYV_COLOR_ORIGIN_MIN = "color_range_min";
const char *YUYV_COLOR_ORIGIN_MAX = "color_range_max";
const char *YUYV_RT_WIDTH = "rt_width";

static const float color_vec0[4] = {1.16438353f, 0.00000000f, 1.79274106f, -0.972945154f};
static const float color_vec1[4] = {1.16438353f, -0.213248610f, -0.532909334f, 0.301482677f};
static const float color_vec2[4] = {1.16438353f, 2.11240172f, 0.f, -1.13340223f};

static const float color_range_min[3] = {0.0627451017f, 0.0627451017f, 0.0627451017f};
static const float color_range_max[3] = {0.921568632f, 0.941176474f, 0.941176474f};

namespace GLContextManager {

static const char *TAG = "GLRenderYUV";

GLRenderYUYV::GLRenderYUYV(string &name) : GLRenderRGBA(name) {}

GLRenderYUYV::GLRenderYUYV(string &name, int width, int height) : GLRenderRGBA(name, width, height) {}

GLRenderYUYV::~GLRenderYUYV() {
    LOGD(TAG, "GLRenderYUV disContructor");
    ReleaseResource();
}

GLProgram *GLRenderYUYV::CreateProgram(string &vertexShader, string &fragmentShader) {
    GLProgram *program = new GLProgram(vertexShader, fragmentShader);
    return program;
}


GLuint GLRenderYUYV::Draw(uint8_t *pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate) {
    if (pixelData == nullptr || pixelWidth <= 0 || pixelHeight <= 0) {
        LOGE(TAG, " error");
        return 0;
    }
    int imgByteSize = pixelWidth * pixelHeight * 3 / 2; // RGBA
    if (m_width != pixelWidth || m_height != pixelHeight) {
        m_width = pixelWidth;
        m_height = pixelHeight;
        LOGI(TAG, "width %{public}d height %{public}d", m_width, m_height);
        ReleaseResource();
        m_buf = new unsigned char[imgByteSize];
        CreateTexture(nullptr, m_width / 2, m_height, GL_RGBA, &m_YUYV);
    }
    // 普通渲染
    memcpy(m_buf, pixelData, imgByteSize);
    glViewport(0, 0, m_windowWidth, m_windowHeight);
    SurfaceDraw();
    FinishDraw();
    return 0;
}


void GLRenderYUYV::SurfaceDraw() {
    m_program->UseProgram();
    glBindVertexArray(m_VaoIds[0]);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_YUYV);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width/2, m_height, GL_RGBA, GL_UNSIGNED_BYTE, m_buf);
    glUniform1i(m_Sampler, 0);
    
    glUniform3fv(m_min, 1, color_range_min);
    glUniform3fv(m_max, 1, color_range_max);

    glUniform4fv(m_vec[0], 1, color_vec0);
    glUniform4fv(m_vec[1], 1, color_vec1);
    glUniform4fv(m_vec[2], 1, color_vec2);
    
    glUniform1f(m_YUYV_width, m_width);

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, (const void *)0);
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
}


void GLRenderYUYV::PreparedLoad() {
    if (!m_program) {
        string vShaderString = string(VERTEX_SHADER_YUV);
        string fShaderString = string(FRAGMENT_SHADER_YUYV);
        m_program = CreateProgram(vShaderString, fShaderString);
        m_program->InitProgram();
        LOGD(TAG, "m_program %{public}d", m_program->GetProgram());
    }
    m_program->UseProgram();
    // 顶点坐标
    GLfloat vVertices[] = {
        -1.0f, -1.0f, 0.0f, 1.0f, -1.0f, 0.0f, -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f,
    };
    // 正常纹理坐标
    GLfloat vTexCoors[] = {
        1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f,
    };
    // 顶点索引
    GLushort indices[] = {1, 3, 0, 3, 2, 0}; //{0, 1, 2, 1, 3, 2};

    // shader attribute & uniform
    m_Sampler = m_program->GetUniform(string(YUYV_TEX));
    m_vec[0] = m_program->GetUniform(string(YUYV_COLOR_VEC0));
    m_vec[1] = m_program->GetUniform(string(YUYV_COLOR_VEC1));
    m_vec[2] = m_program->GetUniform(string(YUYV_COLOR_VEC2));
    m_min = m_program->GetUniform(string(YUYV_COLOR_ORIGIN_MIN));
    m_max = m_program->GetUniform(string(YUYV_COLOR_ORIGIN_MAX));
    m_YUYV_width = m_program->GetUniform(string(YUYV_RT_WIDTH));

    // 创建 vertexBuffer/ indexBuffer
    glGenBuffers(3, m_VboIds);
    glBindBuffer(GL_ARRAY_BUFFER, m_VboIds[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vVertices), vVertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, m_VboIds[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vTexCoors), vTexCoors, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_VboIds[2]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    // 创建VertexArray
    glGenVertexArrays(1, m_VaoIds);
    glBindVertexArray(m_VaoIds[0]);

    glBindBuffer(GL_ARRAY_BUFFER, m_VboIds[0]);
    glEnableVertexAttribArray(VERTEX_POS_INDX);
    glVertexAttribPointer(VERTEX_POS_INDX, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (const void *)0);
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);

    glBindBuffer(GL_ARRAY_BUFFER, m_VboIds[1]);
    glEnableVertexAttribArray(TEXTURE_POS_INDX);
    glVertexAttribPointer(TEXTURE_POS_INDX, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), (const void *)0);
    glBindBuffer(GL_ARRAY_BUFFER, GL_NONE);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_VboIds[2]);
    glBindVertexArray(GL_NONE);
}

void GLRenderYUYV::ReleaseResource() {
    if (m_YUYV)
        glDeleteTextures(1, &m_YUYV);
    if(m_buf){
        delete[] m_buf;
        m_buf = nullptr;
    }

}
} // namespace GLContextManager