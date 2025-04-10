//
// Created on 2024/11/26.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "PixfreeManager.h"
#include <cstdlib>
#include <cstring>

    PixfreeManager::PixfreeManager() {
        
    }

    PixfreeManager::~PixfreeManager(){
       PF_DeletePixelFree(handle);
    }


    void PixfreeManager::initPixfree(void* licData, int licLength, void* bundelData, int bundleLength) {
        _liclength = licLength;
        _bundleLength = bundleLength;
        _licData = (char*)malloc(licLength);
        _bundelData = (char*)malloc(bundleLength);
    
        memcpy(_licData, licData, licLength);
        memcpy(_bundelData, bundelData, bundleLength);
    
        handle = PF_NewPixelFree();
        createBeautyItemFormBundle(_bundelData, _bundleLength, PFSrcTypeFilter);
        createBeautyItemFormBundle(_licData, _liclength, PFSrcTypeAuthFile);
        
        free(_bundelData);
        free(_licData);
    }

    void PixfreeManager::render(PFDetectFormat format,void* date,int textureID, int width, int height) {
        if (!handle) {
           return;
        }
       
        PFIamgeInput image;
        image.textureID = textureID;
        image.p_data0 = date;
        image.p_data1 = (char*)date+width*height;
        image.wigth = width;
        image.height = height;
        image.format = format;
        image.rotationMode = PFRotationMode90;
        image.stride_0 = width;
        image.stride_1 = width/2;
        PF_processWithBuffer(handle, image);
    }

    
    void PixfreeManager::createBeautyItemFormBundle(void* date, int data_size, PFSrcType type) {
       PF_createBeautyItemFormBundle(handle, date, data_size, type);
    }

    void PixfreeManager::pixelFreeSetBeautyFiterParam(PFBeautyFiterType key,float value){
       PF_pixelFreeSetBeautyFiterParam(handle, key, &value);
    }

    void PixfreeManager::pixelFreeSetBeautyOnekey(PFBeautyTypeOneKey value){
       PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterTypeOneKey, &value);
    }
    void PixfreeManager::pixelFreeSetBeautyFiterNameAndValue(char *name,float value) {
       PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterName, (void *)name);
       PF_pixelFreeSetBeautyFiterParam(handle, PFBeautyFiterStrength, &value);
    }

