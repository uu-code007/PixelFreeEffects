//
//  ViewController.m
//  faceLandmark
//
//  Created by mumu on 2021/9/6.
//

#import "ViewController.h"
#import "PFDateHandle.h"
#import "PFEffectResourceManager.h"

@interface PFDetectHintLabel : UILabel
@end

@implementation PFDetectHintLabel

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(8, 16, 8, 16))];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += 32.0;
    size.height += 16.0;
    return size;
}

@end

@interface ViewController ()<PFBeautyEditViewDelegate>

@property (nonatomic, strong) NSUserDefaults *def;
@property (nonatomic, copy) NSString *currentMakeupKey;
@property (nonatomic, strong) PFDetectHintLabel *detectHintLabel;
@property (nonatomic, copy) NSString *currentDetectHintText;
@property (nonatomic, assign) NSTimeInterval lastDetectHintCheckTime;
@property (nonatomic, assign) int currentSkinToneType;
@property (nonatomic, assign) float skinToneIntensity;
@property (nonatomic, assign) float skinToneColdWarmIntensity;
@property (nonatomic, assign) BOOL skinToneBundleLoaded;
@end

@implementation ViewController

- (CGFloat)pf_effectivePanelBottomInset {
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (h <= 0) {
        return 0;
    }
    if (@available(iOS 11.0, *)) {
        CGFloat safeMaxY = CGRectGetMaxY(self.view.safeAreaLayoutGuide.layoutFrame);
        CGFloat fromGuide = h - safeMaxY;
        if (fromGuide > 0.5) {
            return fromGuide;
        }
    }
    CGFloat sb = self.view.safeAreaInsets.bottom;
    if (sb > 0.5) {
        return sb;
    }
    return 16.0;
}

-(PFBeautyEditView *)beautyEditView {
    if (!_beautyEditView) {
        CGFloat inset = [self pf_effectivePanelBottomInset];
        _beautyEditView = [[PFBeautyEditView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 280.0 - inset, self.view.frame.size.width, 280.0)];
        
        _beautyEditView.mDelegate = self;
    }
    return _beautyEditView ;
}

-(void)comparisonButtonDidClick:(BOOL)state{
    self.clickCompare = state;
}

- (PFDetectHintLabel *)pf_detectHintLabel {
    if (!_detectHintLabel) {
        _detectHintLabel = [[PFDetectHintLabel alloc] init];
        _detectHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detectHintLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.72];
        _detectHintLabel.textColor = UIColor.whiteColor;
        _detectHintLabel.textAlignment = NSTextAlignmentCenter;
        _detectHintLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
        _detectHintLabel.numberOfLines = 0;
        _detectHintLabel.alpha = 0.0;
        _detectHintLabel.hidden = YES;
        _detectHintLabel.layer.cornerRadius = 18.0;
        _detectHintLabel.clipsToBounds = YES;
        [_detectHintLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.view addSubview:_detectHintLabel];

        NSLayoutConstraint *topConstraint = nil;
        if (@available(iOS 11.0, *)) {
            topConstraint = [_detectHintLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16.0];
        } else {
            topConstraint = [_detectHintLabel.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:16.0];
        }

        [NSLayoutConstraint activateConstraints:@[
            topConstraint,
            [_detectHintLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [_detectHintLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:24.0],
            [_detectHintLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-24.0],
            [_detectHintLabel.heightAnchor constraintGreaterThanOrEqualToConstant:36.0]
        ]];
    }
    return _detectHintLabel;
}

- (void)pf_showDetectHintText:(NSString *)text {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pf_showDetectHintText:text];
        });
        return;
    }
    if (text.length == 0) {
        [self pf_hideDetectHint];
        return;
    }
    PFDetectHintLabel *label = [self pf_detectHintLabel];
    if ([self.currentDetectHintText isEqualToString:text] && !label.hidden && label.alpha >= 0.99) {
        [self.view bringSubviewToFront:label];
        return;
    }
    self.currentDetectHintText = text;
    label.text = text;
    label.hidden = NO;
    [label invalidateIntrinsicContentSize];
    [self.view bringSubviewToFront:label];
    [UIView animateWithDuration:0.18 animations:^{
        label.alpha = 1.0;
    }];
}

