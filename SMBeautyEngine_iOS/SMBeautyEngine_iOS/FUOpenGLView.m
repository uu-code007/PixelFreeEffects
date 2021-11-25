//
//  FUOpenGLView.m
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/15.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import "FUOpenGLView.h"
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#define STRINGIZE(x)    #x
#define STRINGIZE2(x)    STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const FUYUVToRGBAFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D luminanceTexture;
 uniform sampler2D chrominanceTexture;
 uniform mediump mat3 colorConversionMatrix;
 
 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;
     
     yuv.x = texture2D(luminanceTexture, textureCoordinate).r;
     yuv.yz = texture2D(chrominanceTexture, textureCoordinate).ra - vec2(0.5, 0.5);
     rgb = colorConversionMatrix * yuv;
     
     gl_FragColor = vec4(rgb, 1.0);
 }
 );

NSString *const FURGBAFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 varying highp vec2 textureCoordinate;
 
 void main()
{
    gl_FragColor = vec4(texture2D(inputImageTexture, textureCoordinate).rgb,1.0);
}
 );

NSString *const FUVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const FUPointsFrgShaderString = SHADER_STRING
(
 precision mediump float;
 
 varying highp vec4 fragmentColor;
 
 void main()
{
    if (-smoothstep(0.48, 0.5, length(gl_PointCoord - vec2(0.5))) + 1.0 == 0.0) {
        discard;
    }
    gl_FragColor = fragmentColor;
}
 
 );

NSString *const FUPointsVtxShaderString = SHADER_STRING
(
 attribute vec4 position;
 
 attribute float point_size;
 
 attribute vec4 inputColor;
 
 varying vec4 fragmentColor;
 
 void main()
{
    gl_Position = position;
    
    gl_PointSize = point_size;
    
    fragmentColor = inputColor;
}
 );

enum
{
    furgbaPositionAttribute,
    furgbaTextureCoordinateAttribute,
    fuPointSize,
    fuPointColor,
};

enum
{
    fuyuvConversionPositionAttribute,
    fuyuvConversionTextureCoordinateAttribute
};

@interface FUOpenGLView(){
    dispatch_semaphore_t semaphore;
}

@property (nonatomic, strong) EAGLContext *glContext;

@property(nonatomic) dispatch_queue_t contextQueue;

@end

@implementation FUOpenGLView
{
    GLuint rgbaProgram;
    GLuint rgbaToYuvProgram;
    GLuint pointProgram;
    
    CVOpenGLESTextureCacheRef videoTextureCache;
    
    GLuint frameBufferHandle;
    GLuint renderBufferHandle;
    
    GLint yuvConversionLuminanceTextureUniform, yuvConversionChrominanceTextureUniform;
    GLint yuvConversionMatrixUniform;
    GLint displayInputTextureUniform;
    
    GLfloat vertices[8];
    
    int frameWidth;
    int frameHeight;
    int backingWidth;
    int backingHeight;
    
    CGSize boundsSizeAtFrameBufferEpoch;
    
    GLuint texture;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        self.disapplePointIndex = -1 ;
        _contextQueue = dispatch_queue_create("com.faceunity.contextQueue", DISPATCH_QUEUE_SERIAL);
        
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!_glContext) {
            NSLog(@"This devicde is not support OpenGLES3,try to create OpenGLES2");
            _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        if (!self.glContext) {
            NSLog(@"failed to create context");
        }
        
        if (!videoTextureCache) {
            CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.glContext, NULL, &videoTextureCache);
            if (err != noErr) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
            }
        }
        self.origintation = FUOpenGLViewOrientationPortrait ;
        self.contentMode = FUOpenGLViewContentModeScaleAspectFill;
    }
        
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame] ) {
        self.disapplePointIndex = -1 ;
        _contextQueue = dispatch_queue_create("com.faceunity.contextQueue", DISPATCH_QUEUE_SERIAL);
        
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!_glContext) {
            NSLog(@"This devicde is not support OpenGLES3,try to create OpenGLES2");
            _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        if (!self.glContext) {
            NSLog(@"failed to create context");
        }
        
        if (!videoTextureCache) {
            CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.glContext, NULL, &videoTextureCache);
            if (err != noErr) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
            }
        }
        self.origintation = FUOpenGLViewOrientationPortrait ;
        self.contentMode = FUOpenGLViewContentModeScaleAspectFill;
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame context:(nonnull EAGLContext *)contex{
    if (self = [super initWithFrame:frame] ) {
        self.disapplePointIndex = -1 ;
        _contextQueue = dispatch_queue_create("com.faceunity.contextQueue", DISPATCH_QUEUE_SERIAL);
        
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                          kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        _glContext = contex;
        if (!_glContext) {
            NSLog(@"This devicde is not support OpenGLES3,try to create OpenGLES2");
            _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        if (!self.glContext) {
            NSLog(@"failed to create context");
        }
        
        if (!videoTextureCache) {
            CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.glContext, NULL, &videoTextureCache);
            if (err != noErr) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
            }
        }
        self.origintation = FUOpenGLViewOrientationPortrait ;
        self.contentMode = FUOpenGLViewContentModeScaleAspectFill;
    }
    return self;
}



- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    // The frame buffer needs to be trashed and re-created when the view size changes.
    if (!CGSizeEqualToSize(self.bounds.size, boundsSizeAtFrameBufferEpoch) &&
        !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        
        boundsSizeAtFrameBufferEpoch = self.bounds.size;
        
//        dispatch_async(_contextQueue, ^{
//            [self destroyDisplayFramebuffer];
//            [self createDisplayFramebuffer];
//            [self updateVertices];
//        });
    }
}

- (void)dealloc
{
    
    dispatch_sync(_contextQueue, ^{
        [self destroyDisplayFramebuffer];
        [self destoryProgram];
        if(self->videoTextureCache) {
            CVOpenGLESTextureCacheFlush(self->videoTextureCache, 0);
            CFRelease(self->videoTextureCache);
            self->videoTextureCache = NULL;
            
        }
    });
}

- (void)createDisplayFramebuffer
{
    [EAGLContext setCurrentContext:self.glContext];
    
    glDisable(GL_DEPTH_TEST);
    
    glGenFramebuffers(1, &frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferHandle);
    
    glGenRenderbuffers(1, &renderBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferHandle);
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    });

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    if ( (backingWidth == 0) || (backingHeight == 0) )
    {
        [self destroyDisplayFramebuffer];
        return;
    }
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBufferHandle);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)destroyDisplayFramebuffer;
{
    [EAGLContext setCurrentContext:self.glContext];
    
    if (frameBufferHandle)
    {
        glDeleteFramebuffers(1, &frameBufferHandle);
        frameBufferHandle = 0;
    }
    
    if (renderBufferHandle)
    {
        glDeleteRenderbuffers(1, &renderBufferHandle);
        renderBufferHandle = 0;
    }
}

- (void)setDisplayFramebuffer;
{
    if (!frameBufferHandle)
    {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferHandle);
    
    glViewport(0, 0, (GLint)backingWidth, (GLint)backingHeight);
}

- (void)setImageDisplayFramebuffer;
{
    if (!frameBufferHandle)
    {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferHandle);
    
    float bw = self.frame.size.width * [UIScreen mainScreen].scale ;
    float bh = self.frame.size.height * [UIScreen mainScreen].scale ;
    glViewport(0, 0, (GLint)bw, (GLint)bh);
}

- (void)destoryProgram{
    if (rgbaProgram) {
        glDeleteProgram(rgbaProgram);
        rgbaProgram = 0;
    }
    
    if (rgbaToYuvProgram) {
        glDeleteProgram(rgbaToYuvProgram);
        rgbaToYuvProgram = 0;
    }
    
    if (pointProgram) {
        glDeleteProgram(pointProgram);
        pointProgram = 0;
    }
}

