import Camera from '../camera/Camera'
import { common } from '@kit.AbilityKit';
import PermissionManager from "../utils/Permission"
import XComponentContext from '../interface/XComponentContext';
import { CommonConstant as Common } from '../common/CommonConstant';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI'
import libpixelfree from 'libentry.so'
import { PFRotationMode,PFBeautyFitlerType} from 'libentry.so'
import { promptAction } from '@kit.ArkUI'

import { FilterPanel } from '../panels/FilterPanel'
import sensor from "@ohos.sensor"
import { camera } from '@kit.CameraKit';
import { FilterModel } from '../model/FilterModel';


const context = getContext(this) as common.UIAbilityContext;
const filesDir = context.filesDir
const resourceManager = context.resourceManager

let TAG: string = "CameraPreview"

enum PixelFormat {
  RGBA = 0,
  YUV = 1
}

enum Resolution {
  r1920x1080 = 0,
  r1280x720 = 1
}

@Entry
@Component
struct CameraPreview {
  @State private cameraInstance: Camera = new Camera();
  @State photoAspectRatio: number = 1080.0 / 1920.0
  private flag: boolean = false
  private comparing: boolean = false
  private outputArrayBuffer: ArrayBuffer | undefined
  private cnt = 0
  private lastTime = 0
  private selectedPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT
  private resolutions: Array<camera.Size> = [{ width: 1920, height: 1080 }, { width: 1280, height: 720 }]
  private selectedResolution: Resolution = Resolution.r1280x720
  @State filterPanelVisibility: boolean = true
  @State resolutionResource: Resource = $r('app.media.preview_resolution_720')

  private curOneKey:number = 0;