- (void)pf_hideDetectHint {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pf_hideDetectHint];
        });
        return;
    }
    if (!_detectHintLabel || _detectHintLabel.hidden) {
        self.currentDetectHintText = nil;
        return;
    }
    self.currentDetectHintText = nil;
    [UIView animateWithDuration:0.18 animations:^{
        self.detectHintLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (self.currentDetectHintText.length == 0) {
            self.detectHintLabel.hidden = YES;
        }
    }];
}

- (void)pf_updateDetectHintNeedsFace:(BOOL)needsFace needsHuman:(BOOL)needsHuman {
    NSTimeInterval now = CFAbsoluteTimeGetCurrent();
    if (now - self.lastDetectHintCheckTime < 0.3) {
        return;
    }
    self.lastDetectHintCheckTime = now;

    if (!needsFace && !needsHuman) {
        [self pf_hideDetectHint];
        return;
    }
    if (!self.mPixelFree) {
        [self pf_hideDetectHint];
        return;
    }

    NSMutableArray<NSString *> *messages = [NSMutableArray arrayWithCapacity:2];
    if (needsFace && [self.mPixelFree hasFace] <= 0) {
        [messages addObject:@"未检测到人脸"];
    }
    if (needsHuman && [self.mPixelFree hasHuman] <= 0) {
        [messages addObject:@"未检测到人体"];
    }

    if (messages.count > 0) {
        [self pf_showDetectHintText:[messages componentsJoinedByString:@"\n"]];
    } else {
        [self pf_hideDetectHint];
    }
}

- (NSString *)pf_bundlePathForParam:(PFBeautyParam *)param {
    return [[PFEffectResourceManager sharedManager] bundlePathForParam:param];
}

- (void)pf_downloadBundleForParam:(PFBeautyParam *)param completion:(void (^)(NSString *path))completion {
    param.isDownloading = YES;
    [self.beautyEditView refreshResourceParam:param];
    [[PFEffectResourceManager sharedManager] downloadBundleForParam:param completion:^(NSString * _Nullable path, NSError * _Nullable error) {
        [self.beautyEditView refreshResourceParam:param];
        if (error) {
            NSLog(@"[Effects] bundle download failed: %@", error.localizedDescription);
        }
        if (completion) {
            completion(path);
        }
    }];
}

- (void)pf_fetchRemoteEffects {
    [[PFEffectResourceManager sharedManager] fetchEffectListWithCompletion:^(NSArray<PFBeautyParam *> *stickers, NSArray<PFBeautyParam *> *makeup, NSError * _Nullable error) {
        if (error) {
            NSLog(@"[Effects] fetch failed: %@", error.localizedDescription);
            return;
        }
        if (stickers.count > 1) {
            self.beautyEditView.stickersParams = stickers;
            self.beautyEditView.stickersIndex = 0;
            [self filterValueChange:stickers[0]];
        }
        if (makeup.count > 1) {
            self.beautyEditView.makeupParams = makeup;
        }
        [self.beautyEditView updateDemoBar];
    }];
}

- (float)pf_clamp01:(float)value {
    if (value < 0.0f) {
        return 0.0f;
    }
    if (value > 1.0f) {
        return 1.0f;
    }
    return value;
}

- (void)pf_loadSkinToneBundleIfNeeded {
    if (self.skinToneBundleLoaded) {
        return;
    }
    NSString *skinSrcPath = [[NSBundle mainBundle] pathForResource:@"skin_src.bundle" ofType:nil];
    NSData *skinSrcData = [NSData dataWithContentsOfFile:skinSrcPath];
    if (!skinSrcData) {
        NSLog(@"[SkinTone] skin_src.bundle not found at %@", skinSrcPath);
        return;
    }
    [self.mPixelFree createBeautyItemFormBundleKey:PFSrcTypeSkinSrc
                                             data:(void *)skinSrcData.bytes
                                             size:(int)skinSrcData.length];
    self.skinToneBundleLoaded = YES;
}

