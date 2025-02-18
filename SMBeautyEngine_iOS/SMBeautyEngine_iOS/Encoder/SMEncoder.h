
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SMVideoConfiguration.h"
#import "SMAudioConfiguration.h"

@class SMEncoder;

@protocol SMEncoderDelegate <NSObject>

/*!
 @method encoder:didStartRecordingToOutputFileAtURL:
 @brief 编码的时候的回调.
 */
- (void)encoder:(SMEncoder *__nonnull)encoder didStartRecordingToOutputFileAtURL:(NSURL *__nonnull)fileURL;

/*!
 @method encoder:didFinishRecordingToOutputFileAtURL:
 @brief 编码和写文件完成的回调.
 */
- (void)encoder:(SMEncoder *__nonnull)encoder didFinishRecordingToOutputFileAtURL:(NSURL *__nonnull)outputFileURL;

@end

/*!
 @class SMEncoder
 @brief 编码和写文件类.
 */
@interface SMEncoder : NSObject

/*!
 @property isAccessCamera
 @brief 相机是否授权，如果相机没有授权，将会按照纯音频来写文件.
 */
@property (assign, nonatomic) BOOL isAccessCamera;

/*!
 @property delegate
 @brief 回调代理.
 */
@property (weak, nonatomic) __nullable id<SMEncoderDelegate> delegate;

@property (assign, nonatomic) BOOL isEncoding;

@property (assign, nonatomic) CGAffineTransform videoTransform;

@property (assign, nonatomic, readonly) CMTime startRecordingTime;

- (_Nonnull instancetype)initWithVideoConfiguration:(SMVideoConfiguration * _Nullable)videoConfiguration audioConfiguration:(SMAudioConfiguration * _Nullable)audioConfiguration;

- (void)startEncodingToOutputFileURL:(NSURL* __nonnull)outputFileURL encodingDelegate:(__nullable id<SMEncoderDelegate>)delegate;

- (void)stopEncoding;

- (void)cancelEncoding;

- (void)asyncEncode:(CMSampleBufferRef __nonnull)sampleBuffer isVideo:(BOOL)isVideo;

@end
