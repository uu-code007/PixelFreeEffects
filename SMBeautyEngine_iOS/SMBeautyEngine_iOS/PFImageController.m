//
//  PFImageController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/9/29.
//

#import "PFImageController.h"
#import <Vision/Vision.h>
#import "UIColor+PFBeautyEditView.h"

#import "ToolUI.h"
#import "AdjustmentItem.h"
#import "AdjustmentItem.h"
#import "PFHLSToolView.h"
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
#import "PFFilterView.h"
#import "PFBeautyParam.h"
#import "PFOpenGLView.h"
#import <CoreVideo/CoreVideo.h>

@interface PFImageController ()<PFMuViewDelegate,UIImagePickerControllerDelegate,PFFilterViewDelegate> {
    PFImageColorGrading mColorGrading ;
    PFHLSFilterParams  mHLSFilterParams;
    int handle;
}

@property(nonatomic,strong)UIImage *image;

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)PFOpenGLView *openGlView;
@property(nonatomic,assign)CVPixelBufferRef sourcePixelBuffer;
@property(nonatomic,assign)CVPixelBufferRef renderPixelBuffer;

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

static CVPixelBufferRef PFCreatePixelBufferFromUIImage(UIImage *image) {
    if (!image || !image.CGImage) return NULL;
    const size_t width = CGImageGetWidth(image.CGImage);
    const size_t height = CGImageGetHeight(image.CGImage);
    NSDictionary *attrs = @{
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES
    };
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn ret = CVPixelBufferCreate(kCFAllocatorDefault,
                                       width,
                                       height,
                                       kCVPixelFormatType_32BGRA,
                                       (__bridge CFDictionaryRef)attrs,
                                       &pixelBuffer);
    if (ret != kCVReturnSuccess || pixelBuffer == NULL) return NULL;

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(baseAddress,
                                             width,
                                             height,
                                             8,
                                             bytesPerRow,
                                             colorSpace,
                                             kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!ctx) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVBufferRelease(pixelBuffer);
        return NULL;
    }
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image.CGImage);
    CGContextRelease(ctx);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}

