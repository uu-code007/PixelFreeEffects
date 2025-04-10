/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import Logger from '../utils/Logger';
import CommonConstants from '../common/constants/CommonConstants';
import { Size } from '@ohos/hypium';
import { ArrayList } from '@kit.ArkTS';

const TAG: string = '[CameraModel]';

export default class Camera {
  private cameraDevice: camera.CameraDevice | undefined = undefined;
  private capability: camera.CameraOutputCapability | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private receiver: image.ImageReceiver | undefined = undefined;
  private imageReceiverOutput: camera.PreviewOutput | undefined = undefined;
  private captureSession: camera.VideoSession | undefined = undefined;
  private sceneMode: camera.SceneMode | undefined = undefined;
  private previewProfile: camera.Profile | undefined = undefined;
  captureOutputDidOutputImage?: (image: image.Image) => void

  private get cameraManager(): camera.CameraManager {
    return this._cameraManger()
  }

  private get cameraDevices(): Array<camera.CameraDevice> {
    return this._cameraDevices()
  }

  async initCamera(cameraPosition: camera.CameraPosition, resolution: camera.Size): Promise<void> {
    let cameraArray = this.cameraDevices
    for (let index = 0; index < cameraArray.length; index++) {
      let cameraDevice = cameraArray[index]
      console.log(`@mahaomeng camera device ${JSON.stringify(cameraDevice.cameraPosition)}, ${JSON.stringify(cameraDevice.cameraType)}`)
      if (cameraDevice.cameraPosition == cameraPosition) {
        this.cameraDevice = cameraDevice
        break
      }
    }
    if (!this.cameraDevice) {
      this.cameraDevice = cameraArray[CommonConstants.INPUT_DEVICE_INDEX];
    }
    let sceneMode = this.cameraManager.getSupportedSceneModes(this.cameraDevice);
    sceneMode.forEach((value, index, sceneMode) => {
      console.log(TAG, `camera suppord sceneMode mode : ${value} index ${index}`)
    })
    this.sceneMode = sceneMode[1]
    this.capability = this.cameraManager.getSupportedOutputCapability(this.cameraDevice, this.sceneMode);
    let previewProfiles = this.capability.previewProfiles

    for (let i = 0; i < previewProfiles.length; i++) {
      const previewProfile = previewProfiles[i]
      // console.log(`@mahaomeng resolution ${JSON.stringify(previewProfile)}`)
      if (previewProfile.size.width == resolution.width && previewProfile.size.height == resolution.height) {
        this.previewProfile = previewProfile
        break
      }
    }

    this.cameraInput = this.getCameraInput(this.cameraDevice, this.cameraManager) as camera.CameraInput;
    await this.cameraInput.open();

    // Photo output stream
    this.receiver = image.createImageReceiver(resolution, 4, 8);
    let imageReceiverId = await this.getImageReceiverSurfaceId(this.receiver)
    this.imageReceiverOutput = this.cameraManager.createPreviewOutput(this.previewProfile, imageReceiverId);
    this.receiver!.on('imageArrival', () => {
      // Logger.info(TAG, 'imageArrival');
      this.receiver!.readNextImage((err: BusinessError, nextImage: image.Image) => {
        if (err || nextImage === undefined) {
          console.error('readNextImage failed');
          return;
        }
        if (this.captureOutputDidOutputImage !== undefined) {
          this.captureOutputDidOutputImage(nextImage)
        } else {

        }
      })
    })

    // Session Init
    this.captureSession = this.getCaptureSession(this.cameraManager) as camera.VideoSession;
    this.beginConfig(this.captureSession)
    this.startSession(this.captureSession, this.cameraInput)
  }

  beforeChange(): Promise<void> {
    return new Promise((exc, ero) => {
      this.receiver?.release().then(() => {
        this.captureSession?.release().then(() => {
          exc()
        }).catch((error: BusinessError) => {
          ero(error)
        })
      }).catch((error: BusinessError) => {
        ero(error)
      })
    })
  }

  stop() {
    if (this.captureSession) {
      this.captureSession.stop();
    }
  }

  async releaseCamera(): Promise<void> {
    if (this.cameraInput) {
      await this.cameraInput.close();
      Logger.info(TAG, 'cameraInput release');
    }

    if (this.receiver) {
      await this.receiver.release();
      Logger.info(TAG, 'receiver release');
    }
    if (this.captureSession) {
      await this.captureSession.release();
      Logger.info(TAG, 'captureSession release');
      this.captureSession = undefined;
    }
  }

  getCameraDevices(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
    let cameraArray: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    if (cameraArray != undefined && cameraArray.length > 0) {
      return cameraArray;
    } else {
      Logger.error(TAG, `getSupportedCameras faild`);
      return [];
    }
  }

  getCameraInput(cameraDevice: camera.CameraDevice, cameraManager: camera.CameraManager): camera.CameraInput | undefined {
    let cameraInput: camera.CameraInput | undefined = undefined;
    cameraInput = cameraManager.createCameraInput(cameraDevice);
    cameraInput.on('error', cameraDevice, (e) => {
      console.log(TAG, `create input error ${JSON.stringify(e)}`)
    });
    return cameraInput;
  }

  async getImageReceiverSurfaceId(receiver: image.ImageReceiver | undefined = undefined): Promise<string | undefined> {
    let photoSurfaceId: string | undefined = undefined;
    if (receiver !== undefined) {
      photoSurfaceId = await receiver.getReceivingSurfaceId();
      Logger.info(TAG, `getReceivingSurfaceId success`);
    }
    return photoSurfaceId;
  }

  getCaptureSession(cameraManager: camera.CameraManager): camera.Session | undefined {
    let captureSession: camera.Session | undefined = undefined;
    try {
      captureSession = cameraManager.createSession(this.sceneMode);
    } catch (error) {
      Logger.error(TAG, `Failed to create the CaptureSession instance. error: ${JSON.stringify(error as BusinessError)}`);
    }
    return captureSession;
  }

  beginConfig(captureSession: camera.Session): void {
    try {
      captureSession.beginConfig();
    } catch (error) {
      Logger.error(TAG, `Failed to beginConfig. error: ${JSON.stringify(error as BusinessError)}`);
    }
  }

  async startSession(captureSession: camera.VideoSession, cameraInput: camera.CameraInput | undefined): Promise<void> {
    captureSession.addInput(cameraInput)
    captureSession.addOutput(this.imageReceiverOutput)
    await captureSession.commitConfig()
    await captureSession.start()
  }

  private _cameraManger = (() => {
    let manager: camera.CameraManager
    return () => {
      if (!manager) {
        manager = camera.getCameraManager(getContext())
      }
      return manager
    }
  })()
  private _cameraDevices = (() => {
    let devices: Array<camera.CameraDevice>
    return () => {
      if (!devices) {
        devices = this.cameraManager.getSupportedCameras()
      }
      return devices
    }
  })()
}