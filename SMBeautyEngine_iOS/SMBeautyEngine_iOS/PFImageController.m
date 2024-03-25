//
//  PFImageController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/9/29.
//

#import "PFImageController.h"
#import <Vision/Vision.h>
@interface PFImageController ()

@property(nonatomic,strong)UIImage *image;

@property(nonatomic,strong)UIImageView *imageView;

/** NSTimer */
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSRunLoop *mRunLoop;


@end

@implementation PFImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _imageView = [[UIImageView alloc] init];
//    _image = [UIImage imageNamed:@"IMG_2403"];
    _image = [UIImage imageNamed:@"IMG_2406"];
    _imageView.image = _image;
    
    float x = ([UIScreen mainScreen].bounds.size.width - 250)/2;
    float y = ([UIScreen mainScreen].bounds.size.height - 270)/2;
    
    _imageView.frame = CGRectMake(x, y, 250, 270);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:_imageView atIndex:0];
    
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
       UIImage *newImage = [self.mPixelFree processWithImage:self.image rotationMode:PFRotationMode0];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_imageView.image = newImage;
        });
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _image = [UIImage imageNamed:@"IMG_2406.PNG"];
    
    
    
}


//- (void)performPortraitSegmentationWithImage:(UIImage *)image {
//    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
//    
//    // 创建人像分割请求
//    VNDetectHumanBodyPoseRequest *poseRequest = [[VNDetectHumanBodyPoseRequest alloc] init];
//    VNImageBasedRequest *segmentationRequest = [[VNGeneratePersonSegmentationRequest alloc] init];
//    
//    NSError *error = nil;
//    [handler performRequests:@[poseRequest, segmentationRequest] error:&error];
//    if (error) {
//        NSLog(@"Error performing requests: %@", error);
//        return;
//    }
//    
//    // 获取人像分割结果
//    VNGeneratePersonSegmentationRequest *segmentationObservation = nil;
//    for (VNRequest *request in @[poseRequest, segmentationRequest]) {
//        NSArray *results = [handler.resultsForRequest request];
//        for (VNResult *result in results) {
//            if ([result isKindOfClass:[VNGeneratePersonSegmentationObservation class]]) {
//                segmentationObservation = (VNGeneratePersonSegmentationObservation *)result;
//                break;
//            }
//        }
//    }
//    
//    if (segmentationObservation) {
//        CVPixelBufferRef segmentationBuffer = segmentationObservation.pixelBuffer;
//        
//        // 处理分割结果（segmentationBuffer）
//        // 将分割结果可视化或应用到其他图像处理操作
//    }
//}


-(void)viewWillDisappear:(BOOL)animated{
    [self.timer invalidate];
     self.timer = nil;
    CFRunLoopStop([_mRunLoop getCFRunLoop]);
    NSLog(@"viewWillDisappear ---");
}


-(void)dealloc{
    NSLog(@"dealloc ---");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