- (int)pf_skinToneTypeForParamName:(NSString *)paramName {
    if ([paramName isEqualToString:@"skinTone.fair"]) {
        return PFSkinToneTypeFair;
    }
    if ([paramName isEqualToString:@"skinTone.pinkWhite"]) {
        return PFSkinToneTypePinkWhite;
    }
    if ([paramName isEqualToString:@"skinTone.wheat"]) {
        return PFSkinToneTypeWheat;
    }
    if ([paramName isEqualToString:@"skinTone.bronze"]) {
        return PFSkinToneTypeBronze;
    }
    return PFSkinToneTypeNatural;
}

- (void)pf_applySkinToneFilter {
    if (!self.skinToneBundleLoaded) {
        NSLog(@"[SkinTone] skin_src.bundle has not been loaded before applying skin tone.");
    }
    if (![self.mPixelFree respondsToSelector:@selector(pixelFreeSetSkinToneFilter:)]) {
        NSLog(@"[SkinTone] pixelFreeSetSkinToneFilter is not available in current SDK.");
        return;
    }

    PFSkinToneFilterParams params = {};
    params.isUse = YES;
    params.skinToneType = self.currentSkinToneType;
    params.intensity = [self pf_clamp01:self.skinToneIntensity];
    params.coldWarmIntensity = [self pf_clamp01:self.skinToneColdWarmIntensity];
    [self.mPixelFree pixelFreeSetSkinToneFilter:&params];
}

- (BOOL)pf_handleSkinToneParam:(PFBeautyParam *)param {
    if (param.type != FUDataTypeSkinTone) {
        return NO;
    }

    if ([param.mParam isEqualToString:@"skinTone.off"]) {
        if ([self.mPixelFree respondsToSelector:@selector(pixelFreeClearSkinToneFilter)]) {
            [self.mPixelFree pixelFreeClearSkinToneFilter];
        } else {
            NSLog(@"[SkinTone] pixelFreeClearSkinToneFilter is not available in current SDK.");
        }
        return YES;
    } else if ([param.mParam isEqualToString:@"skinTone.intensity"]) {
        self.skinToneIntensity = [self pf_clamp01:param.mValue];
    } else if ([param.mParam isEqualToString:@"skinTone.temperature"]) {
        self.skinToneColdWarmIntensity = [self pf_clamp01:param.mValue];
    } else {
        self.currentSkinToneType = [self pf_skinToneTypeForParamName:param.mParam];
    }

    [self pf_applySkinToneFilter];
    return YES;
}


