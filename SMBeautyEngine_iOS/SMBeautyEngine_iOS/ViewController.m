//
//  ViewController.m
//  faceLandmark
//
//  Created by mumu on 2021/9/6.
//

#import "ViewController.h"

#import "PFAPIDemoBar.h"
#import "PFDateHandle.h"

@interface ViewController ()<PFAPIDemoBarDelegate>

@property(nonatomic, strong) PFAPIDemoBar *beautyEditView;

@property (nonatomic, strong) NSUserDefaults *def;
@end

@implementation ViewController


-(PFAPIDemoBar *)beautyEditView {
    if (!_beautyEditView) {
        _beautyEditView = [[PFAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 280, self.view.frame.size.width, 280)];
        
        _beautyEditView.mDelegate = self;
    }
    return _beautyEditView ;
}

-(void)comparisonButtonDidClick:(BOOL)state{
    self.clickCompare = state;
}


-(void)filterValueChange:(PFBeautyParam *)param{

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();


    float value = param.mValue;
    if(param.type == FUDataTypeBeautify){
        if ([param.mParam isEqualToString:@"face_EyeStrength"]) {

            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_EyeStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"face_thinning"]) {
              float aa = param.mValue;
              [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_thinning value:&value];
          }
          if ([param.mParam isEqualToString:@"face_narrow"]) {
              [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_narrow value:&value];
          }
          if ([param.mParam isEqualToString:@"face_chin"]) {
              [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_chin value:&value];
          }
        if ([param.mParam isEqualToString:@"face_V"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_V value:&value];

        }
        if ([param.mParam isEqualToString:@"face_small"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_small value:&value];
        }
        if ([param.mParam isEqualToString:@"face_nose"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_nose value:&value];
        }

        if ([param.mParam isEqualToString:@"face_forehead"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_forehead value:&value];
        }
        if ([param.mParam isEqualToString:@"face_mouth"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_mouth value:&value];
        }
        if ([param.mParam isEqualToString:@"face_philtrum"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_philtrum value:&value];
        }

        if ([param.mParam isEqualToString:@"face_long_nose"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_long_nose value:&value];
        }
        if ([param.mParam isEqualToString:@"face_eye_space"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_eye_space value:&value];
        }
        
        if ([param.mParam isEqualToString:@"face_smile"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_smile value:&value];
        }
        if ([param.mParam isEqualToString:@"face_eye_rotate"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_eye_rotate value:&value];
        }
        if ([param.mParam isEqualToString:@"face_canthus"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_canthus value:&value];
        }


          if ([param.mParam isEqualToString:@"runddy"]) {
              [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFaceRuddyStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"writen"]) {
              [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFaceWhitenStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"blur"]) {
              [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFaceBlurStrength value:&value];
          }
          if ([param.mParam isEqualToString:@"sharpen"]) {
              [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFaceSharpenStrength value:&value];
          }
        if ([param.mParam isEqualToString:@"eye_b"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFaceEyeBrighten value:&value];
        }
        
        if ([param.mParam isEqualToString:@"newWhitenStrength"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFaceM_newWhitenStrength value:&value];
        }
        if ([param.mParam isEqualToString:@"qualityStrength"]) {
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFaceH_qualityStrength value:&value];
        }
    }

    if (param.type == FUDataTypeFilter) {

       const char *aaa = [param.mParam UTF8String];
        [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterName value:(void *)aaa];
        [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterStrength value:&value];
    }

    if (param.type == FUDataTypeStickers) {
        if([param.mParam isEqualToString:@"origin"]){
            [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterSticker2DFilter value:NULL];
        } else{
//            NSString *path =  [[NSBundle mainBundle] pathForResource:@"Stickers" ofType:nil];
//            NSString *currentFolder = [path stringByAppendingPathComponent:param.mParam];
//            const char *aaa = [currentFolder UTF8String];
//            [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterSticker2DFilter value:(void *)aaa];
            NSString *name = [NSString stringWithFormat:@"%@.bundle",param.mParam];
            NSString *paths = [[NSBundle mainBundle] pathForResource:name ofType:nil];
            [self.mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterSticker2DFilter value:(void *)[paths UTF8String]];
        }
    }
    
    if (param.type == FUDataTypeOneKey) {
        if ([param.mTitle isEqualToString:@"origin"]) {
            int value = PFBeautyTypeOneKeyNormal;
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"自然"]) {
            int value = PFBeautyTypeOneKeyNatural;
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeOneKey value:&value];
         
        }
        if ([param.mTitle isEqualToString:@"可爱"]) {
            int value = PFBeautyTypeOneKeyCute;
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"女神"]) {
            int value = PFBeautyTypeOneKeyGoddess;
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeOneKey value:&value];
            
        }
        if ([param.mTitle isEqualToString:@"白净"]) {
            int value = PFBeautyTypeOneKeyFair;
            [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeOneKey value:&value];
           
        }

    }

}

