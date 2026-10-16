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
#if defined(_MSC_VER) && !defined(PF_BUILD_SHARED_LIB) && !defined(PF_NO_AUTO_LINK)
#pragma comment(lib, "kernel32.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "winspool.lib")
#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "oleaut32.lib")
#pragma comment(lib, "uuid.lib")
#pragma comment(lib, "comdlg32.lib")
#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "opengl32.lib")
#pragma comment(lib, "glu32.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "wldap32.lib")
#pragma comment(lib, "crypt32.lib")
#pragma comment(lib, "secur32.lib")
#pragma comment(lib, "bcrypt.lib")
#pragma comment(lib, "normaliz.lib")
#pragma comment(lib, "iphlpapi.lib")
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

typedef enum PFFaceDetectMode {
  PF_FACE_DETECT_MODE_IMAGE = 0,
  PF_FACE_DETECT_MODE_VIDEO = 1,
} PFFaceDetectMode;

typedef enum PFSrcType{
    PFSrcTypeFilter = 0,
    PFSrcTypeAuthFile = 2,
    PFSrcTypeStickerFile = 3,
    PFSrcTypeMakeup = 4,
    PFSrcTypeHumanProcessor = 5,
    PFSrcTypeSkinSrc = 6,
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
    bool isUse;
    const char* imagePath;
    float intensity;
} PFExternalFilterConfig;

typedef enum PFSkinToneType {
    PFSkinToneTypeNatural = 0,
    PFSkinToneTypeFair,
    PFSkinToneTypePinkWhite,
    PFSkinToneTypeWheat,
    PFSkinToneTypeBronze,
} PFSkinToneType;

typedef struct {
    bool isUse;
    int skinToneType;
    float intensity;
    // 0.0 = cold, 0.5 = neutral, 1.0 = warm.
    float coldWarmIntensity;
} PFSkinToneFilterParams;

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

typedef struct PFBodyStretchLine {
    float x0;
    float y0;
    float x1;
    float y1;
} PFBodyStretchLine;

typedef struct PFBodyLongLegControl {
    PFBodyStretchLine upper;
    PFBodyStretchLine lower;
    int hasAutoPoints;
    int hasUserOverride;
} PFBodyLongLegControl;

typedef struct PFHumanSegmentationResult {
    // 最近一帧指定人体的人像分割 mask。数据为内部只读缓存，下一次 process/reset/销毁后失效。
    const float* maskData;
    int width;
    int height;
    int count;
    int humanCount;
    int index;
} PFHumanSegmentationResult;

// Live detection result, copied by value. index is local to the latest detection;
// it is not a persistent person ID. rect is x0,y0,x1,y1 normalized in the RAW
// input image (top-left origin), matching GetFaceRects. Apply input rotation in UI.
typedef struct PFHumanDetectionInfo {
    int index;
    int trackId; // Diagnostic only: the detector may return duplicate track IDs.
    float rect[4];
    int hasRect;
} PFHumanDetectionInfo;

