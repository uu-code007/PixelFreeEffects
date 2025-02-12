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
 */

//
// Created by wlanjie on 2019/4/13.
//

#ifndef TRINITY_GL_H
#define TRINITY_GL_H

static const float DEFAULT_VERTEX_COORDINATE[] = {
        -1.F, -1.F,
        1.F, -1.F,
        -1.F, 1.F,
        1.F, 1.F
};

static const float DEFAULT_TEXTURE_COORDINATE[] = {
        0.F, 0.F,
        1.F, 0.F,
        0.F, 1.F,
        1.F, 1.F
};

static float VERTEX_COORDINATE[8] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f, 1.0f,
        1.0f, 1.0f,
};

static float TEXTURE_COORDINATE_NO_ROTATION[8] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f
};

static float TEXTURE_COORDINATE_ROTATED_90[8] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f
};

static float TEXTURE_COORDINATE_ROTATED_180[8] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
};

static float TEXTURE_COORDINATE_ROTATED_270[8] = {
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        1.0f, 0.0f
};

// 默认带matrix的顶点shader
static const char* DEFAULT_VERTEX_MATRIX_SHADER =
        "attribute vec4 position;                                                               \n"
        "attribute vec4 inputTextureCoordinate;                                                 \n"
        "varying vec2 textureCoordinate;                                                        \n"
        "uniform highp mat4 textureMatrix;                                                      \n"
        "void main() {                                                                          \n"
        "  textureCoordinate = (textureMatrix * inputTextureCoordinate).xy;                     \n"
        "  gl_Position = position;                                                              \n"
        "}                                                                                      \n";

// 默认OES fragment shader
static const char* DEFAULT_OES_FRAGMENT_SHADER =
        "#extension GL_OES_EGL_image_external : require                                         \n"
        "precision mediump float;                                                               \n"
        "uniform samplerExternalOES inputImageTexture;                                              \n"
        "varying vec2 textureCoordinate;                                                        \n"
        "void main() {                                                                          \n"
        "  gl_FragColor = texture2D(inputImageTexture, textureCoordinate);                          \n"
        "}                                                                                      \n";

// 默认顶点shader
static const char* DEFAULT_VERTEX_SHADER =
        "#ifdef GL_ES                                                                           \n"
        "precision highp float;                                                                 \n"
        "#endif                                                                                 \n"
        "attribute vec4 position;                                                               \n"
        "attribute vec4 inputTextureCoordinate;                                                 \n"
        "varying vec2 textureCoordinate;                                                        \n"
        "void main() {                                                                          \n"
        "    gl_Position = position;                                                            \n"
        "    textureCoordinate = inputTextureCoordinate.xy;                                     \n"
        "}                                                                                      \n";

// 默认fragment shader
static const char* DEFAULT_FRAGMENT_SHADER =
        "#ifdef GL_ES                                                                           \n"
        "precision highp float;                                                                 \n"
        "#endif                                                                                 \n"
        "varying vec2 textureCoordinate;                                                        \n"
        "uniform sampler2D inputImageTexture;                                                   \n"
        "void main() {                                                                          \n"
        "    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);                    \n"
        "}                                                                                      \n";

// 闪白效果
//static const char* FLASH_WHITE_FRAGMENT_SHADER =
//        "precision highp float;\n"
//        "varying vec2 textureCoordinate;\n"
//        "uniform sampler2D inputImageTexture;\n"
//        "uniform float exposureColor;\n"
//        "void main() {\n"
//        "    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);\n"
//        "    gl_FragColor = vec4(textureColor.r + exposureColor, textureColor.g + exposureColor, textureColor.b + exposureColor, textureColor.a);\n"
//        "}\n";

// 两分屏效果
static const char *SCREEN_TWO_FRAGMENT_SHADER =
        "precision highp float;                                                                 \n"
        "uniform sampler2D inputImageTexture;                                                   \n"
        "varying highp vec2 textureCoordinate;                                                  \n"
        "void main() {                                                                          \n"
        "    int col = int(textureCoordinate.y * 2.0);                                          \n"
        "    vec2 textureCoordinateToUse = textureCoordinate;                                   \n"
        "    textureCoordinateToUse.y = (textureCoordinate.y - float(col) / 2.0) * 2.0;         \n"
        "    textureCoordinateToUse.y = textureCoordinateToUse.y/960.0*480.0+1.0/4.0;           \n"
        "    gl_FragColor=texture2D(inputImageTexture, textureCoordinateToUse);                 \n"
        "}                                                                                      \n";

