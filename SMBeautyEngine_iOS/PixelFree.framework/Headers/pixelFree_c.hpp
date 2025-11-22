//
//  pixelFree_c.hpp
//  PixelFree
//
//  Created by mumu on 2021/9/22.
//

#ifndef pixelFree_c_hpp
#define pixelFree_c_hpp

#include <stdio.h>
#if defined(_WIN32)
#ifdef PF_BUILD_SHARED_LIB
#define PF_CAPI_EXPORT __declspec(dllexport)
#else
#define PF_CAPI_EXPORT
#endif
#else
#define PF_CAPI_EXPORT __attribute__((visibility("default")))
#endif  // _WIN32

#ifdef __cplusplus
extern "C" {
#endif

typedef enum PFDetectFormat{
    PFFORMAT_UNKNOWN = 0,
    PFFORMAT_IMAGE_RGB = 1,
    PFFORMAT_IMAGE_BGR = 2,
    PFFORMAT_IMAGE_RGBA = 3,
    PFFORMAT_IMAGE_BGRA = 4,
    PFFORMAT_IMAGE_ARGB = 5,
    PFFORMAT_IMAGE_ABGR = 6,
    PFFORMAT_IMAGE_GRAY = 7,
    PFFORMAT_IMAGE_YUV_NV12 = 8,
    PFFORMAT_IMAGE_YUV_NV21 = 9,
    PFFORMAT_IMAGE_YUV_I420 = 10,
    PFFORMAT_IMAGE_TEXTURE = 11,
} PFDetectFormat;

typedef enum PFRotationMode{
  PFRotationMode0 = 0,
  PFRotationMode90 = 1,
  PFRotationMode180 = 2,
  PFRotationMode270 = 3,
} PFRotationMode;

typedef enum PFSrcType{
    PFSrcTypeFilter = 0,
    PFSrcTypeAuthFile = 2,
    PFSrcTypeStickerFile = 3,
    PFSrcTypeMakeup = 4,
} PFSrcType;

typedef struct {
    const char* modelPath;
    const char* runCachePath;
} PFDetectPath;

typedef struct {
  int textureID;
  int wigth;
  int height;
  void* p_data0;// Y or rgba
  void* p_data1;
  void* p_data2;
  int stride_0;
  int stride_1;
  int stride_2;
    
  PFDetectFormat format;
  PFRotationMode rotationMode;
} PFImageInput;

typedef struct {
  char *imagePath;
} PFFilter;

typedef struct {
    bool isOpenLvmu;//false
    bool isVideo;//false
    const char *bgSrcPath;
} PFFilterLvmuSetting;

typedef struct {
    bool isUse; //false
    char *path; //
    float positionX;// 0-1.0
    float positionY;// 0-1.0
    float w;  // 0-1.0
    float h;// 0-1.0
    bool isMirror; // false
} PFFilterWatermark;


typedef struct {
    bool isUse; //false
    float brightness;// -1.0 to 1.0
    float contrast; // Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
    float exposure; // Exposure ranges from -10.0 to 10.0, with 0.0 as the normal level
    float highlights; //0 - 1, increase to lighten shadows.
    float shadows;  //0 - 1, decrease to darken highlights.
    float saturation; //Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
    float temperature;//choose color temperature, in degrees Kelvin  default 5000.0
    float tint;       //adjust tint to compensate
    float hue;       //0-360
    
} PFImageColorGrading;


typedef struct {
    float key_color[3]; // 0~1
    float hue;
    float saturation;// 0-1.0
    float brightness;  // 0-1.0
    float similarity; //相似度
} PFHLSFilterParams;

/* 美颜类型 */
typedef enum PFBeautyFilterType{
    PFBeautyFilterTypeFace_EyeStrength = 0,
    //瘦脸
    PFBeautyFilterTypeFace_thinning,
    //窄脸
    PFBeautyFilterTypeFace_narrow,
    //下巴
    PFBeautyFilterTypeFace_chin,
    //v脸
    PFBeautyFilterTypeFace_V,
    //small
    PFBeautyFilterTypeFace_small,
    //瘦鼻
    PFBeautyFilterTypeFace_nose,
    //额头
    PFBeautyFilterTypeFace_forehead,
    //嘴巴
    PFBeautyFilterTypeFace_mouth,
    //人中
    PFBeautyFilterTypeFace_philtrum,
    //长鼻
    PFBeautyFilterTypeFace_long_nose = 10,
    //眼距
    PFBeautyFilterTypeFace_eye_space,
    //微笑嘴角
    PFBeautyFilterTypeFace_smile,
    //旋转眼睛
    PFBeautyFilterTypeFace_eye_rotate,
    //开眼角
    PFBeautyFilterTypeFace_canthus,
    //磨皮
    PFBeautyFilterTypeFaceBlurStrength,
    //美白 (粉嫩美白)
    PFBeautyFilterTypeFaceWhitenStrength,
    //红润
    PFBeautyFilterTypeFaceRuddyStrength,
    //锐化
    PFBeautyFilterTypeFaceSharpenStrength,
    //新美白算法 （基于阴影保护美白）
    PFBeautyFilterTypeFaceM_newWhitenStrength,
    //画质增强
    PFBeautyFilterTypeFaceH_qualityStrength,
    //亮眼（0~1）
    PFBeautyFilterTypeFaceEyeBrighten,
    //滤镜类型
    PFBeautyFilterName,
    //滤镜强度
    PFBeautyFilterStrength,
    //绿幕
    PFBeautyFilterLvmu,
    // 2D 贴纸
    PFBeautyFilterSticker2DFilter,
    // 一键美颜
    PFBeautyFilterTypeOneKey = 26,
    // 水印
    PFBeautyFilterWatermark,
    // 扩展字段
    PFBeautyFilterExtend,
    
    // 祛法令纹
    PFBeautyFilterNasolabial,
    // 祛黑眼圈
    PFBeautyFilterBlackEye,
    
} PFBeautyFilterType;

/* 一键美颜类型 */
typedef enum PFBeautyTypeOneKey{
    // 关闭一键美颜
    PFBeautyTypeOneKeyNormal = 0,
    // 自然
    PFBeautyTypeOneKeyNatural,
    // 可爱
    PFBeautyTypeOneKeyCute,
    // 女神
    PFBeautyTypeOneKeyGoddess,
    // 白净
    PFBeautyTypeOneKeyFair,
    
}PFBeautyTypeOneKey;

PF_CAPI_EXPORT extern const char* PF_Version();


typedef struct PFPixelFree PFPixelFree;

PF_CAPI_EXPORT extern void PF_VLogSetLevel(PFPixelFree* pixelFree,int level,char *path);

PF_CAPI_EXPORT extern PFPixelFree* PF_NewPixelFree();

PF_CAPI_EXPORT extern void PF_DeletePixelFree(PFPixelFree* pixelFree);

//目前仅支持双输入。GPU 纹理由于渲染，cpu buffer 用检测
PF_CAPI_EXPORT extern int PF_processWithBuffer(PFPixelFree* pixelFree,PFImageInput inputImage);

PF_CAPI_EXPORT extern void PF_pixelFreeSetBeautyFilterParam(PFPixelFree* pixelFree, int key,void *value);
PF_CAPI_EXPORT extern void PF_createBeautyItemFormBundle(PFPixelFree* pixelFree, void *data,int size,PFSrcType type);

PF_CAPI_EXPORT extern void PF_pixelFreeGetFaceRect(PFPixelFree* pixelFree,float *faceRect);

PF_CAPI_EXPORT extern int PF_pixelFreeHaveFaceSize(PFPixelFree* pixelFree);

PF_CAPI_EXPORT extern int PF_pixelFreeColorGrading(PFPixelFree* pixelFree,PFImageColorGrading* ImageColorGrading);
PF_CAPI_EXPORT extern int PF_pixelFreeAddHLSFilter(PFPixelFree* pixelFree,PFHLSFilterParams* HLSFilterParams);
PF_CAPI_EXPORT extern int PF_pixelFreeDeleteHLSFilter(PFPixelFree* pixelFree,int handle);
PF_CAPI_EXPORT extern int PF_pixelFreeChangeHLSFilter(PFPixelFree* pixelFree,int handle,PFHLSFilterParams* HLSFilterParams);
// 独立美妆：传入 makeup.json 路径
PF_CAPI_EXPORT extern int PF_pixelFreeSetMakeupPath(PFPixelFree* pixelFree, const char* makeupJsonPath);
PF_CAPI_EXPORT extern int PF_pixelFreeClearMakeup(PFPixelFree* pixelFree);

// 美妆部位
typedef enum PFMakeupPart {
    PFMakeupPartBrow = 0,
    PFMakeupPartBlusher = 1,
    PFMakeupPartEyeShadow = 2,
    PFMakeupPartEyeLiner = 3,
    PFMakeupPartEyeLash = 4,
    PFMakeupPartLip = 5,
    PFMakeupPartHighlight = 6,
    PFMakeupPartShadow = 7,
    PFMakeupPartFoundation = 8
} PFMakeupPart;

// 设置美妆各部位程度值（与配置叠乘）
PF_CAPI_EXPORT extern int PF_pixelFreeSetMakeupPartDegree(PFPixelFree* pixelFree, int part, float degree);
#ifdef __cplusplus
}
#endif
#endif /* pixelFree_c_hpp */
