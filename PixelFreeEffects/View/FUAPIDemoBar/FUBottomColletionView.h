//
//  FUBottomColletionView.h
//  FULiveDemo
//
//  Created by 孙慕 on 2019/11/6.
//  Copyright © 2019 FaceUnity. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol FUBottomColletionViewDelegate <NSObject>

@optional

- (void)bottomColletionDidSelectedIndex:(NSInteger)index;
@end



@interface FUBottomBottomCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *botlabel;

@property (assign, nonatomic) BOOL isSel;


@end

@interface FUBottomColletionView : UIView

@property (nonatomic, strong) NSArray *dataArray;

@property (assign, nonatomic) BOOL isSel;

@property (nonatomic, assign) id<FUBottomColletionViewDelegate>delegate ;

@property (assign, nonatomic,readonly) NSInteger selIndex;
@end

NS_ASSUME_NONNULL_END

