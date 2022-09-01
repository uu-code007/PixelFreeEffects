package com.byteflow.pixelfree


enum class PFDetectFormat(val intFmt: Int) {
    PFFORMAT_UNKNOWN(0),
    PFFORMAT_IMAGE_RGB(1),
    PFFORMAT_IMAGE_BGR(2),
    PFFORMAT_IMAGE_RGBA(3),
    PFFORMAT_IMAGE_BGRA(4),
    PFFORMAT_IMAGE_ARGB(5),
    PFFORMAT_IMAGE_ABGR(6),
    PFFORMAT_IMAGE_GRAY(7),
    PFFORMAT_IMAGE_YUV_NV12(8),
    PFFORMAT_IMAGE_YUV_NV21(9),
    PFFORMAT_IMAGE_YUV_I420(10),
}

enum class PFRotationMode(val intModel: Int) {
    PFRotationMode0(0),
    PFRotationMode90(1),
    PFRotationMode180(2),
    PFRotationMode270(3),
}

enum class PFSrcType(val intType: Int) {
    PFSrcTypeFilter(0),
    PFSrcTypeDetect(1),
}


/* 美颜类型 */
enum class PFBeautyFiterType(val intType: Int) {
    PFBeautyFiterTypeFace_EyeStrength(0),

    //瘦脸
    PFBeautyFiterTypeFace_thinning(1),

    //窄脸
    PFBeautyFiterTypeFace_narrow(2),

    //下巴
    PFBeautyFiterTypeFace_chin(3),

    //v脸
    PFBeautyFiterTypeFace_V(4),

    //small
    PFBeautyFiterTypeFace_small(5),

    //鼻子
    PFBeautyFiterTypeFace_nose(6),

    //额头
    PFBeautyFiterTypeFace_forehead(7),

    //嘴巴
    PFBeautyFiterTypeFace_mouth(8),

    //人中
    PFBeautyFiterTypeFace_philtrum(9),

    //长鼻
    PFBeautyFiterTypeFace_long_nose(10),

    //眼距
    PFBeautyFiterTypeFace_eye_space(11),

    //磨皮
    PFBeautyFiterTypeFaceBlurStrength(12),

    //美白
    PFBeautyFiterTypeFaceWhitenStrength(13),

    //红润
    PFBeautyFiterTypeFaceRuddyStrength(14),

    //锐化
    PFBeautyFiterTypeFaceSharpenStrength(15),

    //新美白算法
    PFBeautyFiterTypeFaceM_newWhitenStrength(16),

    //画质增强
    PFBeautyFiterTypeFaceH_qualityStrength(17),

    PFBeautyFiterName(18),
    PFBeautyFiterStrength(19)
}

class PFIamgeInput {
    var textureID = 0
    var wigth = 0
    var height = 0
    var p_BGRA: ByteArray? = null
    var p_Y: ByteArray? = null
    var p_CbCr: ByteArray? = null
    var stride_BGRA = 0
    var stride_Y = 0
    var stride_CbCr = 0
    var format: PFDetectFormat? = null
    var rotationMode: PFRotationMode? = null
}