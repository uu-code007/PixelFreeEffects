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
// Created by wlanjie on 2019/4/26.
//

#include "encode_render.h"
#include "android_xlog.h"
#include "gl.h"

// form https://stackoverflow.com/questions/7901519/how-to-use-opengl-fragment-shader-to-convert-rgb-to-yuv420
// form https://github.com/doggycoder/AAVT/blob/master/aavt/src/main/assets/shader/convert/export_yuv420p.frag
// 转换公式
// Y’= 0.299*R’ + 0.587*G’ + 0.114*B’
// U’= -0.147*R’ - 0.289*G’ + 0.436*B’ = 0.492*(B’- Y’)
// V’= 0.615*R’ - 0.515*G’ - 0.100*B’ = 0.877*(R’- Y’)
// 导出原理：采样坐标只作为确定输出位置使用，通过输出纹理计算实际采样位置，进行采样和并转换,
// 然后将转换的结果填充到输出位置
static const char* ENCODER_FRAGMENT =
        "precision highp float;\n"
        "precision highp int;\n"
        "varying vec2 textureCoordinate;\n"
        "uniform sampler2D inputImageTexture;\n"
        "uniform float width;\n"
        "uniform float height;\n"
        "float cY(float x, float y) {\n"
        "    vec4 c = texture2D(inputImageTexture, vec2(x, y));\n"
        "    return c.r * 0.257 + c.g * 0.504 + c.b * 0.098 + 0.0625;\n"
        "}\n"
        "vec4 cC(float x, float y, float dx, float dy) {\n"
        "    vec4 c0 = texture2D(inputImageTexture, vec2(x, y));\n"
        "    vec4 c1 = texture2D(inputImageTexture, vec2(x + dx, y));\n"
        "    vec4 c2 = texture2D(inputImageTexture, vec2(x, y + dy));\n"
        "    vec4 c3 = texture2D(inputImageTexture, vec2(x + dx, y + dy));\n"
        "    return (c0 + c1 + c2 + c3) / 4.;\n"
        "}\n"
        "float cU(float x, float y, float dx, float dy) {\n"
        "    vec4 c = cC(x, y, dx, dy);\n"
        "    return -0.148 * c.r - 0.291 * c.g + 0.439 * c.b + 0.5000;\n"
        "}\n"
        "float cV(float x, float y, float dx, float dy) {\n"
        "    vec4 c = cC(x, y, dx, dy);\n"
        "    return 0.439 * c.r - 0.368 * c.g - 0.071 * c.b + 0.5000;\n"
        "}\n"
        "vec2 cPos(float t, float shiftx, float gy) {\n"
        "    vec2 pos = vec2(floor(width * textureCoordinate.x), floor(height * gy));\n"
        "    return vec2(mod(pos.x * shiftx, width), (pos.y * shiftx + floor(pos.x * shiftx / width)) * t);\n"
        "}\n"
        "vec4 calculateY() {\n"
        "    vec2 pos = cPos(1., 4., textureCoordinate.y);\n"
        "    vec4 oColor = vec4(0);\n"
        "    float textureYPos = pos.y / height;\n"
        "    oColor[0] = cY(pos.x / width, textureYPos);\n"
        "    oColor[1] = cY((pos.x + 1.) / width, textureYPos);\n"
        "    oColor[2] = cY((pos.x + 2.) / width, textureYPos);\n"
        "    oColor[3] = cY((pos.x + 3.) / width, textureYPos);\n"
        "    return oColor;\n"
        "}\n"
        "vec4 calculateU(float gy, float dx, float dy) {\n"
        "    vec2 pos = cPos(2., 8., textureCoordinate.y - gy);\n"
        "    vec4 oColor = vec4(0);\n"
        "    float textureYPos = pos.y / height;\n"
        "    oColor[0] = cU(pos.x / width, textureYPos, dx, dy);\n"
        "    oColor[1] = cU((pos.x + 2.) / width, textureYPos, dx, dy);\n"
        "    oColor[2] = cU((pos.x + 4.) / width, textureYPos, dx, dy);\n"
        "    oColor[3] = cU((pos.x + 6.) / width, textureYPos, dx, dy);\n"
        "    return oColor;\n"
        "}\n"
        "vec4 calculateV(float gy, float dx, float dy) {\n"
        "    vec2 pos = cPos(2., 8., textureCoordinate.y - gy);\n"
        "    vec4 oColor = vec4(0);\n"
        "    float textureYPos = pos.y / height;\n"
        "    oColor[0] = cV(pos.x / width, textureYPos, dx, dy);\n"
        "    oColor[1] = cV((pos.x + 2.) / width, textureYPos, dx, dy);\n"
        "    oColor[2] = cV((pos.x + 4.) / width, textureYPos, dx, dy);\n"
        "    oColor[3] = cV((pos.x + 6.) / width, textureYPos, dx, dy);\n"
        "    return oColor;\n"
        "}\n"
        "vec4 calculateUV(float dx, float dy) {\n"
        "    vec2 pos = cPos(2., 4., textureCoordinate.y - 0.2500);\n"
        "    vec4 oColor = vec4(0);\n"
        "    float textureYPos = pos.y / height;\n"
        "    oColor[0] = cU(pos.x / width, textureYPos, dx, dy);\n"
        "    oColor[1] = cV(pos.x / width, textureYPos, dx, dy);\n"
        "    oColor[2] = cU((pos.x + 2.) / width, textureYPos, dx, dy);\n"
        "    oColor[3] = cV((pos.x + 2.) / width, textureYPos, dx, dy);\n"
        "    return oColor;\n"
        "}\n"
        "vec4 calculateVU(float dx, float dy) {\n"
        "    vec2 pos = cPos(2., 4., textureCoordinate.y - 0.2500);\n"
        "    vec4 oColor = vec4(0);\n"
        "    float textureYPos = pos.y / height;\n"
        "    oColor[0] = cV(pos.x / width, textureYPos, dx, dy);\n"
        "    oColor[1] = cU(pos.x / width, textureYPos, dx, dy);\n"
        "    oColor[2] = cV((pos.x + 2.) / width, textureYPos, dx, dy);\n"
        "    oColor[3] = cU((pos.x + 2.) / width, textureYPos, dx, dy);\n"
        "    return oColor;\n"
        "}\n"
        "void main() {\n"
        "   if (textureCoordinate.y < 0.2500) {\n"
        "       gl_FragColor = calculateY();\n"
        "   } else if (textureCoordinate.y < 0.3125) {\n"
        "       gl_FragColor = calculateU(0.2500, 1. / width, 1. / height);\n"
        "   } else if (textureCoordinate.y < 0.3750) {\n"
        "       gl_FragColor = calculateV(0.3125, 1. / width, 1. / height);\n"
        "   } else { \n"
        "       gl_FragColor = vec4(0, 0, 0, 0);"
        "   }\n"
        "}\n";

