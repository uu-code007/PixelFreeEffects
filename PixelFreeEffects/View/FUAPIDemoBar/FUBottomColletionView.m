//
//  FUBottomColletionView.m
//  FULiveDemo
//
//  Created by 孙慕 on 2019/11/6.
//  Copyright © 2019 FaceUnity. All rights reserved.
//

#import "FUBottomColletionView.h"

#pragma  mark -  FUBottomBottomCell
@implementation FUBottomBottomCell
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){

        _botlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
        _botlabel.textAlignment = NSTextAlignmentCenter;
        _botlabel.textColor = [UIColor colorWithRed:44/255.0 green:46/255.0 blue:48/255.0 alpha:1.0];
        _botlabel.font = [UIFont systemFontOfSize:13];
        self.botlabel.center = self.contentView.center;
        [self.contentView addSubview:_botlabel];
    }
    
    return self;
}

-(void)setIsSel:(BOOL)isSel{
    _isSel = isSel;
    if (isSel) {
        _botlabel.textColor = [UIColor colorWithRed:31/255.0 green:178/255.0 blue:255/255.0 alpha:1.0];
    }else{
        _botlabel.textColor = [UIColor colorWithRed:44/255.0 green:46/255.0 blue:48/255.0 alpha:1.0];
    }
}
@end


#pragma  mark -  FUBottomColletionView

@interface FUBottomColletionView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collection;

@property (assign, nonatomic) NSInteger selIndex;
@end

@implementation FUBottomColletionView

static  NSString *cellID = @"bottomCell";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor colorWithRed:5/255.0 green:15/255.0 blue:20/255.0 alpha:0.74];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 16;
        layout.itemSize = CGSizeMake(60, 49);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, frame.size.height) collectionViewLayout:layout];
        _collection.backgroundColor = [UIColor clearColor];
        _collection.delegate = self;
        _collection.dataSource = self;
        [self addSubview:_collection];
        [_collection registerClass:[FUBottomBottomCell class] forCellWithReuseIdentifier:cellID];
        _collection.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
  
    }
    
    return self;
}


-(void)setDataArray:(NSArray*)dataArray{
    _dataArray = dataArray;
    [self.collection reloadData];
}


#pragma mark --- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FUBottomBottomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
//    cell.botlabel.text = NSLocalizedString(self.dataArray[indexPath.row].title, nil);
    cell.isSel = _selIndex == indexPath.row ? YES:NO;
    
    return cell;
}

#pragma mark --- UICollectionViewDelegateFlowLayout


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selIndex = indexPath.row;
    [_collection reloadData];
    if ([self.delegate respondsToSelector:@selector(BottomColletionDidSelectedIndex:)]) {
        [self.delegate bottomColletionDidSelectedIndex:_selIndex];
    }
}

@end
