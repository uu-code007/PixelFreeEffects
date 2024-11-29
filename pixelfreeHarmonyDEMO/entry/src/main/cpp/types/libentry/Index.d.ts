
export const enum PFDetectFormat {
  PFFORMAT_UNKNOWN = 0,
  PFFORMAT_IMAGE_RGB = 1,
  PFFORMAT_IMAGE_BGR = 2,
  PFFORMAT_IMAGE_RGBA = 3,
  PFFORMAT_IMAGE_BGRA = 4,
  PFFORMAT_IMAGE_ARGB = 5,
  PFFORMAT_IMAGE_ABGR = 6,
  PFFORMAT_IMAGE_GRAY = 7,
  PFFORMAT_IMAGE_YUV_NV12 = 8,
  PFFORMAT_IMAGE_YUV_NV21 = 9,
  PFFORMAT_IMAGE_YUV_I420 = 10,
  PFFORMAT_IMAGE_TEXTURE = 11,
}

export const  enum PFRotationMode {
  PFRotationMode0 = 0,
  PFRotationMode90 = 1,
  PFRotationMode180 = 2,
  PFRotationMode270 = 3,
}

export const  enum PFSrcType {
  PFSrcTypeFilter = 0,
  PFSrcTypeAuthFile = 2,
  PFSrcTypeStickerFile = 3,
}

export interface PFDetectPath {
  modelPath: string;
  runCachePath: string;
}

export interface PFIamgeInput {
  textureID: number;
  width: number;
  height: number;
  p_data0: Float32Array | Uint8Array; // Y or RGBA
  p_data1?: Float32Array | Uint8Array; // Optional for additional data
  p_data2?: Float32Array | Uint8Array; // Optional for additional data
  stride_0: number;
  stride_1?: number; // Optional
  stride_2?: number; // Optional
  format: PFDetectFormat;
  rotationMode: PFRotationMode;
}

export interface PFFiter {
  imagePath: string;
}

export interface PFFiterLvmuSetting {
  isOpenLvmu: boolean;
  isVideo: boolean;
  bgSrcPath: string;
}

export interface PFFiterWatermark {
  isUse: boolean;
  path: string;
  positionX: number; // 0-1.0
  positionY: number; // 0-1.0
  w: number; // 0-1.0
  h: number; // 0-1.0
  isMirror: boolean;
}

export const enum PFBeautyFitlerType {
  PFBeautyFilterTypeFace_EyeStrength = 0,
  PFBeautyFitlerTypeFace_thinning,
  PFBeautyFitlerTypeFace_narrow,
  PFBeautyFitlerTypeFace_chin,
  PFBeautyFitlerTypeFace_V,
  PFBeautyFitlerTypeFace_small,
  PFBeautyFitlerTypeFace_nose,
  PFBeautyFitlerTypeFace_forehead,
  PFBeautyFitlerTypeFace_mouth,
  PFBeautyFitlerTypeFace_philtrum,
  PFBeautyFitlerTypeFace_long_nose = 10,
  PFBeautyFitlerTypeFace_eye_space,
  PFBeautyFitlerTypeFace_smile,
  PFBeautyFitlerTypeFace_eye_rotate,
  PFBeautyFitlerTypeFace_canthus,
  PFBeautyFitlerTypeFaceBlurStrength,
  PFBeautyFitlerTypeFaceWhitenStrength,
  PFBeautyFitlerTypeFaceRuddyStrength,
  PFBeautyFitlerTypeFaceSharpenStrength,
  PFBeautyFitlerTypeFaceM_newWhitenStrength,
  PFBeautyFitlerTypeFaceH_qualityStrength,
  PFBeautyFitlerName,
  PFBeautyFitlerStrength,
  PFBeautyFitlerLvmu,
  PFBeautyFitlerSticker2DFilter,
  PFBeautyFitlerTypeOneKey = 25,
  PFBeautyFitlerWatermark,
  PFBeautyFitlerExtend,
}

export const  enum PFBeautyTypeOneKey {
  PFBeautyTypeOneKeyNormal = 0,
  PFBeautyTypeOneKeyNatural,
  PFBeautyTypeOneKeyCute,
  PFBeautyTypeOneKeyGoddess,
  PFBeautyTypeOneKeyFair,
}

export const initPixelFree:(lic: ArrayBuffer, filter_bundle: ArrayBuffer) => number
export const destroyPixelFree:() => number
// 处理
export const streamDetectProcessAndRenderBuffer: (inputBuffer: ArrayBuffer,
                                                  format: number,
                                                  width: number,
                                                  height: number,
                                                  stride: number,
                                                  rotate: PFRotationMode,
                                                  mirror: number,
                                                  outputBuffer: ArrayBuffer,
                                                  isRecording: boolean) => number

export const setBeautyFilter:(name: string, strength: number) => number

export const setBeautyStrength:(param: PFBeautyFitlerType, strength: number) => number
export const setBeautySticker:(buffer: ArrayBuffer) => number

export const setBeautyOnekeyFilter:(type: number) => number




