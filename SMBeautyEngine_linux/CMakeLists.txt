cmake_minimum_required(VERSION 3.10)
project(SMBeautyEngine_linux)

set(CMAKE_CXX_STANDARD 14)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 设置第三方库路径
set(THIRD_PARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party")
set(GLAD_INCLUDE_DIR "${THIRD_PARTY_DIR}/glad/include")
set(GLAD_SOURCE_DIR "${THIRD_PARTY_DIR}/glad/src")
set(STB_INCLUDE_DIR "${THIRD_PARTY_DIR}/stb")
set(GLFW3_INCLUDE_DIRS "${THIRD_PARTY_DIR}/glfw/include")

# 查找系统安装的GLFW
find_package(glfw3 3.3 REQUIRED)
if(NOT glfw3_FOUND)
    message(FATAL_ERROR "GLFW3 not found. Please install libglfw3-dev")
endif()

# 检查必要的目录和文件
foreach(DIR GLAD_INCLUDE_DIR GLAD_SOURCE_DIR STB_INCLUDE_DIR GLFW3_INCLUDE_DIRS)
    if(NOT EXISTS "${${DIR}}")
        message(FATAL_ERROR "${DIR} not found at: ${${DIR}}")
    endif()
endforeach()

# 查找OpenGL
find_package(OpenGL REQUIRED)
if(NOT OPENGL_FOUND)
    message(FATAL_ERROR "OpenGL not found")
endif()

# 设置链接库
set(LINK_LIBS "")

# Linux特定设置
if(UNIX AND NOT APPLE)
    list(APPEND LINK_LIBS 
        ${OPENGL_LIBRARIES}
        X11
        pthread
        dl
    )
endif()

# 添加第三方库
list(APPEND LINK_LIBS glfw)
list(APPEND LINK_LIBS "${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/libPixelFree.so")

# 设置包含目录
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/pixelfreeLib/Include
    ${STB_INCLUDE_DIR}
    ${GLFW3_INCLUDE_DIRS}
    ${OPENGL_INCLUDE_DIRS}
    ${GLAD_INCLUDE_DIR}
)

# 添加源文件
set(SOURCE_FILES
    src/main.cpp
    src/opengl.cpp
    ${GLAD_SOURCE_DIR}/glad.cc
)

# 创建可执行文件
add_executable(SMBeautyEngine_linux ${SOURCE_FILES})

# 链接库
target_link_libraries(SMBeautyEngine_linux ${LINK_LIBS})

# 资源文件处理
set(RES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Res")
set(IMAGE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/IMG_2406.png")

# 检查资源文件
foreach(FILE "${RES_DIR}" "${IMAGE_FILE}")
    if(NOT EXISTS "${FILE}")
        message(FATAL_ERROR "Required file not found: ${FILE}")
    endif()
endforeach()

# 复制资源文件
function(copy_resources)
    # 创建输出目录
    add_custom_command(TARGET SMBeautyEngine_linux POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:SMBeautyEngine_linux>/Res"
    )
    
    # 复制资源目录
    add_custom_command(TARGET SMBeautyEngine_linux POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${RES_DIR}" "$<TARGET_FILE_DIR:SMBeautyEngine_linux>/Res"
    )
    
    # 复制图片文件
    add_custom_command(TARGET SMBeautyEngine_linux POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${IMAGE_FILE}" "$<TARGET_FILE_DIR:SMBeautyEngine_linux>"
    )
endfunction()

copy_resources() 