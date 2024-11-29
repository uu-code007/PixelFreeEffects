//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLRenderRGBA.h"
#include <GLES3/gl3.h>
#include "../common/common.h"
#include "./log/ohos_log.h"

int VERTEX_POS_INDX = 0;
int TEXTURE_POS_INDX = 1;

static const char * TAG = "GLRenderRGBA";  

namespace GLContextManager {

GLRenderRGBA::GLRenderRGBA(string& name):GLBaseModel(name){
    
}

GLRenderRGBA::GLRenderRGBA(string& name, int width, int height):GLBaseModel(name, width, height){
    
}

GLRenderRGBA::~GLRenderRGBA(){
    LOGD(TAG,"GLRenderRGBA disContructor");
    if (m_textureId) glDeleteTextures(1, &m_textureId);
    if (m_VboIds[0]) glDeleteBuffers(3, m_VboIds);
    if (m_VaoIds[0]) glDeleteVertexArrays(1, m_VaoIds);
}

GLProgram* GLRenderRGBA::CreateProgram(string &vertexShader, string &fragmentShader){
    GLProgram *program = new GLProgram(vertexShader, fragmentShader);
    return program;
}

void GLRenderRGBA::Draw() { 
    LOGE(TAG,"Please use Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight)");
}

void GLRenderRGBA::Draw(int width, int height){
     LOGE(TAG,"Please use Draw(uint8_t* pixelData, int dataSize, int pixelWidth, int pixelHeight)");
}

GLuint GLRenderRGBA::Draw(uint8_t* pixelData, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels){
    if (pixelData == nullptr || width <= 0 || height <= 0) {
        LOGE(TAG," error");
        return 0;
    }
    m_osRender->Draw(pixelData, dataSize, width, height, rotate, mirror, needDownloadPixels);
    GLuint ofTex = m_osRender->getOffScreenTexture();
    if (!glIsTexture(ofTex)) return 0;
    normalRender(ofTex, rotate, mirror);
    return 0;
}

void GLRenderRGBA::Draw(GLuint inTex, int dataSize, int width, int height, int rotate, bool mirror, bool needDownloadPixels) {
    if (!glIsTexture(inTex)) return;
    if(needDownloadPixels) 
        m_osRender->DownloadPixeData(inTex, width, height);
    normalRender(inTex, rotate, mirror);
}

void GLRenderRGBA::SimpleDraw(uint8_t* pixelData,  int width, int height, int rotate, bool mirror, bool needDownloadPixels){
    if (pixelData == nullptr || width <= 0 || height <= 0) {
        return;
    }
     if (m_textureId == 0 || m_width != width || m_height != height) {
        m_width = width;
        m_height = height;
        ReleaseResource();
        CreateTexture(nullptr, m_width, m_height, GL_RGBA, &m_textureId);
    }
    glBindTexture(GL_TEXTURE_2D, m_textureId);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixelData);
    if(needDownloadPixels) m_osRender->DownloadPixeData(m_textureId, width, height);
    normalRender(m_textureId, rotate, mirror);
}

void GLRenderRGBA::SimpleDraw(GLuint inTex, int width, int height,  int rotate, bool mirror, bool needDownloadPixels){
    if (!glIsTexture(inTex)) return;
    if(needDownloadPixels) m_osRender->DownloadPixeData(inTex, width, height);
    normalRender(inTex, rotate, mirror);
}

void GLRenderRGBA::normalRender(GLuint textrue, int rotate, bool mirror){
    if (!glIsTexture(textrue)) return;
    m_program->UseProgram();
    glViewport(0, 0, m_windowWidth, m_windowHeight);
    if (lastRotate != rotate) {
        lastRotate = rotate;
        UpdateRotate(rotate, m_VboIds[1]);
    }
    glUniform1f(m_rotate, -1.0);
    if (mirror) {
        glUniform1i(m_mirror, 1);
    } else {
        glUniform1i(m_mirror, 0);
    }
    glBindVertexArray(m_VaoIds[0]);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textrue);
    glUniform1i(m_Sampler, 0);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, (const void *)0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindVertexArray(0);
}

void GLRenderRGBA::getOutData(void* outdata, int width, int height){
    m_osRender->getOutData(outdata, width, height);
}

void GLRenderRGBA::PreparedLoad(){
    if (!m_program) {
        string vShaderString = string(vShaderStr);
        string fShaderString = string(fShaderStr);
        m_program = CreateProgram(vShaderString, fShaderString);
        m_program->InitProgram();
        LOGE(TAG,"GLRenderRGBA m_program %{public}d", m_program->GetProgram());
        string ofName = "ofName";
        m_osRender = new GLOffScreenRender(ofName, m_width, m_height);
        m_osRender->PreparedLoad();
    }
    m_program->UseProgram();
    // 顶点坐标
    GLfloat vVertices[] = {
        -1.0f, -1.0f, 0.0f, 
        1.0f, -1.0f, 0.0f, 
        -1.0f, 1.0f, 0.0f, 
        1.0f, 1.0f, 0.0f,
    };
    // 正常纹理坐标
    GLfloat vTexCoors[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    //顶点索引
    GLushort indices[] = {0, 1, 2, 1, 3, 2};
    
    //shader attribute & uniform
    m_Sampler = m_program->GetUniform(string("s_TextureMap"));
    m_rotate = m_program->GetUniform(string("rotate"));
    m_mirror = m_program->GetUniform(string("mirror"));
    
    //创建 vertexBuffer/ indexBuffer
    glGenBuffers(3, m_VboIds);
    glBindBuffer(GL_ARRAY_BUFFER, m_VboIds[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vVertices), vVertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, m_VboIds[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vTexCoors), vTexCoors, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_VboIds[2]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    //创建VertexArray
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

void GLRenderRGBA::ReleaseResource(){
    GLBaseModel::ReleaseResource();
    if (m_textureId)
        glDeleteTextures(1, &m_textureId);
}

}
