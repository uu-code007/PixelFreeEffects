# pixelFree 美颜SDK使用文档 

#### adroid 接入方式

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
   mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterTypeFace_EyeStrength, 0.5f)
   
   // 瘦脸
   mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterTypeFace_thinning, 0.5f)
   
   // 美牙
   mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFilterWhitenTeeth, 0.5f)

   // AI 祛瑕疵
   mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFilterFleckFlawClean, 0.6f)
   
   // 更多参数设置...
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

5. 美妆功能使用（可选）

   ```kotlin
   // 方式一：通过 bundle 文件加载美妆（推荐）
   val makeupData = mPixelFree.readBundleFile(this@MainActivity, "makeup/makeup_name.bundle")
   mPixelFree.createBeautyItemFormBundle(makeupData, makeupData.size, PFSrcType.PFSrcTypeMakeup)
   
   // 方式二：通过 JSON 配置文件加载美妆 （废弃）
   mPixelFree.setMakeupPath("makeup/makeup_config.json")
   
   // 设置美妆部位程度（可选，与配置叠乘）
   mPixelFree.setMakeupPartDegree(PFMakeupPart.PFMakeupPartLip, 0.8f)
   
   // 清除美妆
   mPixelFree.clearMakeup()
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
    //亮眼（默认0.0，关闭）
    PFBeautyFiterTypeFaceEyeBrighten(21),
    //滤镜类型（默认 origin，原图）
    PFBeautyFiterName(22),
    //滤镜强度
    PFBeautyFiterStrength(23),
    // 2D贴纸 
    PFBeautyFiterSticker2DFilter(24),
    // 一键美颜
    PFBeautyFiterTypeOneKey(25),
    // 扩展字段
    PFBeautyFiterExtend(26),
    // 祛法令纹（默认0.0，关闭）
    PFBeautyFilterNasolabial(27),
    // 祛黑眼圈（默认0.0，关闭）
    PFBeautyFilterBlackEye(28),
    // 美牙（默认0.0，关闭）
    PFBeautyFilterWhitenTeeth(29),
    // AI 祛瑕疵（默认0.0，关闭；v2.5.07+）
    PFBeautyFilterFleckFlawClean(48),
}
```

## 💄 美妆功能说明

### 美妆部位类型

美妆支持以下部位，可通过 `setMakeupPartDegree` 方法单独调节：

- **眉毛** (`PFMakeupPart.PFMakeupPartBrow`): 调节眉毛颜色和形状
- **腮红** (`PFMakeupPart.PFMakeupPartBlusher`): 调节腮红颜色和强度
- **眼影** (`PFMakeupPart.PFMakeupPartEyeShadow`): 调节眼影颜色和效果
- **眼线** (`PFMakeupPart.PFMakeupPartEyeLiner`): 调节眼线粗细和颜色
- **睫毛** (`PFMakeupPart.PFMakeupPartEyeLash`): 调节睫毛长度和浓密程度
- **唇彩** (`PFMakeupPart.PFMakeupPartLip`): 调节唇色和光泽度
- **高光** (`PFMakeupPart.PFMakeupPartHighlight`): 调节高光位置和强度
- **阴影** (`PFMakeupPart.PFMakeupPartShadow`): 调节阴影位置和强度
- **粉底** (`PFMakeupPart.PFMakeupPartFoundation`): 调节粉底颜色和遮瑕度

### 美妆加载方式

1. **Bundle 方式**：推荐使用，性能更好
   - 将美妆资源打包为 `.bundle` 文件
   - 使用 `createBeautyItemFormBundle` 加载，类型为 `PFSrcType.PFSrcTypeMakeup`

2. **JSON 配置方式**：适合动态配置
   - 使用 JSON 文件配置美妆参数
   - 使用 `setMakeupPath` 加载

### 美妆程度调节

- 程度值范围：0.0 ~ 1.0
- 与配置中的程度值叠乘，例如：配置中为 0.5，设置 degree 为 0.8，最终效果为 0.5 × 0.8 = 0.4
- 可在加载美妆后随时调节各部位程度
- 支持批量设置所有部位程度

### 使用建议

1. **性能优化**
   - 建议使用 bundle 方式加载美妆，性能更优
   - 美妆资源文件较大，注意内存管理
   - 切换美妆前建议先调用 `clearMakeup` 清除之前的美妆效果

2. **资源管理**
   - 美妆 bundle 文件通常较大，建议按需加载
   - 及时释放不需要的美妆资源

3. **用户体验**
   - 提供美妆预览功能，让用户选择合适的美妆效果
   - 支持美妆部位独立调节，提供更灵活的个性化选项





