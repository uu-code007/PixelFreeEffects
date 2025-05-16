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
#include <stdio.h>
#include <vector>
#include <string>
#include <windows.h>
#include <dbghelp.h>  // 用于堆栈跟踪
#include "opengl.h"   // 这个头文件会引入所有必要的OpenGL相关头文件
#include <glad/glad.h>  // GLAD must be included before GLFW
#include <GLFW/glfw3.h>
#include "pixelFree_c.hpp"

// Remove the manual function pointer definition since GLAD will handle this
// PFNGLACTIVETEXTUREPROC glActiveTexture = NULL;

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

// 设置堆栈跟踪
void InitStackTrace() {
    SymInitialize(GetCurrentProcess(), NULL, TRUE);
}

void PrintStackTrace() {
    HANDLE process = GetCurrentProcess();
    HANDLE thread = GetCurrentThread();

    CONTEXT context;
    context.ContextFlags = CONTEXT_FULL;
    RtlCaptureContext(&context);

    STACKFRAME64 frame;
    memset(&frame, 0, sizeof(frame));
    frame.AddrPC.Offset = context.Rip;
    frame.AddrPC.Mode = AddrModeFlat;
    frame.AddrFrame.Offset = context.Rbp;
    frame.AddrFrame.Mode = AddrModeFlat;
    frame.AddrStack.Offset = context.Rsp;
    frame.AddrStack.Mode = AddrModeFlat;

    std::cout << "Stack trace:" << std::endl;
    for (int i = 0; i < 25; i++) {
        if (!StackWalk64(IMAGE_FILE_MACHINE_AMD64, process, thread, &frame, &context, NULL, SymFunctionTableAccess64, SymGetModuleBase64, NULL)) {
            break;
        }
        std::cout << "Frame " << i << ": " << std::hex << frame.AddrPC.Offset << std::endl;
    }
}

// 验证静态库函数是否可用
bool VerifyStaticLibrary() {
    std::cout << "Verifying static library functions..." << std::endl;
    
    // 尝试获取函数地址
    void* funcPtr = (void*)PF_NewPixelFree;
    if (funcPtr == nullptr) {
        std::cerr << "Failed to get address of PF_NewPixelFree" << std::endl;
        return false;
    }
    std::cout << "PF_NewPixelFree function found at: " << std::hex << (uintptr_t)funcPtr << std::endl;
    
    funcPtr = (void*)PF_DeletePixelFree;
    if (funcPtr == nullptr) {
        std::cerr << "Failed to get address of PF_DeletePixelFree" << std::endl;
        return false;
    }
    std::cout << "PF_DeletePixelFree function found at: " << std::hex << (uintptr_t)funcPtr << std::endl;
    
    funcPtr = (void*)PF_createBeautyItemFormBundle;
    if (funcPtr == nullptr) {
        std::cerr << "Failed to get address of PF_createBeautyItemFormBundle" << std::endl;
        return false;
    }
    std::cout << "PF_createBeautyItemFormBundle function found at: " << std::hex << (uintptr_t)funcPtr << std::endl;
    
    return true;
}

