//
//  ViewController.m
//  SMBeautyEngine
//
//  Created by 孙慕 on 2020/6/15.
//  Copyright © 2020 孙慕. All rights reserved.
//

#import "ViewController.h"
#import "GPUImageView.h"
#import "GPUImageVideoCamera.h"
#import "SMEffectFilter.h"
#import "GPUImageContext.h"
#import  <pixelFree/SMFilterModel.h>
#import "GPUImagePicture.h"
#import "FUAPIDemoBar.h"

// 色彩滤镜路径
#define kStyleFilterPath            [[NSBundle mainBundle] pathForResource:@"Filters" ofType:nil]
// 特效滤镜路径
#define kStickerFilterPath          [[NSBundle mainBundle] pathForResource:@"Stickers" ofType:nil]

@interface ViewController ()<FUAPIDemoBarDelegate>

@property(nonatomic,strong)GPUImageVideoCamera *mCamera;

@property(nonatomic, strong) GPUImageView *preView;

@property(nonatomic, strong) SMEffectFilter *effectFilter;

@property(nonatomic, strong) FUAPIDemoBar *beautyEditView;

//美颜参数
@property(nonatomic, strong) SMBeautyFilterModel *beautyModel;
//滤镜参数
@property(nonatomic, strong) SMStickerModel *filterModel;
//美妆参数
@property(nonatomic, strong) SMMakeUpFilterModel *makeupModel;

@property (nonatomic, strong) NSArray<SMStickerModel *> *stickerFilterModels;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _stickerFilterModels = [self buildFilterModelsWithPath:kStickerFilterPath];
    _makeupModel = [[SMMakeUpFilterModel alloc] init];
    
    _mCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    _mCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _mCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    _preView= [[GPUImageView alloc] initWithFrame:self.view.bounds];
    _preView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view addSubview:_preView];
    
    _effectFilter = [[SMEffectFilter alloc] init];
    /* 处理链路 */
    [_mCamera addTarget:_effectFilter];
    [_effectFilter addTarget:_preView];
    [_mCamera startCameraCapture];
    
    
    [self setupSubView];
    
    // default
    _beautyModel = [[SMBeautyFilterModel alloc] init];
    _beautyModel.ruddyStrength = 0.6;
    _beautyModel.whitenStrength = 0.6;
    _beautyModel.blurStrength = 0.8;
    _beautyModel.sharpenStrength = 0.1;
    
    NSString *path = [kStyleFilterPath stringByAppendingFormat:@"/pink/filter_lutup_pink.png"];
    _beautyModel.lutImage = [UIImage imageWithContentsOfFile:path];
    _beautyModel.lutImageStrength = 0;
    
    _effectFilter.beautyModel = _beautyModel;
    
}


-(void)setupSubView{
    [self.view addSubview:self.beautyEditView];
}





-(FUAPIDemoBar *)beautyEditView {
    if (!_beautyEditView) {
        _beautyEditView = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 231, self.view.frame.size.width, 231)];
        
        _beautyEditView.mDelegate = self;
    }
    return _beautyEditView ;
}

#pragma mark - editView delegate

-(void)filterValueChange:(FUBeautyParam *)param{
    
    if(param.type == FUDataTypeBeautify){
        if ([param.mParam isEqualToString:@"enlargeEyeStrength"]) {
            _beautyModel.enlargeEyeStrength = param.mValue;
            _beautyModel.lutImageStrength = param.mValue;
        }
        if ([param.mParam isEqualToString:@"faceLiftStrength"]) {
            _beautyModel.faceLiftStrength = param.mValue;
        }
        if ([param.mParam isEqualToString:@"faceShaveStrength"]) {
            _beautyModel.faceShaveStrength = param.mValue;
        }
        if ([param.mParam isEqualToString:@"chinChangeStrength"]) {
            _beautyModel.chinChangeStrength = param.mValue;
        }
        if ([param.mParam isEqualToString:@"runddy"]) {
            _beautyModel.ruddyStrength = param.mValue;
        }
        if ([param.mParam isEqualToString:@"writen"]) {
            _beautyModel.whitenStrength = param.mValue;
        }
        if ([param.mParam isEqualToString:@"blur"]) {
            _beautyModel.blurStrength = param.mValue;
        }
        if ([param.mParam isEqualToString:@"sharpen"]) {
            _beautyModel.sharpenStrength = param.mValue;
        }
    }
    
    if (param.type == FUDataTypeFilter) {//滤镜
        _beautyModel.lutImage = [UIImage imageNamed:param.mParam];
        _beautyModel.lutImageStrength = param.mValue;
    }
    
    if (param.type == FUDataTypeStrick) {//道具贴纸
        SMStickerModel *modle = [self getStickerModelWithName:param.mTitle];
        _effectFilter.stickerModel = modle;
    }
    
    if(param.type == FUDataTypeMakeup){//
        _makeupModel.lipStrength = param.mValue;
        _effectFilter.makeModel = _makeupModel;
    }
    
    _effectFilter.beautyModel = _beautyModel;
    
}

-(void)switchRenderState:(BOOL)state{
    [_effectFilter renderState:state];
}



- (NSArray<SMStickerModel *> *)buildFilterModelsWithPath:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    
    NSMutableArray<SMStickerModel *> *filters = [NSMutableArray array];
    
    NSArray<NSString *> *filterFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString *filter in filterFolder) {
        NSString *currentFolder = [path stringByAppendingPathComponent:filter];
        
        SMStickerModel *model = [SMStickerModel buildStickerFilterModelsWithPath:currentFolder];
        // add
        if (model) {
            [filters addObject:model];
        }
    }
    return filters;
}


-(SMStickerModel *)getStickerModelWithName:(NSString *)name{
    for (SMStickerModel *modle in _stickerFilterModels) {
        if ([modle.name isEqualToString:name]) {
            return modle;
        }
    }
    return nil;
}




@end
