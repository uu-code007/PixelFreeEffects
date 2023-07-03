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


@end

@implementation ViewController


-(PFAPIDemoBar *)beautyEditView {
    if (!_beautyEditView) {
        _beautyEditView = [[PFAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 231, self.view.frame.size.width, 231)];
        
        _beautyEditView.mDelegate = self;
    }
    return _beautyEditView ;
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

    if (param.type == FUDataTypeStrick) {

    }

    if(param.type == FUDataTypeMakeup){

    }


//    CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
//
//    NSLog(@"setparms 方法耗时: %f ms", endTime * 1000.0);

}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initPixelFree];
    
    [self setDefaultParam];

    
}

-(void)initPixelFree{
    NSString *face_FiltePath = [[NSBundle mainBundle] pathForResource:@"face_fiter.bundle" ofType:nil];
    NSString *face_DetectPath = [[NSBundle mainBundle] pathForResource:@"face_detect.bundle" ofType:nil];
    NSString *authFile = [[NSBundle mainBundle] pathForResource:@"pixelfreeAuth.lic" ofType:nil];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    self.mPixelFree = [[SMPixelFree alloc] initWithProcessContext:nil srcFilterPath:face_FiltePath srcDetectPath:face_DetectPath authFile:authFile];
    
    NSLog(@"mPixelFree retain  count = %ld\n",CFGetRetainCount((__bridge  CFTypeRef)(self.mPixelFree)));

    CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);

    [self.view addSubview:self.beautyEditView];
}

-(void)setDefaultParam{
    NSArray<PFBeautyParam *>* defaultData = [PFDateHandle setupShapData];
    for (PFBeautyParam *param in defaultData) {
        [self filterValueChange:param];
    }
    
    NSArray<PFBeautyParam *>* defaultSkinData = [PFDateHandle setupSkinData];
    for (PFBeautyParam *param in defaultSkinData) {
        [self filterValueChange:param];
    }
}


-(void)dealloc{
    NSLog(@"aaaa");
}


@end
