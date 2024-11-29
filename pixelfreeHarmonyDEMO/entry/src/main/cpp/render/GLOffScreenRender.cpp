//
// Created on 2024/4/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLOffScreenRender.h"
#include "./log/ohos_log.h"
#include "../common/common.h"

extern int VERTEX_POS_INDX;
extern int TEXTURE_POS_INDX;

const char *OFFSCREENTAG = "OFFSCREENTAG";

namespace GLContextManager {

GLOffScreenRender::GLOffScreenRender(string &name) : GLBaseModel(name) {}

GLOffScreenRender::GLOffScreenRender(string &name, int width, int height) : GLBaseModel(name, width, height) {}

GLOffScreenRender::~GLOffScreenRender() {
    ReleaseResource();
}

GLProgram *GLOffScreenRender::CreateProgram(string &vertexShader, string &fragmentShader) {
    GLProgram *program = new GLProgram(vertexShader, fragmentShader);
    return program;
}

void GLOffScreenRender::Draw() {
    LOGE("Please use Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight)");
}

void GLOffScreenRender::Draw(int width, int height) {
    LOGE("Please use Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight)");
}

GLuint GLOffScreenRender::Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate, bool mirror, bool needDownloadPixels) {
    if (pixelData == nullptr || pixelWidth <= 0 || pixelHeight <= 0) {
        return 0;
    }
    int imgByteSize = dataSize;
    if (m_textureId == 0 || m_width != pixelWidth || m_height != pixelHeight) {
        m_width = pixelWidth;
        m_height = pixelHeight;
        ReleaseResource();
        CreateTexture(nullptr, m_width, m_height, GL_RGBA, &m_textureId);
        CreateFrameBuffer();
        CreatePBOs(imgByteSize);
        m_pixelBuffer = new uint8_t[imgByteSize];
    }
    glViewport(0, 0, m_width, m_height);
    glBindFramebuffer(GL_FRAMEBUFFER, m_FboId);
    m_program->UseProgram();
    glUniform1f(m_rotate, 1.0);
    glBindVertexArray(m_VaoIds[0]);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_textureId);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width, m_height, GL_RGBA, GL_UNSIGNED_BYTE, pixelData);
    glUniform1i(m_Sampler, 0);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, (const void *)0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    //Download
    if (needDownloadPixels) {
        LOGE("@mahaomeng needDownloadPixels");
        DownloadPixels();
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glFlush();
    return m_textureId;
}

void GLOffScreenRender::Draw(GLuint inTex, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels) {
    if (!glIsTexture(inTex))
        return;
    int imgByteSize = dataSize; // RGBA
    if (m_width != width || m_height != height) {
        LOGE("@mahaomeng width %d  height %d", m_width, m_height);
        m_width = width;
        m_height = height;
        ReleaseResource();
        CreateFrameBuffer();
        CreatePBOs(imgByteSize);
        m_pixelBuffer = new uint8_t[imgByteSize];
    }
    glViewport(0, 0, m_width, m_height);
    m_program->UseProgram();
    glUniform1f(m_rotate, 1.0);
    glBindFramebuffer(GL_FRAMEBUFFER, m_FboId);
    glBindVertexArray(m_VaoIds[0]);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, inTex);
    glUniform1i(m_Sampler, 0);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, (const void *)0);
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    //Download
    if (needDownloadPixels) {
        LOGE("@mahaomeng needDownloadPixels");
        DownloadPixels();
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glFlush();
}

void GLOffScreenRender::DownloadPixeData(GLuint inTex, int width, int height){
    if (!glIsTexture(inTex) || width <= 0 || height <= 0) return;
    int imgByteSize = width * height * 4;
    if (m_width != width || m_height != height) {
        m_width = width;
        m_height = height;
        ReleaseResource();
        CreateFrameBuffer();
        CreatePBOs(imgByteSize);
        m_pixelBuffer = new uint8_t[imgByteSize];
    }
    glBindFramebuffer(GL_FRAMEBUFFER, m_FboId);
    glBindTexture(GL_TEXTURE_2D, inTex);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, inTex, 0);
    DownloadPixels();
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glFlush();
}

void GLOffScreenRender::getOutData(void* outdata, int width, int height){
    memcpy(outdata, m_pixelBuffer, width * height << 2);
}

void GLOffScreenRender::PreparedLoad() {
    if (!m_program) {
        string vShaderString = string(vShaderStr);
        string fShaderString = string(fShaderStr);
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
        0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
    };

    // 顶点索引
    GLushort indices[] = {0, 1, 2, 1, 3, 2};

    // shader attribute & uniform
    m_Sampler = m_program->GetUniform(string("s_TextureMap"));
    m_rotate = m_program->GetUniform(string("rotate"));
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

void GLOffScreenRender::ReleaseResource() {
    GLBaseModel::ReleaseResource();
    if (m_fboTextureId){
        glDeleteTextures(1, &m_fboTextureId);
        m_fboTextureId = 0;
    }
    if (m_FboId){
        glDeleteFramebuffers(1, &m_FboId);
        m_FboId = 0;
    }
    if(m_pixelBuffer){
        delete [] m_pixelBuffer;
        m_pixelBuffer = nullptr;
    }
}


bool GLOffScreenRender::CreateFrameBuffer() {
    if (!m_FboId || !m_fboTextureId) {
        // 创建纹理Fbo关联纹理
        CreateTexture(nullptr, m_width, m_height, GL_RGBA, &m_fboTextureId);
        glGenFramebuffers(1, &m_FboId);
        glBindFramebuffer(GL_FRAMEBUFFER, m_FboId);
        glBindTexture(GL_TEXTURE_2D, m_fboTextureId);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_fboTextureId, 0);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_width, m_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            LOGE("PBOSample::CreateFrameBufferObj glCheckFramebufferStatus status != GL_FRAMEBUFFER_COMPLETE");
            return false;
        }
        glBindTexture(GL_TEXTURE_2D, GL_NONE);
        glBindFramebuffer(GL_FRAMEBUFFER, GL_NONE);
    }
    return true;
}

GLuint GLOffScreenRender::getOffScreenTexture(){
    return m_fboTextureId ?: 0;
}
}