static void PFCopyPixelBuffer(CVPixelBufferRef src, CVPixelBufferRef dst) {
    if (!src || !dst) return;
    CVPixelBufferLockBaseAddress(src, kCVPixelBufferLock_ReadOnly);
    CVPixelBufferLockBaseAddress(dst, 0);
    const size_t srcHeight = CVPixelBufferGetHeight(src);
    const size_t srcBytesPerRow = CVPixelBufferGetBytesPerRow(src);
    const size_t dstBytesPerRow = CVPixelBufferGetBytesPerRow(dst);
    const size_t copyBytesPerRow = MIN(srcBytesPerRow, dstBytesPerRow);
    uint8_t *srcBase = (uint8_t *)CVPixelBufferGetBaseAddress(src);
    uint8_t *dstBase = (uint8_t *)CVPixelBufferGetBaseAddress(dst);
    for (size_t y = 0; y < srcHeight; ++y) {
        memcpy(dstBase + y * dstBytesPerRow, srcBase + y * srcBytesPerRow, copyBytesPerRow);
    }
    CVPixelBufferUnlockBaseAddress(dst, 0);
    CVPixelBufferUnlockBaseAddress(src, kCVPixelBufferLock_ReadOnly);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    // 设置返回按钮颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexColorString:@"BAACFF"];
    
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
    
    
//        _image = [UIImage imageNamed:@"IMG_2406"];
//    _image = [UIImage imageNamed:@"2631742911906_.pic_hd.jpg"];
    _image = [UIImage imageNamed:@"image_src"];
//    _image = [UIImage imageNamed:@"diamge"];
    
    float x = 0;
    float y = 0;
    
    // 计算图片显示区域（考虑导航栏和安全区域）
    // 注意：在 viewDidLoad 时导航栏可能还没有布局完成，所以使用固定值
    // 实际布局会在 viewDidLayoutSubviews 中更新
    CGFloat topMargin = 80;
    CGFloat toolUIHeight = 400;
    CGFloat segmentHeight = 40;
    CGFloat spacing = 10;
    CGFloat imageHeight = self.view.bounds.size.height - topMargin - toolUIHeight - segmentHeight - spacing * 2;
    if (imageHeight < 200) {
        imageHeight = 200; // 最小高度
    }
    
    _openGlView = [[PFOpenGLView alloc] initWithFrame:CGRectMake(x, topMargin, self.view.frame.size.width, imageHeight)
                                               context:self.mPixelFree.glContext];
    _openGlView.contentMode = PFOpenGLViewContentModeScaleAspectFit;
    [self.view insertSubview:_openGlView atIndex:0];
    
    
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
    self.toolUI.hidden = YES;
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
    
    // 创建 SegmentedControl，放在图片下方、toolUI 上方
    _mSegm = [[UISegmentedControl alloc] initWithItems:@[@"美颜",@"调色", @"全局 HLS 调节"]];
    _mSegm.selectedSegmentIndex = 0; // 默认选中"调色"
    [_mSegm addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    // 设置样式
    if (@available(iOS 13.0, *)) {
        _mSegm.selectedSegmentTintColor = [UIColor colorWithHexColorString:@"BAACFF"];
    } else {
        _mSegm.tintColor = [UIColor colorWithHexColorString:@"BAACFF"];
    }
    
    // 设置文字颜色
    NSDictionary *normalAttributes = @{
        NSForegroundColorAttributeName: [UIColor grayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14]
    };
    NSDictionary *selectedAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:14]
    };
    [_mSegm setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [_mSegm setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    
    [self.view addSubview:_mSegm];
    
    // 布局：放在图片下方，toolUI 上方
    // 使用 frame 布局，在 viewDidLayoutSubviews 中更新位置
    // 先设置一个初始 frame，实际位置会在 viewDidLayoutSubviews 中更新
    CGFloat segmentMargin = 20;
    _mSegm.frame = CGRectMake(segmentMargin, 0, self.view.bounds.size.width - segmentMargin * 2, segmentHeight);
    
    // 创建美妆列表视图
    
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
    
    // 设置图片检测模式
//    [self.mPixelFree setDetectMode:0]; // 0 = PF_FACE_DETECT_MODE_IMAGE
//    [self.mPixelFree pixelFreeSetSkinMaskEnabled:true];
    self.sourcePixelBuffer = PFCreatePixelBufferFromUIImage(_image);
    self.renderPixelBuffer = PFCreatePixelBufferFromUIImage(_image);
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
    } else if (seg.selectedSegmentIndex == 3) {
        self.beautyEditView.hidden = YES;
        _toolUI.hidden = YES;
        _hlsToolView.hidden = YES;
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
    if (_image && self.sourcePixelBuffer && self.renderPixelBuffer) {
        if (self.clickCompare) {
            [self.openGlView displayPixelBuffer:self.sourcePixelBuffer];
            return;
        }
        // 每帧从原图拷贝，避免 processWithBuffer 对同一 buffer 累积变形。
        PFCopyPixelBuffer(self.sourcePixelBuffer, self.renderPixelBuffer);
        [self.mPixelFree processWithBuffer:self.renderPixelBuffer rotationMode:PFRotationMode0];
        [self.openGlView displayPixelBuffer:self.renderPixelBuffer];
        
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


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 更新布局以适应屏幕尺寸变化
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat topMargin = navBarHeight > 0 ? navBarHeight : 80;
    CGFloat toolUIHeight = 400;
    CGFloat segmentHeight = 40;
    CGFloat spacing = 10;
    
    // 计算图片高度
    CGFloat imageHeight = self.view.bounds.size.height - topMargin - toolUIHeight - segmentHeight - spacing * 2;
    if (imageHeight < 200) {
        imageHeight = 200; // 最小高度
    }
    
    // 更新 OpenGL 预览 frame
    _openGlView.frame = CGRectMake(0, topMargin, self.view.frame.size.width, imageHeight);
    
    // 更新 SegmentedControl frame：放在图片下方
    CGFloat segmentMargin = 20;
    CGFloat segmentY = CGRectGetMaxY(_openGlView.frame) + spacing;
    _mSegm.frame = CGRectMake(segmentMargin, segmentY, self.view.bounds.size.width - segmentMargin * 2, segmentHeight);
    
    // 更新 toolUI 和 hlsToolView frame
    self.toolUI.frame = CGRectMake(0, self.view.bounds.size.height - toolUIHeight, self.view.bounds.size.width, toolUIHeight);
    _hlsToolView.frame = CGRectMake(0, self.view.bounds.size.height - toolUIHeight, self.view.bounds.size.width, toolUIHeight);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    CFRunLoopStop([_mRunLoop getCFRunLoop]);
    if (_openGlView) {
        [_openGlView removeFromSuperview];
    }
    NSLog(@"viewWillDisappear ---");
}



-(void)dealloc{
    if (_sourcePixelBuffer) {
        CVBufferRelease(_sourcePixelBuffer);
        _sourcePixelBuffer = NULL;
    }
    if (_renderPixelBuffer) {
        CVBufferRelease(_renderPixelBuffer);
        _renderPixelBuffer = NULL;
    }
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
        if (self.sourcePixelBuffer) {
            CVBufferRelease(self.sourcePixelBuffer);
            self.sourcePixelBuffer = NULL;
        }
        self.sourcePixelBuffer = PFCreatePixelBufferFromUIImage(image);
        if (self.renderPixelBuffer) {
            CVBufferRelease(self.renderPixelBuffer);
            self.renderPixelBuffer = NULL;
        }
        self.renderPixelBuffer = PFCreatePixelBufferFromUIImage(image);
        
        [self.mPixelFree pixelFreeSetSkinMaskEnabled:true];
    }];
    
}


