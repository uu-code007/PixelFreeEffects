//
//  FUSlider.m
//  FUAPIDemoBar
//
//  Created by L on 2018/6/27.
//  Copyright © 2018年 L. All rights reserved.
//

#import "FUSlider.h"
#import "FUDemoBarDefine.h"
#import "UIImage+demobar.h"
#import "UIColor+FUAPIDemoBar.h"

@implementation FUSlider
{
    UILabel *tipLabel;
    UIImageView *bgImgView;
    
    UIView *middleView ;
    UIView *line ;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setThumbImage:[UIImage imageWithName:@"expource_slider_dot"] forState:UIControlStateNormal];
    
    UIImage *bgImage = [UIImage imageWithName:@"slider_tip_bg"];
    bgImgView = [[UIImageView alloc] initWithImage:bgImage];
    bgImgView.frame = CGRectMake(0, -bgImage.size.height, bgImage.size.width, bgImage.size.height);
    [self addSubview:bgImgView];
    
    tipLabel = [[UILabel alloc] initWithFrame:bgImgView.frame];
    tipLabel.text = @"";
    tipLabel.textColor = [UIColor darkGrayColor];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:tipLabel];
    
    bgImgView.hidden = YES;
    tipLabel.hidden = YES;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setThumbImage:[UIImage imageWithName:@"expource_slider_dot"] forState:UIControlStateNormal];
        
        UIImage *bgImage = [UIImage imageWithName:@"slider_tip_bg"];
        bgImgView = [[UIImageView alloc] initWithImage:bgImage];
        bgImgView.frame = CGRectMake(0, -bgImage.size.height, bgImage.size.width, bgImage.size.height);
        [self addSubview:bgImgView];
        
        tipLabel = [[UILabel alloc] initWithFrame:bgImgView.frame];
        tipLabel.text = @"";
        tipLabel.textColor = [UIColor darkGrayColor];
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:tipLabel];
        
        bgImgView.hidden = YES;
        tipLabel.hidden = YES;
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (!middleView) {
        middleView = [[UIView alloc] initWithFrame:CGRectMake(2, self.frame.size.height /2.0 - 1, 100, 4)];
        middleView.backgroundColor = [UIColor colorWithHexColorString:@"5EC7FE"];
        middleView.hidden = YES;
        [self insertSubview:middleView atIndex: self.subviews.count - 1];
    }
    
    if (!line) {
        line = [[UIView alloc] init];
        line.backgroundColor = [UIColor whiteColor];
        line.layer.masksToBounds = YES ;
        line.layer.cornerRadius = 1.0 ;
        line.hidden = YES;
        [self insertSubview:line atIndex: self.subviews.count - 1];
    }
    
    line.frame = CGRectMake(self.frame.size.width / 2.0 - 1.0, 4.0, 2.0, self.frame.size.height - 8.0) ;
    
    CGFloat value = self.value ;
    [self setValue:value animated:NO];
}

-(void)setType:(FUSliderType)type {
    _type = type ;
    switch (_type) {
        case FUFilterSliderType101:{
            
            line.hidden = NO ;
            middleView.hidden = NO ;
            [self setMinimumTrackTintColor:[UIColor whiteColor]];
        }
            break;
            
        default:{
            
            line.hidden = YES ;
            middleView.hidden = YES ;
            [self setMinimumTrackTintColor:[UIColor colorWithHexColorString:@"5EC7FE"]];
        }
            break;
    }
}


// 后设置 value
- (void)setValue:(float)value animated:(BOOL)animated   {
    [super setValue:value animated:animated];
    
    
    switch (_type) {
        case FUFilterSliderType101:{
            
            tipLabel.text = [NSString stringWithFormat:@"%d",(int)(value * 100 - 50)];
            
            CGFloat currentValue = value - 0.5 ;
            CGFloat width = currentValue * (self.frame.size.width - 4);
            if (width < 0 ) {
                width = -width ;
            }
            CGFloat X = currentValue > 0 ? self.frame.size.width / 2.0 : self.frame.size.width / 2.0 - width ;
            
            CGRect frame = middleView.frame ;
            frame = CGRectMake(X, frame.origin.y, width, frame.size.height) ;
            middleView.frame = frame ;
        }
            break ;
            
        default:{
            
            tipLabel.text = [NSString stringWithFormat:@"%d",(int)(value * 100)];
        }
            break;
    }
    
    CGFloat x = value * (self.frame.size.width - 20) - tipLabel.frame.size.width * 0.5 + 10;
    CGRect frame = tipLabel.frame;
    frame.origin.x = x;
    
    bgImgView.frame = frame;
    tipLabel.frame = frame;
    tipLabel.hidden = !self.tracking;
    bgImgView.hidden = !self.tracking;
    
}

@end