// 设置异常处理
LONG WINAPI TopLevelExceptionHandler(EXCEPTION_POINTERS* pExceptionInfo) {
    // 获取当前目录
    char currentDir[MAX_PATH];
    GetCurrentDirectoryA(MAX_PATH, currentDir);
    std::string dumpPath = std::string(currentDir) + "\\crash.dmp";
    
    std::cerr << "Creating crash dump at: " << dumpPath << std::endl;
    
    // 创建 MiniDump 文件
    HANDLE hFile = CreateFileA(dumpPath.c_str(), GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile == INVALID_HANDLE_VALUE) {
        std::cerr << "Failed to create crash dump file. Error code: " << GetLastError() << std::endl;
        return EXCEPTION_CONTINUE_SEARCH;
    }

    MINIDUMP_EXCEPTION_INFORMATION exInfo;
    exInfo.ExceptionPointers = pExceptionInfo;
    exInfo.ThreadId = GetCurrentThreadId();
    exInfo.ClientPointers = TRUE;

    // 写入 MiniDump
    BOOL result = MiniDumpWriteDump(
        GetCurrentProcess(),
        GetCurrentProcessId(),
        hFile,
        MiniDumpNormal,
        &exInfo,
        NULL,
        NULL
    );

    if (!result) {
        std::cerr << "Failed to write crash dump. Error code: " << GetLastError() << std::endl;
    } else {
        std::cerr << "Crash dump created successfully" << std::endl;
    }

    CloseHandle(hFile);

    // 打印异常信息
    std::cerr << "Exception occurred!" << std::endl;
    std::cerr << "Exception code: 0x" << std::hex << pExceptionInfo->ExceptionRecord->ExceptionCode << std::endl;
    std::cerr << "Exception address: 0x" << std::hex << (uintptr_t)pExceptionInfo->ExceptionRecord->ExceptionAddress << std::endl;
    
    // 打印寄存器信息
    std::cerr << "Register values:" << std::endl;
    std::cerr << "RAX: 0x" << std::hex << pExceptionInfo->ContextRecord->Rax << std::endl;
    std::cerr << "RBX: 0x" << std::hex << pExceptionInfo->ContextRecord->Rbx << std::endl;
    std::cerr << "RCX: 0x" << std::hex << pExceptionInfo->ContextRecord->Rcx << std::endl;
    std::cerr << "RDX: 0x" << std::hex << pExceptionInfo->ContextRecord->Rdx << std::endl;
    std::cerr << "RSI: 0x" << std::hex << pExceptionInfo->ContextRecord->Rsi << std::endl;
    std::cerr << "RDI: 0x" << std::hex << pExceptionInfo->ContextRecord->Rdi << std::endl;
    std::cerr << "RIP: 0x" << std::hex << pExceptionInfo->ContextRecord->Rip << std::endl;
    std::cerr << "RSP: 0x" << std::hex << pExceptionInfo->ContextRecord->Rsp << std::endl;
    std::cerr << "RBP: 0x" << std::hex << pExceptionInfo->ContextRecord->Rbp << std::endl;

    return EXCEPTION_CONTINUE_SEARCH;
}

// 包装 PF_NewPixelFree 调用
PFPixelFree* SafeNewPixelFree() {
    PFPixelFree* handle = nullptr;
    try {
        handle = PF_NewPixelFree();
        if (handle == nullptr) {
            std::cerr << "PF_NewPixelFree returned null" << std::endl;
        }
    } catch (const std::exception& e) {
        std::cerr << "Exception in PF_NewPixelFree: " << e.what() << std::endl;
        throw;
    } catch (...) {
        std::cerr << "Unknown exception in PF_NewPixelFree" << std::endl;
        throw;
    }
    return handle;
}

