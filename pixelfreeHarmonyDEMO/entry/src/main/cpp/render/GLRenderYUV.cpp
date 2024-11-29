//
// Created on 2024/3/8.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "GLRenderYUV.h"
#include "log.h"
#include "../common/common.h"
#include <sys/stat.h>

const int VERTEX_POS_INDX = 0;
const int TEXTURE_POS_INDX = 1;

const int Y_INDEX = 0;
const int U_INDEX = 1;
const int V_INDEX = 2;

namespace GLContextManager {

static const char* TAG = "GLRenderYUV";

GLRenderYUV::GLRenderYUV(string& name):GLRenderRGBA(name){
    
}

GLRenderYUV::GLRenderYUV(string& name, int width, int height):GLRenderRGBA(name, width, height){
    
}

GLRenderYUV::~GLRenderYUV() {
    LOGD(TAG,"GLRenderYUV disContructor");
    ReleaseResource();
}

GLProgram *GLRenderYUV::CreateProgram(string &vertexShader, string &fragmentShader) {
    GLProgram *program = new GLProgram(vertexShader, fragmentShader);
    return program;
}


GLuint GLRenderYUV::Draw(uint8_t *pixelData, int dataSize, int pixelWidth, int pixelHeight, int rotate) {
    if (pixelData == nullptr || pixelWidth <= 0 || pixelHeight <= 0) {
        LOGE(TAG," error");
    }
    int imgByteSize = dataSize; // RGBA
    if (m_width != pixelWidth || m_height != pixelHeight) {
        m_width = pixelWidth;
        m_height = pixelHeight;
        LOGI(TAG, "width %{public}d height %{public}d", m_width, m_height);
        ReleaseResource();
        m_buf[0] = new unsigned char[m_width * m_height];
        m_buf[1] = new unsigned char[m_width * m_height / 4];
        m_buf[2] = new unsigned char[m_width * m_height / 4];
        //ReadYuvFile(m_width, m_height);
        CreateTexture(nullptr, m_width, m_height, GL_LUMINANCE, &m_YUV[0]);
        CreateTexture(nullptr, m_width/2, m_height/2, GL_LUMINANCE, &m_YUV[1]);
        CreateTexture(nullptr, m_width/2, m_height/2, GL_LUMINANCE, &m_YUV[2]);
    }
    // 普通渲染
    int ySize = m_width * m_height; 
    int uvSize = ySize/4;
    memcpy(m_buf[0], pixelData, ySize);
    memcpy(m_buf[1], pixelData+ySize, uvSize);
    memcpy(m_buf[2], pixelData+ySize+uvSize, uvSize);
    glViewport(0, 0, m_windowWidth, m_windowHeight);
    SurfaceDraw();
    FinishDraw();
    return 0;
}

bool GLRenderYUV::ReadYuvFile(int width, int height) {
    FILE *fp = fopen(YUV_DATASOURCE, "rb");
    if (!fp) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "file", "openFileErr");
        return false;
    }
    m_buf[0] = new unsigned char[width * height];     // y
    m_buf[1] = new unsigned char[width * height / 4]; // u
    m_buf[2] = new unsigned char[width * height / 4]; // v
    
    if (feof(fp) == 0) {
        fread(m_buf[0], 1, width * height, fp);
        fread(m_buf[1], 1, width * height / 4, fp);
        fread(m_buf[2], 1, width * height / 4, fp);
        fclose(fp);
        return true;
    }
    fclose(fp);
    return false;
}


void GLRenderYUV::SurfaceDraw() {
    m_program->UseProgram();
    glBindVertexArray(m_VaoIds[0]);
    //Y
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_YUV[0]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width, m_height,GL_LUMINANCE, GL_UNSIGNED_BYTE, m_buf[Y_INDEX]);
    glUniform1i(m_YUVUniform[Y_INDEX], Y_INDEX);
    //U
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, m_YUV[1]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width/2, m_height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, m_buf[U_INDEX]);
    glUniform1i(m_YUVUniform[U_INDEX], U_INDEX);
    //V
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, m_YUV[2]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_width/2, m_height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, m_buf[V_INDEX]);
    glUniform1i(m_YUVUniform[V_INDEX], V_INDEX);

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, (const void *)0);
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
}


void GLRenderYUV::PreparedLoad() {
    if (!m_program) {
        string vShaderString = string(VERTEX_SHADER_YUV);
        string fShaderString = string(FRAGMENT_SHADER_YUV);
        m_program = CreateProgram(vShaderString, fShaderString);
        m_program->InitProgram();
        LOGD(TAG, "m_program %{public}d", m_program->GetProgram());
    }
    m_program->UseProgram();
    // 顶点坐标
    GLfloat vVertices[] = {
			-1.0f, -1.0f, 0.0f,
			 1.0f, -1.0f, 0.0f,
			-1.0f,  1.0f, 0.0f,
			 1.0f,  1.0f, 0.0f,
    };
    // 正常纹理坐标
    GLfloat vTexCoors[] = {
            1.0f, 0.0f,
            1.0f, 1.0f,
            0.0f, 0.0f,
            0.0f, 1.0f,
    };
    // 顶点索引
    GLushort indices[] = {1,3,0,3,2,0};//{0, 1, 2, 1, 3, 2};

    // shader attribute & uniform
    m_YUVUniform[Y_INDEX] = m_program->GetUniform(string("yTexture"));
    m_YUVUniform[U_INDEX] = m_program->GetUniform(string("uTexture"));
    m_YUVUniform[V_INDEX] = m_program->GetUniform(string("vTexture"));

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

void GLRenderYUV::ReleaseResource() {
    if (m_YUV)
        glDeleteTextures(3, m_YUV);
    if(m_buf[0] != nullptr) {
        delete[] m_buf[0];
    }
    if(m_buf[1] != nullptr){
        delete[] m_buf[1];
    } 
    if(m_buf[2] != nullptr) {
        delete[] m_buf[2];
    }
}
}