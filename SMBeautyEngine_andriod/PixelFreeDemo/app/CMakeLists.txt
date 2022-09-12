cmake_minimum_required(VERSION 3.18.1)
project(pixel_free_jni)

find_library(log-lib log)
find_library(pixel_free-lib pixel-free PATHS ./src/main/jni/libs/${ANDROID_ABI}/ NO_CMAKE_FIND_ROOT_PATH)

add_library(pixel_free_jni SHARED
        src/main/jni/include/pixelFree_c.hpp
        src/main/jni/pixel_free_jni.cpp)

target_link_libraries(pixel_free_jni ${log-lib} ${pixelfree-lib})