int main() {
    try {
        // 设置异常处理器
        SetUnhandledExceptionFilter(TopLevelExceptionHandler);
        
        std::cout << "Program started..." << std::endl;
        
        // 验证静态库
        if (!VerifyStaticLibrary()) {
            std::cerr << "Static library verification failed!" << std::endl;
            return -1;
        }
        
        glfwInit();
        glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
        GLFWwindow* window = glfwCreateWindow(720, 1024, "SMBeautyEngine Windows", nullptr, nullptr);
        if(!window) {
            std::cerr << "Failed to create window!" << std::endl;
            glfwTerminate();
            return -1;
        }
        std::cout << "Window created successfully" << std::endl;
        
        glfwMakeContextCurrent(window);
        
        // Initialize GLAD
        if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
            std::cerr << "Failed to initialize GLAD" << std::endl;
            glfwTerminate();
            return -1;
        }
        std::cout << "GLAD initialized successfully" << std::endl;
        
        // 获取可执行文件路径，用于定位资源文件
        std::string exePath = GetExePath();
        std::cout << "Executable path: " << exePath << std::endl;
        
        std::string resPath = exePath + "\\Res";
        std::string authPath = resPath + "\\pixelfreeAuth.lic";
        std::string filterPath = resPath + "\\filter_model.bundle";
        std::string imagePath = exePath + "\\IMG_2406.png";
        
        std::cout << "Resource directory path: " << resPath << std::endl;
        std::cout << "Auth file path: " << authPath << std::endl;
        std::cout << "Filter file path: " << filterPath << std::endl;
        std::cout << "Image file path: " << imagePath << std::endl;
        
        // 检查文件是否存在
        if (GetFileAttributesA(resPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            std::cerr << "Resource directory does not exist: " << resPath << std::endl;
            std::cerr << "Error code: " << GetLastError() << std::endl;
        } else {
            std::cout << "Resource directory exists" << std::endl;
        }
        
        if (GetFileAttributesA(authPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            std::cerr << "Auth file does not exist: " << authPath << std::endl;
            std::cerr << "Error code: " << GetLastError() << std::endl;
        } else {
            std::cout << "Auth file exists" << std::endl;
        }
        
        if (GetFileAttributesA(filterPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            std::cerr << "Filter file does not exist: " << filterPath << std::endl;
            std::cerr << "Error code: " << GetLastError() << std::endl;
        } else {
            std::cout << "Filter file exists" << std::endl;
        }
        
        if (GetFileAttributesA(imagePath.c_str()) == INVALID_FILE_ATTRIBUTES) {
            std::cerr << "Image file does not exist: " << imagePath << std::endl;
            std::cerr << "Error code: " << GetLastError() << std::endl;
        } else {
            std::cout << "Image file exists" << std::endl;
        }
        
        std::cout << "About to create PixelFree handle..." << std::endl;
        PFPixelFree* handle = nullptr;
        try {
            // 在创建 handle 之前先读取授权文件
            std::ifstream authFile(authPath, std::ios::binary);
            if (!authFile) {
                std::cerr << "Cannot open auth file: " << authPath << std::endl;
                std::cerr << "Error code: " << GetLastError() << std::endl;
                return -1;
            }
            std::cout << "Auth file opened successfully" << std::endl;
            
            // 获取文件大小
            authFile.seekg(0, std::ios::end);
            std::streamsize size = authFile.tellg();
            authFile.seekg(0, std::ios::beg);
            
            // 读取文件内容到缓冲区
            std::vector<char> authBuffer(size);
            if (!authFile.read(authBuffer.data(), size)) {
                std::cerr << "Failed to read auth file" << std::endl;
                return -1;
            }
            std::cout << "Successfully read auth file: " << size << " bytes" << std::endl;
            

      
            
            // 创建 handle
            std::cout << "Calling PF_NewPixelFree()..." << std::endl;
            handle = SafeNewPixelFree();
            if (handle == nullptr) {
                std::cerr << "Failed to create PixelFree handle - returned null" << std::endl;
                return -1;
            }
            std::cout << "PixelFree handle created successfully" << std::endl;
            
            // 初始化授权
            std::cout << "About to initialize authorization..." << std::endl;
            std::cout << "Auth buffer size: " << size << " bytes" << std::endl;
            std::cout << "Auth buffer address: " << std::hex << (uintptr_t)authBuffer.data() << std::endl;
            std::cout << "Handle address: " << std::hex << (uintptr_t)handle << std::endl;
            
            PF_createBeautyItemFormBundle(handle, authBuffer.data(), (int)size, PFSrcTypeAuthFile);
            
        } catch (const std::exception& e) {
            std::cerr << "Exception while creating PixelFree handle: " << e.what() << std::endl;
            if (handle) {
                PF_DeletePixelFree(handle);
            }
            return -1;
        } catch (...) {
            std::cerr << "Unknown exception while creating PixelFree handle" << std::endl;
            if (handle) {
                PF_DeletePixelFree(handle);
            }
            return -1;
        }

        // 读取滤镜文件
        std::ifstream file2(filterPath, std::ios::binary);
        if (!file2) {
            std::cerr << "Cannot open filter file: " << filterPath << std::endl;
            return -1;
        }
        
        // 获取文件大小
        file2.seekg(0, std::ios::end);
        int size = file2.tellg();
        file2.seekg(0, std::ios::beg);

        // 读取文件内容到缓冲区
        std::vector<char> filterBuffer(size);
        if (file2.read(filterBuffer.data(), size)) {
            std::cout << "Successfully read filter file: " << size << " bytes." << std::endl;
        } else {
            std::cerr << "Failed to read filter file." << std::endl;
            return -1;
        }
        
        // PF_createBeautyItemFormBundle(handle, filterBuffer.data(), (int)size, PFSrcTypeFilter);
        
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
            std::cerr << "Failed to load image: " << imagePath << std::endl;
            return -1;
        }
        
        printf("Image size: width = %d height = %d channels = %d\n", width, height, nrChannels);
        
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
            
            // PFIamgeInput image;
            // image.textureID = texture_id;
            // image.p_data0 = data;
            // image.wigth = width;
            // image.height = height;
            // image.stride_0 = width * 4;
            // image.format = PFFORMAT_IMAGE_TEXTURE;
            // image.rotationMode = PFRotationMode0;
            // PF_processWithBuffer(handle, image);
            
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
        // PF_DeletePixelFree(handle);

    } catch (const std::exception& e) {
        std::cerr << "Exception in main: " << e.what() << std::endl;
        return -1;
    } catch (...) {
        std::cerr << "Unknown exception in main" << std::endl;
        return -1;
    }
    
    return 0;
} 