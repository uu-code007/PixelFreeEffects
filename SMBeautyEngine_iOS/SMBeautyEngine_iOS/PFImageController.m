//
//  PFImageController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/9/29.
//

#import "PFImageController.h"

@interface PFImageController ()

@property(nonatomic,strong)UIImage *image;

@property(nonatomic,strong)UIImageView *imageView;

/** NSTimer */
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation PFImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageView = [[UIImageView alloc] init];
//    _image = [UIImage imageNamed:@"IMG_2403"];
    _image = [UIImage imageNamed:@"image_00"];
    _imageView.image = _image;
    _imageView.frame = self.view.bounds;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:_imageView atIndex:0];
    
}
-(void)viewWillAppear:(BOOL)animated{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFun) userInfo:@"参数" repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        //如果是子线程还需要启动runloop
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
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
    _image = [UIImage imageNamed:@"IMG_2424.PNG"];
}


-(void)viewWillDisappear:(BOOL)animated{
    [self.timer invalidate];
     self.timer = nil;
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
