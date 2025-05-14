cmake_minimum_required(VERSION 3.10)
project(SMBeautyEngine_windows)

set(CMAKE_CXX_STANDARD 14)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

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
    ${CMAKE_CURRENT_SOURCE_DIR}/stb
    ${GLFW3_INCLUDE_DIRS}
    ${OPENGL_INCLUDE_DIRS}
)

# 添加源文件
set(SOURCE_FILES
    src/main.cpp
    src/opengl.cpp
    src/stb_image.cpp
)

# 创建可执行文件
add_executable(SMBeautyEngine_windows ${SOURCE_FILES})

# 链接所有库
target_link_libraries(SMBeautyEngine_windows ${LINK_LIBS})

# 复制资源文件到输出目录
add_custom_command(TARGET SMBeautyEngine_windows POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_CURRENT_SOURCE_DIR}/Res $<TARGET_FILE_DIR:SMBeautyEngine_windows>/Res
)
add_custom_command(TARGET SMBeautyEngine_windows POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_SOURCE_DIR}/IMG_2406.png $<TARGET_FILE_DIR:SMBeautyEngine_windows>/IMG_2406.png
)
add_custom_command(TARGET SMBeautyEngine_windows POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/pixelFree.dll $<TARGET_FILE_DIR:SMBeautyEngine_windows>/pixelFree.dll
) 