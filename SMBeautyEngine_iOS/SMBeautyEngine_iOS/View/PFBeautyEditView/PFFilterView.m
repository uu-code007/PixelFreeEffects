//
//  PFFilterView.m
//  PFAPIDemoBar
//
//
//  Created by mumu on 2021/9/6.
//
#import "PFFilterView.h"
#import "UIColor+PFBeautyEditView.h"
#import "UIImage+demobar.h"
#import <SDWebImage/SDWebImage.h>

@interface PFFilterView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation PFFilterView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.dataSource = self ;
    [self registerClass:[FUFilterCell class] forCellWithReuseIdentifier:@"FUFilterCell"];
    if (_selectedIndex == 0 && self.filters.count == 0) {
        _selectedIndex = 0;
    }
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
    UIImage *placeholder = [UIImage imageWithName:model.mParam];
    if (model.iconURL.length > 0) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.iconURL] placeholderImage:placeholder];
    } else {
        [cell.imageView sd_cancelCurrentImageLoad];
        cell.imageView.image = placeholder;
    }
    BOOL needsDownload = model.isRemoteResource && !model.isDownloaded;
    cell.downloadBadgeView.hidden = !needsDownload || model.isDownloading;
    cell.downloadIndicatorView.hidden = !model.isDownloading;
    if (model.isDownloading) {
        [cell.downloadIndicatorView startAnimating];
    } else {
        [cell.downloadIndicatorView stopAnimating];
    }
    
    cell.imageView.layer.borderWidth = 0.0 ;
    cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    
    if (_selectedIndex == indexPath.row) {
        
        cell.imageView.layer.borderWidth = 2.0 ;
        cell.imageView.layer.borderColor = [UIColor colorWithHexColorString:@"BAACFF"].CGColor;
        cell.titleLabel.textColor = [UIColor colorWithHexColorString:@"BAACFF"];
    }
    
    return cell ;
}

- (void)refreshItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.filters.count) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    if ([self.indexPathsForVisibleItems containsObject:indexPath]) {
        [self reloadItemsAtIndexPaths:@[indexPath]];
    }
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

-(void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
    self.downloadBadgeView.hidden = YES;
    [self.downloadIndicatorView stopAnimating];
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
        self.imageView.layer.masksToBounds = YES ;
        self.imageView.layer.cornerRadius = 3.0 ;
        self.imageView.layer.borderWidth = 0.0 ;
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor ;
        [self addSubview:self.imageView];

        self.downloadBadgeView = [[UIImageView alloc] initWithFrame:CGRectMake(38, -2, 18, 18)];
        if (@available(iOS 13.0, *)) {
            self.downloadBadgeView.image = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
            self.downloadBadgeView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        }
        self.downloadBadgeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
        self.downloadBadgeView.layer.cornerRadius = 9.0;
        self.downloadBadgeView.clipsToBounds = YES;
        self.downloadBadgeView.hidden = YES;
        [self addSubview:self.downloadBadgeView];

        if (@available(iOS 13.0, *)) {
            self.downloadIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            self.downloadIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
        self.downloadIndicatorView.frame = CGRectMake(0, 0, 28, 28);
        self.downloadIndicatorView.center = self.imageView.center;
        self.downloadIndicatorView.hidesWhenStopped = YES;
        self.downloadIndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
        self.downloadIndicatorView.layer.cornerRadius = 14.0;
        self.downloadIndicatorView.clipsToBounds = YES;
        self.downloadIndicatorView.hidden = YES;
        if (@available(iOS 13.0, *)) {
            self.downloadIndicatorView.color = UIColor.whiteColor;
        }
        [self addSubview:self.downloadIndicatorView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-8, 54, 70, frame.size.height - 54)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter ;
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.titleLabel];
    }
    return self ;
}
@end
