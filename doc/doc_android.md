# pixelFree 美颜SDK使用文档 


####  仅需四步，完成接入使用  

1. 初始化

   ```kotlin
   mPixelFree.create()
   // 授权
   val authData = mPixelFree.readBundleFile(this@MainActivity, "pixelfreeAuth.lic")
   mPixelFree.auth(this.applicationContext, authData, authData.size)
   
   // 设置滤镜资源
   val face_fiter = mPixelFree.readBundleFile(this@MainActivity,"filter_model.bundle")
   mPixelFree.createBeautyItemFormBundle( face_fiter,
                                          face_fiter.size,
                                          PFSrcType.PFSrcTypeFilter)
    
   ```

2. 美颜参数设置

   ```kotlin
   // 大眼
   mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterTypeFace_EyeStrength,value); 
   ```

3. 滤镜与程度

   ```kotlin
   // 滤镜类型与程度  0 ~ 1.0
   mPixelFree.pixelFreeSetBeautyFiterParam("heibai1",0.5); 
   ```

4. 图像渲染处理，内部会内存回写

   ```kotlin
   // pixbuffer 视频数据
   mPixelFree.processWithBuffer(pxInput)
   ```

   

#### 设置美颜参数说明,参数范围 （0.0~1.0）

```java
/* 美颜类型 */
enum class PFBeautyFiterType(val intType: Int) {
    //大眼 （默认0.0，关闭）
    PFBeautyFiterTypeFace_EyeStrength(0),
    //瘦脸（默认0.0，关闭）
    PFBeautyFiterTypeFace_thinning(1),
    //窄脸（默认0.0，关闭）
    PFBeautyFiterTypeFace_narrow(2),
    //下巴 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_chin(3),
    //v脸（默认0.0，关闭）
    PFBeautyFiterTypeFace_V(4),
    //small（默认0.0，关闭）
    PFBeautyFiterTypeFace_small(5),
    //鼻子（默认0.0，关闭）
    PFBeautyFiterTypeFace_nose(6),
    //额头 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_forehead(7),
    //嘴巴 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_mouth(8),
    //人中 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_philtrum(9),
    //长鼻 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_long_nose(10),
    //眼距 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_eye_space(11),
    //微笑嘴角（默认0.0，关闭）
    PFBeautyFiterTypeFace_smile(12),
    //旋转眼睛 （默认0.5，两个方向调节）
    PFBeautyFiterTypeFace_eye_rotate(13),
    //开眼角（默认0.0，关闭）
    PFBeautyFiterTypeFace_canthus(14),
    //磨皮（默认0.0，关闭）
    PFBeautyFiterTypeFaceBlurStrength(15),
    //美白（默认0.0，关闭）
    PFBeautyFiterTypeFaceWhitenStrength(16),
    //红润（默认0.0，关闭）
    PFBeautyFiterTypeFaceRuddyStrength(17),
    //锐化（默认0.0，关闭）
    PFBeautyFiterTypeFaceSharpenStrength(18),
    //新美白算法（默认0.0，关闭）
    PFBeautyFiterTypeFaceM_newWhitenStrength(19),
    //画质增强（默认0.0，关闭）
    PFBeautyFiterTypeFaceH_qualityStrength(20),
    //滤镜类型（默认 origin，原图）
    PFBeautyFiterName(21),
    // 2D贴纸 
    PFBeautyFiterSticker2DFilter(24),
    // 一键美颜
    PFBeautyFiterTypeOneKey(25),
    // 扩展字段
    PFBeautyFiterExtend(26),
}
```







