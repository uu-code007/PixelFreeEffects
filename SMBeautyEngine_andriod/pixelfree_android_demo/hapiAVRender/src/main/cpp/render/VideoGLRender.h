//
// Created by 1 on 2022/3/28.
//

#ifndef ENCODER_VIDEOGLRENDER_H
#define ENCODER_VIDEOGLRENDER_H

#include <mutex>
#include <GLES3/gl3.h>
#include <detail/type_mat.hpp>
#include <detail/type_mat4x4.hpp>
#include <vec2.hpp>
#include "NativeImage.h"

#define MATH_PI 3.1415926535897932384626433832802
#define TEXTURE_NUM 3

using namespace glm;

class VideoGLRender {
public:
    VideoGLRender();

    ~VideoGLRender() = default;

    void RenderVideoFrame(NativeImage *image);

    void UnInit();

    void OnSurfaceCreated();

    void OnSurfaceChanged(int w, int h);

    void OnDrawFrame();

    void UpdateMVPMatrix(int angleX, int angleY, float scaleX, float scaleY);

    void UpdateMVPMatrix(TransformMatrix *pTransformMatrix);

    void SetTouchLoc(float touchX, float touchY) {
        m_TouchXY.x = touchX / m_ScreenSize.x;
        m_TouchXY.y = touchY / m_ScreenSize.y;
    }

private:

    GLuint m_ProgramObj = GL_NONE;
    GLuint m_TextureIds[TEXTURE_NUM]{};
    GLuint m_VaoId{};
    GLuint m_VboIds[3]{};
    volatile NativeImage *m_RenderImage = nullptr;
    glm::mat4 m_MVPMatrix;

    int m_FrameIndex{};
    vec2 m_TouchXY;
    vec2 m_ScreenSize;
};


#endif //ENCODER_VIDEOGLRENDER_H
