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
//#import "SMBeautyShapFilter.h"
//#import "SMKeyPointFilter.h"
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

@property(nonatomic, strong) SMBeautyFilterModel *beautyModel;
@property(nonatomic, strong) SMStickerModel *filterModel;

@property(nonatomic, strong) SMMakeUpFilterModel *makeupModel;

@property (nonatomic, strong) NSArray<SMStickerModel *> *stickerFilterModels;

@property(nonatomic, strong) GPUImagePicture *test;

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
//    [_mCamera addTarget:_effectFilter];
//    [_effectFilter addTarget:_preView];
//    [_mCamera startCameraCapture];
    
    
    _test = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"021450138411019.jpg"]];
    [_test addTarget:_effectFilter];
    [_effectFilter addTarget:_preView];
    
    
    
    
    
    [self setupSubView];
    _beautyModel = [[SMBeautyFilterModel alloc] init];
    // default
    _beautyModel.ruddyStrength = 0.6;
    _beautyModel.whitenStrength = 0.6;
    _beautyModel.blurStrength = 0.8;
    _beautyModel.sharpenStrength = 0.1;
    
    NSString *path = [kStyleFilterPath stringByAppendingFormat:@"/pink/filter_lutup_pink.png"];
    _beautyModel.lutImage = [UIImage imageWithContentsOfFile:path];
    
    _effectFilter.beautyModel = _beautyModel;

    [_test processImage];

}


-(void)setupSubView{
    [self.view addSubview:self.beautyEditView];
}



#pragma mark - FaceUnity

-(FUAPIDemoBar *)beautyEditView {
    if (!_beautyEditView) {
        _beautyEditView = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 231, self.view.frame.size.width, 231)];
        
        _beautyEditView.mDelegate = self;
    }
    return _beautyEditView ;
}

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

    if (param.type == FUDataTypeFilter) {
        _beautyModel.lutImage = [UIImage imageNamed:param.mParam];
        _beautyModel.lutImageStrength = param.mValue;
    }

    if (param.type == FUDataTypeStrick) {
      SMStickerModel *modle = [self getStickerModelWithName:param.mTitle];
        _effectFilter.stickerModel = modle;
    }

    if(param.type == FUDataTypeMakeup){
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
