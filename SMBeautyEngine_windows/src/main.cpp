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
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <windows.h>
#include "opengl.h"
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "pixelFree_c.hpp"

bool dragging = false;
double lastX = 0, lastY = 0;

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
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
void main() {
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
}
)";

std::string GetExePath() {
    char buffer[MAX_PATH];
    GetModuleFileNameA(NULL, buffer, MAX_PATH);
    std::string::size_type pos = std::string(buffer).find_last_of("\\/");
    return std::string(buffer).substr(0, pos);
}

void mouse_button_callback(GLFWwindow* window, int button, int action, int mods) {
    if (button == GLFW_MOUSE_BUTTON_LEFT) {
        if (action == GLFW_PRESS) {
            dragging = true;
            glfwGetCursorPos(window, &lastX, &lastY);
        } else if (action == GLFW_RELEASE) {
            dragging = false;
        }
    }
}

void cursor_position_callback(GLFWwindow* window, double xpos, double ypos) {
    if (dragging) {
        double deltaX = xpos - lastX;
        double deltaY = ypos - lastY;
        lastX = xpos;
        lastY = ypos;
    }
}

void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mode) {
    if(key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE);
    }
}

int main() {
    try {
        glfwInit();
        glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
        GLFWwindow* window = glfwCreateWindow(720, 1024, "SMBeautyEngine Windows", nullptr, nullptr);
        if(!window) {
            glfwTerminate();
            return -1;
        }
        
        glfwMakeContextCurrent(window);
        
        if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
            glfwTerminate();
            return -1;
        }
        
        std::string exePath = GetExePath();
        std::string resPath = exePath + "\\Res";
        std::string authPath = resPath + "\\pixelfreeAuth.lic";
        std::string filterPath = resPath + "\\filter_model.bundle";
        std::string imagePath = exePath + "\\IMG_2406.png";
        
        // 读取授权文件
        std::ifstream authFile(authPath, std::ios::binary);
        if (!authFile) {
            return -1;
        }
        
        authFile.seekg(0, std::ios::end);
        std::streamsize size = authFile.tellg();
        authFile.seekg(0, std::ios::beg);
        
        std::vector<char> authBuffer(size);
        if (!authFile.read(authBuffer.data(), size)) {
            return -1;
        }
        
        // 创建 PixelFree handle
        PFPixelFree* handle = PF_NewPixelFree();
        if (handle == nullptr) {
            return -1;
        }
        
        // 初始化授权
        PF_createBeautyItemFormBundle(handle, authBuffer.data(), (int)size, PFSrcTypeAuthFile);
        
        // 读取滤镜文件
        std::ifstream filterFile(filterPath, std::ios::binary);
        if (!filterFile) {
            PF_DeletePixelFree(handle);
            return -1;
        }
        
        filterFile.seekg(0, std::ios::end);
        int filterSize = filterFile.tellg();
        filterFile.seekg(0, std::ios::beg);
        
        std::vector<char> filterBuffer(filterSize);
        if (!filterFile.read(filterBuffer.data(), filterSize)) {
            PF_DeletePixelFree(handle);
            return -1;
        }
        
        PF_createBeautyItemFormBundle(handle, filterBuffer.data(), filterSize, PFSrcTypeFilter);
        const char *param = "heibai1";
        PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterName, (void*)param);
        float value = 1.0f;
        PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterTypeFace_narrow, &value);
        PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterTypeFace_V, &value);
        
        glfwSetKeyCallback(window, keyCallback);
        glfwSetMouseButtonCallback(window, mouse_button_callback);
        glfwSetCursorPosCallback(window, cursor_position_callback);
        
        glDisable(GL_DEPTH_TEST);
        
        int window_width, window_height;
        glfwGetFramebufferSize(window, &window_width, &window_height);
        pixelfree::OpenGL render_screen(window_width, window_height, DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER);
        
        // 加载图像
        int width, height, nrChannels;
        stbio_set_flip_vertically_on_load(true);
        unsigned char *data = stbio_load(imagePath.c_str(), &width, &height, &nrChannels, 0);
        if (!data) {
            PF_DeletePixelFree(handle);
            return -1;
        }
        
        GLuint texture_id;
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
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
            glBindTexture(GL_TEXTURE_2D, 0);
            
            PFIamgeInput image;
            image.textureID = texture_id;
            image.p_data0 = data;
            image.wigth = width;
            image.height = height;
            image.stride_0 = width * 4;
            image.format = PFFORMAT_IMAGE_TEXTURE;
            image.rotationMode = PFRotationMode180;
            int outTexture = PF_processWithBuffer(handle, image);
            
            render_screen.ActiveProgram();
            render_screen.ProcessImage(outTexture);
            glfwSwapBuffers(window);
            
            Sleep(30);
        }
        
        // 清理资源
        stbio_image_free(data);
        glDeleteTextures(1, &texture_id);
        glfwTerminate();
        PF_DeletePixelFree(handle);
        
    } catch (...) {
        return -1;
    }
    
    return 0;
} 