/* 美体类型 */
typedef enum PFBodyBeautyType {
    // 预设组合：0~6 对应 H 型 / 沙漏型 / 梨型 / 自然 / 苹果 / 型男 / 双开门
    PFBodyBeautyTypePreset = 0,
    // 瘦身（整体）
    PFBodyBeautyTypeSlimBody,
    // 瘦腰
    PFBodyBeautyTypeSlimWaist,
    // 沙漏腰 / 小肚子
    PFBodyBeautyTypeBelly,
    // 曲线（胸腰臀 S 曲线）
    PFBodyBeautyTypeCurve,
    // 全身瘦（整体横向压缩）
    PFBodyBeautyTypeFullSlim,
    // 提跨（0.5 中性；>0.5 上提，<0.5 下压）
    PFBodyBeautyTypeHipLift,
    // 丰臀（0.5 中性；>0.5 丰臀，<0.5 缩臀）
    PFBodyBeautyTypeHipEnlarge,
    // 丰胸
    PFBodyBeautyTypeBreastEnlarge,
    // 手臂
    PFBodyBeautyTypeSlimArm,
    // 天鹅颈
    PFBodyBeautyTypeSwanNeck,
    // 瘦肩膀
    PFBodyBeautyTypeShoulderThin,
    // 直角肩
    PFBodyBeautyTypeRightAngleShoulder,
    // 左大臂（7-8）
    PFBodyBeautyTypeLeftUpperArm,
    // 左小臂（8-9）
    PFBodyBeautyTypeLeftLowerArm,
    // 右大臂（10-11）
    PFBodyBeautyTypeRightUpperArm,
    // 右小臂（11-12）
    PFBodyBeautyTypeRightLowerArm,
    // 左大腿（0-1）
    PFBodyBeautyTypeLeftUpperLeg,
    // 左小腿（1-2）
    PFBodyBeautyTypeLeftLowerLeg,
    // 右大腿（3-4）
    PFBodyBeautyTypeRightUpperLeg,
    // 右小腿（4-5）
    PFBodyBeautyTypeRightLowerLeg,
    // 长腿（0.5 中性；>0.5 拉长，<0.5 缩短）：沿胯→踝矩形、脚下再延 20%、横向胯宽×1.3）
    PFBodyBeautyTypeHeight,
    // 瘦肚子（0.5 中性；同瘦身径向液化，作用半径小于瘦身）
    PFBodyBeautyTypeSlimBelly,
} PFBodyBeautyType;

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
    //开眼角（默认0.5，两个方向调节；>0.5 外开，<0.5 内收）
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
    // @deprecated v2.5.01 已废弃，请使用 PFBeautyFilterTypeFaceSharpenStrength
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
    // 白牙
    PFBeautyFilterWhitenTeeth,

    // ===== 新增：PFWarpFace 细分（ins1.png 0-74）=====
    // 默认值：0.5（中性，不改变）
    // 取值建议：0.0 ~ 1.0

    // 眼部：眼睛上下（整体上/下移）
    // 默认值：0.5；>0.5 上移，<0.5 下移
    PFBeautyFilterTypeFace_eye_y,
    // 眼部：眼高低（上下眼睑开合）
    // 默认值：0.5；>0.5 眼裂增大，<0.5 眼裂减小
    PFBeautyFilterTypeFace_eye_height,
    // 鼻部：鼻子整体大小
    // 默认值：0.5；>0.5 放大，<0.5 缩小
    PFBeautyFilterTypeFace_nose_size,
    // 鼻部：鼻子高低（纵向高度感）
    // 默认值：0.5；>0.5 增高，<0.5 降低
    PFBeautyFilterTypeFace_nose_height,
    // 鼻部：鼻子上下（整体位置上/下移）
    // 默认值：0.5；>0.5 上移，<0.5 下移
    PFBeautyFilterTypeFace_nose_y,
    // 鼻部：鼻尖
    // 默认值：0.5；>0.5 更突出，<0.5 更收敛
    PFBeautyFilterTypeFace_nose_tip,
    // 鼻部：鼻梁
    // 默认值：0.5；>0.5 更立体，<0.5 更平缓
    PFBeautyFilterTypeFace_nose_bridge,
    // 眉部：眉粗细
    // 默认值：0.5；>0.5 加粗，<0.5 变细
    PFBeautyFilterTypeFace_brow_thickness,
    // 眉部：眉长短
    // 默认值：0.5；>0.5 变长，<0.5 变短
    PFBeautyFilterTypeFace_brow_length,
    // 眉部：眉提升
    // 默认值：0.5；>0.5 上提，<0.5 下压
    PFBeautyFilterTypeFace_brow_lift,
    // 眉部：眉距离
    // 默认值：0.5；>0.5 拉开，<0.5 靠近
    PFBeautyFilterTypeFace_brow_distance,
    // 眉部：眉倾斜
    // 默认值：0.5；>0.5 眉尾上扬，<0.5 眉尾下压
    PFBeautyFilterTypeFace_brow_tilt,
    // 唇部：上唇厚度
    // 默认值：0.5；>0.5 变厚，<0.5 变薄
    PFBeautyFilterTypeFace_upper_lip_thickness,
    // 唇部：下唇厚度
    // 默认值：0.5；>0.5 变厚，<0.5 变薄
    PFBeautyFilterTypeFace_lower_lip_thickness,
    // 唇部：丰唇（整体饱满/收薄）
    // 默认值：0.5；>0.5 更饱满，<0.5 更收薄
    PFBeautyFilterTypeFace_lip_fullness,
    // 唇部：嘴唇宽度
    // 默认值：0.5；>0.5 变宽，<0.5 变窄
    PFBeautyFilterTypeFace_mouth_width,

    // 瑕疵祛除（基于 skin segmentation + delspot 输出）
    PFBeautyFilterFleckFlawClean,
    // 皮肤细节纹理（SkinDetial/detial.jpg）
    PFBeautyFilterSkinDetailTexture,
    // 皮肤细节清晰柔光（SkinDetial/SoftLight_detial.jpg）
    PFBeautyFilterSkinDetailClarity,
    // 皮肤细节高光柔光（SkinDetial/SoftLight.jpg）
    PFBeautyFilterSkinDetailHighlight,
    // 皮肤细节水光（SkinDetial/HighlightMask.png）
    PFBeautyFilterSkinDetailWaterGlow,
    // 皮肤细节哑光
    PFBeautyFilterSkinDetailMatte,
    
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
    // 甜美
    PFBeautyTypeOneKeySweet,
    // 质感
    PFBeautyTypeOneKeyTexture,
    // 硬派
    PFBeautyTypeOneKeyHard,
    
}PFBeautyTypeOneKey;

