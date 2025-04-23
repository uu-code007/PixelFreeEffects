//
//  FULvMuView.m
//  FULiveDemo
//
//  Created by 孙慕 on 2020/8/13.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import "PFHLSToolView.h"
#import <Masonry/Masonry.h>
#import "AdjustmentItem.h"


typedef NS_ENUM(NSUInteger, FULvMuState) {
    FULvMukeying,
    FULvMubackground,
};


@implementation PFMuColorCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgImageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, frame.size.width -2, frame.size.width-2)];
        _bgImageLayer.image = [UIImage imageNamed:@"demo_bg_transparent"];
        _bgImageLayer.layer.cornerRadius = _bgImageLayer.frame.size.width / 2.0 ;
        [self addSubview:_bgImageLayer];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.imageView.layer.masksToBounds = YES ;
        self.imageView.layer.cornerRadius = frame.size.width / 2.0 ;
        self.contentView.layer.borderWidth = 0;
        self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = frame.size.width / 2.0 ;
        
        [self addSubview:self.imageView];
        
    }
    return self ;
}

-(void)setColorItemSelected:(BOOL)selecte{
    if (selecte) {
        self.imageView.transform = CGAffineTransformIdentity;
        self.bgImageLayer.transform = CGAffineTransformIdentity;
        self.contentView.layer.borderWidth = 2;
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            self.bgImageLayer.transform = CGAffineTransformMakeScale(0.7, 0.7);
        }];
    }else{
        self.contentView.layer.borderWidth = 0;
        //        [UIView animateWithDuration:0.25 animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
        self.bgImageLayer.transform = CGAffineTransformIdentity;
        //        }];
    }
}
@end

static NSString *LvMuCellID = @"FULvMuCellID";
static NSString *colorCellID = @"PFMuColorCellID";

@interface PFHLSToolView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView *mColorCollectionView;



@property (strong, nonatomic) NSMutableArray <UIColor *>* colors;

@property (assign, nonatomic) FUTakeColorState colorEditState;

@end

@implementation PFHLSToolView

-(PFTakeColorView *)mTakeColorView{
    if (!_mTakeColorView) {
        __weak typeof(self)weakSelf  = self ;
        _mTakeColorView = [[PFTakeColorView alloc] initWithFrame:CGRectMake(100, 100, 36, 60) didChangeBlock:^(UIColor * _Nonnull color) {
            if (!weakSelf.mColorCollectionView) {
                return ;
            }
            
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
            PFMuColorCell *cell = (PFMuColorCell *)[weakSelf.mColorCollectionView cellForItemAtIndexPath:indexpath];
            cell.imageView.backgroundColor = color;
            [weakSelf.colors replaceObjectAtIndex:0 withObject:color];
            
        }complete:^{
            UIColor *color = weakSelf.colors[0];
            CGFloat r,g,b,a;
            [color getRed:&r green:&g blue:&b alpha:&a];
            
            if ([weakSelf.mDelegate respondsToSelector:@selector(colorDidSelectedR:G:B:A:)]) {
                [weakSelf.mDelegate colorDidSelectedR:r G:g B:b A:a];
            }
            
            /* 开始渲染 */
            [self changeTakeColorState:FUTakeColorStateStop];
        }];
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        PFMuColorCell *cell = (PFMuColorCell *)[weakSelf.mColorCollectionView cellForItemAtIndexPath:indexpath];
        _mTakeColorView.hidden = YES;
        _mTakeColorView.backgroundColor = [UIColor clearColor];
        _mTakeColorView.perView.backgroundColor = cell.imageView.backgroundColor;
        _mTakeColorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/4);
        [_mTakeColorView actionRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 180)];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:_mTakeColorView];
    }
    
    return _mTakeColorView;
}

- (instancetype)initWithFrame:(CGRect)frame Colors:(NSArray<UIColor *>*) colors adjustmentItems:(NSArray<AdjustmentItem *> *)items {
    if (self = [super initWithFrame:frame]) {
        
        _colorSelectedIndex = 1;
        _colorEditState = FUTakeColorStateStop;
        
        [self setupSubView];
        [self setupData];
        if (colors.count > 0) {
            [_colors addObjectsFromArray:colors];
        }
        
        
        // 创建 ToolUI
        ToolUI* toolUI = [[ToolUI alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, self.frame.size.height - 40) adjustmentItems:items];
        [self addSubview:toolUI];
        
        // 设置滑动事件回调
        __weak typeof(self) weakSelf = self;
        toolUI.sliderValueChangedBlock = ^(AdjustmentItem *item) {
            if (weakSelf.mDelegate && [weakSelf.mDelegate respondsToSelector:@selector(sliderValueChanged:)]) {
                [weakSelf.mDelegate sliderValueChanged:item];
            }
            
        };
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectview.alpha = 1.0;
        [self insertSubview:effectview atIndex:0];
        effectview.frame = frame;
    }
    return self;
}




