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
/**
 * Common constants for all features.
 */
export default class CommonConstants {
  /**
   * The size of arraybuffer size.
   */
  static readonly ARRAYBUFFER_SIZE: number = 4069;
  /**
   * The device outputs the sequence number.
   */
  static readonly OUTPUT_DEVICE_INDEX: number = 0;
  /**
   * The device inputs the sequence number.
   */
  static readonly INPUT_DEVICE_INDEX: number = 0;
  /**
   * The width of the image receiving stream.
   */
  static readonly IMAGE_RECEIVER_WIDTH: number = 640;
  /**
   * The height of the image receiving stream.
   */
  static readonly IMAGE_RECEIVER_HEIGHT: number = 480;
  /**
   * The capacity of the image receiving stream.
   */
  static readonly IMAGE_RECEIVER_CAPACITY: number = 8;
  /**
   * The size of full width.
   */
  static readonly FULL_WIDTH: string = "100%";
  /**
   * The size of full height.
   */
  static readonly FULL_Height: string = "100%";
  /**
   * The true number.
   */
  static readonly TRUE_NUMBER: number = 1;
  /**
   * The false number.
   */
  static readonly FALSE_NUMBER: number = 0;
  /**
   * The width of surface.
   */
  static readonly SURFACE_WIDTH: number = 190;
  /**
   * The height of surface.
   */
  static readonly SURFACE_HEIGHT: number = 100;
  /**
   * The type of xcomponent.
   */
  static readonly XCOMPONENT_TYPE: string = 'surface';
  /**
   * The id of xcomponent.
   */
  static readonly XCOMPONENT_ID: string = 'xcomponent1';
  /**
   * The height expect xcomponent.
   */
  static readonly OTHER_HEIGHT: number = 264;
  /**
   * The width of dialog_block.
   */
  static readonly DIALOG_WIDTH: string = "93%";
  /**
   * The color of dialog_mask.
   */
  static readonly DIALOG_TEXT_MASK_COLOR: string = "rgba(0, 0, 0, 0.2)";
  /**
   * The weight of bold font.
   */
  static readonly FONT_WEIGHT: number = 500;
}