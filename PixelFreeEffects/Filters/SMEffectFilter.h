//
//  SMEffectFilter.h
//  SMBeautyEngine
//
//  Created by 孙慕 on 2020/6/15.
//  Copyright © 2020 孙慕. All rights reserved.
//
#import "GPUImageFilter.h"
#import <pixelFree/SMFilterModel.h>


NS_ASSUME_NONNULL_BEGIN

@interface SMEffectFilter : GPUImageFilter

@property(nonatomic, strong) SMStickerModel *stickerModel;

@property(nonatomic, strong) SMBeautyFilterModel *beautyModel;

@property(nonatomic, strong) SMMakeUpFilterModel *makeModel;

-(void)renderState:(BOOL)isRender;

@end

NS_ASSUME_NONNULL_END
