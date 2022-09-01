# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.18.1)

# Declares and names the project.

project("hapiplay")

set(jnilibs ${CMAKE_SOURCE_DIR}/../jniLibs)
set(libname hapiplay)

include_directories(
        include
        glm
        include/libyuv
        render
        common
        util
)

link_directories(
        ${jnilibs}/${ANDROID_ABI}
)

file(GLOB src-files
        ${CMAKE_SOURCE_DIR}/*.cpp
        ${CMAKE_SOURCE_DIR}/render/*.cpp
        ${CMAKE_SOURCE_DIR}/common/*.cpp
        ${CMAKE_SOURCE_DIR}/util/*.cpp
        )

add_library( # Sets the name of the library.
        ${libname}

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        ${src-files}
        )
#
set(third-party-libs_yuv
        yuv
        )
set(third-party-libs_ffmpeg
        swresample
        avutil
        )
set(native-libs
        android
        EGL
        GLESv3
        OpenSLES
        log
        m
        z
        )

target_link_libraries( # Specifies the target library.
        ${libname}
        ${native-libs}
        ${third-party-libs_ffmpeg}
        ${third-party-libs_yuv}
        # Links the target library to the log library
        # included in the NDK.
        ${log-lib})