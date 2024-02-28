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

@end

@interface PFAPIDemoBar : UIView

@property (nonatomic, assign) id<PFAPIDemoBarDelegate>mDelegate ;

@property (nonatomic, assign) int oneKeyType;

// 关闭上半部分
-(void)hiddenTopViewWithAnimation:(BOOL)animation;

// 上半部是否显示
@property (nonatomic, assign) BOOL isTopViewShow ;

-(void)setDefaultFilter:(PFBeautyParam *)filter;



@end
