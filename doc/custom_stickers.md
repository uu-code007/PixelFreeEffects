#### 自定义贴纸配置

##### 文件结构   ([模板](.././SMBeautyEngine_iOS/SMBeautyEngine_iOS/res/baixiaomaohuxu) ./SMBeautyEngine_iOS/res/baixiaomaohuxu)

 如果有需要，请配置贴纸。贴纸相关资源文件存放在stickers目录下，一套贴纸对应一个目录，每套贴纸包含一个config.json文件，其中配置了音效文件名及每个item参数等信息。其结构如下：

```
|--[sticker_1] （贴纸1）
|   |--config.json （贴纸配置文件）
|   |--[item_1]（贴纸序列图文件夹1）
|   |   |--[frame_1]（贴纸序列图1）
|   |   |--[frame_2]（贴纸序列图2）
|   |   |--...
|   |   |--[frame_n]（贴纸序列图n）
|   |--[item_2]（贴纸序列图文件夹2）
|   |--...
|   |--[item_n]（贴纸序列图文件夹n）
|--[sticker_2]（贴纸2）
```



###### config.json

参数名称意义

```
type | 贴纸显示的位置类型（脸部、全屏）
facePos | 贴纸在脸部的位置
scaleWidthOffset | 贴纸宽度缩放系数
scaleHeightOffset | 贴纸高度缩放系数
scaleXOffset | 贴纸在脸部水平方向偏移系数
scaleYOffset | 贴纸在脸部垂直方向偏移系数
alignPos | 边缘item参数
alignX | 边缘水平方向偏移系数
alignY | 边缘垂直方向系数
frameFolder | 贴纸资源目录（包括一组图片序列帧）
frameNum |  帧数（一组序列帧组成一个动画效果）
frameDuration | 每帧的间隔（秒）
frameWidth | 图片的宽
frameHeight | 图片的高
trigerType | 触发条件，默认0，始终显示
```



##### facePos 人脸点位置

```
0) 额头中点
1) 眉毛中点
2) 眼睛中
3) 鼻子中
4) 鼻尖
5) 胡子上沿中点
6) 上嘴唇
7) 下嘴唇
9) 下巴
```



##### 测试

打开 iOS  demo，将编辑好的文件，导入 xcode 添加调用

```
NSString *path =  [[NSBundle mainBundle] pathForResource:@"baixiaomaohuxu" ofType:nil];
[self.mPixelFree  pixelFreeSetFiterStickerWithPath:path];
```

