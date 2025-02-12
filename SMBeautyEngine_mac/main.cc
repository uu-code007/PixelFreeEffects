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
//  main.cc
//  opengl
//
//  Created by wlanjie on 2019/8/26.
//  Copyright © 2019 com.wlanjie.opengl. All rights reserved.
//

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#include <iostream>
#include <fstream>

#include <stdio.h>
#include <glfw3.h>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>
#include <OpenGL/glext.h>
#include <time.h>
#include <unistd.h>
#include "opengl.h"
#include "gl.h"

#include <iostream>
#include <fstream>
#include <vector>

#define STB_IMAGE_IMPLEMENTATION

#include "stb_image.h"
#include "pixelfreeLib/Include/pixelFree_c.hpp"
//
//extern "C" {
//#include "cJSON.h"
//}

bool dragging = false; // 标志变量，指示是否正在拖动
double lastX, lastY;   // 上一次鼠标位置

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
    GLFWwindow* window = glfwCreateWindow(720, 1024, "OpenGL", nullptr, nullptr);
    if(!window) {
        glfwTerminate();
    }
    glfwMakeContextCurrent(window);
    

    PFPixelFree* handle = PF_NewPixelFree();

    // 打开文件
    // TODO: 替换本地绝对路径
    std::ifstream file("/Users/keyes/Desktop/mumuFU/push_github/SMBeautyEngine/SMBeautyEngine_mac/Res/pixelfreeAuth.lic", std::ios::binary);
    // 获取文件大小
    file.seekg(0, std::ios::end);
    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);

    // 读取文件内容到缓冲区
    std::vector<char> authBuffer(size);
    if (file.read(authBuffer.data(), size)) {
        std::cout << "成功读取 " << size << " 字节." << std::endl;
    } else {
        std::cerr << "读取文件失败." << std::endl;
    }
    
    PF_createBeautyItemFormBundle(handle, authBuffer.data(), (int)size, PFSrcTypeAuthFile);
    
    // 设置一个黑白滤镜
//    std::string filter = "heibai1";
//    PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterName, (void *)filter.c_str());
//    float aa = 1.0;
//    PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterStrength, &aa);
    
    // 设置一个窄脸，并将程度设置成最大
    float aa = 1.0;
    PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterTypeFace_narrow, &aa);
    
    // TODO: 替换本地绝对路径
    std::ifstream file2("/Users/keyes/Desktop/mumuFU/push_github/SMBeautyEngine/SMBeautyEngine_mac/Res/filter_model.bundle", std::ios::binary);
    // 获取文件大小
    file2.seekg(0, std::ios::end);
    size = file2.tellg();
    file2.seekg(0, std::ios::beg);

    // 读取文件内容到缓冲区
    std::vector<char> filterBuffer(size);
    if (file2.read(filterBuffer.data(), size)) {
        std::cout << "成功读取 " << size << " 字节." << std::endl;
    }
    PF_createBeautyItemFormBundle(handle, filterBuffer.data(), (int)size, PFSrcTypeFilter);
    
    
    glfwSetKeyCallback(window, keyCallback);
    
    glfwSetMouseButtonCallback(window, mouse_button_callback);
    glfwSetCursorPosCallback(window, cursor_position_callback);

    glDisable(GL_DEPTH_TEST);

    int window_width;
    int window_height;
    glfwGetFramebufferSize(window, &window_width, &window_height);
    pixelfree::OpenGL render_screen(window_width, window_height, DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER);
    
    int nrChannels;
    stbio_set_flip_vertically_on_load(true);
    int width;
    int height;
    GLuint texture_id;

    // TODO: 替换本地绝对路径
    unsigned char *data = stbio_load("/Users/keyes/Desktop/mumuFU/push_github/SMBeautyEngine/SMBeautyEngine_mac/IMG_2406.png", &width, &height, &nrChannels, 0);
    printf("width = %d height = %d\n", width, height);
    
    // 处理 Y 轴翻转
    unsigned char* flippedData = flip_image_y(data, width, height, nrChannels);

    glGenTextures(1, &texture_id);


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
        usleep(30 * 1000);
    }
    
    stbio_image_free(data);
    free(flippedData);
    glDeleteTextures(1, &texture_id);
    glfwTerminate();

    return 0;
}



