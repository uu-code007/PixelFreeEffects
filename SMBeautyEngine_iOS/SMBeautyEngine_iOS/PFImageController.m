//
//  PFImageController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/9/29.
//

#import "PFImageController.h"
#import <Vision/Vision.h>

#import "ToolUI.h"
#import "AdjustmentItem.h"
#import "AdjustmentItem.h"
#import "PFHLSToolView.h"
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>

@interface PFImageController ()<PFMuViewDelegate,UIImagePickerControllerDelegate> {
    PFImageColorGrading mColorGrading ;
    PFHLSFilterParams  mHLSFilterParams;
    int handle;
}

@property(nonatomic,strong)UIImage *image;

@property(nonatomic,strong)UIImageView *imageView;

/** NSTimer */
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSRunLoop *mRunLoop;


@property (nonatomic, strong) ToolUI *toolUI;

@property (nonatomic, strong) PFHLSToolView *hlsToolView;

@property (nonatomic, strong) UISegmentedControl *mSegm;

@property (nonatomic, assign) CGRect lvRect;
@property (nonatomic, strong) UIGestureRecognizer *panGesture;
@property (nonatomic, strong) UIGestureRecognizer *pinchGesture;


@end

@implementation PFImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(0, 0, 44, 44); // 标准导航栏按钮尺寸
    [albumBtn setImage:[UIImage imageNamed:@"tab_album_nor"] forState:UIControlStateNormal];

    // 3. 添加点击事件（更安全的内存管理写法）
    [albumBtn addTarget:self
                 action:@selector(albumBtnClick:)
       forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:albumBtn];

    // 5. 设置导航栏按钮（考虑iOS 11+的布局兼容）
    if (@available(iOS 11.0, *)) {
        albumBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        barButtonItem.imageInsets = UIEdgeInsetsMake(0, -15, 0, 0); // 调整位置
    }

    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    
    _imageView = [[UIImageView alloc] init];
        _image = [UIImage imageNamed:@"IMG_2406"];
//    _image = [UIImage imageNamed:@"2631742911906_.pic_hd.jpg"];
//    _image = [UIImage imageNamed:@"timg"];
    _imageView.image = _image;
    
    float x = 0;
    float y = 0;
    
    _imageView.frame = CGRectMake(x, 80, self.view.frame.size.width, 270);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:_imageView atIndex:0];
    
    
    // 初始化调节项
    NSArray<AdjustmentItem *> *adjustmentItems = @[
        [[AdjustmentItem alloc] initWithName:@"亮度" value:0.0 minValue:-1.0 maxValue:1.0], // brightness
        [[AdjustmentItem alloc] initWithName:@"对比度" value:1.0 minValue:0.0 maxValue:4.0], // contrast
        [[AdjustmentItem alloc] initWithName:@"曝光" value:0.0 minValue:-10.0 maxValue:10.0], // exposure
        [[AdjustmentItem alloc] initWithName:@"高光" value:0.0 minValue:-1.0 maxValue:1.0], // highlights
        [[AdjustmentItem alloc] initWithName:@"阴影" value:0.0 minValue:-1.0 maxValue:1.0], // shadows
        [[AdjustmentItem alloc] initWithName:@"饱和度" value:1.0 minValue:0.0 maxValue:2.0], // saturation
        [[AdjustmentItem alloc] initWithName:@"色温" value:5000.0 minValue:0.0 maxValue:10000.0], // temperature
        [[AdjustmentItem alloc] initWithName:@"色相" value:0.0 minValue:0.0 maxValue:360.0] // hue
    ];
    
    // 初始化调节项
    NSArray<AdjustmentItem *> *adjustmentItems2 = @[
        [[AdjustmentItem alloc] initWithName:@"色相" value:0.0 minValue:-0.45 maxValue:0.45], // brightness
        [[AdjustmentItem alloc] initWithName:@"饱和度" value:1.0 minValue:0.3 maxValue:1.8], // contrast
        [[AdjustmentItem alloc] initWithName:@"明亮度" value:0.0 minValue:-3.0 maxValue:3.0], // exposure
        [[AdjustmentItem alloc] initWithName:@"相似度" value:0.8 minValue:0.0 maxValue:1.0], // exposure
    ];
    
    // 创建 ToolUI
    self.toolUI = [[ToolUI alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 400, self.view.bounds.size.width, 400) adjustmentItems:adjustmentItems];
    
    [self.view addSubview:self.toolUI];
    
    // 设置滑动事件回调
    __weak typeof(self) weakSelf = self;
    self.toolUI.sliderValueChangedBlock = ^(AdjustmentItem *item) {
        [weakSelf handleSliderValueChanged:item];
    };
    
    
    _hlsToolView = [[PFHLSToolView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 400, self.view.bounds.size.width, 400) Colors:nil adjustmentItems:adjustmentItems2];
    _hlsToolView.hidden = YES;
    _hlsToolView.mDelegate = self;
    [self.view addSubview:_hlsToolView];
    
    
    _mSegm = [[UISegmentedControl alloc] initWithItems:@[@"美颜",@"调色", @"全局 HLS 调节"]];
    _mSegm.selectedSegmentIndex = 1; // 默认选中第一个选项
    [_mSegm addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_mSegm];
    
    
    CGFloat segmentWidth = 200;
    CGFloat segmentHeight = 40;
    CGFloat rightMargin = 20;
    CGFloat bottomMargin = 30;
    
    _mSegm.frame = CGRectMake(
                              CGRectGetWidth(self.view.frame) - segmentWidth - rightMargin,
                              CGRectGetHeight(self.view.frame) - segmentHeight - bottomMargin,
                              segmentWidth,
                              segmentHeight
                              );
    
    
    PFImageColorGrading ColorGrading = {
        .isUse = false,
        .brightness = 0.0f,
        .contrast = 1.0f,
        .exposure = 0.0f,
        .highlights = 0.0f,
        .shadows = 0.0f,
        .saturation = 1.0f,
        .temperature = 5000.0f,
        .tint = 0.0f,
        .hue = 0.0f
    };
    mColorGrading = ColorGrading;
    
    PFHLSFilterParams HLSFilterParams = {
        .brightness = 0.0f,
        .saturation = 1.0f,
        .hue = 0.0f,
        .similarity = 0.8
    };
    HLSFilterParams.key_color[0] = 0.75;
    HLSFilterParams.key_color[1] = 0.24;
    HLSFilterParams.key_color[2] = 0.31;
    
    mHLSFilterParams = HLSFilterParams;
    
    handle = [self.mPixelFree pixelFreeAddHLSFilter:&mHLSFilterParams];
}