-(void)setupData{
    _colors = [NSMutableArray array];
    // 定义颜色
    UIColor *red = [UIColor colorWithRed:193.0/255.0 green:62.0/255.0 blue:81.0/255.0 alpha:1.0];       // 红
    UIColor *orange = [UIColor colorWithRed:239.0/255.0 green:142.0/255.0 blue:87.0/255.0 alpha:1.0];    // 橙
    UIColor *yellow = [UIColor colorWithRed:250.0/255.0 green:229.0/255.0 blue:102.0/255.0 alpha:1.0];     // 黄
    UIColor *green = [UIColor colorWithRed:132.0/255.0 green:251.0/255.0 blue:102.0/255.0 alpha:1.0];      // 绿
    UIColor *blue = [UIColor colorWithRed:95.0/255.0 green:155.0/255.0 blue:247.0/255.0 alpha:1.0];       // 蓝
    UIColor *indigo = [UIColor colorWithRed:167.0/255.0 green:79.0/255.0 blue:245.0/255.0 alpha:1.0];   // 靛
    UIColor *purple = [UIColor colorWithRed:234.0/255.0 green:68.0/255.0 blue:163.0/255.0 alpha:1.0];     // 紫

    // 将颜色添加到数组
    [_colors addObject:[UIColor clearColor]];
    [_colors addObject:red];
    [_colors addObject:orange];
    [_colors addObject:yellow];
    [_colors addObject:green];
    [_colors addObject:blue];
    [_colors addObject:indigo];
    [_colors addObject:purple];
}


-(void)setupSubView{
    
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc] init];
    layout1.minimumInteritemSpacing = 0;
    layout1.minimumLineSpacing = 16;
    layout1.itemSize = CGSizeMake(28, 28);
    layout1.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _mColorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout1];
    _mColorCollectionView.backgroundColor = [UIColor clearColor];
    _mColorCollectionView.delegate = self;
    _mColorCollectionView.dataSource = self;
    [self addSubview:_mColorCollectionView];
    [_mColorCollectionView registerClass:[PFMuColorCell class] forCellWithReuseIdentifier:colorCellID];
    
//    [_mColorCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top);
//        make.left.right.equalTo(self);
//        make.height.mas_equalTo(36);
//    }];
    
    CGFloat collectionViewHeight = 36;
    _mColorCollectionView.frame = CGRectMake(
        0,                                      // x (left对齐)
        0,                                      // y (top对齐)
        CGRectGetWidth(self.bounds),            // width (与父视图同宽)
        collectionViewHeight                    // height (固定高度36)
    );
    
}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _colors.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PFMuColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:colorCellID forIndexPath:indexPath];
    [cell setColorItemSelected:_colorSelectedIndex == indexPath.row ?YES:NO];
    
    cell.imageView.backgroundColor = _colors[indexPath.row];
    if(indexPath.row == 0){
        cell.imageView.backgroundColor = [UIColor clearColor];
        if(_colorSelectedIndex != 0){
            cell.imageView.image = [UIImage imageNamed:@"demo_icon_straw"];
            
        }else{
            cell.imageView.image = NULL;
        }
        
    }else{
        cell.imageView.image = NULL;
    }
    
    return cell;
    
    
}

#pragma mark ---- UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_colorSelectedIndex == indexPath.row && indexPath.row != 0){
        return;
    }
    self.mTakeColorView.hidden = indexPath.row == 0 ?NO:YES;
    
    if (indexPath.row == 0) {
        self.mTakeColorView.perView.backgroundColor = [UIColor clearColor];
        [self changeTakeColorState:FUTakeColorStateRunning];
    }else{
        [self changeTakeColorState:FUTakeColorStateStop];
    }
    _colorSelectedIndex = indexPath.row ;
    
    [self didSelColorWithIdnex:(int)indexPath.row];
    
    [self.mColorCollectionView reloadData];
}

#pragma  mark - update UI
- (UIViewController *)viewControllerFromView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}



-(void)didSelColorWithIdnex:(int)index{
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
    PFMuColorCell *cell = (PFMuColorCell *)[_mColorCollectionView cellForItemAtIndexPath:indexpath];
    CGFloat r,g,b,a;
    [cell.imageView.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    if ([self.mDelegate respondsToSelector:@selector(colorDidSelectedR:G:B:A:)]) {
        [self.mDelegate colorDidSelectedR:r G:g B:b A:a];
    }
}


-(void)destoryLvMuView{
    [self.mTakeColorView removeFromSuperview];
    _mTakeColorView  = nil;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self changeTakeColorState:FUTakeColorStateStop];
}

-(void)willRemoveSubview:(UIView *)subview{
    [_mTakeColorView removeFromSuperview];
}



-(void)changeTakeColorState:(FUTakeColorState )state{
    if (state != self.colorEditState) {
        self.colorEditState = state;
    }else{
        return;
    }
    if (state == FUTakeColorStateStop) {
        _mTakeColorView.hidden = YES;
    }
    
    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(takeColorState:)]) {
        [self.mDelegate takeColorState:state];
    }
    
}


-(void)dealloc{
    NSLog(@"lv ---- dealloc");
}



@end
