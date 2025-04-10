//
// Created on 2024/3/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLRenderNV21.h"
#include "log.h"
#include "../common/common.h"
#include <sys/stat.h>

const int VERTEX_POS_INDX = 0;
const int TEXTURE_POS_INDX = 1;

const int Y_INDEX = 0;
const int UV_INDEX = 1;

const char *Y_TEX = "tex_y";
const char *UV_TEX = "tex_uv";

namespace GLContextManager {

static const char *TAG = "GLRenderNV21";

GLRenderNV21::GLRenderNV21(string &name) : GLBaseModel(name) {}

GLRenderNV21::GLRenderNV21(string &name, int width, int height) : GLBaseModel(name, width, height) {}

GLRenderNV21::~GLRenderNV21() {
    LOGD(TAG, "GLRenderNV21 disContructor");
    ReleaseResource();
    if (m_VboIds[0])
        glDeleteBuffers(3, m_VboIds);
    if (m_VaoIds[0])
        glDeleteVertexArrays(1, m_VaoIds);
}

GLProgram *GLRenderNV21::CreateProgram(string &vertexShader, string &fragmentShader) {
    GLProgram *program = new GLProgram(vertexShader, fragmentShader);
    return program;
}

void GLRenderNV21::Draw() {
    LOGE(TAG, "Please use Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight)");
}

void GLRenderNV21::Draw(int width, int height) {
    LOGE(TAG, "Please use Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight)");
}

GLuint GLRenderNV21::Draw(uint8_t *pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels) {
    if (pixelData == nullptr || pixelWidth <= 0 || pixelHeight <= 0) {
        LOGE(TAG, " error");
    }
    
    if (this->lastRotate != rotate) {
        this->lastRotate = rotate;
        UpdateRotate(rotate, m_VboIds[1]);
    }

    if (m_width != pixelWidth || m_height != pixelHeight) {
        m_width = pixelWidth;
        m_height = pixelHeight;
        LOGI(TAG, "width %{public}d height %{public}d", m_width, m_height);
        ReleaseResource();
        m_buf[Y_INDEX] = new unsigned char[m_width * m_height];
        m_buf[UV_INDEX] = new unsigned char[m_width * m_height / 2];
        CreateTexture(nullptr, m_width, m_height, GL_LUMINANCE, &m_YUV[0]);
        CreateTexture(nullptr, m_width / 2, m_height / 2, GL_LUMINANCE_ALPHA, &m_YUV[1]);
    }
    
    // 普通渲染
    int ySize = m_width * m_height;
    int uvSize = ySize / 2;
    memcpy(m_buf[Y_INDEX], pixelData, ySize);
    memcpy(m_buf[UV_INDEX], pixelData + ySize, uvSize);
    glViewport(0, 0, m_windowWidth, m_windowHeight);
    m_program->UseProgram();
    if (mirror) {
        glUniform1i(m_mirror, 1);
    } else {
        glUniform1i(m_mirror, 0);
    }
    glBindVertexArray(m_VaoIds[0]);
    // Y
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_YUV[0]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width, m_height, GL_LUMINANCE, GL_UNSIGNED_BYTE, m_buf[Y_INDEX]);
    glUniform1i(m_YUVUniform[Y_INDEX], Y_INDEX);
    // UV
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, m_YUV[1]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width / 2, m_height / 2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE,
                    m_buf[UV_INDEX]);
    glUniform1i(m_YUVUniform[UV_INDEX], UV_INDEX);

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, (const void *)0);
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    FinishDraw();
    return 0;
}

void GLRenderNV21::Draw(GLuint inTex, int dataSize, int width, int height, int rotate, bool  mirror, bool needDownloadPixels){}


void GLRenderNV21::PreparedLoad() {
    if (!m_program) {
        string vShaderString = string(VERTEX_SHADER_YUV);
        string fShaderString = string(FRAGMENT_SHADER_NV21);
        m_program = CreateProgram(vShaderString, fShaderString);
        m_program->InitProgram();
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
    m_YUVUniform[Y_INDEX] = m_program->GetUniform(string(Y_TEX));
    m_YUVUniform[UV_INDEX] = m_program->GetUniform(string(UV_TEX));
    m_mirror = m_program->GetUniform(string("mirror"));

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



void GLRenderNV21::ReleaseResource() {
    GLBaseModel::ReleaseResource();
    glDeleteTextures(2, m_YUV);
    if (m_buf[0] != nullptr) 
        delete[] m_buf[0];
    if (m_buf[1] != nullptr) 
        delete[] m_buf[1];
}
} // namespace GLContextManager