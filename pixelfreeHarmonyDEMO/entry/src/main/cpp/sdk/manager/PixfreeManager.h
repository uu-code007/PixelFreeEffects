//
// Created on 2024/11/26.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef EFFECTSHARMONY_PIXFREEMANAGER_H
#define EFFECTSHARMONY_PIXFREEMANAGER_H
#include "sdk/include/pixelFree_c.hpp"

class PixfreeManager {
private:
    PFPixelFree* handle;

    size_t _liclength;
    void *_licData;
    size_t _bundleLength;
    void *_bundelData; 

    
public:
    PixfreeManager();
    ~PixfreeManager();
    
    void initPixfree(void* licData, int licLength, void* bundelData, int bundleLength);
    
    void render(PFDetectFormat format,void* date,int textureID, int width, int height) ;
    
    void createBeautyItemFormBundle(void* date, int data_size, PFSrcType type);

    void pixelFreeSetBeautyFiterParam(PFBeautyFiterType key,float  value);
    void pixelFreeSetBeautyFiterNameAndValue(char *name,float value);
    
    void pixelFreeSetBeautyOnekey(PFBeautyTypeOneKey value);
    
};

#endif //EFFECTSHARMONY_PIXFREEMANAGER_H
