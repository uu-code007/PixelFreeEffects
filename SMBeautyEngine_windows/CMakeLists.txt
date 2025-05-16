cmake_minimum_required(VERSION 3.10)
project(SMBeautyEngine_windows)

set(CMAKE_CXX_STANDARD 14)

# 设置MSVC运行时库和调试级别
if(MSVC)
    # 使用静态发布运行时库
    set(CMAKE_CXX_FLAGS_DEBUG "/MT /Zi /Ob0 /Od")
    set(CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /DNDEBUG")
    
    # 设置迭代器调试级别为0（发布模式）
    add_definitions(-D_ITERATOR_DEBUG_LEVEL=0)
    
    # 禁用特定警告
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    
    # 设置运行时库
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")
endif()

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 设置 GLAD 相关路径
set(GLAD_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/glad/include")
set(GLAD_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/glad/src")

# 设置 STB 相关路径
set(STB_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/stb")

# 查找OpenGL包
find_package(OpenGL REQUIRED)

# 设置链接库列表
set(LINK_LIBS "")

# 检测Windows平台类型
if(WIN32)
    # 检测是否为64位平台
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(WIN64 TRUE)
        message(STATUS "Targeting 64-bit Windows")
        add_definitions(-DWIN64)
    else()
        set(WIN64 FALSE)
        message(STATUS "Targeting 32-bit Windows")
    endif()
endif()

# 针对64位Windows的特定库
if(WIN64)
    list(APPEND LINK_LIBS opengl32 glu32 gdi32 user32 kernel32)
# 针对32位Windows的特定库
elseif(WIN32)
    list(APPEND LINK_LIBS opengl32 glu32 gdi32 user32 kernel32)
endif()

# GLFW3手动设置
message(STATUS "Using bundled GLFW3 paths")
set(GLFW3_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/third_party/glfw/include")
set(GLFW3_LIBRARIES "${CMAKE_CURRENT_SOURCE_DIR}/third_party/glfw/glfw3.lib")
list(APPEND LINK_LIBS ${GLFW3_LIBRARIES})

# 添加pixelFree库
list(APPEND LINK_LIBS ${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/pixelFree.lib)

# 设置包含目录
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/Include
    ${STB_INCLUDE_DIR}
    ${GLFW3_INCLUDE_DIRS}
    ${OPENGL_INCLUDE_DIRS}
    ${GLAD_INCLUDE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/glfw/include
)

# 如果是Windows平台，添加Windows SDK路径
if(WIN32)
    if(MSVC)
        # 添加Windows SDK路径
        include_directories("C:/Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/um"
                          "C:/Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/shared"
                          "C:/Program Files (x86)/Windows Kits/10/Include/10.0.19041.0/ucrt")
    endif()
endif()

# 添加源文件
set(SOURCE_FILES
    src/main.cpp
    src/opengl.cpp
    ${GLAD_SOURCE_DIR}/glad.cc
)

# 创建可执行文件
add_executable(SMBeautyEngine_windows ${SOURCE_FILES})

# 链接所有库
target_link_libraries(SMBeautyEngine_windows ${LINK_LIBS})

# 复制资源文件到输出目录
if(WIN32)
    # 使用简单的复制命令
    add_custom_command(TARGET SMBeautyEngine_windows POST_BUILD
        COMMAND cmd /c "if not exist \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}\\Res\" mkdir \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}\\Res\""
        COMMAND cmd /c "xcopy /Y /E /I \"${CMAKE_CURRENT_SOURCE_DIR}\\Res\\*\" \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}\\Res\\\""
        COMMAND cmd /c "copy /Y \"${CMAKE_CURRENT_SOURCE_DIR}\\IMG_2406.png\" \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}\""
        COMMAND cmd /c "copy /Y \"${CMAKE_CURRENT_SOURCE_DIR}\\pixelfreeLib\\pixelFree.dll\" \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}\""
    )
else()
    # 使用 CMake 命令（非 Windows 平台）
    add_custom_command(TARGET SMBeautyEngine_windows POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Res"
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/Res" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Res"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/IMG_2406.png" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/pixelFree.dll" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    )
endif() 