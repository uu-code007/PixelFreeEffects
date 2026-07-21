//
//  PFEffectResourceManager.h
//  SMBeautyEngine_iOS
//

#import <Foundation/Foundation.h>
#import "PFBeautyParam.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PFEffectListCompletion)(NSArray<PFBeautyParam *> *stickers, NSArray<PFBeautyParam *> *makeup, NSError * _Nullable error);
typedef void(^PFEffectDownloadCompletion)(NSString * _Nullable path, NSError * _Nullable error);

@interface PFEffectResourceManager : NSObject

@property (nonatomic, copy) NSString *effectListURLString;

+ (instancetype)sharedManager;

- (NSArray<PFBeautyParam *> *)originParamsForType:(FUDataType)type;
- (void)fetchEffectListWithCompletion:(PFEffectListCompletion)completion;
- (NSString * _Nullable)bundlePathForParam:(PFBeautyParam *)param;
- (void)refreshDownloadStateForParam:(PFBeautyParam *)param;
- (void)downloadBundleForParam:(PFBeautyParam *)param completion:(PFEffectDownloadCompletion)completion;

@end

NS_ASSUME_NONNULL_END