#pragma mark - PFFilterViewDelegate

- (void)filterViewDidSelectedFilter:(PFBeautyParam *)param {
    
    if ([param.mParam isEqualToString:@""] || param.mParam.length == 0) {
        // 关闭美妆
        NSLog(@"[Makeup] 关闭美妆");
        [self.mPixelFree clearMakeup];
    } else {
        // 设置美妆
        NSString *path = [[NSBundle mainBundle] pathForResource:@"makeup" ofType:nil];
        if (!path) {
            NSLog(@"[Makeup] 错误: 找不到 makeup 资源文件夹");
            return;
        }
        
        NSString *currentFolder = [path stringByAppendingPathComponent:param.mParam];
        NSLog(@"[Makeup] 美妆路径: %@", currentFolder);
        
        // 检查文件夹是否存在
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory = NO;
        BOOL exists = [fileManager fileExistsAtPath:currentFolder isDirectory:&isDirectory];
        
        if (exists && isDirectory) {
            NSLog(@"[Makeup] 文件夹存在，应用美妆");
//            int ret = [self.mPixelFree pixelFreeSetMakeupWithJsonPath:currentFolder];
            
            NSString *name = [NSString stringWithFormat:@"%@.bundle",param.mParam];
            NSString *currentBundle = [path stringByAppendingPathComponent:name];
            NSData *date = [NSData dataWithContentsOfFile:currentBundle];
            
            [self.mPixelFree createBeautyItemFormBundleKey:PFSrcTypeMakeup data:(void *)date.bytes size:date.length];
//            NSLog(@"[Makeup] 应用美妆返回值: %d", ret);
        } else {
            NSLog(@"[Makeup] 错误: 美妆文件夹不存在: %@", currentFolder);
        }
    }
}

@end
