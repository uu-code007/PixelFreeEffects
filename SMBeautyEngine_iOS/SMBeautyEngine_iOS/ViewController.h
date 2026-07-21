//
//  ViewController.h
//  SMBeautyEngine_iOS
//
//  Created by mumu on 2021/11/19.
//

#import <UIKit/UIKit.h>
#include <PixelFree/SMPixelFree.h>
#import "PFBeautyEditView.h"

@interface ViewController : UIViewController

@property (nonatomic,strong) SMPixelFree *mPixelFree;

@property(nonatomic, strong) PFBeautyEditView *beautyEditView;

@property (nonatomic,assign)BOOL clickCompare;

/// PFBeautyEditView 底部 Tab 切换（子类可 `super` 扩展）
- (void)bottomDidChange:(int)index;

/// 底部面板相对屏幕底边的留白：优先用 safeAreaLayoutGuide（含 Home Indicator 安全区），无安全区时约 16pt
- (CGFloat)pf_effectivePanelBottomInset;

/// 根据最近一次渲染检测结果刷新提示。
- (void)pf_updateDetectHintNeedsFace:(BOOL)needsFace needsHuman:(BOOL)needsHuman;
- (void)pf_hideDetectHint;

@end
