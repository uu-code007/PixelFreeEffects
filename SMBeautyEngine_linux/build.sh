#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}请使用sudo运行此脚本${NC}"
        exit 1
    fi
}

# 检查并安装依赖
check_dependencies() {
    echo -e "${YELLOW}检查并安装依赖...${NC}"
    
    # 检查并安装基本开发工具
    if ! command -v cmake &> /dev/null; then
        echo "安装 cmake..."
        apt-get update && apt-get install -y cmake
    fi
    
    if ! command -v g++ &> /dev/null; then
        echo "安装 g++..."
        apt-get update && apt-get install -y g++
    fi
    
    # 检查并安装OpenGL相关依赖
    if ! pkg-config --exists gl; then
        echo "安装 OpenGL 开发库..."
        apt-get update && apt-get install -y \
            libgl1-mesa-dev \
            libglu1-mesa-dev \
            mesa-common-dev
    fi
    
    # 检查并安装GLFW3
    if ! pkg-config --exists glfw3; then
        echo "安装 GLFW3..."
        apt-get update && apt-get install -y libglfw3-dev
    fi
    
    # 检查并安装X11开发库
    if ! pkg-config --exists x11; then
        echo "安装 X11 开发库..."
        apt-get update && apt-get install -y \
            libx11-dev \
            libxrandr-dev \
            libxinerama-dev \
            libxcursor-dev \
            libxi-dev
    fi
    
    # 检查并安装其他必要的开发工具
    if ! command -v pkg-config &> /dev/null; then
        echo "安装 pkg-config..."
        apt-get update && apt-get install -y pkg-config
    fi
    
    # 检查并安装其他可能需要的库
    apt-get update && apt-get install -y \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        libxcb-keysyms1-dev \
        libxcb-icccm4-dev \
        libxcb-image0-dev \
        libxcb-shm0-dev \
        libxcb-util0-dev \
        libxcb-xinerama0-dev \
        libxcb-xkb-dev \
        libxcb-xfixes0-dev \
        libxcb-render-util0-dev \
        libxcb-xinput-dev \
        libxcb-xkb-dev \
        libxcb-randr0-dev \
        libxcb-xinerama0-dev \
        libxcb-shape0-dev \
        libxcb-sync-dev \
        libxcb-xfixes0-dev \
        libxcb-present-dev \
        libxcb-dri3-dev \
        libxcb-util-dev \
        libxcb-xrm-dev \
        libxcb-icccm4-dev \
        libxcb-ewmh-dev \
        libxcb-keysyms1-dev \
        libxcb-image0-dev \
        libxcb-shm0-dev \
        libxcb-util0-dev \
        libxcb-xinerama0-dev \
        libxcb-xkb-dev \
        libxcb-xfixes0-dev \
        libxcb-render-util0-dev \
        libxcb-xinput-dev \
        libxcb-xkb-dev \
        libxcb-randr0-dev \
        libxcb-xinerama0-dev \
        libxcb-shape0-dev \
        libxcb-sync-dev \
        libxcb-xfixes0-dev \
        libxcb-present-dev \
        libxcb-dri3-dev \
        libxcb-util-dev \
        libxcb-xrm-dev \
        libxcb-icccm4-dev \
        libxcb-ewmh-dev
}

# 检查第三方库
check_third_party() {
    echo -e "${YELLOW}检查第三方库...${NC}"
    
    # 检查GLAD
    if [ ! -d "third_party/glad" ]; then
        echo -e "${RED}错误: GLAD库不存在${NC}"
        exit 1
    fi
    
    # 检查GLFW
    if [ ! -d "third_party/glfw" ]; then
        echo -e "${RED}错误: GLFW库不存在${NC}"
        exit 1
    fi
    
    # 检查STB
    if [ ! -d "third_party/stb" ]; then
        echo -e "${RED}错误: STB库不存在${NC}"
        exit 1
    fi
}

# 检查资源文件
check_resources() {
    echo -e "${YELLOW}检查资源文件...${NC}"
    
    # 检查授权文件
    if [ ! -f "Res/pixelfreeAuth.lic" ]; then
        echo -e "${RED}错误: 授权文件不存在${NC}"
        exit 1
    fi
    
    # 检查滤镜文件
    if [ ! -f "Res/filter_model.bundle" ]; then
        echo -e "${RED}错误: 滤镜文件不存在${NC}"
        exit 1
    fi
    
    # 检查测试图片
    if [ ! -f "IMG_2406.png" ]; then
        echo -e "${RED}错误: 测试图片不存在${NC}"
        exit 1
    fi
}

# 创建构建目录
create_build_dir() {
    echo -e "${YELLOW}创建构建目录...${NC}"
    mkdir -p build
}

# 编译项目
build_project() {
    echo -e "${YELLOW}编译项目...${NC}"
    cd build
    cmake ..
    if [ $? -ne 0 ]; then
        echo -e "${RED}CMake配置失败${NC}"
        exit 1
    fi
    
    make -j$(nproc)
    if [ $? -ne 0 ]; then
        echo -e "${RED}编译失败${NC}"
        exit 1
    fi
    cd ..
}

# 复制资源文件
copy_resources() {
    echo -e "${YELLOW}复制资源文件...${NC}"
    mkdir -p build/bin/Res
    cp -r Res/* build/bin/Res/
    cp IMG_2406.png build/bin/
}

# 设置权限
set_permissions() {
    echo -e "${YELLOW}设置权限...${NC}"
    chmod +x build/bin/SMBeautyEngine_linux
}

# 设置库路径
set_library_path() {
    echo -e "${YELLOW}设置库路径...${NC}"
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/pixelfreeLib
}

# 运行程序
run_program() {
    echo -e "${YELLOW}运行程序...${NC}"
    cd build/bin
    ./SMBeautyEngine_linux
    cd ../..
}

# 主函数
main() {
    check_root
    check_dependencies
    check_third_party
    check_resources
    create_build_dir
    build_project
    copy_resources
    set_permissions
    set_library_path
    
    echo -e "${GREEN}构建完成!${NC}"
    read -p "是否要运行程序? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_program
    fi
}

# 执行主函数
main 