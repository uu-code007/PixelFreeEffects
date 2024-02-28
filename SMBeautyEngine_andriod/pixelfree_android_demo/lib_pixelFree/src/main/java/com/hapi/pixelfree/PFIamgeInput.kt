package com.hapi.pixelfree


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
    PFFORMAT_IMAGE_TEXTURE(11),
}

enum class PFRotationMode(val intModel: Int) {
    PFRotationMode0(0),
    PFRotationMode90(1),
    PFRotationMode180(2),
    PFRotationMode270(3),
}

/* 一键美颜类型 */
enum class PFBeautyTypeOneKey(val intModel: Int) {
    // 关闭一键美颜
    PFBeautyTypeOneKeyNormal(0),
    // 自然
    PFBeautyTypeOneKeyNatural(1),
    // 可爱
    PFBeautyTypeOneKeyCute(2),
    // 女神
    PFBeautyTypeOneKeyGoddess(3),
    // 白净
    PFBeautyTypeOneKeyFair(4),
};

enum class PFSrcType(val intType: Int) {
    PFSrcTypeFilter(0),
    PFSrcTypeStickerFile(3),
}


/* 美颜类型 */
enum class PFBeautyFiterType(val intType: Int) {
    //大眼
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

    //微笑嘴角
    PFBeautyFiterTypeFace_smile(12),
    //旋转眼睛
    PFBeautyFiterTypeFace_eye_rotate(13),
    //开眼角
    PFBeautyFiterTypeFace_canthus(14),
    //磨皮
    PFBeautyFiterTypeFaceBlurStrength(15),
    //美白
    PFBeautyFiterTypeFaceWhitenStrength(16),

    //红润
    PFBeautyFiterTypeFaceRuddyStrength(17),

    //锐化
    PFBeautyFiterTypeFaceSharpenStrength(18),

    //新美白算法
    PFBeautyFiterTypeFaceM_newWhitenStrength(19),

    //画质增强
    PFBeautyFiterTypeFaceH_qualityStrength(20),

    PFBeautyFiterName(21),
    PFBeautyFiterSticker2DFilter(24),
    // 一键美颜
    PFBeautyFiterTypeOneKey(25),
    // 扩展字段
    PFBeautyFiterExtend(26),
}

class PFIamgeInput {
    var textureID = 0
    var wigth = 0
    var height = 0
    var p_data0: ByteArray? = null
    var p_data1: ByteArray? = null
    var p_data2: ByteArray? = null
    var stride_0 = 0
    var stride_1 = 0
    var stride_2 = 0
    var format: PFDetectFormat? = null
    var rotationMode: PFRotationMode? = null
}

