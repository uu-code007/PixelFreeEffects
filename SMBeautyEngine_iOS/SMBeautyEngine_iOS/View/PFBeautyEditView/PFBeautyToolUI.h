//
//  PFDemoBar.h
//
//  Created by mumu on 2021/9/6.
//
#import <UIKit/UIKit.h>
#import "PFBeautyParam.h"

typedef NS_ENUM(NSInteger, PFBeautyToolUIModuleType) {
    PFBeautyToolUIModuleTypeNone       = -1,
    PFBeautyToolUIModuleTypeOneKey     = 0,
    PFBeautyToolUIModuleTypeSkin       = 1,
    PFBeautyToolUIModuleTypeShape      = 2,
    PFBeautyToolUIModuleTypeFilter     = 3,
    PFBeautyToolUIModuleTypeMakeup     = 4,
    PFBeautyToolUIModuleTypeStickers   = 5,
};

@protocol PFBeautyToolUIDelegate <NSObject>

// 滤镜程度改变
- (void)filterValueChange:(PFBeautyParam *)param;

-(void)bottomDidChange:(int)index;
// 显示上半部分View
-(void)showTopView:(BOOL)shown;

// 开启关闭按钮
- (void)switchRenderState:(BOOL)state;

- (void)comparisonButtonDidClick:(BOOL)state;

@end

@interface PFBeautyToolUI : UIView

/* 滤镜参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *filtersParams;
/* 美肤参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *skinParams;
/* 美型参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *shapeParams;

@property (nonatomic, strong) NSArray<PFBeautyParam *> *faceTypeParams;
@property (nonatomic, strong) NSArray<PFBeautyParam *> *makeupParams;
@property (nonatomic, strong) NSArray<PFBeautyParam *> *stickersParams;

@property (nonatomic, copy) NSArray<NSNumber *> *moduleTypes;

@property (nonatomic, assign) id<PFBeautyToolUIDelegate>mDelegate ;

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
