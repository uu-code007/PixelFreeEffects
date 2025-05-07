//
//  PFFilterView.m
//  PFAPIDemoBar
//
//
//  Created by mumu on 2021/9/6.
//
#import "PFFilterView.h"
#import "UIColor+PFAPIDemoBar.h"
#import "UIImage+demobar.h"

@interface PFFilterView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation PFFilterView

-(void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.dataSource = self ;
    [self registerClass:[FUFilterCell class] forCellWithReuseIdentifier:@"FUFilterCell"];
    
    _selectedIndex = 0 ;
}

-(void)setType:(PFFilterViewType)type {
    _type = type ;
    [self reloadData];
}

-(void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex ;
    [self reloadData];
}

-(void)setDefaultFilter:(PFBeautyParam *)filter{
    for (int i = 0; i < _filters.count; i ++) {
        PFBeautyParam *model = _filters[i];
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
    
    PFBeautyParam *model = _filters[indexPath.row];
    
    cell.titleLabel.text = NSLocalizedString(model.mTitle,nil);
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageWithName:model.mParam];
    
    cell.imageView.layer.borderWidth = 0.0 ;
    cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    
    if (_selectedIndex == indexPath.row) {
        
        cell.imageView.layer.borderWidth = 2.0 ;
        cell.imageView.layer.borderColor = [UIColor colorWithHexColorString:@"BAACFF"].CGColor;
        cell.titleLabel.textColor = [UIColor colorWithHexColorString:@"BAACFF"];
    }
    
    return cell ;
}

#pragma mark ---- UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedIndex = indexPath.row ;
    [self reloadData];
    
    PFBeautyParam *model = _filters[indexPath.row];
    
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
