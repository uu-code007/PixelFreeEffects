#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "gl.h"
#include "opengl.h"
#include "pixelFree_c.hpp"
#include <unistd.h> // for usleep
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

bool dragging = false;
double lastX = 0, lastY = 0;

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

void error_callback(int error, const char* description) {
    std::cerr << "GLFW Error " << error << ": " << description << std::endl;
}

// int main() {
//     try {
//         // 设置错误回调
//         glfwSetErrorCallback(error_callback);

//         // 初始化GLFW
//         if (!glfwInit()) {
//             std::cerr << "Failed to initialize GLFW" << std::endl;
//             const char* error;
//             int error_code = glfwGetError(&error);
//             if (error) {
//                 std::cerr << "GLFW Error " << error_code << ": " << error << std::endl;
//             }
//             return -1;
//         }

//         // 设置OpenGL版本和核心模式
//         glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
//         glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
//         glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
//         glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
//         glfwWindowHint(GLFW_VISIBLE, GLFW_TRUE);
//         glfwWindowHint(GLFW_DECORATED, GLFW_TRUE);
//         glfwWindowHint(GLFW_FOCUSED, GLFW_TRUE);
//         glfwWindowHint(GLFW_AUTO_ICONIFY, GLFW_TRUE);
//         glfwWindowHint(GLFW_FLOATING, GLFW_FALSE);
//         glfwWindowHint(GLFW_MAXIMIZED, GLFW_FALSE);
//         glfwWindowHint(GLFW_CENTER_CURSOR, GLFW_TRUE);
//         glfwWindowHint(GLFW_TRANSPARENT_FRAMEBUFFER, GLFW_FALSE);
//         glfwWindowHint(GLFW_FOCUS_ON_SHOW, GLFW_TRUE);
//         glfwWindowHint(GLFW_SCALE_TO_MONITOR, GLFW_FALSE);
//         glfwWindowHint(GLFW_COCOA_RETINA_FRAMEBUFFER, GLFW_FALSE);
//         glfwWindowHint(GLFW_COCOA_GRAPHICS_SWITCHING, GLFW_FALSE);

//         // 创建窗口
//         GLFWwindow* window = glfwCreateWindow(720, 1024, "SMBeautyEngine Linux", nullptr, nullptr);
//         if(!window) {
//             std::cerr << "Failed to create GLFW window" << std::endl;
//             const char* error;
//             int error_code = glfwGetError(&error);
//             if (error) {
//                 std::cerr << "GLFW Error " << error_code << ": " << error << std::endl;
//             }
//             glfwTerminate();
//             return -1;
//         }
        
//         // 设置当前上下文
//         glfwMakeContextCurrent(window);
        
//         // 初始化GLAD
//         if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
//             std::cerr << "Failed to initialize GLAD" << std::endl;
//             glfwTerminate();
//             return -1;
//         }

//         // 打印OpenGL版本信息
//         std::cout << "OpenGL Version: " << glGetString(GL_VERSION) << std::endl;
//         std::cout << "GLSL Version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl;
//         std::cout << "Vendor: " << glGetString(GL_VENDOR) << std::endl;
//         std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;
        
//         std::string resPath = "Res";
//         std::string authPath = resPath + "/pixelfreeAuth.lic";
//         std::string filterPath = resPath + "/filter_model.bundle";
//         std::string imagePath = "IMG_2406.png";
        
//         // 读取授权文件
//         std::ifstream authFile(authPath, std::ios::binary);
//         if (!authFile) {
//             std::cerr << "Failed to open auth file" << std::endl;
//             return -1;
//         }
        
//         authFile.seekg(0, std::ios::end);
//         std::streamsize size = authFile.tellg();
//         authFile.seekg(0, std::ios::beg);
        
//         std::vector<char> authBuffer(size);
//         if (!authFile.read(authBuffer.data(), size)) {
//             std::cerr << "Failed to read auth file" << std::endl;
//             return -1;
//         }
        
//         // 创建 PixelFree handle
//         PFPixelFree* handle = PF_NewPixelFree();
//         if (handle == nullptr) {
//             std::cerr << "Failed to create PixelFree handle" << std::endl;
//             return -1;
//         }
        
//         // 初始化授权
//         PF_createBeautyItemFormBundle(handle, authBuffer.data(), (int)size, PFSrcTypeAuthFile);
        
//         // 读取滤镜文件
//         std::ifstream filterFile(filterPath, std::ios::binary);
//         if (!filterFile) {
//             std::cerr << "Failed to open filter file" << std::endl;
//             PF_DeletePixelFree(handle);
//             return -1;
//         }
        
//         filterFile.seekg(0, std::ios::end);
//         int filterSize = filterFile.tellg();
//         filterFile.seekg(0, std::ios::beg);
        
//         std::vector<char> filterBuffer(filterSize);
//         if (!filterFile.read(filterBuffer.data(), filterSize)) {
//             std::cerr << "Failed to read filter file" << std::endl;
//             PF_DeletePixelFree(handle);
//             return -1;
//         }
        
//         PF_createBeautyItemFormBundle(handle, filterBuffer.data(), filterSize, PFSrcTypeFilter);
//         const char *param = "heibai1";
//         PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterName, (void*)param);
//         float value = 1.0f;
//         PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFace_narrow, &value);
//         PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFace_V, &value);
        
//         glfwSetKeyCallback(window, keyCallback);
//         glfwSetMouseButtonCallback(window, mouse_button_callback);
//         glfwSetCursorPosCallback(window, cursor_position_callback);
        
//         glDisable(GL_DEPTH_TEST);
        