-(void)segmentChanged:(UISegmentedControl *)seg {
    if (seg.selectedSegmentIndex == 0) {
        self.beautyEditView.hidden = NO;
        _toolUI.hidden = YES;
        _hlsToolView.hidden = YES;
    } else if (seg.selectedSegmentIndex == 1) {
        self.beautyEditView.hidden = YES;
        _toolUI.hidden = NO;
        _hlsToolView.hidden = YES;
    } else if (seg.selectedSegmentIndex == 2)  {
        self.beautyEditView.hidden = YES;
        _toolUI.hidden = YES;
        _hlsToolView.hidden = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFun) userInfo:@"参数" repeats:YES];
        
        _mRunLoop = [NSRunLoop currentRunLoop];
        [_mRunLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
        //        //如果是子线程还需要启动runloop
        [_mRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
    });
    
}

- (void)timerFun{
    if (_image) {
        if (self.clickCompare) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_imageView.image = self.image;
            });
            return;
        }
        
        UIImage *newImage = [self.mPixelFree processWithImage:self.image rotationMode:PFRotationMode0];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_imageView.image = newImage;
            [self->_imageView.layer setNeedsDisplay];
            [self->_imageView.layer displayIfNeeded];
        });
        
    }
    
}

- (void)albumBtnClick:(UIButton *)sender {
    // 检查相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        // 请求权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self presentImagePicker];
            } else {
                [self showPermissionAlert];
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        // 已授权，打开相册
        [self presentImagePicker];
    } else {
        // 未授权，提示用户
        [self showPermissionAlert];
    }
}

- (void)presentImagePicker{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:nil];
    });
    
}

- (void)showPermissionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"权限请求"
                                                                   message:@"请在设置中允许访问相册。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:settingsAction];
    [alert addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    CFRunLoopStop([_mRunLoop getCFRunLoop]);
    NSLog(@"viewWillDisappear ---");
}



-(void)dealloc{
    NSLog(@"dealloc ---");
}


#pragma mark - 滑动事件回调处理

- (void)handleSliderValueChanged:(AdjustmentItem *)item {
    // 根据调节项更新滤镜参数
    
    mColorGrading.isUse = true;
    
    if ([item.name isEqualToString:@"亮度"]) {
        mColorGrading.brightness = item.value;
    } else if ([item.name isEqualToString:@"对比度"]) {
        mColorGrading.contrast = item.value;
    } else if ([item.name isEqualToString:@"曝光"]) {
        mColorGrading.exposure = item.value;
    } else if ([item.name isEqualToString:@"高光"]) {
        mColorGrading.highlights = item.value;
    } else if ([item.name isEqualToString:@"阴影"]) {
        mColorGrading.shadows = item.value;
    } else if ([item.name isEqualToString:@"饱和度"]) {
        mColorGrading.saturation = item.value;
    } else if ([item.name isEqualToString:@"色温"]) {
        mColorGrading.temperature = item.value;
    } else if ([item.name isEqualToString:@"色相"]) {
        mColorGrading.hue = item.value;
    }
    
    [self.mPixelFree pixelFreeSetColorGrading:&mColorGrading];
    
}


-(void)sliderValueChanged:(AdjustmentItem *)item{
        if ([item.name isEqualToString:@"明亮度"]) {
            mHLSFilterParams.brightness = item.value;
        } else if ([item.name isEqualToString:@"色相"]) {
            mHLSFilterParams.hue = item.value;
        } else if ([item.name isEqualToString:@"饱和度"]) {
            mHLSFilterParams.saturation = item.value;
        } else if ([item.name isEqualToString:@"相似度"]) {
            mHLSFilterParams.similarity = item.value;
        }
    [self.mPixelFree pixelFreeChangeHLSFilter:handle params:&mHLSFilterParams];
}
- (void)colorDidSelectedR:(float)r G:(float)g B:(float)b A:(float)a {
    //    [_mHLSFilter setColorDidSelectedR:r G:g B:b A:a];
    //    [self.sourcePicture processImage];
    mHLSFilterParams.key_color[0] = r;
    mHLSFilterParams.key_color[1] = g;
    mHLSFilterParams.key_color[2] = b;
    [self.mPixelFree pixelFreeChangeHLSFilter:handle params:&mHLSFilterParams];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 关闭相册
    [picker dismissViewControllerAnimated:NO completion:^{
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // 图片转正
        if (image.imageOrientation != UIImageOrientationUp && image.imageOrientation != UIImageOrientationUpMirrored) {
            
            UIGraphicsBeginImageContext(CGSizeMake(image.size.width * 0.5, image.size.height * 0.5));
            
            [image drawInRect:CGRectMake(0, 0, image.size.width * 0.5, image.size.height * 0.5)];
            
            image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
        }
        
        self.image = image;
        
    
    }];
    
}



@end
