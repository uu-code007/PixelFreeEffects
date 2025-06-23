# pixelFree 美颜SDK使用文档 

#### iOS 接入方式

1. 手动接入

   Demo 工程中有子工程 sdk-aar 拖入到你的项目中，并引用

2. Maven 导入

   ```
   implementation 'io.github.uu-code007:lib_pixelFree:2.4.9'
   ```


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
   mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterTypeFace_EyeStrength,0.5f); 
   
   // 瘦脸
   mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterTypeFace_thinning,0.5f); 
   
   ···
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

#### processWithBuffer 详细使用说明

`processWithBuffer` 是美颜SDK的核心处理方法，用于对输入图像进行美颜处理。该方法需要传入一个 `PFImageInput` 对象，包含图像的所有必要信息。

##### PFImageInput 参数详解

```kotlin
val pxInput = PFImageInput().apply {
    // 图像尺寸
    wigth = frame.width          // 图像宽度
    height = frame.height        // 图像高度
    
    // 图像数据指针（根据format格式设置）
    p_data0 = frame.data         // 主要数据通道（Y或RGBA）
    p_data1 = frame.data         // 第二数据通道（UV或null）
    p_data2 = frame.data         // 第三数据通道（通常为null）
    
    // 每行字节数
    stride_0 = frame.rowStride   // 第一通道行步长
    stride_1 = frame.rowStride   // 第二通道行步长
    stride_2 = frame.rowStride   // 第三通道行步长
    
    // 图像格式
    format = PFDetectFormat.PFFORMAT_IMAGE_RGBA  // 图像格式
    
    // 旋转模式
    rotationMode = PFRotationMode.PFRotationMode90  // 图像旋转
    
    // 纹理ID（纹理模式下使用）
    textureID = 0  // OpenGL纹理ID，buffer模式下为0
}
```

##### 支持的图像格式

```kotlin
enum class PFDetectFormat(val intType: Int) {
    PFFORMAT_UNKNOWN(0),           // 未知格式
    PFFORMAT_IMAGE_RGB(1),         // RGB格式
    PFFORMAT_IMAGE_BGR(2),         // BGR格式
    PFFORMAT_IMAGE_RGBA(3),        // RGBA格式（推荐）
    PFFORMAT_IMAGE_BGRA(4),        // BGRA格式
    PFFORMAT_IMAGE_ARGB(5),        // ARGB格式
    PFFORMAT_IMAGE_ABGR(6),        // ABGR格式
    PFFORMAT_IMAGE_GRAY(7),        // 灰度图
    PFFORMAT_IMAGE_YUV_NV12(8),    // YUV NV12格式
    PFFORMAT_IMAGE_YUV_NV21(9),    // YUV NV21格式
    PFFORMAT_IMAGE_YUV_I420(10),   // YUV I420格式
    PFFORMAT_IMAGE_TEXTURE(11),    // OpenGL纹理格式
}
```

##### 旋转模式（用于人脸检测方向）

```kotlin
enum class PFRotationMode(val intType: Int) {
    PFRotationMode0(0),    // 0度旋转
    PFRotationMode90(1),   // 90度旋转
    PFRotationMode180(2),  // 180度旋转
    PFRotationMode270(3),  // 270度旋转
}
```

##### 使用示例

**1. RGBA格式图像处理（推荐）**

```kotlin
// 摄像头实时处理示例
override fun onProcessFrame(frame: VideoFrame): VideoFrame {
    if (mPixelFree.isCreate()) {
        val pxInput = PFImageInput().apply {
            wigth = frame.width
            height = frame.height
            p_data0 = frame.data
            p_data1 = frame.data
            p_data2 = frame.data
            stride_0 = frame.rowStride
            stride_1 = frame.rowStride
            stride_2 = frame.rowStride
            format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
            rotationMode = PFRotationMode.PFRotationMode90
        }
        
        // 执行美颜处理
        mPixelFree.processWithBuffer(pxInput)
        // 获取处理后的data,源数据会被覆盖，
        pxInput.p_data0;        
    }
    return super.onProcessFrame(frame)
}
```

**2. 静态图像处理**

```kotlin
// 处理Bitmap图像
val pxInput = PFImageInput().apply {
    wigth = bitmap.width
    height = bitmap.height
    p_data0 = rgbaData        // RGBA字节数组
    p_data1 = null
    p_data2 = null
    stride_0 = rowBytes       // 每行字节数 = width * 4
    stride_1 = 0
    stride_2 = 0
    textureID = 0
    format = PFDetectFormat.PFFORMAT_IMAGE_RGBA
    rotationMode = PFRotationMode.PFRotationMode0
}

mPixelFree.processWithBuffer(pxInput)

// 获取处理后的data,源数据会被覆盖，
   pxInput.p_data0; 
```

**3. YUV格式处理**

```kotlin
// YUV NV21格式处理
val pxInput = PFImageInput().apply {
    wigth = width
    height = height
    
    // YUV数据分离
    val ySize = width * height
    val uvSize = width * height / 2
    val yData = ByteArray(ySize)
    val uvData = ByteArray(uvSize)
    
    System.arraycopy(yuvData, 0, yData, 0, ySize)
    System.arraycopy(yuvData, ySize, uvData, 0, uvSize)
    
    p_data0 = yData
    p_data1 = uvData
    p_data2 = null
    stride_0 = width
    stride_1 = width
    stride_2 = 0
    format = PFDetectFormat.PFFORMAT_IMAGE_YUV_NV21
    rotationMode = PFRotationMode.PFRotationMode90
}

mPixelFree.processWithBuffer(pxInput)
// 获取处理后的data,源数据会被覆盖，
pxInput.p_data0;
pxInput.p_data1;
```

**4. OpenGL纹理处理**

```kotlin
// 纹理模式处理
val pxInput = PFImageInput().apply {
    wigth = width
    height = height
    p_data0 = null
    p_data1 = null
    p_data2 = null
    stride_0 = 0
    stride_1 = 0
    stride_2 = 0
    format = PFDetectFormat.PFFORMAT_IMAGE_TEXTURE
    rotationMode = PFRotationMode.PFRotationMode0
    textureID = inputTextureID  // 输入纹理ID
}

mPixelFree.processWithBuffer(pxInput)
val outputTextureID = pxInput.textureID  // 输出纹理ID
```

##### 注意事项

1. **数据格式匹配**：确保 `format` 与实际的图像数据格式一致
2. **内存管理**：处理过程中SDK会修改输入数据，注意数据备份
3. **OpenGL上下文**：纹理模式需要在正确的OpenGL上下文中调用
4. **性能优化**：建议在子线程中处理，避免阻塞UI线程
5. **错误处理**：检查 `mPixelFree.isCreate()` 确保SDK已正确初始化

##### 返回值说明

`processWithBuffer` 方法执行后，`pxInput.textureID` 会被设置为处理后的OpenGL纹理ID，可用于后续渲染显示。

   

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







