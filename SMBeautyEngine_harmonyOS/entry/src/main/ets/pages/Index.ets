import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = '相机';

  onPageShow(): void {
    router.pushUrl({
      url: "pages/CameraPreview" // 目标url
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke pushUrl succeeded.');
    });
  }
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            router.pushUrl({
              url: "pages/CameraPreview" // 目标url
            }, router.RouterMode.Standard, (err) => {
              if (err) {
                console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke pushUrl succeeded.');
            });
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
