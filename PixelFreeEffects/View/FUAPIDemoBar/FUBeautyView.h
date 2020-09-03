//
//  FUBeautyView.h
//  FUAPIDemoBar
//
//  Created by L on 2018/6/27.
//  Copyright © 2018年 L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FUDemoBarDefine.h"
#import "FUBeautyParam.h"

@class FUBeautyView;
@protocol FUBeautyViewDelegate <NSObject>

- (void)beautyCollectionView:(FUBeautyView *)beautyView didSelectedParam:(FUBeautyParam *)param;

@end

@interface FUBeautyView : UICollectionView

@property (nonatomic, assign) id<FUBeautyViewDelegate>mDelegate ;

@property (nonatomic, assign) NSInteger selectedIndex ;

@property (nonatomic, strong) NSArray <FUBeautyParam *>*dataArray;


@end


@interface FUBeautyCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView ;
@property (nonatomic, strong) UILabel *titleLabel ;
@end
