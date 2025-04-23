//
//  PFHLSToolView.h
//  testGPUImage
//
//  Created by sunmu on 2025/3/17.
//

#import <UIKit/UIKit.h>
#import "ToolUI.h"
#import "PFTakeColorView.h"

NS_ASSUME_NONNULL_BEGIN
@class AdjustmentItem;
@class PFTakeColorView;


typedef NS_ENUM(NSUInteger, FUTakeColorState) {
    FUTakeColorStateRunning,
    FUTakeColorStateStop,
};


@protocol PFMuViewDelegate <NSObject>

- (void)colorDidSelectedR:(float)r G:(float)g B:(float)b A:(float)a;

-(void)takeColorState:(FUTakeColorState)state;

-(void)sliderValueChanged:(AdjustmentItem *)item;

@end

@interface PFHLSToolView : UIView

@property (nonatomic, assign) id<PFMuViewDelegate>mDelegate ;

@property (nonatomic, copy) SliderValueChangedBlock sliderValueChangedBlock; // 滑动事件回调

@property (strong, nonatomic) PFTakeColorView *mTakeColorView;

@property (nonatomic, assign) NSInteger colorSelectedIndex ;

- (instancetype)initWithFrame:(CGRect)frame Colors:(NSArray<UIColor *>*)colors adjustmentItems:(NSArray<AdjustmentItem *> *)items;

@end

@interface PFMuColorCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *bgImageLayer ;
@property (nonatomic, strong) UILabel *titleLabel ;
@property (nonatomic, strong) UIColor *color;
@end

NS_ASSUME_NONNULL_END
