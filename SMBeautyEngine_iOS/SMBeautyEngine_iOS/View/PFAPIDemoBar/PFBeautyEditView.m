//
//  PFBeautyEditView.m
//  SMEngineDemo
//
//  Created by mumu on 2019/11/6.
//  Copyright © 2019 pfdetect. All rights reserved.
//

#import "PFBeautyEditView.h"
#import "PFBottomColletionView.h"
#import "PFBeautyView.h"

@interface PFBeautyEditView()<PFBottomColletionViewDelegate>
/* 美肤View */
@property (strong, nonatomic) PFBeautyView *colorCollectionView;
//
//@property (strong, nonatomic) FUAvatarContentColletionView *avatarContentColletionView;
/* 底部选择器 */
@property (strong, nonatomic) PFBottomColletionView *bottomColletionView;

@end
@implementation PFBeautyEditView



- (id)initWithFrame:(CGRect)frame withData:(NSArray *)dataArray{
    self = [super initWithFrame:frame];
    if (self){

        
        _bottomColletionView = [[PFBottomColletionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frame) - 49,[UIScreen mainScreen].bounds.size.width, 49)];
        _bottomColletionView.delegate = self;
        _bottomColletionView.backgroundColor = [UIColor whiteColor];
        _bottomColletionView.dataArray = @[@"美肤",@"美型",@"滤镜"];
        [self addSubview:_bottomColletionView];
    }
    
    return self;
}


#pragma  mark -  PFBottomColletionViewDelegate
-(void)bottomColletionDidSelectedIndex:(NSInteger)index{

}

@end
