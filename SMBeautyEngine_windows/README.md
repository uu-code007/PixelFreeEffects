# SMBeautyEngine Windows版

这是SMBeautyEngine的Windows实现版本，基于Mac版本移植。

## 项目结构

```
SMBeautyEngine_windows/
├── CMakeLists.txt        # CMake构建配置
├── include/              # 头文件
│   ├── gl.h
│   ├── opengl.h
│   ├── opengl_observer.h
│   └── stb_image.h
├── pixelfreeLib/         # pixelFree库文件
│   ├── Include/
│   │   └── pixelFree_c.hpp
│   ├── pixelFree.lib     # Windows静态库
│   └── pixelFree.dll     # Windows动态库
├── Res/                  # 资源文件
│   ├── pixelfreeAuth.lic
│   └── filter_model.bundle
├── src/                  # 源代码
│   ├── main.cpp
│   ├── opengl.cpp
│   └── stb_image.cpp
└── IMG_2406.png          # 测试图片
```

## 环境要求

- Windows 10或更高版本
- Visual Studio 2019或更高版本
- CMake 3.10或更高版本
- GLFW3库
- OpenGL库

## 编译步骤

1. 创建build目录并进入
```
mkdir build
cd build
```

2. 使用CMake生成Visual Studio项目文件
```
cmake ..
```

3. 使用Visual Studio打开生成的.sln文件或直接使用CMake编译
```
cmake --build . --config Release
```

4. 编译完成后，可执行文件将位于`build/bin/Release/`目录中

## 运行说明

运行编译好的程序前，确保`Res`目录和`IMG_2406.png`文件都在可执行文件的同一目录下。

## 注意事项

- 确保 Res 目录中的授权文件正确，否则美颜效果将无法正常显示
- 项目使用 OpenGL 和 GLFW 进行渲染，请确保系统支持 OpenGL

## 使用说明

1. 运行程序后将显示一个窗口，展示美颜处理后的图像, demo 写死的黑白滤镜和夸张瘦脸，接入sdk 可以自行设置
2. 按ESC键可退出程序

   