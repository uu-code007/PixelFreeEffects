//
//  AdjustmentCell.h
//  testGPUImage
//
//  Created by sunmu on 2025/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AdjustmentItem;
@interface AdjustmentCell : UITableViewCell

@property (nonatomic, strong) AdjustmentItem *item; // 调节项
@property (nonatomic, copy) void (^sliderValueChangedBlock)(float value); // 滑动事件回调

@end

NS_ASSUME_NONNULL_END
