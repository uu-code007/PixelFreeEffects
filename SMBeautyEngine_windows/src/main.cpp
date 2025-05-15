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
//  main.cpp
//  SMBeautyEngine_windows
//

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <vector>
#include <string>
#include <windows.h>
#include "opengl.h"   // 这个头文件会引入所有必要的OpenGL相关头文件
#include <GLFW/glfw3.h>
#include "stb_image.h"
#include "pixelFree_c.hpp"

// 定义 OpenGL 扩展函数指针
PFNGLACTIVETEXTUREPROC glActiveTexture = NULL;

bool dragging = false; // 标志变量，指示是否正在拖动
double lastX = 0, lastY = 0; // 上次鼠标位置

// 定义着色器源代码
const char* DEFAULT_VERTEX_SHADER = R"(
attribute vec4 position;
attribute vec4 inputTextureCoordinate;
varying vec2 textureCoordinate;
void main() {
    gl_Position = position;
    textureCoordinate = inputTextureCoordinate.xy;
}
)";

const char* DEFAULT_FRAGMENT_SHADER = R"(
varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
void main() {
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
}
)";

// 获取可执行文件所在目录
std::string GetExePath() {
    char buffer[MAX_PATH];
    GetModuleFileNameA(NULL, buffer, MAX_PATH);
    std::string::size_type pos = std::string(buffer).find_last_of("\\/");
    return std::string(buffer).substr(0, pos);
}

void mouse_button_callback(GLFWwindow* window, int button, int action, int mods) {
    if (button == GLFW_MOUSE_BUTTON_LEFT) {
        if (action == GLFW_PRESS) {
            dragging = true; // 开始拖动
            glfwGetCursorPos(window, &lastX, &lastY); // 获取初始位置
            std::cout << "Started dragging at (" << lastX << ", " << lastY << ")\n";
        } else if (action == GLFW_RELEASE) {
            dragging = false; // 结束拖动
            std::cout << "Stopped dragging\n";
        }
    }
}

void cursor_position_callback(GLFWwindow* window, double xpos, double ypos) {
    if (dragging) {
        double deltaX = xpos - lastX; // 计算鼠标移动的距离
        double deltaY = ypos - lastY;
        std::cout << "Dragging to (" << xpos << ", " << ypos << "), delta: ("
                  << deltaX << ", " << deltaY << ")\n";
        
        lastX = xpos; // 更新最后位置
        lastY = ypos;
    }
}

unsigned char* flip_image_y(unsigned char* data, int width, int height, int nrChannels) {
    unsigned char* flippedData = (unsigned char*)malloc(width * height * nrChannels);
    if (!flippedData) {
        fprintf(stderr, "Failed to allocate memory for flipped image\n");
        return NULL;
    }

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            for (int c = 0; c < nrChannels; c++) {
                flippedData[(height - 1 - y) * width * nrChannels + x * nrChannels + c] =
                    data[y * width * nrChannels + x * nrChannels + c];
            }
        }
    }

    return flippedData;
}

void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mode) {
    if(key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE);
    }
}

int main() {
    glfwInit();
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
    GLFWwindow* window = glfwCreateWindow(720, 1024, "SMBeautyEngine Windows", nullptr, nullptr);
    if(!window) {
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    
    // 初始化 OpenGL 扩展函数指针
    glActiveTexture = (PFNGLACTIVETEXTUREPROC)wglGetProcAddress("glActiveTexture");
    if (!glActiveTexture) {
        std::cerr << "无法获取 glActiveTexture 函数指针！" << std::endl;
        glfwTerminate();
        return -1;
    }
    
    // 获取可执行文件路径，用于定位资源文件
    std::string exePath = GetExePath();
    std::string resPath = exePath + "\\Res";
    std::string authPath = resPath + "\\pixelfreeAuth.lic";
    std::string filterPath = resPath + "\\filter_model.bundle";
    std::string imagePath = exePath + "\\IMG_2406.png";
    
    PFPixelFree* handle = PF_NewPixelFree();

    // 读取授权文件
    std::ifstream file(authPath, std::ios::binary);
    if (!file) {
        std::cerr << "无法打开授权文件: " << authPath << std::endl;
        return -1;
    }
    
    // 获取文件大小
    file.seekg(0, std::ios::end);
    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);

    // 读取文件内容到缓冲区
    std::vector<char> authBuffer(size);
    if (file.read(authBuffer.data(), size)) {
        std::cout << "成功读取授权文件: " << size << " 字节." << std::endl;
    } else {
        std::cerr << "读取授权文件失败." << std::endl;
        return -1;
    }
    
    PF_createBeautyItemFormBundle(handle, authBuffer.data(), (int)size, PFSrcTypeAuthFile);
    
    // 设置一个窄脸，并将程度设置成最大
    float faceStrength = 1.0;
    PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterTypeFace_narrow, &faceStrength);
    
    // 读取滤镜文件
    std::ifstream file2(filterPath, std::ios::binary);
    if (!file2) {
        std::cerr << "无法打开滤镜文件: " << filterPath << std::endl;
        return -1;
    }
    
    // 获取文件大小
    file2.seekg(0, std::ios::end);
    size = file2.tellg();
    file2.seekg(0, std::ios::beg);

    // 读取文件内容到缓冲区
    std::vector<char> filterBuffer(size);
    if (file2.read(filterBuffer.data(), size)) {
        std::cout << "成功读取滤镜文件: " << size << " 字节." << std::endl;
    } else {
        std::cerr << "读取滤镜文件失败." << std::endl;
        return -1;
    }
    
    PF_createBeautyItemFormBundle(handle, filterBuffer.data(), (int)size, PFSrcTypeFilter);
    
    // 设置回调
    glfwSetKeyCallback(window, keyCallback);
    glfwSetMouseButtonCallback(window, mouse_button_callback);
    glfwSetCursorPosCallback(window, cursor_position_callback);

    glDisable(GL_DEPTH_TEST);

    int window_width;
    int window_height;
    glfwGetFramebufferSize(window, &window_width, &window_height);
    pixelfree::OpenGL render_screen(window_width, window_height, DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER);
    
    // 加载图像
    int nrChannels;
    stbio_set_flip_vertically_on_load(true);
    int width;
    int height;
    GLuint texture_id;

    // 加载测试图片
    unsigned char *data = stbio_load((char*)imagePath.c_str(), &width, &height, &nrChannels, 0);
    if (!data) {
        std::cerr << "无法加载图片: " << imagePath << std::endl;
        return -1;
    }
    
    printf("图片尺寸: width = %d height = %d channels = %d\n", width, height, nrChannels);
    
    // 处理 Y 轴翻转
    unsigned char* flippedData = flip_image_y(data, width, height, nrChannels);

    glGenTextures(1, &texture_id);

    // 主循环
    while(!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture_id);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, flippedData);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        PFIamgeInput image;
        image.textureID = texture_id;
        image.p_data0 = data;
        image.wigth = width;
        image.height = height;
        image.stride_0 = width * 4;
        image.format = PFFORMAT_IMAGE_TEXTURE;
        image.rotationMode = PFRotationMode0;
        PF_processWithBuffer(handle, image);
        
        render_screen.ActiveProgram();
        render_screen.ProcessImage(texture_id);
        glfwSwapBuffers(window);
        
        // 使用Windows的Sleep代替Mac的usleep
        Sleep(30); // 30毫秒
    }
    
    // 清理资源
    stbio_image_free(data);
    free(flippedData);
    glDeleteTextures(1, &texture_id);
    glfwTerminate();
    PF_DeletePixelFree(handle);

    return 0;
} 