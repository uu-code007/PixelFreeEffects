// ToolUI.h
#import <UIKit/UIKit.h>

@class AdjustmentItem;

// 滑动事件回调 Block
typedef void (^SliderValueChangedBlock)(AdjustmentItem *item);

@interface ToolUI : UIView

@property (nonatomic, copy) SliderValueChangedBlock sliderValueChangedBlock; // 滑动事件回调

- (instancetype)initWithFrame:(CGRect)frame adjustmentItems:(NSArray<AdjustmentItem *> *)items;

@end
