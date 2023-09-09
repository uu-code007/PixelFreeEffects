//
//  PFBeautyView.m
//  PFAPIDemoBar

//  Created by mumu on 2019/11/6.
//  Copyright © 2019 pfdetect. All rights reserved.
//

#import "PFBeautyView.h"
#import "UIImage+demobar.h"
#import "UIColor+PFAPIDemoBar.h"

@interface PFBeautyView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end

@implementation PFBeautyView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self ;
    self.dataSource = self ;
    [self registerClass:[FUBeautyCell class] forCellWithReuseIdentifier:@"FUBeautyCell"];
    
    _selectedIndex = -1;
}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FUBeautyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FUBeautyCell" forIndexPath:indexPath];
    
    if (indexPath.row < self.dataArray.count){
        PFBeautyParam *modle = self.dataArray[indexPath.row] ;
        NSString *imageName  = modle.mTitle;
        
            BOOL opened = YES;
        
        if (modle.iSStyle101) {
            opened = fabs(modle.mValue - 0.5) > 0.01 ? YES : NO;
        }else{
            opened = fabsf(modle.mValue - 0) > 0.01 ? YES : NO;
        }
        
        
            BOOL selected = _selectedIndex == indexPath.row ;
            
            if (selected) {
                imageName = opened ? [modle.mTitle stringByAppendingString:@"-3.png"] : [modle.mTitle stringByAppendingString:@"-2.png"] ;
            }else {
                imageName = opened ? [modle.mTitle stringByAppendingString:@"-1.png"] : [modle.mTitle stringByAppendingString:@"-0.png"] ;
            }

        cell.imageView.image = [UIImage imageWithName:imageName];
        cell.titleLabel.text = NSLocalizedString(modle.mTitle,nil);
        cell.titleLabel.textColor = _selectedIndex == indexPath.row ? [UIColor colorWithHexColorString:@"5EC7FE"] : [UIColor whiteColor];
    }
    return cell ;
}

#pragma mark ---- UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectedIndex == indexPath.row) {
        return ;
    }
    PFBeautyParam *model = _dataArray[indexPath.row];
    _selectedIndex = indexPath.row ;
    
    [self reloadData];
    
    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(beautyCollectionView:didSelectedParam:)]) {
        [self.mDelegate beautyCollectionView:self didSelectedParam:model];
    }
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(16, 16, 6, 16) ;
}





@end


@implementation FUBeautyCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.imageView.layer.masksToBounds = YES ;
        self.imageView.layer.cornerRadius = frame.size.width / 2.0 ;
        [self addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, frame.size.width + 2, frame.size.width + 20, frame.size.height - frame.size.width - 2)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter ;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:self.titleLabel ];
    }
    return self ;
}

@end
