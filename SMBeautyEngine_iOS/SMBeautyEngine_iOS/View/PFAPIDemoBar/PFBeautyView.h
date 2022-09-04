//
//  PFBeautyView.h
//  PFAPIDemoBar
//
//  Created by mumu on 2019/11/6.
//  Copyright © 2019 mmface. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PFDemoBarDefine.h"
#import "PFBeautyParam.h"

@class PFBeautyView;
@protocol PFBeautyViewDelegate <NSObject>

- (void)beautyCollectionView:(PFBeautyView *)beautyView didSelectedParam:(PFBeautyParam *)param;

@end

@interface PFBeautyView : UICollectionView

@property (nonatomic, assign) id<PFBeautyViewDelegate>mDelegate ;

@property (nonatomic, assign) NSInteger selectedIndex ;

@property (nonatomic, strong) NSArray <PFBeautyParam *>*dataArray;


@end


@interface FUBeautyCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView ;
@property (nonatomic, strong) UILabel *titleLabel ;
@end
