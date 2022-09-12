package com.liuyue.pixelfreedemo.core;

public enum BeautyType {
    // -------------- 美型 --------------------
    /**
     * 大眼
     */
    EYE_SIZE(0),
    /**
     * 瘦脸
     */
    FACE_THINNING(1),
    /**
     * 窄脸
     */
    FACE_NARROW(2),
    /**
     * 下巴长度
     */
    CHIN_LENGTH(3),
    /**
     * V 脸
     */
    FACE_V(4),
    /**
     * 小脸
     */
    FACE_SMALL(5),
    /**
     * 鼻子大小
     */
    NOSE_SIZE(6),
    /**
     * 额头高度
     */
    FOREHEAD_HEIGHT(7),
    /**
     * 嘴巴大小
     */
    MOUTH_SIZE(8),
    /**
     * 人中长度
     */
    PHILTRUM_LENGTH(9),
    /**
     * 鼻子长度
     */
    NOSE_LENGTH(10),
    /**
     * 眼镜间距
     */
    EYE_DISTANCE(11),

    // ------------- 基础美颜 -----------------

    /**
     * 磨皮
     */
    BASE_SMOOTH(12),
    /**
     * 美白
     */
    BASE_WHITEN(13),
    /**
     * 红润
     */
    BASE_REDDEN(13),

    // ------------- 进阶美颜 ------------------

    /**
     * 新美白算法
     */
    ADVANCED_NEW_WHITEN(14),
    /**
     * 画质增强
     */
    ADVANCED_IMAGE_ENHANCEMENT(15),

    // -------------- 美颜参数 ---------------------

    /**
     * 特效名称
     */
    NAME(16),
    /**
     * 特效强度
     */
    STRENGTH(17);

    int value;

    BeautyType(int value) {
        this.value = value;
    }

}