//         int window_width, window_height;
//         glfwGetFramebufferSize(window, &window_width, &window_height);
//         pixelfree::OpenGL render_screen(window_width, window_height, DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER);
        
//         // 加载图像
//         int width, height, nrChannels;
//         stbio_set_flip_vertically_on_load(true);
//         unsigned char *data = stbio_load(imagePath.c_str(), &width, &height, &nrChannels, 0);
//         if (!data) {
//             std::cerr << "Failed to load image" << std::endl;
//             PF_DeletePixelFree(handle);
//             return -1;
//         }
        
//         GLuint texture_id;
//         glGenTextures(1, &texture_id);
        
//         // 主循环
//         while(!glfwWindowShouldClose(window)) {
//             glfwPollEvents();
            
//             glActiveTexture(GL_TEXTURE0);
//             glBindTexture(GL_TEXTURE_2D, texture_id);
//             glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//             glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//             glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//             glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//             glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
//             glBindTexture(GL_TEXTURE_2D, 0);
            
//             PFImageInput image;
//             image.textureID = texture_id;
//             image.p_data0 = data;
//             image.wigth = width;
//             image.height = height;
//             image.stride_0 = width * 4;
//             image.format = PFFORMAT_IMAGE_TEXTURE;
//             image.rotationMode = PFRotationMode180;
//             int outTexture = PF_processWithBuffer(handle, image);
            
//             render_screen.ActiveProgram();
//             render_screen.ProcessImage(outTexture);
//             glfwSwapBuffers(window);
            
//             usleep(30000); // Linux下的Sleep替代
//         }
        
//         // 清理资源
//         stbio_image_free(data);
//         glDeleteTextures(1, &texture_id);
//         glfwTerminate();
//         PF_DeletePixelFree(handle);
        
//     } catch (const std::exception& e) {
//         std::cerr << "Error: " << e.what() << std::endl;
//         return -1;
//     } catch (...) {
//         std::cerr << "Unknown error occurred" << std::endl;
//         return -1;
//     }
    
//     return 0;
// } 


int main() {
    try {
        
        std::string resPath = "Res";
        std::string authPath = resPath + "/pixelfreeAuth.lic";
        std::string filterPath = resPath + "/filter_model.bundle";
        std::string imagePath = "IMG_2406.png";
        
        // 读取授权文件
        std::ifstream authFile(authPath, std::ios::binary);
        if (!authFile) {
            std::cerr << "Failed to open auth file" << std::endl;
            return -1;
        }
        
        authFile.seekg(0, std::ios::end);
        std::streamsize size = authFile.tellg();
        authFile.seekg(0, std::ios::beg);
        
        std::vector<char> authBuffer(size);
        if (!authFile.read(authBuffer.data(), size)) {
            std::cerr << "Failed to read auth file" << std::endl;
            return -1;
        }
        
        // 创建 PixelFree handle
        PFPixelFree* handle = PF_NewPixelFree();
        if (handle == nullptr) {
            std::cerr << "Failed to create PixelFree handle" << std::endl;
            return -1;
        }
        
        // 初始化授权
        PF_createBeautyItemFormBundle(handle, authBuffer.data(), (int)size, PFSrcTypeAuthFile);
        
        // 读取滤镜文件
        std::ifstream filterFile(filterPath, std::ios::binary);
        if (!filterFile) {
            std::cerr << "Failed to open filter file" << std::endl;
            PF_DeletePixelFree(handle);
            return -1;
        }
        
        filterFile.seekg(0, std::ios::end);
        int filterSize = filterFile.tellg();
        filterFile.seekg(0, std::ios::beg);
        
        std::vector<char> filterBuffer(filterSize);
        if (!filterFile.read(filterBuffer.data(), filterSize)) {
            std::cerr << "Failed to read filter file" << std::endl;
            PF_DeletePixelFree(handle);
            return -1;
        }
        
        PF_createBeautyItemFormBundle(handle, filterBuffer.data(), filterSize, PFSrcTypeFilter);
        const char *param = "heibai1";
        PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterName, (void*)param);
        float value = 1.0f;
        PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFace_narrow, &value);
        PF_pixelFreeSetBeautyFilterParam(handle, PFBeautyFilterTypeFace_V, &value);
        
        // 加载图像
        printf("outTexture -- PF_processWithBuffer1: %d\n");
        int width, height, nrChannels;
        stbio_set_flip_vertically_on_load(true);
        unsigned char *data = stbio_load(imagePath.c_str(), &width, &height, &nrChannels, 0);
        if (!data) {
            std::cerr << "Failed to load image" << std::endl;
            PF_DeletePixelFree(handle);
            return -1;
        }
        
        printf("outTexture -- PF_processWithBuffer: %d\n");
        GLuint texture_id;
        glGenTextures(1, &texture_id);
        
            printf("outTexture -- PF_processWithBuffer: %d\n");
            PFImageInput image;
            image.textureID = texture_id;
            image.p_data0 = data;
            image.wigth = width;
            image.height = height;
            image.stride_0 = width * 4;
            image.format = PFFORMAT_IMAGE_TEXTURE;
            image.rotationMode = PFRotationMode180;
            int outTexture = PF_processWithBuffer(handle, image);
            
            printf("outTexture: %d\n", outTexture);
        // 清理资源
        stbio_image_free(data);
        glDeleteTextures(1, &texture_id);
        glfwTerminate();
        PF_DeletePixelFree(handle);
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return -1;
    } catch (...) {
        std::cerr << "Unknown error occurred" << std::endl;
        return -1;
    }
    
    return 0;
} 