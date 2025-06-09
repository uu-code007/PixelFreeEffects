# SMBeautyEngine Linux版

## 项目结构

```
SMBeautyEngine_linux/
├── CMakeLists.txt        # CMake构建配置
├── include/              # 头文件
│   ├── gl.h
│   ├── opengl.h
│   └── stb_image.h
├── pixelfreeLib/         # pixelFree库文件
│   ├── Include/
│   │   └── pixelFree_c.hpp
│   └── libPixelFree.so   # Linux动态库
├── Res/                  # 资源文件
│   ├── pixelfreeAuth.lic
│   └── filter_model.bundle
├── src/                  # 源代码
│   ├── main.cpp
│   └── opengl.cpp
└── third_party/          # 第三方库
    ├── glad/
    ├── glfw/
    └── stb/
```

## 环境要求

### Linux 环境
- Ubuntu 20.04或更高版本
- CMake 3.10或更高版本
- OpenGL库
- GLFW3库
- X11开发库


## 编译和运行

### Linux 环境
1. 运行构建脚本（会自动安装所需依赖）
```bash
sudo ./build.sh
```