typedef enum PFSDKErrorCode {
    PFSDKErrorCodeOK = 0,
    PFSDKErrorCodeInvalidArgument = 1001,
    PFSDKErrorCodeFaceProcessorInitFailed = 1101,
    PFSDKErrorCodeHumanProcessorInitFailed = 1102,
    PFSDKErrorCodeGLInitFailed = 1103,
    PFSDKErrorCodeAuthBundleNotAllowed = 2001,
    PFSDKErrorCodeAuthPlatformNotAllowed = 2002,
    PFSDKErrorCodeAuthExpired = 2003,
    PFSDKErrorCodeAuthFeatureNotAllowed = 2004,
    PFSDKErrorCodeRenderStopped = 2005,
    PFSDKErrorCodeNoFaceDetected = 3001,
    PFSDKErrorCodeNoHumanDetected = 3002,
} PFSDKErrorCode;

PF_CAPI_EXPORT extern const char* PF_Version();


typedef struct PFPixelFree PFPixelFree;

/* Immutable owned detection. Views below are borrowed until the result is released.
 * Geometry is normalized in the orientation-corrected full image, top-left origin.
 * Same-aspect resizes with the same rotation are supported. Crops, warps and new
 * source images require a new detection; callers must track their source version.
 * Results survive subsequent detection/reset calls; they belong to the engine
 * instance that created them. Legacy hasFace/getFaceRects query the live detector;
 * use PF_getFaceDetectionCount/Info for explicit image sessions.
 * Creation requires a valid advanced beauty (BeautyV2) certificate. Basic
 * beauty/style-only certificates return PFFaceErrorUnauthorized, even if other
 * features are licensed. Authorized snapshots remain readable until released.
 */
