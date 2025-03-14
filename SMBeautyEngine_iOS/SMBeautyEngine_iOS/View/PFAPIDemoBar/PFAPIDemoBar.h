//
//  PFDemoBar.h
//
//  Created by mumu on 2021/9/6.
//
#import <UIKit/UIKit.h>
#import "PFBeautyParam.h"

@protocol PFAPIDemoBarDelegate <NSObject>

// 滤镜程度改变
- (void)filterValueChange:(PFBeautyParam *)param;

-(void)bottomDidChange:(int)index;
// 显示上半部分View
-(void)showTopView:(BOOL)shown;

// 开启关闭按钮
- (void)switchRenderState:(BOOL)state;

- (void)comparisonButtonDidClick:(BOOL)state;

@end

@interface PFAPIDemoBar : UIView

/* 滤镜参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *filtersParams;
/* 美肤参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *skinParams;
/* 美型参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *shapeParams;

@property (nonatomic, strong) NSArray<PFBeautyParam *> *faceTypeParams;
@property (nonatomic, strong) NSArray<PFBeautyParam *> *makeupParams;
@property (nonatomic, strong) NSArray<PFBeautyParam *> *stickersParams;

@property (nonatomic, assign) id<PFAPIDemoBarDelegate>mDelegate ;

@property (nonatomic, assign) int oneKeyType;

@property (nonatomic, assign) int filterIndex;

@property (nonatomic, assign) int stickersIndex;

// 关闭上半部分
-(void)hiddenTopViewWithAnimation:(BOOL)animation;

// 上半部是否显示
@property (nonatomic, assign) BOOL isTopViewShow ;

-(void)setDefaultFilter:(PFBeautyParam *)filter;

-(void)updateDemoBar;


@end
