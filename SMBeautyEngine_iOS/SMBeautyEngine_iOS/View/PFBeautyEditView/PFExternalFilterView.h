//
//  PFExternalFilterView.h
//  SMBeautyEngine_iOS
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PFExternalFilterView;

@protocol PFExternalFilterViewDelegate <NSObject>

- (void)externalFilterView:(PFExternalFilterView *)view didSelectLutPath:(nullable NSString *)lutPath intensity:(float)intensity;
- (void)externalFilterView:(PFExternalFilterView *)view intensityDidChange:(float)intensity lutPath:(nullable NSString *)lutPath;

@end

@interface PFExternalFilterView : UIView

@property (nonatomic, weak) id<PFExternalFilterViewDelegate> delegate;

- (void)loadFiltersIfNeeded;

@end

NS_ASSUME_NONNULL_END