-(void)filterValueChange:(PFBeautyParam *)param{

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();


    float value = param.mValue;
    if ([self pf_handleSkinToneParam:param]) {
        return;
    }
    if(param.type == FUDataTypeBeautify){
        if ([param.mParam isEqualToString:@"face_EyeStrength"]) {

            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_EyeStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"face_thinning"]) {
              float aa = param.mValue;
              [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_thinning value:&value];
          }
          if ([param.mParam isEqualToString:@"face_narrow"]) {
              [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_narrow value:&value];
          }
          if ([param.mParam isEqualToString:@"face_chin"]) {
              [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_chin value:&value];
          }
        if ([param.mParam isEqualToString:@"face_V"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_V value:&value];

        }
        if ([param.mParam isEqualToString:@"face_small"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_small value:&value];
        }
        if ([param.mParam isEqualToString:@"face_nose"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_nose value:&value];
        }

        if ([param.mParam isEqualToString:@"face_forehead"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_forehead value:&value];
        }
        if ([param.mParam isEqualToString:@"face_mouth"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_mouth value:&value];
        }
        if ([param.mParam isEqualToString:@"face_philtrum"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_philtrum value:&value];
        }

        if ([param.mParam isEqualToString:@"face_long_nose"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_long_nose value:&value];
        }
        if ([param.mParam isEqualToString:@"face_eye_space"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_eye_space value:&value];
        }
        
        if ([param.mParam isEqualToString:@"face_smile"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_smile value:&value];
        }
        if ([param.mParam isEqualToString:@"face_eye_rotate"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_eye_rotate value:&value];
        }
        if ([param.mParam isEqualToString:@"face_canthus"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_canthus value:&value];
        }

        // ===== 新增：ins1.png 点位细分 =====
        if ([param.mParam isEqualToString:@"face_eye_y"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_eye_y value:&value];
        }
        if ([param.mParam isEqualToString:@"face_eye_height"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_eye_height value:&value];
        }
        if ([param.mParam isEqualToString:@"face_nose_size"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_nose_size value:&value];
        }
        if ([param.mParam isEqualToString:@"face_nose_height"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_nose_height value:&value];
        }
        if ([param.mParam isEqualToString:@"face_nose_y"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_nose_y value:&value];
        }
        if ([param.mParam isEqualToString:@"face_nose_tip"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_nose_tip value:&value];
        }
        if ([param.mParam isEqualToString:@"face_nose_bridge"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_nose_bridge value:&value];
        }

        if ([param.mParam isEqualToString:@"face_brow_thickness"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_brow_thickness value:&value];
        }
        if ([param.mParam isEqualToString:@"face_brow_length"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_brow_length value:&value];
        }
        if ([param.mParam isEqualToString:@"face_brow_lift"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_brow_lift value:&value];
        }
        if ([param.mParam isEqualToString:@"face_brow_distance"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_brow_distance value:&value];
        }
        if ([param.mParam isEqualToString:@"face_brow_tilt"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_brow_tilt value:&value];
        }

        if ([param.mParam isEqualToString:@"face_upper_lip_thickness"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_upper_lip_thickness value:&value];
        }
        if ([param.mParam isEqualToString:@"face_lower_lip_thickness"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_lower_lip_thickness value:&value];
        }
        if ([param.mParam isEqualToString:@"face_lip_fullness"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_lip_fullness value:&value];
        }
        if ([param.mParam isEqualToString:@"face_mouth_width"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFace_mouth_width value:&value];
        }

          if ([param.mParam isEqualToString:@"runddy"]) {
              [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceRuddyStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"writen"]) {
              [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceM_newWhitenStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"blur"]) {
              [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceBlurStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"sharpen"]) {
              [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceSharpenStrength value:&value];
          }
        if ([param.mParam isEqualToString:@"eye_b"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceEyeBrighten value:&value];
        }
        
        if ([param.mParam isEqualToString:@"newWhitenStrength"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceM_newWhitenStrength value:&value];
        }
        if ([param.mParam isEqualToString:@"qualityStrength"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeFaceH_qualityStrength value:&value];
        }
        
        if ([param.mParam isEqualToString:@"nasolabialStrength"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterNasolabial value:&value];
        }
        if ([param.mParam isEqualToString:@"blackEyeStrength"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterBlackEye value:&value];
        }
        
        if ([param.mParam isEqualToString:@"teethStrength"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterWhitenTeeth value:&value];
        }
        if ([param.mParam isEqualToString:@"fleckFlawClean"]) {
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterFleckFlawClean value:&value];
        }
        
    }

    if (param.type == FUDataTypeFilter) {

       const char *aaa = [param.mParam UTF8String];
        [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterName value:(void *)aaa];
        [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterStrength value:&value];
    }

    if (param.type == FUDataTypeStickers) {
        if([param.mParam isEqualToString:@"origin"]){
            [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSticker2DFilter value:NULL];
        } else{
//            NSString *path =  [[NSBundle mainBundle] pathForResource:@"pixelfree2D" ofType:nil];
//            NSString *currentFolder = [path stringByAppendingPathComponent:param.mParam];
//            const char *aaa = [currentFolder UTF8String];
//            [self.mPixelFree  pixelFreeSetFiterStickerWithPath:currentFolder];
            
            NSString *paths = [self pf_bundlePathForParam:param];
            if (!paths && param.isRemoteResource) {
                [self pf_downloadBundleForParam:param completion:^(NSString *path) {
                    if (path.length > 0) {
                        [self filterValueChange:param];
                    }
                }];
                return;
            }
            if (!paths) {
                NSLog(@"[Sticker] bundle not found for %@", param.mParam);
                return;
            }
            [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSticker2DFilter value:(void *)[paths UTF8String]];
            
//            NSString *path =  [[NSBundle mainBundle] pathForResource:@"effect" ofType:nil];
//            NSString *currentFolder = [path stringByAppendingPathComponent:@"roseEyeMakeup"];
//            const char *aaa = [currentFolder UTF8String];
//            [self.mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterSticker2DFilter value:(void *)aaa];
            
            
        }
    }
    
    if (param.type == FUDataTypeMakeup) {
        if (param.mParam.length == 0 || [param.mParam isEqualToString:@"origin"]) {
            [self.mPixelFree clearMakeup];
            self.currentMakeupKey = nil;
            return;
        }
        if (![param.mParam isEqualToString:self.currentMakeupKey]) {
            NSString *bundlePath = [self pf_bundlePathForParam:param];
            if (!bundlePath && param.isRemoteResource) {
                [self pf_downloadBundleForParam:param completion:^(NSString *path) {
                    if (path.length > 0) {
                        [self filterValueChange:param];
                    }
                }];
                return;
            }
            NSData *bundleData = [NSData dataWithContentsOfFile:bundlePath];
            if (!bundleData) {
                NSLog(@"[Makeup] bundle not found at %@", bundlePath);
                return;
            }
            [self.mPixelFree createBeautyItemFormBundleKey:PFSrcTypeMakeup data:(void *)bundleData.bytes size:(int)bundleData.length];
            self.currentMakeupKey = param.mParam;
        }
        float degree = fmaxf(0.0f, fminf(param.mValue, 1.0f));
        for (int part = PFMakeupPartBrow; part <= PFMakeupPartFoundation; part++) {
            [self.mPixelFree pixelFreeSetMakeupPart:part degree:degree];
        }
        return;
    }
    
    if (param.type == FUDataTypeOneKey) {
        if ([param.mTitle isEqualToString:@"origin"]) {
            int value = PFBeautyTypeOneKeyNormal;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"自然"]) {
            int value = PFBeautyTypeOneKeyNatural;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
         
        }
        if ([param.mTitle isEqualToString:@"可爱"]) {
            int value = PFBeautyTypeOneKeyCute;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"女神"]) {
            int value = PFBeautyTypeOneKeyGoddess;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"白净"]) {
            int value = PFBeautyTypeOneKeyFair;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
           
        }
        if ([param.mTitle isEqualToString:@"甜美"]) {
            int value = PFBeautyTypeOneKeySweet;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"质感"]) {
            int value = PFBeautyTypeOneKeyTexture;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"硬派"]) {
            int value = PFBeautyTypeOneKeyHard;
            [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
            
        }

    }

}

