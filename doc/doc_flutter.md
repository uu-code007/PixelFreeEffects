# pixelFree 美颜SDK使用文档 

#### Flutter 接入方式

```yaml
dependencies:
  pixelfree: ^2.4.15
```


####  仅需四步，完成接入使用  

1. 初始化

   ```kotlin
   await _pixelFreePlugin.createWithLic(licPath);
    
   ```

2. 美颜参数设置

   ```kotlin
   // 大眼
   _pixelFreePlugin.pixelFreeSetBeautyFiterParam(PFBeautyFiterType.EyeStrength,value); 
   ```

3. 滤镜与程度

   ```kotlin
   // 滤镜类型与程度  0 ~ 1.0
   _pixelFreePlugin.pixelFreeSetFilterParam("heibai1", 1.0);
   ```

4. 支持多种处理方式

   ```kotlin
   // pixbuffer 视频数据
   final texid = await _pixelFreePlugin.processWithImage(
               bytes.buffer.asUint8List(0), width, height);
   setState(() => _currentTextureId = texid);
   ```

   

#### 设置美颜参数说明,参数范围 （0.0~1.0）

```java
/* 美颜类型 */
enum PFBeautyFiterType {
  // 大眼（默认0.0，关闭）
  eyeStrength,
  // 瘦脸（默认0.0，关闭）
  faceThinning,
  // 窄脸（默认0.0，关闭）
  faceNarrow,
  // 下巴（默认0.5，两个方向调节）
  faceChin,
  // V脸（默认0.0，关闭）
  faceV,
  // 小脸（默认0.0，关闭）
  faceSmall,
  // 鼻子（默认0.0，关闭）
  faceNose,
  // 额头（默认0.5，两个方向调节）
  faceForehead,
  // 嘴巴（默认0.5，两个方向调节）
  faceMouth,
  // 人中（默认0.5，两个方向调节）
  facePhiltrum,
  // 长鼻（默认0.5，两个方向调节）
  faceLongNose,
  // 眼距（默认0.5，两个方向调节）
  faceEyeSpace,
  // 微笑嘴角（默认0.0，关闭）
  faceSmile,
  // 旋转眼睛（默认0.5，两个方向调节）
  faceEyeRotate,
  // 开眼角（默认0.0，关闭）
  faceCanthus,
  // 磨皮（默认0.0，关闭）
  faceBlurStrength,
  // 美白（默认0.0，关闭）
  faceWhitenStrength,
  // 红润（默认0.0，关闭）
  faceRuddyStrength,
  // 锐化（默认0.0，关闭）
  faceSharpenStrength,
  // 新美白算法（默认0.0，关闭）
  faceNewWhitenStrength,
  // 画质增强（默认0.0，关闭）
  faceQualityStrength,
  // 亮眼（默认0.0，关闭）
  faceEyeBrighten,
  // 滤镜类型（默认origin，原图）
  filterName,
  // 滤镜强度（默认0.0，关闭）
  filterStrength,
  // 绿幕（默认关闭）
  lvmu,
  // 2D贴纸（默认关闭）
  sticker2DFilter,
  // 一键美颜（默认关闭）
  typeOneKey,
  // 水印（默认关闭）
  watermark,
  // 扩展
}
```