/**
 * YV12
 * "void main() {\n" +
    "    if(vTextureCo.y<0.2500){\n" +
    "        gl_FragColor=calculateY();\n" +
    "    }else if(vTextureCo.y<0.3125){\n" +
    "        gl_FragColor=calculateV(0.2500,1./uWidth,1./uHeight);\n" +
    "    }else if(vTextureCo.y<0.3750){\n" +
    "        gl_FragColor=calculateU(0.3125,1./uWidth,1./uHeight);\n" +
    "    }else{\n" +
    "        gl_FragColor=vec4(0,0,0,0);\n" +
    "    }\n" +
    "}")
 */

/**
 * NV12
 * "void main() {\n" +
    "    if(vTextureCo.y<0.2500){\n" +
    "        gl_FragColor=calculateY();\n" +
    "    }else if(vTextureCo.y<0.3750){\n" +
    "        gl_FragColor=calculateUV(1./uWidth,1./uHeight);\n" +
    "    }else{\n" +
    "        gl_FragColor=vec4(0,0,0,0);\n" +
    "    }\n" +
    "}"
 */

/**
 * NV21
 * "void main() {\n" +
    "    if(vTextureCo.y<0.2500){\n" +
    "        gl_FragColor=calculateY();\n" +
    "    }else if(vTextureCo.y<0.3750){\n" +
    "        gl_FragColor=calculateVU(1./uWidth,1./uHeight);\n" +
    "    }else{\n" +
    "        gl_FragColor=vec4(0,0,0,0);\n" +
    "    }\n" +
    "}"
 */

namespace trinity {

EncodeRender::EncodeRender() : OpenGL(DEFAULT_VERTEX_SHADER, ENCODER_FRAGMENT) {
    width_ = 0;
    height_ = 0;
}

EncodeRender::~EncodeRender() {
}

void EncodeRender::CopyYUV420Image(GLuint texture, uint8_t *buffer, int width, int height) {
    width_ = width;
    height_ = height;
    ConvertYUV420(texture, width, height, buffer);
}

void EncodeRender::Destroy() {
}

void EncodeRender::RunOnDrawTasks() {
    SetFloat("width", width_ * 1.0f);
    SetFloat("height", height_ * 1.0f);
}

void EncodeRender::ConvertYUV420(int texture_id, int width, int height, void *buffer) {
    glViewport(0, 0, width, height);
    // 这里画的时候不能改变顶点或纹理的坐标
    ActiveProgram();
    ProcessImage(texture_id);
    glReadPixels(0, 0, width, height * 3 / 8, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
}

}  // namespace trinity
