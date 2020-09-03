//
//  FUBeautyEditView.m
//  FULiveDemo
//
//  Created by 孙慕 on 2019/11/6.
//  Copyright © 2019 FaceUnity. All rights reserved.
//

#import "FUBeautyEditView.h"
#import "FUBottomColletionView.h"
#import "FUBeautyView.h"

@interface FUBeautyEditView()<FUBottomColletionViewDelegate>
/* 美肤View */
@property (strong, nonatomic) FUBeautyView *colorCollectionView;
//
//@property (strong, nonatomic) FUAvatarContentColletionView *avatarContentColletionView;
/* 底部选择器 */
@property (strong, nonatomic) FUBottomColletionView *bottomColletionView;

@end
@implementation FUBeautyEditView



- (id)initWithFrame:(CGRect)frame withData:(NSArray *)dataArray{
    self = [super initWithFrame:frame];
    if (self){

        
        _bottomColletionView = [[FUBottomColletionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frame) - 49,[UIScreen mainScreen].bounds.size.width, 49)];
        _bottomColletionView.delegate = self;
        _bottomColletionView.backgroundColor = [UIColor whiteColor];
        _bottomColletionView.dataArray = @[@"美肤",@"美型",@"滤镜"];
        [self addSubview:_bottomColletionView];
    }
    
    return self;
}


#pragma  mark -  FUBottomColletionViewDelegate
-(void)bottomColletionDidSelectedIndex:(NSInteger)index{

}

@end