typedef struct PFFaceDetectionResult PFFaceDetectionResult;
typedef enum PFFacePayloadFormat {
    PFFacePayloadFloat32 = 1,
    PFFacePayloadUInt8 = 2,
} PFFacePayloadFormat;
typedef struct PFFacePayloadView {
    const void* data;
    int width;
    int height;
    int channels;
    PFFacePayloadFormat format;
    float rect[4]; // Mapping into the orientation-corrected image: x0,y0,x1,y1.
} PFFacePayloadView;
typedef struct PFDetectedFaceInfo {
    int faceId; // Unique only within this result; never a cross-image identity.
    float rect[4];
    const float* landmarks; // Fixed 168-point layout, 336 interleaved x,y floats.
                           // Same ordering as PF_pixelFreeGetFaceLandmarks168,
                           // including estimated forehead and outer-ring points.
                           // Normalized coordinates may extend beyond the image.
    int landmarkCount; // Always 168 in public snapshot views; not float count.
    float quaternion[4]; // Native x,y,z,w orientation.
    PFFacePayloadView skinMask;
    PFFacePayloadView occlusionMask;
    PFFacePayloadView repairImage;
    int sourceWidth;
    int sourceHeight;
    PFRotationMode rotationMode;
    unsigned int coordinateSpace; // 1 = normalized, orientation-corrected image.
    unsigned int schemaVersion; // 1.
    unsigned long long sourceVersion; // Monotonic detection serial for this engine.
} PFDetectedFaceInfo;
typedef struct PFFaceParameter {
    PFBeautyFilterType key;
    float value; // Finite [0,1]. Numeric face keys only; unspecified keys are neutral.
                 // Legacy whiten/quality are aliases of new whitening/sharpening.
} PFFaceParameter;
typedef struct PFFaceRenderConfig {
    int faceId;
    const PFFaceParameter* parameters;
    int parameterCount;
    const char* makeupJsonPath; // Optional local JSON path, directory, or encrypted .bundle file (legacy field name).
    float makeupStrength; // Finite [0,1], independent for each face.
} PFFaceRenderConfig;
// Separate configuration keeps PFFaceRenderConfig's existing ABI unchanged.
typedef struct PFFaceStickerConfig {
    int faceId;
    const char* stickerPath; // Local encrypted .bundle or sticker directory; null clears this face.
} PFFaceStickerConfig;
typedef enum PFFaceError {
    PFFaceErrorInvalidArgument = -4101,
    PFFaceErrorInvalidSnapshot = -4102,
    PFFaceErrorDuplicateID = -4103,
    PFFaceErrorUnknownID = -4104,
    PFFaceErrorSourceMismatch = -4105,
    PFFaceErrorUnauthorized = -4106,
    PFFaceErrorDetectorUnavailable = -4107,
    PFFaceErrorMakeupResource = -4108,
    PFFaceErrorInternal = -4109,
    PFFaceErrorStickerResource = -4110,
} PFFaceError;

// Detection never renders or modifies input pixels. Requires valid BeautyV2
// authorization; returns 0 or a negative error (Unauthorized = -4106).
PF_CAPI_EXPORT extern int PF_detectFacesWithBuffer(PFPixelFree*, PFImageInput, PFFaceDetectionResult**);
PF_CAPI_EXPORT extern void PF_releaseFaceDetectionResult(PFFaceDetectionResult*);
PF_CAPI_EXPORT extern int PF_getFaceDetectionCount(const PFFaceDetectionResult*);
PF_CAPI_EXPORT extern int PF_getFaceDetectionInfo(const PFFaceDetectionResult*, int index, PFDetectedFaceInfo*);
// Render returns the output texture ID or a negative error. Retain the snapshot
// through the synchronous call. Zero configs means global effects only.
PF_CAPI_EXPORT extern int PF_processWithBufferAndFace(PFPixelFree*, PFImageInput, const PFFaceDetectionResult*, const PFFaceRenderConfig*);
PF_CAPI_EXPORT extern int PF_processWithBufferAndFaces(PFPixelFree*, PFImageInput, const PFFaceDetectionResult*, const PFFaceRenderConfig*, int count);
// Explicit stickers are independent per face. Unspecified faces have no sticker;
// the legacy global sticker is ignored. Beauty/global stages still run once.
PF_CAPI_EXPORT extern int PF_processWithBufferAndFaceEffects(PFPixelFree*, PFImageInput, const PFFaceDetectionResult*,
    const PFFaceRenderConfig*, int count, const PFFaceStickerConfig*, int stickerCount);

