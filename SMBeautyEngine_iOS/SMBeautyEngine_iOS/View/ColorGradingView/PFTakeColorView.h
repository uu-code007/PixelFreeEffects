//
//  PFTakeColorView.h
//  FULiveDemo
//
//  Created by 孙慕 on 2020/8/18.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PFTakeColorChange)(UIColor *color);

typedef void(^PFTakeColorComplete)(void);

@interface PFTakeColorView : UIView

@property(nonatomic,strong)UIView *perView;


-(instancetype)initWithFrame:(CGRect)frame didChangeBlock:(PFTakeColorChange)block complete:(PFTakeColorComplete)complete;

-(void)actionRect:(CGRect )rect;

-(void)toucheSetPoint:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
