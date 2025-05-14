cmake_minimum_required(VERSION 3.10)
project(SMBeautyEngine_windows)

set(CMAKE_CXX_STANDARD 14)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 设置包含目录
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/stb
)

# 查找OpenGL和GLFW库
find_package(OpenGL REQUIRED)
find_package(GLFW3 REQUIRED)

# 如果找不到GLFW3，可以在Windows上手动设置
if (NOT GLFW3_FOUND)
    message(STATUS "GLFW3 not found via find_package, using bundled paths")
    set(GLFW3_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/external/glfw/include")
    set(GLFW3_LIBRARIES "${CMAKE_CURRENT_SOURCE_DIR}/external/glfw/lib/glfw3.lib")
endif()

# 添加源文件
set(SOURCE_FILES
    src/main.cpp
    src/opengl.cpp
    src/stb_image.cpp
)

# 创建可执行文件
add_executable(SMBeautyEngine_windows ${SOURCE_FILES})

# 链接库
target_link_libraries(SMBeautyEngine_windows
    ${OPENGL_LIBRARIES}
    ${GLFW3_LIBRARIES}
    ${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/pixelFree.lib
)

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