// 三分屏效果
static const char* SCREEN_THREE_FRAGMENT_SHADER =
        "precision highp float;                                                                 \n"
        "uniform sampler2D inputImageTexture;                                                   \n"
        "varying highp vec2 textureCoordinate;                                                  \n"
        "void main() {                                                                          \n"
        "    int col = int(textureCoordinate.y * 3.0);                                          \n"
        "    vec2 textureCoordinateToUse = textureCoordinate;                                   \n"
        "    textureCoordinateToUse.y = (textureCoordinate.y - float(col) / 3.0) * 3.0;         \n"
        "    textureCoordinateToUse.y = textureCoordinateToUse.y/960.0*320.0+1.0/3.0;           \n"
        "    gl_FragColor=texture2D(inputImageTexture, textureCoordinateToUse);                 \n"
        "}                                                                                      \n";

// 四分屏效果
static const char* SCREEN_FOUR_FRAGMENT_SHADER =
        "precision highp float;                                                                 \n"
        "uniform sampler2D inputImageTexture;                                                   \n"
        "varying highp vec2 textureCoordinate;                                                  \n"
        "void main() {                                                                          \n"
        "    int row = int(textureCoordinate.x * 2.0);                                          \n"
        "    int col = int(textureCoordinate.y * 2.0);                                          \n"
        "    vec2 textureCoordinateToUse = textureCoordinate;                                   \n"
        "    textureCoordinateToUse.x = (textureCoordinate.x - float(row) / 2.0) * 2.0;         \n"
        "    textureCoordinateToUse.y = (textureCoordinate.y - float(col) / 2.0) * 2.0;         \n"
        "    gl_FragColor=texture2D(inputImageTexture, textureCoordinateToUse);                 \n"
        "}                                                                                      \n";

// 六分屏效果
static const char* SCREEN_SIX_FRAGMENT_SHADER =
        "precision highp float;                                                                 \n"
        "uniform sampler2D inputImageTexture;                                                   \n"
        "varying highp vec2 textureCoordinate;                                                  \n"
        "void main() {                                                                          \n"
        "    int row = int(textureCoordinate.x * 3.0);                                          \n"
        "    int col = int(textureCoordinate.y * 2.0);                                          \n"
        "    vec2 textureCoordinateToUse = textureCoordinate;                                   \n"
        "    textureCoordinateToUse.x = (textureCoordinate.x - float(row) / 3.0) * 3.0;         \n"
        "    textureCoordinateToUse.y = (textureCoordinate.y - float(col) / 2.0) * 2.0;         \n"
        "    textureCoordinateToUse.x = textureCoordinateToUse.x/540.0*360.0+90.0/540.0;        \n"
        "    gl_FragColor=texture2D(inputImageTexture, textureCoordinateToUse);                 \n"
        "}                                                                                      \n";

// 九分屏效果
static const char* SCREEN_NINE_FRAGMENT_SHADER =
        "precision highp float;                                                                 \n"
        "uniform sampler2D inputImageTexture;                                                   \n"
        "varying highp vec2 textureCoordinate;                                                  \n"
        "void main() {                                                                          \n"
        "    int row = int(textureCoordinate.x * 3.0);                                          \n"
        "    int col = int(textureCoordinate.y * 3.0);                                          \n"
        "    vec2 textureCoordinateToUse = textureCoordinate;                                   \n"
        "    textureCoordinateToUse.x = (textureCoordinate.x - float(row) / 3.0) * 3.0;         \n"
        "    textureCoordinateToUse.y = (textureCoordinate.y - float(col) / 3.0) * 3.0;         \n"
        "    gl_FragColor=texture2D(inputImageTexture, textureCoordinateToUse);                 \n"
        "}                                                                                      \n";

#endif //TRINITY_GL_H
