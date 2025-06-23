# pixelFree 接入问题排查


####  控制台打印日志查看

1. **[PixelFree] 过滤日志，查看初始化是否有报错**

   ```kotlin
   [PixelFree] will init SMPixelFree
   [PixelFree] CFBundleGetBundleWithIdentifier(CFSTR(com.apple.opengles))[PixelFree], GLLoader is missing glBlendEquationEXT
   [PixelFree], GLLoader is missing glUseShaderProgramEXT
   [PixelFree], GLLoader is missing glActiveProgramEXT
   [PixelFree], GLLoader is missing glCreateShaderProgramEXT
   [PixelFree], GLLoader is missing glTexStorage1DEXT
   [PixelFree], GLLoader is missing glTexStorage3DEXT
   [PixelFree], GLLoader is missing glTextureStorage1DEXT
   [PixelFree], GLLoader is missing glTextureStorage2DEXT
   [PixelFree], GLLoader is missing glTextureStorage3DEXT
   [PixelFree] version major:2 minor:0
   [PixelFree] init success
   [PixelFree] Decoding resources succeeded
   [PixelFree] new mPFDetectProcessorModel = 0x10324c000
   [PixelFree] FiterParamkey--8192---vlaue--com.mumu.SMBeautyEngine.cn......
   [PixelFree] Decoding resources succeeded
   [PixelFree] will bundle config json
   [PixelFree] did bundle config json
   [PixelFree] FiterParamkey--8193---vlaue--18318113774362070305734656.000000......
    
   ```

2. **[PixelFree] 过滤日志，查看设置 SDK 的美颜参数是否符合预期， --<u>枚举类型</u>---value--<u>参数值</u>**

   ```kotlin
   [PixelFree] FiterParamkey--0---vlaue--0.200000......
   [PixelFree] FiterParamkey--1---vlaue--0.200000......
   [PixelFree] FiterParamkey--2---vlaue--0.200000......
   [PixelFree] FiterParamkey--3---vlaue--0.500000......
   ```

3. **问题1，接入正常美颜没有效果**

   ```kotlin
   1. 单纹理模式需要依赖，原纹理 gl 上下文，mPixelFree.create() 需要放在此上下文，参考如下
          public int onTextureCustomProcess(int i, int i1, int i2) {
                   PFIamgeInput pxInput = new PFIamgeInput();
                   int texId = i;
                   if (mPixelFree.isCreate()) {
                       // 处理
                     mPixelFree.processWithBuffer(pxInput);
                   } else {
                       // 授权
                       mPixelFree.create();
                   }
          }
   
   ```

4. **问题2，美肤和滤镜有效果，美型没有效果**

   ```kotlin
   美型依赖人脸检测，可以改变检测方向
   pxInput.setRotationMode(PFRotationMode.PFRotationMode0);
   ```

   

5. **问题3，美颜处理后噪点问题**

   ```
   磨皮减低高频部分，锐化和增强，会增加高频；稍加些锐化设置可使画质清晰，修复磨皮导致的质感降低；当原图噪点多，并锐化开启过大，会使得图片有噪点感觉。锐化和增强针对当前图片质量，自行调节
   ```

   