-(void)bottomDidChange:(int)index{
    if (index != 0 && _beautyEditView.oneKeyType != PFBeautyTypeOneKeyNormal) {
        int value = PFBeautyTypeOneKeyNormal;
        [_mPixelFree pixelFreeSetBeautyFilterParam:PFBeautyFilterTypeOneKey value:&value];
        [self showDelayedAlert];
        _beautyEditView.oneKeyType = PFBeautyTypeOneKeyNormal;
    }
}


- (void)showDelayedAlert {
    // 创建 UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"一键美颜已关闭" preferredStyle:UIAlertControllerStyleAlert];
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });

    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.def = [NSUserDefaults standardUserDefaults];
    
    [self initPixelFree];
    
    [self setDefaultParam];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    // 归档
//    NSData *shapeParamsData = [NSKeyedArchiver archivedDataWithRootObject:_beautyEditView.shapeParams];
//    NSData *skinParamsData = [NSKeyedArchiver archivedDataWithRootObject:_beautyEditView.skinParams];
//    NSData *stickerseData = [NSKeyedArchiver archivedDataWithRootObject:_beautyEditView.stickersParams];
//    
//    NSUserDefaults*userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setInteger:_beautyEditView.oneKeyType forKey:@"oneKeyType"];
//    [userDefaults setInteger:_beautyEditView.filterIndex forKey:@"filtersUseIndex"];
//    [userDefaults setInteger:_beautyEditView.stickersIndex forKey:@"stickerUseIndex"];
//    [userDefaults synchronize];
//    
//    // 写本地
//    [self writeData:shapeParamsData fileName:@"shapeParamsData"];
//    [self writeData:skinParamsData fileName:@"skinParamsData"];
//    [self writeData:stickerseData fileName:@"stickerseData"];
    
}


