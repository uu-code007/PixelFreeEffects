//
//  FUFilterView.m
//  FUAPIDemoBar
//
//  Created by L on 2018/6/27.
//  Copyright © 2018年 L. All rights reserved.
//

#import "FUFilterView.h"
#import "UIColor+FUAPIDemoBar.h"
#import "UIImage+demobar.h"

@interface FUFilterView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation FUFilterView

-(void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.dataSource = self ;
    [self registerClass:[FUFilterCell class] forCellWithReuseIdentifier:@"FUFilterCell"];
    
    _selectedIndex = 0 ;
}

-(void)setType:(FUFilterViewType)type {
    _type = type ;
    [self reloadData];
}

-(void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex ;
    [self reloadData];
}

-(void)setDefaultFilter:(FUBeautyParam *)filter{
    for (int i = 0; i < _filters.count; i ++) {
        FUBeautyParam *model = _filters[i];
        if (model == filter) {
            self.selectedIndex = i;
            return;
        }
    }
}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FUFilterCell *cell = (FUFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FUFilterCell" forIndexPath:indexPath];
    
    FUBeautyParam *model = _filters[indexPath.row];
    
    cell.titleLabel.text = NSLocalizedString(model.mTitle,nil);
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageWithName:[model.mParam stringByAppendingString:@"_icon"]];
    
    cell.imageView.layer.borderWidth = 0.0 ;
    cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    
    if (_selectedIndex == indexPath.row) {
        
        cell.imageView.layer.borderWidth = 2.0 ;
        cell.imageView.layer.borderColor = [UIColor colorWithHexColorString:@"5EC7FE"].CGColor;
        cell.titleLabel.textColor = [UIColor colorWithHexColorString:@"5EC7FE"];
    }
    
    return cell ;
}

#pragma mark ---- UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedIndex = indexPath.row ;
    [self reloadData];
    
    FUBeautyParam *model = _filters[indexPath.row];
    
    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(filterViewDidSelectedFilter:)]) {
        [self.mDelegate filterViewDidSelectedFilter:model];
    }
}

#pragma mark ---- UICollectionViewDelegateFlowLayout


@end


@implementation FUFilterCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
        self.imageView.layer.masksToBounds = YES ;
        self.imageView.layer.cornerRadius = 3.0 ;
        self.imageView.layer.borderWidth = 0.0 ;
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor ;
        [self addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-8, 54, 70, frame.size.height - 54)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter ;
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.titleLabel];
    }
    return self ;
}
@end
