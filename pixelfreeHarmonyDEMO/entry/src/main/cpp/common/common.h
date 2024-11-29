//
// Created on 2024/3/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#pragma once

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <EGL/eglplatform.h>
#include <GLES3/gl3.h>
#include <napi/native_api.h>

/**
 * Egl red size default.
 */
const int EGL_RED_SIZE_DEFAULT = 8;

/**
 * Egl green size default.
 */
const int EGL_GREEN_SIZE_DEFAULT = 8;

/**
 * Egl blue size default.
 */
const int EGL_BLUE_SIZE_DEFAULT = 8;

/**
 * Egl alpha size default.
 */
const int EGL_ALPHA_SIZE_DEFAULT = 8;

/**
 * Vertex shader.
 */
const char vShaderStr[] = "#version 300 es                            \n"
                          "layout(location = 0) in vec4 a_position;   \n"
                          "layout(location = 1) in vec2 a_texCoord;   \n"
                          "out vec2 v_texCoord;                       \n"
                          "uniform float rotate;                      \n"
                          "uniform int mirror;                      \n"
                          "void main()                                \n"
                          "{                                          \n"
                          "   gl_Position = vec4(a_position.x, rotate * a_position.y, a_position.z, 1.0);               \n" 
                          "   v_texCoord = vec2(a_texCoord.x, mirror == 0 ? a_texCoord.y : 1.0 - a_texCoord.y);\n"
                          "}                                          \n";
/**
 * Fragment shader.
 */
const char fShaderStr[] = "#version 300 es\n"
                          "precision mediump float;\n"
                          "in vec2 v_texCoord;\n"
                          "layout(location = 0) out vec4 outColor;\n"
                          "uniform sampler2D s_TextureMap;\n"
                          "void main()\n"
                          "{\n"
                          "    outColor = texture(s_TextureMap, v_texCoord);\n"
                          "}";

/**
 * Vertex shader.
 */
const char VERTEX_SHADER_YUV[] = "#version 300 es                            \n" 
                                 "layout(location = 0) in vec4 a_position;   \n"
                                 "layout(location = 1) in vec2 a_texCoord;   \n"
                                 "uniform int mirror;                      \n"
                                 "out vec2 v_texCoord; \n"
                                 "void main() {\n"
                                 "    v_texCoord = vec2(a_texCoord.x, mirror == 1 ? a_texCoord.y : 1.0 - a_texCoord.y);\n"
                                 "    gl_Position = a_position;\n"
                                 "}\n";

/**
 * Fragment shader.
 */
const char FRAGMENT_SHADER_YUV[] =  "#version 300 es\n"
                                    "precision mediump float;\n"
                                    "in vec2 v_texCoord;\n"
                                    "layout(location = 0) out vec4 outColor;\n"
                                    "uniform sampler2D yTexture;\n"
                                    "uniform sampler2D uTexture;\n"
                                    "uniform sampler2D vTexture;\n"
                                    "\n"
                                    "void main()\n"
                                    "{\n"
                                    "    vec3 yuv;\n"
                                    "    vec3 rgb;\n"
                                    "    yuv.r = texture(yTexture, v_texCoord).g;\n"
                                    "    yuv.g = texture(uTexture, v_texCoord).g - 0.5;\n"
                                    "    yuv.b = texture(vTexture, v_texCoord).g - 0.5;\n"
                                    "\n"
                                    "    rgb = mat3(\n"
                                    "        1.0, 1.0, 1.0,\n"
                                    "        0.0, -0.39465, 2.03211,\n"
                                    "        1.13983, -0.5806, 0.0\n"
                                    "    ) * yuv;\n"
                                    "    outColor = vec4(rgb, 1.0);\n"
                                    "}\n";

/**
 * Fragment shader.
 */