-(void)initPixelFree{
    NSString *face_FiltePath = [[NSBundle mainBundle] pathForResource:@"filter_model.bundle" ofType:nil];
//    NSString *face_DetectPath = [[NSBundle mainBundle] pathForResource:@"face_detect.bundle" ofType:nil];
    NSString *authFile = [[NSBundle mainBundle] pathForResource:@"pixelfreeAuth.lic" ofType:nil];
    self.currentSkinToneType = PFSkinToneTypeNatural;
    self.skinToneIntensity = 0.6f;
    self.skinToneColdWarmIntensity = 0.5f;
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    self.mPixelFree = [[SMPixelFree alloc] initWithProcessContext:nil srcFilterPath:face_FiltePath authFile:authFile];
    [self pf_loadSkinToneBundleIfNeeded];
    
//    NSLog(@"mPixelFree retain  count = %ld\n",CFGetRetainCount((__bridge  CFTypeRef)(self.mPixelFree)));


    
    CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
    
    NSLog(@"initPixelFree --- %d",endTime/1000);

    [self.view addSubview:self.beautyEditView];
}

-(void)setDefaultParam{
    NSArray<PFBeautyParam *>* defaultData = [PFDateHandle setupShapData];
    NSArray<PFBeautyParam *>* defaultSkinData = [PFDateHandle setupSkinData];
    NSArray<PFBeautyParam *>* defaultfiltersData = [PFDateHandle setupFilterData];
    NSArray<PFBeautyParam *>* defaultfaceData = [PFDateHandle setupFaceType];
    NSArray<PFBeautyParam *>* defaultStickerseData = [[PFEffectResourceManager sharedManager] originParamsForType:FUDataTypeStickers];
    NSArray<PFBeautyParam *>* defaultMakeupData = [[PFEffectResourceManager sharedManager] originParamsForType:FUDataTypeMakeup];
    
    // 读本地缓存
    NSData *data = [self readDatafileName:@"shapeParamsData"];
    if (data) {
        defaultData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    data = [self readDatafileName:@"skinParamsData"];
    if (data) {
        defaultSkinData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    data = [self readDatafileName:@"filtersParamsData"];
    if (data) {
        defaultfiltersData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    data = [self readDatafileName:@"oneKeyParamsData"];
    if (data) {
        defaultfaceData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    // 更新 UI
    self.beautyEditView.shapeParams = defaultData;
    self.beautyEditView.skinParams = defaultSkinData;
    self.beautyEditView.filtersParams = defaultfiltersData;
    self.beautyEditView.faceTypeParams = defaultfaceData;
    self.beautyEditView.stickersParams = defaultStickerseData;
    self.beautyEditView.makeupParams = defaultMakeupData;
    
    NSUserDefaults*userDefaults = [NSUserDefaults standardUserDefaults];
    int oneKeyType = (int)[userDefaults integerForKey:@"oneKeyType"];
    int filtersIndex = (int)[userDefaults integerForKey:@"filtersUseIndex"];
    int stickerIndex = (int)[userDefaults integerForKey:@"stickerUseIndex"];
    if (oneKeyType < 0 || oneKeyType >= defaultfaceData.count) {
        oneKeyType = 0;
    }
    if (filtersIndex < 0 || filtersIndex >= defaultfiltersData.count) {
        filtersIndex = 0;
    }
    if (stickerIndex < 0 || stickerIndex >= defaultStickerseData.count) {
        stickerIndex = 0;
    }

    self.beautyEditView.oneKeyType = oneKeyType;
    self.beautyEditView.filterIndex = filtersIndex;
    self.beautyEditView.stickersIndex = stickerIndex;
    
    [self.beautyEditView updateDemoBar];
    
    
    // 更新 SDK 设置
    for (PFBeautyParam *param in defaultData) {
        [self filterValueChange:param];
    }
    
    for (PFBeautyParam *param in defaultSkinData) {
        [self filterValueChange:param];
    }
    
    
    PFBeautyParam *param = defaultfaceData[oneKeyType];
    [self filterValueChange:param];
    param = defaultfiltersData[filtersIndex];
    [self filterValueChange:param];
    
    param = defaultStickerseData[stickerIndex];
    [self filterValueChange:param];
    [self pf_fetchRemoteEffects];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_beautyEditView.superview == self.view) {
        CGFloat w = CGRectGetWidth(self.view.bounds);
        CGFloat h = CGRectGetHeight(self.view.bounds);
        CGFloat panelH = 280.0;
        CGFloat panelBottomInset = [self pf_effectivePanelBottomInset];
        _beautyEditView.frame = CGRectMake(0, h - panelH - panelBottomInset, w, panelH);
    }
}

-(void)appBecomeActive{
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
}


-(void)writeData:(NSData *)data fileName:(NSString *)fileName{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];

    // 获取目标文件的完整路径
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
//    [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    // 创建文件并覆盖写入数据
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:filePath
                                                          contents:data
                                                        attributes:nil];
    if (success) {
        NSLog(@"数据写入成功");
    } else {
        NSLog(@"数据写入失败");
    }
    
}

-(NSData *)readDatafileName:(NSString *)fileName{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];

    // 获取目标文件的完整路径
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}


