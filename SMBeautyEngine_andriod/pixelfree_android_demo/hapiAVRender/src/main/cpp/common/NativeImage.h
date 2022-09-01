//
// Created by 1 on 2022/3/28.
//

#ifndef HAPIPLAY_NATIVEIMAGE_H
#define HAPIPLAY_NATIVEIMAGE_H

#include <cstdint>
#include <cstdlib>
#include <LogUtil.h>

#define IMAGE_FORMAT_RGBA           0x01
#define IMAGE_FORMAT_NV21           0x02
#define IMAGE_FORMAT_NV12           0x03
#define IMAGE_FORMAT_I420           0x04

struct TransformMatrix {
    int degree;
    int mirror;
    float translateX;
    float translateY;
    float scaleX;
    float scaleY;
    int angleX;
    int angleY;

    TransformMatrix() :
            translateX(0),
            translateY(0),
            scaleX(1.0),
            scaleY(1.0),
            degree(0),
            mirror(0),
            angleX(0),
            angleY(0) {

    }

    void Reset() {
        translateX = 0;
        translateY = 0;
        scaleX = 1.0;
        scaleY = 1.0;
        degree = 0;
        mirror = 0;
    }
};

class NativeImage {

private:

public:
    int textureID=-1000;
    int width = 0;
    int height = 0;
    int format = 0;
    int rotationDegrees = 0;
    uint8_t *ppPlane[3]{};
    int pLineSize[3]{};
    int pixelStride = 0;
    int rowPadding = 0;

    NativeImage() {

        ppPlane[0] = nullptr;
        ppPlane[1] = nullptr;
        ppPlane[2] = nullptr;
    };

    ~NativeImage() {
        if (ppPlane[0] != nullptr) {
            free(ppPlane[0]);
        }
        ppPlane[0] = nullptr;
        ppPlane[1] = nullptr;
        ppPlane[2] = nullptr;
    }

};


#endif //HAPIPLAY_NATIVEIMAGE_H