const char FRAGMENT_SHADER_YUYV[] = "#version 300 es\n"
                                    "precision mediump float;\n"
                                    "in vec2 v_texCoord;\n"
                                    "layout(location = 0) out vec4 outColor;\n"
                                    "uniform sampler2D tex_yuyv;\n"
                                    "uniform vec4 color_vec0;\n"
                                    "uniform vec4 color_vec1;\n"
                                    "uniform vec4 color_vec2;\n"
                                    "uniform vec3 color_range_min;\n"
                                    "uniform vec3 color_range_max;\n"
                                    "uniform float rt_width;\n"
                                    "\n"
                                    "void main()\n"
                                    "{\n"
                                    "   vec4 yuyv = texture(tex_yuyv, v_texCoord);\n"
                                    "   vec2 yy = yuyv.xz;\n"
                                    "   vec2 cbcr = yuyv.yw;\n"
                                    "   ivec2 tex_size = textureSize(tex_yuyv, 0);\n"
                                    "   float texturex = float(tex_size.x);\n"
                                    "   float factor = texturex/rt_width;\n"
                                    "   float cur_y = (v_texCoord.x * factor) < 0.5f ? yy.x : yy.y;\n"
                                    "\n"
                                    "   vec3 yuv = vec3(cur_y, cbcr);\n"
                                    "   yuv = clamp(yuv, color_range_min, color_range_max);\n"
                                    "\n"
                                    "   vec3 rgb = vec3(0.f);\n"
                                    "   rgb.r = dot(color_vec0.xyz, yuv) + color_vec0.w;\n"
                                    "   rgb.g = dot(color_vec1.xyz, yuv) + color_vec1.w;\n"
                                    "   rgb.b = dot(color_vec2.xyz, yuv) + color_vec2.w;\n"
                                   "    outColor = vec4(rgb, 1.0);\n"
                                   "}\n";

const char FRAGMENT_SHADER_NV21[] = "#version 300 es\n"
                                    "precision mediump float;\n"
                                    "in vec2 v_texCoord;\n"
                                    "layout(location = 0) out vec4 outColor;\n"
                                    "uniform sampler2D tex_y;\n"
                                    "uniform sampler2D tex_uv;\n"
                                    "\n"
                                    "void main()\n"
                                    "{\n"
                                    "   vec3 yuv;\n"
                                    "   yuv.x = texture(tex_y, v_texCoord).r - 0.063;\n"
                                    "   yuv.y = texture(tex_uv, v_texCoord).a - 0.502;\n"
                                    "   yuv.z = texture(tex_uv, v_texCoord).r - 0.502;\n"
                                    "   vec3 rgb = mat3(1.164, 1.164, 1.164, 0,-0.392, 2.017, 1.596, -0.813, 0.0) * yuv;\n"
                                    "   outColor = vec4(rgb, 1.0);\n"
                                    "}\n";
// 顶点着色器源代码
const char DRAW_POINT_VERTEX_SHADER[] = "#version 300 es\n"
                                        "layout(location = 0) in vec2 aPos;\n"
                                        "void main()\n"
                                        "{\n"
                                        "    gl_Position = vec4(aPos, 0.0, 1.0);\n"
                                        "    gl_PointSize = 10.0;\n"
                                        "}\n";

// 片段着色器源代码
const char DRAW_POINT_FRAGMENT_SHADER[] = "#version 300 es\n"
                                        "precision mediump float;\n"
                                        "layout(location = 0) out vec4 outColor;\n"
                                        "void main()\n"
                                        "{\n"
                                        "    outColor = vec4(0.0, 1.0, 0.0, 1.0);\n"
                                        "}\n";

const char YUV_DATASOURCE[] = "/data/storage/el2/base/haps/entry/files/image.yuv";

enum ErrorCode{
    OK = 0,
    PROGRAM_ERROR = -1,
    PARAM_ERROR = -2,
};

/**
 * Config attribute list.
 */
const EGLint ATTRIB_LIST[] = {
    // Key,value.
    EGL_SURFACE_TYPE, EGL_WINDOW_BIT, 
    EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
    EGL_RED_SIZE, EGL_RED_SIZE_DEFAULT, 
    EGL_GREEN_SIZE, EGL_GREEN_SIZE_DEFAULT,
    EGL_BLUE_SIZE, EGL_BLUE_SIZE_DEFAULT, 
    EGL_ALPHA_SIZE, EGL_ALPHA_SIZE_DEFAULT,
    EGL_DEPTH_SIZE, 24,
    EGL_NONE};

/**
 * Context attributes.
 */
const EGLint CONTEXT_ATTRIBS[] = {EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE};


/**
 * Log print domain.
 */
const unsigned int LOG_PRINT_DOMAIN = 0xFF00;

const char OPENGL_XCOMPONENT_ID[] = "opengl_xcomponent";

#include <cstring>
#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

// #endif //EFFECTSHARMONY_COMMON_H