//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"makeup" ofType:nil];
//    if (!path) {
//        NSLog(@"[Makeup] 错误: 找不到 makeup 资源文件夹");
//        return;
//    }
//    
//    NSString *currentFolder = [path stringByAppendingPathComponent:@"大气"];
//    NSLog(@"[Makeup] 美妆路径: %@", currentFolder);
//    
//    // 检查文件夹是否存在
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL isDirectory = NO;
//    BOOL exists = [fileManager fileExistsAtPath:currentFolder isDirectory:&isDirectory];
//    
//    if (exists && isDirectory) {
//        NSLog(@"[Makeup] 文件夹存在，应用美妆");
//            int ret = [self.mPixelFree pixelFreeSetMakeupWithJsonPath:currentFolder];
//        
////        NSString *name = [NSString stringWithFormat:@"%@.bundle",@"大气"];
////        NSString *currentBundle = [path stringByAppendingPathComponent:name];
////        NSData *date = [NSData dataWithContentsOfFile:currentBundle];
////        
////        [self.mPixelFree createBeautyItemFormBundleKey:PFSrcTypeMakeup data:(void *)date.bytes size:date.length];
////            NSLog(@"[Makeup] 应用美妆返回值: %d", ret);
//    } else {
//        NSLog(@"[Makeup] 错误: 美妆文件夹不存在: %@", currentFolder);
//    }
//
//}

-(void)dealloc{
    // 清理 mPixelFree，确保资源释放
    if (_mPixelFree) {
        // SMPixelFree 的 dealloc 会调用 destroy 方法清理资源
        _mPixelFree = nil;
    }
    NSLog(@"ViewController dealloc");
}

@end