// Owned, image-only body snapshot. Coordinates match explicit face snapshots:
// normalized upright image, top-left origin (not the legacy RAW live rects).
// Body IDs are unique only within this snapshot; trackId is diagnostic only.
typedef struct PFBodyDetectionResult PFBodyDetectionResult;
typedef struct PFDetectedBodyInfo {
    int bodyId;
    int trackId;
    float rect[4]; // x0,y0,x1,y1, clamped to [0,1].
    int sourceWidth;
    int sourceHeight;
    PFRotationMode rotationMode;
    unsigned int coordinateSpace; // 1 = normalized upright image.
    unsigned int schemaVersion; // 1.
    unsigned long long sourceVersion;
} PFDetectedBodyInfo;
typedef struct PFBodyParameter {
    PFBodyBeautyType key;
    float value; // Finite [0,1], neutral .5. Preset: integer [0,6].
} PFBodyParameter;
typedef struct PFBodyRenderConfig {
    int bodyId;
    const PFBodyParameter* parameters;
    int parameterCount; // Unspecified parameters are neutral, never inherited.
} PFBodyRenderConfig;
typedef enum PFBodyError {
    PFBodyErrorInvalidArgument = -4201,
    PFBodyErrorInvalidSnapshot = -4202,
    PFBodyErrorDuplicateID = -4203,
    PFBodyErrorUnknownID = -4204,
    PFBodyErrorSourceMismatch = -4205,
    PFBodyErrorUnauthorized = -4206,
    PFBodyErrorDetectorUnavailable = -4207,
    PFBodyErrorInternal = -4209,
} PFBodyError;
// CPU-only synchronous inference. Requires body authorization and loaded model.
// No GL context needed. Snapshots remain valid until explicitly released,
// including across resetDetectState and subsequent detector runs. Body info
// exposes metadata only; keypoints and confidences stay inside the snapshot.
PF_CAPI_EXPORT extern int PF_detectBodiesWithBuffer(PFPixelFree*, PFImageInput, PFBodyDetectionResult**);
PF_CAPI_EXPORT extern void PF_releaseBodyDetectionResult(PFBodyDetectionResult*);
PF_CAPI_EXPORT extern int PF_getBodyDetectionCount(const PFBodyDetectionResult*);
PF_CAPI_EXPORT extern int PF_getBodyDetectionInfo(const PFBodyDetectionResult*, int index, PFDetectedBodyInfo*);
// Render returns output texture ID or a negative error. Always rerender from the
// original source. Body snapshots never trigger human inference; zero body tasks
// means no body effects. Configurations are applied in snapshot order.
PF_CAPI_EXPORT extern int PF_processWithBufferAndBodies(PFPixelFree*, PFImageInput,
    const PFBodyDetectionResult*, const PFBodyRenderConfig*, int bodyCount);
// Optional face/body snapshots; at least one is required. A missing snapshot
// requires zero matching configs and DISABLES that legacy face/body stage.
// Global color/filter stages still run once. No global makeup/sticker fallback.
// Face errors use PFFaceError, body errors use PFBodyError.
PF_CAPI_EXPORT extern int PF_processWithBufferAndEffects(PFPixelFree*, PFImageInput,
    const PFFaceDetectionResult*, const PFFaceRenderConfig*, int faceCount,
    const PFFaceStickerConfig*, int stickerCount,
    const PFBodyDetectionResult*, const PFBodyRenderConfig*, int bodyCount);

