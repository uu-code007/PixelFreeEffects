# pixelFree 美颜SDK使用文档 

#### iOS 接入方式

1.  手动接入 [PixelFree.lib](../SMBeautyEngine_windows/pixelfreeLib/PixelFree.lib)

    Demo 工程中有接入 PixelFree.lib，参考 demo 接入



####  仅需四步，完成接入使用  

1. 初始化

   ```
   // 初始化
   handle = PF_NewPixelFree();
    
    // 授权文件 & 导入素材
   PF_createBeautyItemFormBundle(handle, authBuffer.data(), (int)size, PFSrcTypeAuthFile);
   PF_createBeautyItemFormBundle(handle, filterBuffer.data(), (int)size, PFSrcTypeFilter);
    
    
   ```
   
2. 美颜参数设置

   ```
   // 设置瘦脸
   float valuea = 1.0f;
   PF_pixelFreeSetBeautyFiterParam(handle,PFBeautyFiterTypeFace_thinning,&valuea);
   ```

3. 滤镜设置 (内置 10 款滤镜 )

   ```
   // 滤镜类型，类型字段查看，滤镜表格
   const char *param = "heibai1";
   PF_pixelFreeSetBeautyFiterParam(handle,PFBeautyFiterName,(void*)param);
   // 滤镜程度
   float valuea = 1.0f;
   PF_pixelFreeSetBeautyFiterParam(handle,PFBeautyFiterStrength,&valuea);
   ```

4. 图像渲染处理，内部会内存回写

   ```
   PFIamgeInput image;
     image.textureID = texture_id;
     image.p_data0 = data;
  image.wigth = width;
     image.height = height;
     image.stride_0 = width * 4;
     image.format = PFFORMAT_IMAGE_TEXTURE;
     image.rotationMode = PFRotationMode180;
   // 处理图
   int outTexture = PF_processWithBuffer(handle, image);
   ```
   
   

#### 设置美颜参数说明,参数范围 （0.0~1.0）

```objective-c
typedef enum PFBeautyFiterType{
    PFBeautyFiterTypeFace_EyeStrength = 0,
    //瘦脸
    PFBeautyFiterTypeFace_thinning,
    //窄脸
    PFBeautyFiterTypeFace_narrow,
    //下巴
    PFBeautyFiterTypeFace_chin,
    //v脸
    PFBeautyFiterTypeFace_V,
    //small
    PFBeautyFiterTypeFace_small,
    //鼻子
    PFBeautyFiterTypeFace_nose,
    //额头
    PFBeautyFiterTypeFace_forehead,
    //嘴巴
    PFBeautyFiterTypeFace_mouth,
    //人中
    PFBeautyFiterTypeFace_philtrum,
    //长鼻
    PFBeautyFiterTypeFace_long_nose = 10,
    //眼距
    PFBeautyFiterTypeFace_eye_space,
    //微笑嘴角
    PFBeautyFiterTypeFace_smile,
    //旋转眼睛
    PFBeautyFiterTypeFace_eye_rotate,
    //开眼角
    PFBeautyFiterTypeFace_canthus,
    //磨皮
    PFBeautyFiterTypeFaceBlurStrength,
    //美白
    PFBeautyFiterTypeFaceWhitenStrength,
    //红润
    PFBeautyFiterTypeFaceRuddyStrength,
    //锐化
    PFBeautyFiterTypeFaceSharpenStrength,
    //新美白算法
    PFBeautyFiterTypeFaceM_newWhitenStrength,
    //画质增强
    PFBeautyFiterTypeFaceH_qualityStrength,
    //滤镜类型
    PFBeautyFiterName,
    //滤镜强度
    PFBeautyFiterStrength,
    //绿幕
    PFBeautyFiterLvmu,
    // 2D 贴纸
    PFBeautyFiterSticker2DFilter,
    // 一键美颜
    PFBeautyFiterTypeOneKey,
    // 扩展字段
    PFBeautyFiterExtend,
} PFBeautyFiterType;
```







