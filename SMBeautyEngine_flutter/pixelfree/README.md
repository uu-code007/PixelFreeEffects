# PixelFree Flutter Plugin

A Flutter plugin for image and video processing with beauty filters, color grading, and HLS filters.

## Features

- Beauty filters (face thinning, eye enlargement, etc.)
- Color grading
- HLS (Hue, Lightness, Saturation) filters
- Image and video processing
- Support for both Android and iOS platforms

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pixelfree: ^2.4.18
```

## Usage

### Initialization

```dart
import 'package:pixelfree/pixelfree.dart';

final pixelfree = Pixelfree();

// Initialize with license
await pixelfree.createWithLic('path/to/license.lic');
```

### Beauty Filters

```dart
// Set beauty filter parameters
await pixelfree.pixelFreeSetBeautyFilterParam(
  PFBeautyFiterType.faceThinning,  // Filter type
  0.5,  // Value (0.0 to 1.0)
);

// Set beauty type parameter
await pixelfree.pixelFreeSetBeautyTypeParam(
  PFBeautyFiterType.typeOneKey,  // Beauty type
  1,  // Value
);
```

### Color Grading

```dart
final params = PFImageColorGrading(
  isUse: true,  // Enable color grading
  brightness: 0.1,  // -1.0 to 1.0
  contrast: 1.2,  // 0.0 to 4.0
  exposure: 0.5,  // -10.0 to 10.0
  highlights: 0.3,  // 0.0 to 1.0
  shadows: 0.2,  // 0.0 to 1.0
  saturation: 1.1,  // 0.0 to 2.0
  temperature: 5500.0,  // Color temperature in Kelvin
  tint: 0.1,  // Tint adjustment
  hue: 180.0,  // 0-360 degrees
);

final result = await pixelfree.pixelFreeSetColorGrading(params);
```

### HLS Filters

```dart
// Add HLS filter
final hlsParams = PFHLSFilterParams(
  keyColor: [1.0, 0.0, 0.0],  // RGB values (0-1)
  hue: 0.0,  // Hue adjustment
  saturation: 1.0,  // Saturation (0-1)
  brightness: 0.0,  // Brightness (0-1)
  similarity: 0.0,  // Similarity threshold
);

final handle = await pixelfree.pixelFreeAddHLSFilter(hlsParams);

// Change HLS filter
await pixelfree.pixelFreeChangeHLSFilter(handle, hlsParams);

// Delete HLS filter
await pixelfree.pixelFreeDeleteHLSFilter(handle);
```

### Image Processing

```dart
// Process image and get texture ID
final textureId = await pixelfree.processWithImage(
  imageData,  // Uint8List
  width,
  height,
);

// Process image and get byte data
final byteData = await pixelfree.processWithImageToByteData(
  imageData,  // Uint8List
  width,
  height,
);
```

## API Reference

### Beauty Filter Types

```dart
enum PFBeautyFiterType {
  eyeStrength,      // Eye enlargement
  faceThinning,     // Face thinning
  faceNarrow,       // Face narrowing
  faceChin,         // Chin adjustment
  faceV,            // V-face
  faceSmall,        // Small face
  faceNose,         // Nose adjustment
  faceForehead,     // Forehead adjustment
  faceMouth,        // Mouth adjustment
  facePhiltrum,     // Philtrum adjustment
  faceLongNose,     // Long nose adjustment
  faceEyeSpace,     // Eye space adjustment
  faceSmile,        // Smile adjustment
  faceEyeRotate,    // Eye rotation
  faceCanthus,      // Canthus adjustment
  faceBlurStrength, // Skin smoothing
  faceWhitenStrength, // Skin whitening
  faceRuddyStrength,  // Ruddy adjustment
  faceSharpenStrength, // Sharpening
  faceNewWhitenStrength, // New whitening algorithm
  faceQualityStrength,  // Quality enhancement
  faceEyeBrighten,     // Eye brightening
  filterName,          // Filter name
  filterStrength,      // Filter strength
  lvmu,                // Green screen
  sticker2DFilter,     // 2D sticker
  typeOneKey,          // One-key beauty
  watermark,           // Watermark
  extend,              // Extension field
}
```

## Platform Support

- Android: API level 21+
- iOS: iOS 11.0+

## Dependencies

- Android: lib_pixelFree 2.4.18
- iOS: PixelFree.framework

## License

This plugin is proprietary software. All rights reserved.

## Version History

### 2.5.01
- 更新了磨皮锐化算法
- 移除了画质增强，改用锐化
- 增加日志，修复低端 Android 偶现花屏问题

### 2.4.18
- Android SDK updated to v2.4.18
- Added makeup functionality support
  - Set makeup path (`setMakeupPath`)
  - Clear makeup (`clearMakeup`)
  - Set makeup part degree (`setMakeupPartDegree`)
- Added face detection related APIs
  - Get face rectangle (`getFaceRect`)
  - Get face count (`getFaceSize`)
  - Set detect mode (`setDetectMode`)
  - Check if has face (`hasFace`)
- Added version query API (`getVersion`)
- Added log level setting API (`setVLogLevel`)
- Fixed Android API compatibility issues
- Completed Flutter wrappers for all C APIs

### 2.4.14
- Fixed type conversion warnings in Android implementation
- Improved error handling for method calls
- Added parameter validation
- Enhanced type safety for all platform methods

### 2.4.13
- Added HLS filter support
- Improved color grading implementation
- Enhanced error handling

### 2.4.12
- Initial public release
- Basic beauty filter support
- Image processing capabilities