PF_CAPI_EXPORT extern void PF_VLogSetLevel(PFPixelFree* pixelFree,int level,char *path);
// 启用/禁用日志输出到控制台（1: 启用，0: 禁用），全局开关
PF_CAPI_EXPORT extern void PF_VLogSetConsoleEnabled(int enabled);

PF_CAPI_EXPORT extern PFPixelFree* PF_NewPixelFree();

PF_CAPI_EXPORT extern void PF_DeletePixelFree(PFPixelFree* pixelFree);

// 仅释放当前 GL 上下文相关资源，不销毁 PixelFree 实例、授权、模型和参数。
// 需在拥有对应 GL 上下文的线程调用；下一次 PF_processWithBuffer 会重新初始化 GL。
PF_CAPI_EXPORT extern void PF_ReleaseGLResources(PFPixelFree* pixelFree);

//目前仅支持双输入。GPU 纹理由于渲染，cpu buffer 用检测
PF_CAPI_EXPORT extern int PF_processWithBuffer(PFPixelFree* pixelFree,PFImageInput inputImage);

// 获取最近一次功能设置/渲染后的错误码，0 表示正常。
PF_CAPI_EXPORT extern int PF_pixelFreeGetLastErrorCode(PFPixelFree* pixelFree);

PF_CAPI_EXPORT extern void PF_pixelFreeSetBeautyFilterParam(PFPixelFree* pixelFree, int key,void *value);
PF_CAPI_EXPORT extern void PF_pixelFreeSetBodyBeautyParam(PFPixelFree* pixelFree, int key, void *value);
// IMAGE 模式会复用人脸、人体及相关 AI 结果；换图或图像方向变化后调用此接口失效缓存。
PF_CAPI_EXPORT extern void PF_pixelFreeResetDetectState(PFPixelFree* pixelFree);
PF_CAPI_EXPORT extern int PF_pixelFreeGetBodyLongLegControl(PFPixelFree* pixelFree, PFBodyLongLegControl* control);
PF_CAPI_EXPORT extern int PF_pixelFreeSetBodyLongLegControl(PFPixelFree* pixelFree, const PFBodyLongLegControl* control);
PF_CAPI_EXPORT extern int PF_pixelFreeSetExternalFilter(PFPixelFree* pixelFree, PFExternalFilterConfig* config);
PF_CAPI_EXPORT extern int PF_pixelFreeClearExternalFilter(PFPixelFree* pixelFree);
PF_CAPI_EXPORT extern int PF_pixelFreeSetSkinToneFilter(PFPixelFree* pixelFree, PFSkinToneFilterParams* params);
PF_CAPI_EXPORT extern int PF_pixelFreeClearSkinToneFilter(PFPixelFree* pixelFree);
PF_CAPI_EXPORT extern void PF_createBeautyItemFormBundle(PFPixelFree* pixelFree, void *data,int size,PFSrcType type);

PF_CAPI_EXPORT extern void PF_pixelFreeGetFaceRect(PFPixelFree* pixelFree,float *faceRect);
// faceRects 每张脸 4 个值：x, y, x1, y1，相对输入图宽高归一化，原点在左上角。返回写入的人脸数。
PF_CAPI_EXPORT extern int PF_pixelFreeGetFaceRects(PFPixelFree* pixelFree, float *faceRects, int maxCount);
// 与 GetFaceRects 同序，写入检测器人脸 id。返回写入的人脸数。
PF_CAPI_EXPORT extern int PF_pixelFreeGetFaceIds(PFPixelFree* pixelFree, int *faceIds, int maxCount);
// points 每张脸 168 个点、336 个 float（x,y 交错），相对输入图归一化，原点左上。需要高级证书中的美型授权，否则返回 0。
PF_CAPI_EXPORT extern int PF_pixelFreeGetFaceLandmarks168(PFPixelFree* pixelFree, float *points, int maxFaces);

PF_CAPI_EXPORT extern int PF_pixelFreeHaveFaceSize(PFPixelFree* pixelFree);

