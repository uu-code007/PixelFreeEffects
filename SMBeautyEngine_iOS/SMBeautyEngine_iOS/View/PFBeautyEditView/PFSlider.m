//
//  PFSlider.m
//  PFAPIDemoBar
//
//
//  Created by mumu on 2021/9/6.
//
#import "PFSlider.h"
#import "PFDemoBarDefine.h"
#import "UIImage+demobar.h"
#import "UIColor+PFBeautyEditView.h"

@implementation PFSlider
{
    UILabel *tipLabel;
    UIImageView *bgImgView;
    UIView *trackView;
    UIView *activeTrackView;
    UIView *centerLineView;
    UIImageView *thumbImageView;
}

- (void)commonInit {
    if (trackView) {
        return;
    }

    UIImage *thumbImage = [UIImage imageWithName:@"expource_slider_dot"];
    UIImage *clearThumbImage = [self clearImageWithSize:thumbImage.size];
    UIImage *clearTrackImage = [self clearImageWithSize:CGSizeMake(1.0, 5.0)];
    [self setThumbImage:clearThumbImage forState:UIControlStateNormal];
    [self setThumbImage:clearThumbImage forState:UIControlStateHighlighted];
    [self setMinimumTrackImage:clearTrackImage forState:UIControlStateNormal];
    [self setMaximumTrackImage:clearTrackImage forState:UIControlStateNormal];
    self.minimumTrackTintColor = [UIColor clearColor];
    self.maximumTrackTintColor = [UIColor clearColor];

    trackView = [[UIView alloc] init];
    trackView.backgroundColor = [UIColor whiteColor];
    trackView.userInteractionEnabled = NO;
    trackView.layer.cornerRadius = 2.5;
    [self addSubview:trackView];

    activeTrackView = [[UIView alloc] init];
    activeTrackView.backgroundColor = [UIColor colorWithHexColorString:@"BAACFF"];
    activeTrackView.userInteractionEnabled = NO;
    activeTrackView.layer.cornerRadius = 2.5;
    [self addSubview:activeTrackView];

    centerLineView = [[UIView alloc] init];
    centerLineView.backgroundColor = [UIColor whiteColor];
    centerLineView.userInteractionEnabled = NO;
    centerLineView.layer.cornerRadius = 1.0;
    [self addSubview:centerLineView];

    thumbImageView = [[UIImageView alloc] initWithImage:thumbImage];
    thumbImageView.userInteractionEnabled = NO;
    [self addSubview:thumbImageView];

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

    [self addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self updateSliderAppearance];
}

- (UIImage *)clearImageWithSize:(CGSize)size {
    if (size.width <= 0.0 || size.height <= 0.0) {
        size = CGSizeMake(20.0, 20.0);
    }

    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [[UIColor clearColor] setFill];
    UIRectFill(CGRectMake(0.0, 0.0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGFloat)normalizedValue {
    CGFloat range = self.maximumValue - self.minimumValue;
    if (fabs(range) <= 0.0001) {
        return 0.0;
    }

    CGFloat normalized = (self.value - self.minimumValue) / range;
    return MIN(1.0, MAX(0.0, normalized));
}

- (CGRect)customTrackRect {
    CGFloat height = 5.0;
    CGFloat inset = 10.0;
    return CGRectMake(inset,
                      CGRectGetMidY(self.bounds) - height * 0.5,
                      MAX(0.0, CGRectGetWidth(self.bounds) - inset * 2.0),
                      height);
}

- (void)updateSliderAppearance {
    if (!trackView) {
        return;
    }

    CGRect trackRect = [self customTrackRect];
    CGFloat normalized = [self normalizedValue];
    CGFloat thumbCenterX = CGRectGetMinX(trackRect) + normalized * CGRectGetWidth(trackRect);
    CGFloat centerX = CGRectGetMidX(trackRect);

    trackView.frame = trackRect;

    if (_type == FUFilterSliderType101) {
        CGFloat activeWidth = fabs(normalized - 0.5) * CGRectGetWidth(trackRect);
        CGFloat activeX = normalized >= 0.5 ? centerX : centerX - activeWidth;
        activeTrackView.frame = CGRectMake(activeX, CGRectGetMinY(trackRect), activeWidth, CGRectGetHeight(trackRect));
        centerLineView.hidden = NO;
        centerLineView.frame = CGRectMake(centerX - 1.0, CGRectGetMidY(trackRect) - 4.0, 2.0, 8.0);
        tipLabel.text = [NSString stringWithFormat:@"%d",(int)(self.value * 100 - 50)];
    } else {
        activeTrackView.frame = CGRectMake(CGRectGetMinX(trackRect),
                                           CGRectGetMinY(trackRect),
                                           thumbCenterX - CGRectGetMinX(trackRect),
                                           CGRectGetHeight(trackRect));
        centerLineView.hidden = YES;
        tipLabel.text = [NSString stringWithFormat:@"%d",(int)(self.value * 100)];
    }

    CGSize thumbSize = thumbImageView.image.size;
    if (thumbSize.width <= 0.0 || thumbSize.height <= 0.0) {
        thumbSize = CGSizeMake(20.0, 20.0);
    }
    thumbImageView.frame = CGRectMake(thumbCenterX - thumbSize.width * 0.5,
                                      CGRectGetMidY(trackRect) - thumbSize.height * 0.5,
                                      thumbSize.width,
                                      thumbSize.height);

    CGFloat tipX = thumbCenterX - tipLabel.frame.size.width * 0.5;
    CGRect tipFrame = tipLabel.frame;
    tipFrame.origin.x = tipX;
    bgImgView.frame = tipFrame;
    tipLabel.frame = tipFrame;
    tipLabel.hidden = !self.tracking;
    bgImgView.hidden = !self.tracking;

    [self bringSubviewToFront:trackView];
    [self bringSubviewToFront:activeTrackView];
    [self bringSubviewToFront:centerLineView];
    [self bringSubviewToFront:thumbImageView];
    [self bringSubviewToFront:bgImgView];
    [self bringSubviewToFront:tipLabel];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self updateSliderAppearance];
}

-(void)setType:(PFSliderType)type {
    _type = type ;
    [self updateSliderAppearance];
}

- (void)setValue:(float)value {
    [super setValue:value];
    [self updateSliderAppearance];
}

- (void)setValue:(float)value animated:(BOOL)animated {
    [super setValue:value animated:animated];
    [self updateSliderAppearance];
}

- (void)sliderValueChanged {
    [self updateSliderAppearance];
}

@end