- (void)presentFramebuffer;
{

    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferHandle);
    [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
//    glFinish();
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    [self displayPixelBuffer:pixelBuffer withLandmarks:NULL count:0 MAX:NO];
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer withLandmarks:(float *)landmarks count:(int)count MAX:(BOOL)max
{
    if (pixelBuffer == NULL) return;
    
    CVPixelBufferRetain(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    dispatch_sync(_contextQueue, ^{  //dispatch_sync  iphone8p 可能死锁
        self->frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        self->frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        
        if ([EAGLContext currentContext] != self.glContext) {
            if (![EAGLContext setCurrentContext:self.glContext]) {
                NSLog(@"fail to setCurrentContext");
            }
        }
        
        [self setDisplayFramebuffer];
        
        OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
        if (type == kCVPixelFormatType_32BGRA)
        {
            [self prepareToDrawBGRAPixelBuffer:pixelBuffer];
            
        }else{
            [self prepareToDrawYUVPixelBuffer:pixelBuffer];
        }
        
        if (landmarks) {
            [self prepareToDrawLandmarks:landmarks count:count MAX:max zoomScale:1];
        }
        
        [self presentFramebuffer];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVPixelBufferRelease(pixelBuffer);
    });
    
}

- (void)displaySyncPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (pixelBuffer == NULL) return;
    
    CVPixelBufferRetain(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//    dispatch_async(_contextQueue, ^{  //dispatch_sync  iphone8p 可能死锁
        self->frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        self->frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        
        if ([EAGLContext currentContext] != self.glContext) {
            if (![EAGLContext setCurrentContext:self.glContext]) {
                NSLog(@"fail to setCurrentContext");
            }
        }
        
        [self setDisplayFramebuffer];
        
        OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
        if (type == kCVPixelFormatType_32BGRA)
        {
            [self prepareToDrawBGRAPixelBuffer:pixelBuffer];
            
        }else{
            [self prepareToDrawYUVPixelBuffer:pixelBuffer];
        }
        
        [self presentFramebuffer];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVPixelBufferRelease(pixelBuffer);
//    });
}

- (void)displayImageData:(void *)imageData withSize:(CGSize)size{
    
    frameWidth = (int)size.width;
    frameHeight = (int)size.height;
    
    if ([EAGLContext currentContext] != self.glContext) {
        if (![EAGLContext setCurrentContext:self.glContext]) {
            NSLog(@"fail to setCurrentContext");
        }
    }
    [self setDisplayFramebuffer];
    
    if (!rgbaProgram) {
        [self loadShadersRGBA];
    }
    
    if (texture == 0) {
        glGenTextures(1, &texture);
    }
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glUseProgram(rgbaProgram);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(displayInputTextureUniform, 1);
    
    [self updateVertices];
    
    // 更新顶点数据
    glVertexAttribPointer(furgbaPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(furgbaPositionAttribute);
    
    GLfloat quadTextureData[] =  {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    glVertexAttribPointer(furgbaTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(furgbaTextureCoordinateAttribute);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self presentFramebuffer];
}

- (void)displayImageData:(void *)imageData withSize:(CGSize)size Center:(CGPoint)center Landmarks:(float *)landmarks count:(int)count {
    
    frameWidth = (int)size.width;
    frameHeight = (int)size.height;
    
    if ([EAGLContext currentContext] != self.glContext) {
        if (![EAGLContext setCurrentContext:self.glContext]) {
            NSLog(@"fail to setCurrentContext");
        }
    }
    [self setImageDisplayFramebuffer];
    
    if (!rgbaProgram) {
        [self loadShadersRGBA];
    }
    
    if (texture == 0) {
        glGenTextures(1, &texture);
    }
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glUseProgram(rgbaProgram);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);;
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(displayInputTextureUniform, 1);
    
    [self updateVertices];
    
    // 更新顶点数据
    glVertexAttribPointer(furgbaPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(furgbaPositionAttribute);
    
    GLfloat quadTextureData[] =  {
        center.x - 0.1, center.y + 0.1,
        center.x + 0.1, center.y + 0.1,
        center.x - 0.1, center.y - 0.1,
        center.x + 0.1, center.y - 0.1,
    };
    
    glVertexAttribPointer(furgbaTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(furgbaTextureCoordinateAttribute);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    if (landmarks) {
        [self drawImageLandmarks:landmarks count:count center:center];
    }
    
    [self presentFramebuffer];
}


- (void)drawImageLandmarks:(float *)landmarks count:(int)count center:(CGPoint)center
{
    if (!pointProgram) {
        [self loadPointsShaders];
    }
    
    glUseProgram(pointProgram);
    
    count = count;
    
    float sizeData[count];
    
    float colorData[count * 4];
    
    float newLandmarks[count *2];
    
    float bw = self.frame.size.width * [UIScreen mainScreen].scale ;
    float bh = self.frame.size.height * [UIScreen mainScreen].scale ;
    
    const float width   = frameWidth;
    const float height  = frameHeight;
    const float dH      = bh / height;
    const float dW      = bw / width;
    const float dd      = MAX(dH, dW);
    const float h       = (height * dd / (float)bw) * 10/2;
    const float w       = (width  * dd / (float)bw) * 10/2;
    
    for (int i = 0; i < count/2; i++)
    {
        if (self.disapplePointIndex == i) {
            continue ;
        }
        //点的大小
        sizeData[i] = [UIScreen mainScreen].scale * 5;
        
        //点的颜色
        colorData[4 * i] = 1.0;
        colorData[4 * i + 1] = .0;
        colorData[4 * i + 2] = .0;
        colorData[4 * i + 3] = .0;
        
        //转化坐标
        newLandmarks[2 * i] = (float)((2 * landmarks[2 * i] / frameWidth - 1)) * w - (center.x - 0.5) * 2 * w;
        
        newLandmarks[2 * i + 1] = (float)(1 - 2 * landmarks[2 * i + 1] / frameHeight ) * h - (0.5 - center.y) * 2 * h;
    }
    
    for (int i = count/2; i < count; i++)
    {
        sizeData[i] = [UIScreen mainScreen].scale * 3;
        
        colorData[4 * i ] = 1.0;
        colorData[4 * i + 1] = 1.0;
        colorData[4 * i + 2] = 1.0;
        colorData[4 * i + 3] = 1.0;
        
        newLandmarks[2 * i] = (float)((2 * landmarks[2 * i - count] / frameWidth - 1)) * w - (center.x - 0.5) * 2 * w;
        newLandmarks[2 * i + 1] = (float)(1 - 2 * landmarks[2 * i + 1 - count] / frameHeight ) * h - (0.5 - center.y) * 2 * h;
    }
    
    glEnableVertexAttribArray(fuPointSize);
    glVertexAttribPointer(fuPointSize, 1, GL_FLOAT, GL_FALSE, 0, sizeData);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, (GLfloat *)newLandmarks);
    
    glEnableVertexAttribArray(fuPointColor);
    glVertexAttribPointer(fuPointColor, 4, GL_FLOAT, GL_FALSE, 0, colorData);
    
    glDrawArrays(GL_POINTS, 0, count);
}

- (void)displayImageData:(void *)imageData Size:(CGSize)size Landmarks:(float *)landmarks count:(int)count zoomScale:(float)zoomScale{
    
    frameWidth = (int)size.width;
    frameHeight = (int)size.height;
    
    if ([EAGLContext currentContext] != self.glContext) {
        if (![EAGLContext setCurrentContext:self.glContext]) {
            NSLog(@"fail to setCurrentContext");
        }
    }
    [self setDisplayFramebuffer];
    
    if (!rgbaProgram) {
        [self loadShadersRGBA];
    }
    
    if (texture == 0) {
        glGenTextures(1, &texture);
    }
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glUseProgram(rgbaProgram);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);;
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(displayInputTextureUniform, 1);
    
    [self updateVertices];
    
    // 更新顶点数据
    glVertexAttribPointer(furgbaPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(furgbaPositionAttribute);
    
    GLfloat quadTextureData[] =  {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    glVertexAttribPointer(furgbaTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(furgbaTextureCoordinateAttribute);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    if (landmarks) {
        [self prepareToDrawLandmarks:landmarks count:count MAX:NO zoomScale:zoomScale];
    }
    
    [self presentFramebuffer];
}

//- (void)updateVerticesRenderImage
//{
//    const float width   = frameWidth;
//    const float height  = frameHeight;
//    const float dH      = (float)backingHeight / height;
//    const float dW      = (float)backingWidth      / width;
//    const float dd      = MIN(dH, dW);
//    const float h       = (height * dd / (float)backingHeight);
//    const float w       = (width  * dd / (float)backingWidth );
//
//    imageVertices[0] = - w;
//    imageVertices[1] = - h;
//    imageVertices[2] =   w;
//    imageVertices[3] = - h;
//    imageVertices[4] = - w;
//    imageVertices[5] =   h;
//    imageVertices[6] =   w;
//    imageVertices[7] =   h;
//}

- (void)prepareToDrawLandmarks:(float *)landmarks count:(int)count MAX:(BOOL)max zoomScale:(float)zoomScale
{
    if (!pointProgram) {
        [self loadPointsShaders];
    }
    
    glUseProgram(pointProgram);
    
    count = count;
    
    float sizeData[count];
    
    float colorData[count * 4];
    
    float newLandmarks[count * 2];
    
    float width   = frameWidth;
    float height  = frameHeight;
    float dH      = (float)backingHeight / height;
    float dW      = (float)backingWidth  / width;
    float dd      = 0;
    if (max) {
        dd      = MAX(dH, dW);
    }else {
        dd      = MIN(dH, dW) ;
    }
    float h       = (height * dd / (float)backingHeight);
    float w       = (width  * dd / (float)backingWidth );
    
    for (int i = 0; i < count / 2; i++)
    {
        //点的大小
        sizeData[i] = [UIScreen mainScreen].scale * 2 / zoomScale;
  
        colorData[4 * i ] = 1.0;
        colorData[4 * i + 1] = 0.0;
        colorData[4 * i + 2] = 0.0;
        colorData[4 * i + 3] = 0.0;
        
        //转化坐标
        newLandmarks[2 * i] = (float)((2 * landmarks[2 * i] / frameWidth - 1))*w;
        newLandmarks[2 * i + 1] = (float)(1 - 2 * landmarks[2 * i + 1] / frameHeight)*h;
    }
    
    for (int i = count/2; i < count; i++)
    {
        sizeData[i] = [UIScreen mainScreen].scale  / zoomScale;

        colorData[4 * i ] = 1.0;
        colorData[4 * i + 1] = 1.0;
        colorData[4 * i + 2] = 1.0;
        colorData[4 * i + 3] = 1.0;

        newLandmarks[2 * i] = (float)((2 * landmarks[2 * i - count] / frameWidth - 1))*w;
        newLandmarks[2 * i + 1] = (float)(1 - 2 * landmarks[2 * i + 1 - count] / frameHeight)*h;
    }
    
    glEnableVertexAttribArray(fuPointSize);
    glVertexAttribPointer(fuPointSize, 1, GL_FLOAT, GL_FALSE, 0, sizeData);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, (GLfloat *)newLandmarks);
    
    glEnableVertexAttribArray(fuPointColor);
    glVertexAttribPointer(fuPointColor, 4, GL_FLOAT, GL_FALSE, 0, colorData);
    
    glDrawArrays(GL_POINTS, 0, count);
}

- (void)prepareToDrawBGRAPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (!rgbaProgram) {
        [self loadShadersRGBA];
    }
    CVOpenGLESTextureRef rgbaTexture = NULL;
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, frameWidth, frameHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &rgbaTexture);
    
    if (!rgbaTexture || err) {
        
        NSLog(@"Camera CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);
        return;
    }
    
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(rgbaTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glUseProgram(rgbaProgram);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(rgbaTexture));
    glUniform1i(displayInputTextureUniform, 4);
    
    [self updateVertices];
    // 更新顶点数据
    glVertexAttribPointer(furgbaPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(furgbaPositionAttribute);
    
    GLfloat quadTextureData[] =  {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    if (_origintation == FUOpenGLViewOrientationPortrait) {
        float quadTextureData0[] =  {
                0.0f, 1.0f,
                1.0f, 1.0f,
                0.0f,  0.0f,
                1.0f,  0.0f,
        };
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }
    
    if (_origintation == FUOpenGLViewOrientationLandscapeRight) {
        float quadTextureData0[] =  {
            1.0f, 1.0f,
            1.0f, 0.0f,
            0.0f,  1.0f,
            0.0f,  0.0f,
        };
        
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }
    
    if (_origintation == FUOpenGLViewOrientationPortraitUpsideDown) {
        float quadTextureData0[] =  {
            1.0f, 0.0f,
            0.0f, 0.0f,
            1.0f,  1.0f,
            0.0f,  1.0f,
        };
        
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }
    
    if (_origintation == FUOpenGLViewOrientationLandscapeLeft) {
        float quadTextureData0[] =  {
            0.0f, 0.0f,
            0.0f, 1.0f,
            1.0f,  0.0f,
            1.0f,  1.0f,
        };
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }


    glVertexAttribPointer(furgbaTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(furgbaTextureCoordinateAttribute);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    if (rgbaTexture) {
        CFRelease(rgbaTexture);
        rgbaTexture = NULL;
    }
}

- (void)prepareToDrawYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (!rgbaToYuvProgram) {
        [self loadShadersYUV];
    }
    
    CVReturn err;
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    
    /*
     CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture optimally from CVPixelBufferRef.
     */
    
    /*
     Create Y and UV textures from the pixel buffer. These textures will be drawn on the frame buffer Y-plane.
     */
    glActiveTexture(GL_TEXTURE0);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_LUMINANCE,
                                                       frameWidth,
                                                       frameHeight,
                                                       GL_LUMINANCE,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &luminanceTextureRef);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(luminanceTextureRef));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // UV-plane.
    glActiveTexture(GL_TEXTURE1);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_LUMINANCE_ALPHA,
                                                       frameWidth / 2,
                                                       frameHeight / 2,
                                                       GL_LUMINANCE_ALPHA,
                                                       GL_UNSIGNED_BYTE,
                                                       1,
                                                       &chrominanceTextureRef);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(chrominanceTextureRef));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glClearColor(0.1f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Use shader program.
    glUseProgram(rgbaToYuvProgram);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(luminanceTextureRef));
    glUniform1i(yuvConversionLuminanceTextureUniform, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(chrominanceTextureRef));
    glUniform1i(yuvConversionChrominanceTextureUniform, 1);
    
    GLfloat kColorConversion601FullRange[] = {
        1.0,    1.0,    1.0,
        0.0,    -0.343, 1.765,
        1.4,    -0.711, 0.0,
    };
    
    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, kColorConversion601FullRange);
    
    // 更新顶点数据
    [self updateVertices];
    
    glVertexAttribPointer(fuyuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(fuyuvConversionPositionAttribute);
    
    GLfloat quadTextureData[] =  {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    if (_origintation == FUOpenGLViewOrientationPortrait) {
        float quadTextureData0[] =  {
                0.0f, 1.0f,
                1.0f, 1.0f,
                0.0f,  0.0f,
                1.0f,  0.0f,
        };
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }
    
    if (_origintation == FUOpenGLViewOrientationLandscapeRight) {
        float quadTextureData0[] =  {
            1.0f, 1.0f,
            1.0f, 0.0f,
            0.0f,  1.0f,
            0.0f,  0.0f,
        };
        
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }
    
    if (_origintation == FUOpenGLViewOrientationPortraitUpsideDown) {
        float quadTextureData0[] =  {
            1.0f, 0.0f,
            0.0f, 0.0f,
            1.0f,  1.0f,
            0.0f,  1.0f,
        };
        
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }
    
    if (_origintation == FUOpenGLViewOrientationLandscapeLeft) {
        float quadTextureData0[] =  {
            0.0f, 0.0f,
            0.0f, 1.0f,
            1.0f,  0.0f,
            1.0f,  1.0f,
        };
        memcpy(quadTextureData, quadTextureData0, sizeof(quadTextureData));
    }

    
    
    glVertexAttribPointer(fuyuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(fuyuvConversionTextureCoordinateAttribute);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    if (luminanceTextureRef) {
        CFRelease(luminanceTextureRef);
        luminanceTextureRef = NULL;
    }
    
    if (chrominanceTextureRef) {
        CFRelease(chrominanceTextureRef);
        chrominanceTextureRef = NULL;
    }
    
}

- (void)updateVertices
{
    float height   = frameHeight;
    float width  = frameWidth;
    if (_origintation == FUOpenGLViewOrientationLandscapeRight || _origintation == FUOpenGLViewOrientationLandscapeLeft) {
        height   = frameWidth;
        width  = frameHeight;
    }
    
    float dH      = (float)backingHeight / height;
    float dW      = (float)backingWidth      / width;
    
    if(_contentMode == FUOpenGLViewContentModeScaleToFill){
        vertices[0] = - 1;
        vertices[1] = - 1;
        vertices[2] =   1;
        vertices[3] = - 1;
        vertices[4] = - 1;
        vertices[5] =   1;
        vertices[6] =   1;
        vertices[7] =   1;
    }
    
    if (_contentMode == FUOpenGLViewContentModeScaleAspectFill) {
        float dd      = MAX(dH, dW) ;
        float h       = (height * dd / (float)backingHeight);
        float w       = (width  * dd / (float)backingWidth );
        
        vertices[0] = - w;
        vertices[1] = - h;
        vertices[2] =   w;
        vertices[3] = - h;
        vertices[4] = - w;
        vertices[5] =   h;
        vertices[6] =   w;
        vertices[7] =   h;
    }
    
    if (_contentMode == FUOpenGLViewContentModeScaleAspectFit) {
        float dd      = MIN(dH, dW) ;
        float h       = (height * dd / (float)backingHeight);
        float w       = (width  * dd / (float)backingWidth );
        
        vertices[0] = - w;
        vertices[1] = - h;
        vertices[2] =   w;
        vertices[3] = - h;
        vertices[4] = - w;
        vertices[5] =   h;
        vertices[6] =   w;
        vertices[7] =   h;
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShadersRGBA
{
    GLuint vertShader, fragShader;
    
    if (!rgbaProgram) {
        rgbaProgram = glCreateProgram();
    }
    
    // Create and compile the vertex shader.
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER string:FUVertexShaderString]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER string:FURGBAFragmentShaderString]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(rgbaProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(rgbaProgram, fragShader);
    
    // Bind attribute locations. This needs to be done prior to linking.
    glBindAttribLocation(rgbaProgram, furgbaPositionAttribute, "position");
    glBindAttribLocation(rgbaProgram, furgbaTextureCoordinateAttribute, "inputTextureCoordinate");
    
    // Link the program.
    if (![self linkProgram:rgbaProgram]) {
        NSLog(@"Failed to link program: %d", rgbaProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (rgbaProgram) {
            glDeleteProgram(rgbaProgram);
            rgbaProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    displayInputTextureUniform = glGetUniformLocation(rgbaProgram, "inputImageTexture");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(rgbaProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(rgbaProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)loadShadersYUV
{
    GLuint vertShader, fragShader;
    
    if (!rgbaToYuvProgram) {
        rgbaToYuvProgram = glCreateProgram();
    }
    
    // Create and compile the vertex shader.
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER string:FUVertexShaderString]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER string:FUYUVToRGBAFragmentShaderString]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to rgbaToYuvProgram.
    glAttachShader(rgbaToYuvProgram, vertShader);
    
    // Attach fragment shader to rgbaToYuvProgram.
    glAttachShader(rgbaToYuvProgram, fragShader);
    
    // Bind attribute locations. This needs to be done prior to linking.
    glBindAttribLocation(rgbaToYuvProgram, fuyuvConversionPositionAttribute, "position");
    glBindAttribLocation(rgbaToYuvProgram, fuyuvConversionTextureCoordinateAttribute, "inputTextureCoordinate");
    
    // Link the rgbaToYuvProgram.
    if (![self linkProgram:rgbaToYuvProgram]) {
        NSLog(@"Failed to link program: %d", rgbaToYuvProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (rgbaToYuvProgram) {
            glDeleteProgram(rgbaToYuvProgram);
            rgbaToYuvProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    yuvConversionLuminanceTextureUniform = glGetUniformLocation(rgbaToYuvProgram, "luminanceTexture");
    yuvConversionChrominanceTextureUniform = glGetUniformLocation(rgbaToYuvProgram, "chrominanceTexture");
    yuvConversionMatrixUniform = glGetUniformLocation(rgbaToYuvProgram, "colorConversionMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(rgbaToYuvProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(rgbaToYuvProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    glUseProgram(rgbaToYuvProgram);
    
    return YES;
}


- (BOOL)loadPointsShaders
{
    GLuint vertShader, fragShader;
    
    pointProgram = glCreateProgram();
    
    // Create and compile the vertex shader.
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER string:FUPointsVtxShaderString]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER string:FUPointsFrgShaderString]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(pointProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(pointProgram, fragShader);
    
    // Bind attribute locations. This needs to be done prior to linking.
    glBindAttribLocation(pointProgram, fuPointSize, "point_size");
    glBindAttribLocation(pointProgram, fuPointColor, "inputColor");
    
    // Link the program.
    if (![self linkProgram:pointProgram]) {
        NSLog(@"Failed to link program: %d", pointProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (pointProgram) {
            glDeleteProgram(pointProgram);
            pointProgram = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(pointProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(pointProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type string:(NSString *)shaderString
{
    GLint status;
    const GLchar *source;
    source = (GLchar *)[shaderString UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (UIColor*)getColorWithPoint:(CGPoint)point{
    __block UIColor *color = nil;
    semaphore = dispatch_semaphore_create(0);

    float imageW = frameWidth;
    float imageH = frameHeight;
       
    point = CGPointMake(point.x/self.bounds.size.width,point.y/self.bounds.size.height);

    point.x = point.x * backingWidth;
    point.y = (1- point.y)* backingHeight;
    dispatch_async(_contextQueue, ^{

        if ([EAGLContext currentContext] != self.glContext) {
            if (![EAGLContext setCurrentContext:self.glContext]) {
                NSLog(@"fail to setCurrentContext");
            }
        }
        
        [self setDisplayFramebuffer];
            
        GLubyte aa[4] = {0};
        GLint aaa = (GLint)point.x;
        GLint bb = (GLint)point.y;
        glReadPixels(aaa,bb,1, 1, GL_BGRA, GL_UNSIGNED_BYTE, aa);
        color = [UIColor colorWithRed:(aa[2]/255.0f) green:(aa[1]/255.0f) blue:(aa[0]/255.0f) alpha:(aa[3]/255.0f)];
    
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return color;
}




@end