  build() {
    Stack() {
      Row() {
        Column() {
          Row() {
            Blank()
              .flexGrow(1)

            Image(this.resolutionResource)
              .focusable(true)
              .focusOnTouch(true)
              .width(30)
              .height(30)
              .margin({ right: 10 })
              .onClick(() => {
                this.cameraInstance.beforeChange().then(() => {
                  this.selectedResolution =
                    this.selectedResolution == Resolution.r1920x1080 ? Resolution.r1280x720 : Resolution.r1920x1080
                  this.resolutionResource =
                    this.selectedResolution == Resolution.r1920x1080 ? $r('app.media.preview_resolution_1080') :
                    $r('app.media.preview_resolution_720')
                  const resolution = this.resolutions[this.selectedResolution]
                  this.photoAspectRatio = resolution.height / resolution.width
                  this.initCamera(this.selectedPosition, resolution)
                }).catch((error: BusinessError) => {
                  console.log(`@mahaomeng testStop ${error}`)
                })
              })

            Blank()
              .width(50)

            Image($r('app.media.preview_flip'))
              .focusable(true)
              .focusOnTouch(true)
              .width(23)
              .height(23)
              .margin({ right: 10 })
              .onClick(() => {
                this.cameraInstance.beforeChange().then(() => {
                  this.selectedPosition = this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_BACK ?
                  camera.CameraPosition.CAMERA_POSITION_FRONT : camera.CameraPosition.CAMERA_POSITION_BACK
                  this.initCamera(this.selectedPosition, this.resolutions[this.selectedResolution])
                }).catch((error: BusinessError) => {
                  console.log(`@mahaomeng testStop ${error}`)
                })
              })
          }
          .width('100%')
          .height(44)
          .backgroundColor(Color.White)

          Stack({ alignContent: Alignment.Top }) {
            XComponent({
              id: Common.XCOMPONENT_ID,
              type: XComponentType.TEXTURE,
              libraryname: Common.LIBRARY_NAME,
            })
              .width('100%')
              .aspectRatio(this.photoAspectRatio)
          }
        }
        .width('100%')
      }
      .height('100%')

      Column() {
        Row() {
          Blank()
            .flexGrow(1)
          Image($r('app.media.comparison'))
            .width(30)
            .height(30)
            .onTouch((event) => {
              if (event.type == TouchType.Down) {
                this.comparing = true
              } else if (event.type == TouchType.Up) {
                this.comparing = false
              }
            })
            .margin({ right: 10 })
        }
        .width('100%')

        Blank()
          .height(220)
      }

      if (this.filterPanelVisibility){
        FilterPanel({
          onFilterSelected: (filter: FilterModel,currentCategory: number ) => {
            if (currentCategory === 0){//一键美颜
              const result = libpixelfree.setBeautyOnekeyFilter(filter.value_type);
              this.curOneKey = filter.value_type!;
            } else {
              if (this.curOneKey != 0) {
                const result = libpixelfree.setBeautyOnekeyFilter(0);
                promptAction.showToast({ message: '已关闭一键美颜', duration: 1000 })
              }
            }

            if (currentCategory === 1 || currentCategory === 2){//
              const result = libpixelfree.setBeautyStrength(filter.value_type,filter.value);
            }

            if (currentCategory === 3){//滤镜
              const result = libpixelfree.setBeautyFilter(filter.value_str,filter.value);
            }
          },
          onFilterStrengthChanged: (filter: FilterModel, currentCategory: number) => {
            if (currentCategory === 1 || currentCategory === 2){//
              const result = libpixelfree.setBeautyStrength(filter.value_type,filter.value);
            }
            if (currentCategory === 3){//滤镜
              const result = libpixelfree.setBeautyFilter(filter.value_str,filter.value);
            }
          },
          onFilterClose: () => {
            this.filterPanelVisibility = false
          }
        })
          .height(180)
          .width('100%')
          .opacity(0.9)
      }
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
  }


  async initCamera(cameraPosition: camera.CameraPosition, resolution: camera.Size) {
    await this.cameraInstance.initCamera(cameraPosition, resolution)
    this.cameraInstance.captureOutputDidOutputImage = (nextImage: image.Image) => {
      this.cnt++
      if (this.lastTime == 0) {
        this.lastTime = Date.now()
      } else {
        let currentTime = Date.now()
        let delta = currentTime - this.lastTime
        if (delta >= 1000) {
          // console.log(`fps is: ${this.cnt / delta * 1000.0}`)
          this.lastTime = currentTime
          this.cnt = 0
        }
      }
      if (!this.flag) {
        nextImage.getComponent(4, (err: BusinessError, imgComponent: image.Component) => {
          if (err || imgComponent === undefined) {
            nextImage.release();
            return;
          }
          let buffer: ArrayBuffer;
          if (imgComponent.byteBuffer as ArrayBuffer) {
            buffer = imgComponent.byteBuffer
            let width = nextImage.size.width
            let height = nextImage.size.height
            let rotate =
              (this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_FRONT) ? PFRotationMode.PFRotationMode270 :
              PFRotationMode.PFRotationMode90
            let mirror = (this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_FRONT) ? 1 : 0
            let stride = (rotate == PFRotationMode.PFRotationMode90 || rotate == PFRotationMode.PFRotationMode270) ? height : width
            if (this.outputArrayBuffer === undefined ||
                this.outputArrayBuffer.byteLength != nextImage.size.width * nextImage.size.height * 4){
              this.outputArrayBuffer = new ArrayBuffer(nextImage.size.width * nextImage.size.height * 4)
            }
            if (this.comparing) {
              libpixelfree.streamDetectProcessAndRenderBuffer(buffer, 1, width, height, stride, rotate, mirror,
                this.outputArrayBuffer, false)
            } else {
              libpixelfree.streamDetectProcessAndRenderBuffer(buffer, 1, width, height, stride, rotate, mirror,
                this.outputArrayBuffer, true)
            }
            nextImage.release();
          } else {
            nextImage.release();
            return;
          }
        });
      } else {
        nextImage.release();
      }
    }
  }

  uint8ArrayToArrayBuffer(uint8Array: Uint8Array) {
    let arrayBuffer = new ArrayBuffer(uint8Array.length);
    let bufferView = new Uint8Array(arrayBuffer);
    bufferView.set(uint8Array);
    return arrayBuffer;
  }

  myAsyncFunction(pixelBuffer: Uint8Array, width: number, height: number): Promise<void> {
    return new Promise((resolve: Function) => {
      for (let index = 0; index < width * height * 4; index += 4) {
        let temp = pixelBuffer[index];
        pixelBuffer[index] = pixelBuffer[index+2];
        pixelBuffer[index+2] = temp;
      }
      image.createPixelMap(this.uint8ArrayToArrayBuffer(pixelBuffer), {
        size: { width, height },
        pixelFormat: image.PixelMapFormat.RGBA_8888,
        editable: true
      }).then((pixelMap) => {
        pixelMap.rotate(this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_FRONT ? 270 : 90).then(() => {
          pixelMap.flip(this.selectedPosition == camera.CameraPosition.CAMERA_POSITION_FRONT, false).then(() => {
          }).catch((error: BusinessError) => {
            console.log(`@mahaoemng ${error}}`)
          })
        }).catch((error: BusinessError) => {
          console.log(`@mahaoemng ${error}}`)
        })
      }).catch((error: BusinessError) => {
        console.log(`@mahaomeng createPixelMap error ${error}`)
      })
    });
  }

  async onPageShow() {
    PermissionManager.requestPermissions(['ohos.permission.CAMERA']).then((permission) => {
      if (permission) {
        this.initCamera(this.selectedPosition, this.resolutions[this.selectedResolution]);
      }
    })
  }

  onPageHide(): void {
    this.cameraInstance.stop()
  }

  aboutToAppear(): void {
    let pixelfreeLic = resourceManager.getRawFileContentSync('pixelfree/pixelfreeAuth.lic')
    const pixelfreeLicBuffer = pixelfreeLic.buffer.slice(0);

    let filterBundle = resourceManager.getRawFileContentSync('pixelfree/filter_model.bundle')
    const filterBundleBuffer = filterBundle.buffer.slice(0);
    const result = libpixelfree.initPixelFree(pixelfreeLicBuffer, filterBundleBuffer);
  }

  aboutToDisappear() {
    console.log(`@mahaomeng aboutToDisappear`);
    this.flag = true
    this.cameraInstance.beforeChange()
    // libstmobile.destroyHandle()
  }

  showDialog(message: string) {
    promptAction.showDialog({
      message: message,
      buttons: [
        {
          text: '好的',
          color: '#000000'
        }
      ],
    })
      .then(data => {
        console.info('showDialog success, click button: ' + data.index);
      })
  }



  getDeviceOrientation(): Promise<number> {
    return new Promise((resolve: Function, reject: Function) => {
      let orientation = 3
      sensor.once(sensor.SensorId.ORIENTATION, (data: sensor.OrientationResponse) => {
        if (data.gamma >= 70) {
          // console.log(`@mahaomeng rotation is: 270`)
          orientation = 2
        } else if (data.gamma <= -70) {
          // console.log(`@mahaomeng rotation is: 90`)
          orientation = 0
        } else if (data.gamma <= 10 && data.gamma >= -10) {
          if (data.beta >= 70) {
            // console.log(`@mahaomeng rotation is: 180`)
            orientation = 1
          } else if (data.beta <= -70) {
            // console.log(`@mahaomeng rotation is: 0`)
            orientation = 3
          }
        }
        resolve(orientation)
      })
    })
  }
}