PF_CAPI_EXPORT extern void PF_pixelFreeSetDetectMode(PFPixelFree* pixelFree, PFFaceDetectMode mode);

PF_CAPI_EXPORT extern int PF_pixelFreeHasFace(PFPixelFree* pixelFree);
PF_CAPI_EXPORT extern int PF_pixelFreeHasHuman(PFPixelFree* pixelFree);
// Load a HumanProcessor bundle and process once in IMAGE mode before querying.
PF_CAPI_EXPORT extern int PF_pixelFreeGetHumanCount(PFPixelFree* pixelFree);
// Returns 1 on success, 0 for unavailable/invalid index; always clears *info first.
PF_CAPI_EXPORT extern int PF_pixelFreeGetHumanInfo(PFPixelFree* pixelFree, int index, PFHumanDetectionInfo* info);
// Four floats per body, preserving detection order; unavailable rects are zeros.
PF_CAPI_EXPORT extern int PF_pixelFreeGetHumanRects(PFPixelFree* pixelFree, float* rects, int maxCount);
// 0 = success, -1 = invalid index or unauthorized. -1 index restores the legacy
// body processing. An explicit index selects just that body's geometry for all
// existing SetBodyBeautyParam calls, including explicit face snapshot rendering.
// Long legs retain the original full-width stretch; selection changes hipY only.
// Image-mode indices survive slider renders; reset/mode or source changes clear
// selection. Redetection may reorder indices in VIDEO mode; not a tracking API.
// Parameters are shared, not saved per person: the editor owns per-person values.
PF_CAPI_EXPORT extern int PF_pixelFreeSetBodyBeautyTargetIndex(PFPixelFree* pixelFree, int index);
// -2 = IMAGE cache invalidated: body effects pause until reselected after process.
PF_CAPI_EXPORT extern int PF_pixelFreeGetBodyBeautyTargetIndex(PFPixelFree* pixelFree);
// 设置是否开启人体/人像分割；需要先加载 PFSrcTypeHumanProcessor bundle。
PF_CAPI_EXPORT extern void PF_pixelFreeSetHumanSegmentation(PFPixelFree* pixelFree, int enable);
// 获取最近一次 process 后的人像分割结果；返回 1 表示有 mask，0 表示当前无可用 mask。
PF_CAPI_EXPORT extern int PF_pixelFreeGetHumanSegmentationResult(PFPixelFree* pixelFree, PFHumanSegmentationResult* result);
// 按人体 index 获取最近一次 process 后的人像分割结果；index 从 0 开始。
PF_CAPI_EXPORT extern int PF_pixelFreeGetHumanSegmentationResultAtIndex(PFPixelFree* pixelFree, int index, PFHumanSegmentationResult* result);

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
    PFMakeupPartFoundation = 8,
    PFMakeupPartPupil = 9
} PFMakeupPart;

// 设置美妆各部位程度值（与配置叠乘）
PF_CAPI_EXPORT extern int PF_pixelFreeSetMakeupPartDegree(PFPixelFree* pixelFree, int part, float degree);
// 设置美妆是否开启面部遮挡分割；默认开启，妆只作用在非遮挡区域
PF_CAPI_EXPORT extern void PF_pixelFreeSetMakeupFaceOccu(PFPixelFree* pixelFree, int enable);

// 设置是否开启皮肤分割（Skin Mask），enable != 0 表示开启
PF_CAPI_EXPORT extern void PF_pixelFreeSetSkinMask(PFPixelFree* pixelFree, int enable);
// 设置是否开启 mask 磨皮，默认关闭；enable != 0 时才生成磨皮用人脸 mask
PF_CAPI_EXPORT extern void PF_pixelFreeSetSmoothSkinMask(PFPixelFree* pixelFree, int enable);
#ifdef __cplusplus
}
#endif
#endif /* pixelFree_c_hpp */
