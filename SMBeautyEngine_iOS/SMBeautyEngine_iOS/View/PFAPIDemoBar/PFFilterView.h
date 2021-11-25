//
//  PFFilterView.h
//  PFAPIDemoBar
//
//  Created by L on 2018/6/27.
//  Copyright © 2018年 L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFDemoBarDefine.h"
#import "PFBeautyParam.h"


@protocol PFFilterViewDelegate <NSObject>

// 开启滤镜
- (void)filterViewDidSelectedFilter:(PFBeautyParam *)param;
@end


@interface PFFilterView : UICollectionView

@property (nonatomic, assign) PFFilterViewType type ;

@property (nonatomic, assign) id<PFFilterViewDelegate>mDelegate ;

@property (nonatomic, assign) NSInteger selectedIndex ;

@property (nonatomic, strong) NSArray<PFBeautyParam *> *filters;

-(void)setDefaultFilter:(PFBeautyParam *)filter;

@end

@interface FUFilterCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView ;
@property (nonatomic, strong) UILabel *titleLabel ;
@end
