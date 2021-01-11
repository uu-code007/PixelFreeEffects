//
//  SMStickerModel.h
//  SMBeautyEngine
//
//  Created by 孙慕 on 2020/7/27.
//  Copyright © 2020 孙慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SMFilterType)
{
    SMFilterTypeBeauty,         // 磨皮、瘦脸等
    SMFilterTypeStyle,          // 风格滤镜
    SMFilterTypeEffects         // 人脸特效
};

typedef NS_ENUM(NSInteger, SMStickerType)
{
    SMStickerType2D,
    SMStickerType3D,
};

/* 美颜 */
@interface SMBeautyFilterModel : NSObject


//是否使用cpu，默认使用
//@property (nonatomic, assign) BOOL use_cpu;
//大眼
@property (nonatomic, assign) float face_EyeStrength;
//瘦脸
@property (nonatomic, assign) float face_thinning;
//窄脸
@property (nonatomic, assign) float face_narrow;
//下巴
@property (nonatomic, assign) float face_chin;
//v脸
@property (nonatomic, assign) float face_V;
//small
@property (nonatomic, assign) float face_small;
//鼻子
@property (nonatomic, assign) float face_nose;
//额头
@property (nonatomic, assign) float face_forehead;
//嘴巴
@property (nonatomic, assign) float face_mouth;
//人中
@property (nonatomic, assign) float face_philtrum;
//长鼻
@property (nonatomic, assign) float face_long_nose;
//眼距
@property (nonatomic, assign) float face_eye_space;


//磨皮
@property (nonatomic, assign) float blurStrength;
//美白
@property (nonatomic, assign) float whitenStrength;
//红润
@property (nonatomic, assign) float ruddyStrength;
//锐化
@property (nonatomic, assign) float sharpenStrength;
//新美白算法
@property (nonatomic, assign) float m_newWhitenStrength;
//画质增强
@property (nonatomic, assign) float h_qualityStrength;

+(SMBeautyFilterModel *)defaultConfig;


/* 滤镜输入 */
@property (nonatomic, strong) UIImage *lutImage;
@property (nonatomic, assign) float lutImageStrength;
@end


@interface SMMakeUpFilterModel : NSObject
@property (nonatomic, assign) float lipStrength;
@end

/* 人脸特效道具 */
@interface SMNodeModel : NSObject
/// 模型类型
@property (nonatomic, strong) NSString *type;
/// 存放素材的文件夹名称 (素材目录下图片格式 dirname_000.png)
@property (nonatomic, strong) NSString *dirname;
/// 图片素材文件路径
@property (nonatomic, strong) NSString *filePath;
/// 贴纸中心点
@property (nonatomic, assign) NSInteger facePos;
/// 人脸起始位置
@property (nonatomic, assign) NSInteger startIndex;
/// 人脸结束位置，起始位置和结束位置用于求人脸宽度的
@property (nonatomic, assign) NSInteger endIndex;
/// 贴纸x轴偏移量
@property (nonatomic, assign) float offsetX;
/// 贴纸y轴偏移量
@property (nonatomic, assign) float offsetY;

/// 贴纸模型x轴旋转 pi * x
@property (nonatomic, assign) float rotationX;
/// 贴纸模型y轴旋转 pi * x
@property (nonatomic, assign) float rotationY;
/// 贴纸模型z轴旋转 pi * x
@property (nonatomic, assign) float rotationZ;

@property (nonatomic, assign) float scale;

/// 贴纸缩放倍数(相对于人脸)
@property (nonatomic, assign) float ratio;
/// 素材图片的个数
@property (nonatomic, assign) NSInteger number;
/// 素材图片的分辨率，同一个dirname下的素材图片分辨率要一致
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
/// 该dirname下所有的素材图片，每张图片的播放时间，以毫秒为单位。不同dirname下的素材图片的duration可以不同。
@property (nonatomic, assign) NSInteger duration;
/// 该dirname下所有素材图片都播放完一遍之后，是否重新循环播放。1：循环播放，0：不循环播放。
@property (nonatomic, assign) NSInteger isloop;
/// 最多支持人脸数
@property (nonatomic, assign) NSInteger maxcount;


@end

@interface SMStickerModel : NSObject

@property (nonatomic, assign) SMStickerType type;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *icon;

/* 滤镜输入 */
//@property (nonatomic, strong) NSString *image;
//@property (nonatomic, assign) BOOL isAdjust;
//@property (nonatomic, assign) float currentAlphaValue;
//@property (nonatomic, strong) NSArray<NSString *> *textureImages;
/* 是否渲染 */
@property (nonatomic, assign) BOOL isRender;
/* 用户贴纸*/
@property (nonatomic, strong) NSArray<SMNodeModel *> *nodes;


// 人脸特效
+ (SMStickerModel *)buildStickerFilterModelsWithPath:(NSString *)filter;

@end

NS_ASSUME_NONNULL_END