-(void)bottomDidChange:(int)index{
    if (index != 0 && _beautyEditView.oneKeyType != PFBeautyTypeOneKeyNormal) {
        int value = PFBeautyTypeOneKeyNormal;
        [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeOneKey value:&value];
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
    NSData *shapeParamsData = [NSKeyedArchiver archivedDataWithRootObject:_beautyEditView.shapeParams];
    NSData *skinParamsData = [NSKeyedArchiver archivedDataWithRootObject:_beautyEditView.skinParams];
    NSData *stickerseData = [NSKeyedArchiver archivedDataWithRootObject:_beautyEditView.stickersParams];
    
    NSUserDefaults*userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:_beautyEditView.oneKeyType forKey:@"oneKeyType"];
    [userDefaults setInteger:_beautyEditView.filterIndex forKey:@"filtersUseIndex"];
    [userDefaults setInteger:_beautyEditView.stickersIndex forKey:@"stickerUseIndex"];
    [userDefaults synchronize];
    
    // 写本地
    [self writeData:shapeParamsData fileName:@"shapeParamsData"];
    [self writeData:skinParamsData fileName:@"skinParamsData"];
    [self writeData:stickerseData fileName:@"stickerseData"];
    
}


-(void)initPixelFree{
    NSString *face_FiltePath = [[NSBundle mainBundle] pathForResource:@"filter_model.bundle" ofType:nil];
//    NSString *face_DetectPath = [[NSBundle mainBundle] pathForResource:@"face_detect.bundle" ofType:nil];
    NSString *authFile = [[NSBundle mainBundle] pathForResource:@"pixelfreeAuth.lic" ofType:nil];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    self.mPixelFree = [[SMPixelFree alloc] initWithProcessContext:nil srcFilterPath:face_FiltePath authFile:authFile];
    
//    NSLog(@"mPixelFree retain  count = %ld\n",CFGetRetainCount((__bridge  CFTypeRef)(self.mPixelFree)));

    CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);

    [self.view addSubview:self.beautyEditView];
}

-(void)setDefaultParam{
    NSArray<PFBeautyParam *>* defaultData = [PFDateHandle setupShapData];
    NSArray<PFBeautyParam *>* defaultSkinData = [PFDateHandle setupSkinData];
    NSArray<PFBeautyParam *>* defaultfiltersData = [PFDateHandle setupFilterData];
    NSArray<PFBeautyParam *>* defaultfaceData = [PFDateHandle setupFaceType];
    NSArray<PFBeautyParam *>* defaultStickerseData = [PFDateHandle setupStickers];
    
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
    
    data = [self readDatafileName:@"stickerseData"];
    if (data) {
        defaultStickerseData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    // 更新 UI
    self.beautyEditView.shapeParams = defaultData;
    self.beautyEditView.skinParams = defaultSkinData;
    self.beautyEditView.filtersParams = defaultfiltersData;
    self.beautyEditView.faceTypeParams = defaultfaceData;
    self.beautyEditView.stickersParams = defaultStickerseData;
    
    NSUserDefaults*userDefaults = [NSUserDefaults standardUserDefaults];
    int oneKeyType = (int)[userDefaults integerForKey:@"oneKeyType"];
    int filtersIndex = (int)[userDefaults integerForKey:@"filtersUseIndex"];
    int stickerIndex = (int)[userDefaults integerForKey:@"stickerUseIndex"];

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


-(void)dealloc{
    NSLog(@"aaaa");
}


@end
