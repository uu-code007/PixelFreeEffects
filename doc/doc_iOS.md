# pixelFree 美颜SDK使用文档 

#### iOS 接入方式

1.  手动接入

    Demo 工程中有接入 PixelFree.framework，参考 demo 接入

2. pod 导入

   ```objective-c
     pod 'PixelFree'
   ```


####  仅需四步，完成接入使用  

1. 初始化

   ```
   // 素材路径
    NSString *face_FiltePath = [[NSBundle mainBundle] pathForResource:@"filter_model.bundle" ofType:nil];
    
    // 授权文件
    NSString *authFile = [[NSBundle mainBundle] pathForResource:@"pixelfreeAuth.lic" ofType:nil];
    
    // 初始化实例
    self.mPixelFree = [[SMPixelFree alloc] initWithProcessContext:nil srcFilterPath:face_FiltePath authFile:authFile];
    
   ```

2. 美颜参数设置

    ```
   // 大眼
   [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterTypeFace_EyeStrength value:&value]; 
   ```

3. 滤镜设置 (内置 10 款滤镜 )

   ```
   // 滤镜类型，类型字段查看，滤镜表格
   const char *aaa = [param.mParam UTF8String];
   [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterName value:(void *)aaa];
   // 滤镜程度
   [_mPixelFree pixelFreeSetBeautyFiterParam:PFBeautyFiterStrength value:&value];
   ```

4. 图像渲染处理，内部会内存回写

   ```
   // pixbuffer 视频数据
   [_mPixelFree processWithBuffer:pixbuffer];
   ```

   

#### 设置美颜参数说明,参数范围 （0.0~1.0）

```objective-c
typedef enum PFBeautyFiterType{
    PFBeautyFiterTypeFace_EyeStrength = 0,
    //瘦脸
    PFBeautyFiterTypeFace_thinning,
    //窄脸
    PFBeautyFiterTypeFace_narrow,
    //下巴 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_chin,
    //v脸
    PFBeautyFiterTypeFace_V,
    //small
    PFBeautyFiterTypeFace_small,
    //鼻子
    PFBeautyFiterTypeFace_nose,
    //额头（默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_forehead,
    //嘴巴（默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_mouth,
    //人中（默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_philtrum,
    //长鼻（默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_long_nose = 10,
    //眼距（默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_eye_space,
    //微笑嘴角
    PFBeautyFiterTypeFace_smile,
    //旋转眼睛（默认0.5，两个方向调节）
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

## 💡 使用建议

1. **性能优化**
   - 建议在后台线程进行图像处理
   - 适当调整美颜参数，避免过度处理
   - 注意内存管理，及时释放资源

2. **参数调节**
   - 所有参数范围均为 0.0 ~ 1.0
   - 建议从较小值开始调节
   - 注意参数间的相互影响

3. **常见问题**
   - 确保授权文件正确配置
   - 检查资源文件路径是否正确
   - 注意内存使用和性能监控

## 📝 注意事项

1. 请确保正确配置授权文件
2. 注意资源文件的正确引入
3. 建议在真机上进行测试
4. 注意内存管理和性能优化

## 🔗 相关资源

- [示例代码](https://github.com/uu-code007/PixelFreeEffects/tree/master/SMBeautyEngine_iOS)
- [常见问题](./frequently_asked_questions.md)
- [更新日志](./release_note.md)







