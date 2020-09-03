//
//  SMEffectFilter.m
//  SMBeautyEngine
//
//  Created by 孙慕 on 2020/7/27.
//  Copyright © 2020 孙慕. All rights reserved.
//

#import "SMEffectFilter.h"
#import <pixelFree/SMPixelFree.h>

@interface SMEffectFilter()

//@property (nonatomic, strong) SMBeautyEffect *effectHandler;

@property (nonatomic, strong) SMPixelFree *pixelFreeHandler;

@property (nonatomic, assign) BOOL isRender;

@end


@implementation SMEffectFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _pixelFreeHandler = [[SMPixelFree alloc] initWithProcessNewContext:NO];
        _pixelFreeHandler = [[SMPixelFree alloc] initWithProcessContext:[GPUImageContext sharedImageProcessingContext].context];
        _isRender = YES;
    }
    return self;
}

static int frame = 0;
static float total = 0;
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates{
    if (_isRender) {
        frame ++;
        CFAbsoluteTime aa = CFAbsoluteTimeGetCurrent();
        
        [_pixelFreeHandler processWithTexture:firstInputFramebuffer.texture width:[self sizeOfFBO].width height:[self sizeOfFBO].height];
        
        CFAbsoluteTime bb = CFAbsoluteTimeGetCurrent();
        
        total += (bb - aa) * 1000;
        if (frame % 100 == 0) {
            NSLog(@"render 耗时----%lf",total / 100);
            total = 0;
        }
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        
        [filterProgram use];
    }

    //------------->绘制特效图像<--------------//
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

/* 美颜相关 */
-(void)setBeautyModel:(SMBeautyFilterModel *)beautyModel{
    _beautyModel = beautyModel;
    _pixelFreeHandler.beautyModel = _beautyModel;
}

/* 贴纸相关 */
-(void)setStickerModel:(SMStickerModel *)stickerModel{
    _stickerModel = stickerModel;
    _pixelFreeHandler.stickerModel = stickerModel;
}

/* 美妆相关 */
-(void)setMakeModel:(SMMakeUpFilterModel *)makeModel{
    _makeModel = makeModel;
    _pixelFreeHandler.makeupModle = makeModel;
}


-(void)renderState:(BOOL)isRender{
    _isRender = isRender;
}
@end
