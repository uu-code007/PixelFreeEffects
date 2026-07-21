//
//  PFEffectResourceManager.m
//  SMBeautyEngine_iOS
//

#import "PFEffectResourceManager.h"

static NSString * const PFDefaultEffectListURLString = @"https://pixelfreesdk.cn/effects-api/v1/effects";

@interface PFEffectResourceManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<PFEffectDownloadCompletion> *> *downloadCompletions;
@end

@implementation PFEffectResourceManager

+ (instancetype)sharedManager {
    static PFEffectResourceManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PFEffectResourceManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _effectListURLString = PFDefaultEffectListURLString;
        _downloadCompletions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<PFBeautyParam *> *)originParamsForType:(FUDataType)type {
    PFBeautyParam *param = [[PFBeautyParam alloc] init];
    param.mParam = @"origin";
    param.mTitle = @"origin";
    param.type = type;
    param.mValue = 0.0f;
    param.defaultValue = 0.0f;
    param.isDownloaded = YES;
    return @[param];
}

- (void)fetchEffectListWithCompletion:(PFEffectListCompletion)completion {
    NSURL *url = [NSURL URLWithString:self.effectListURLString];
    if (!url) {
        if (completion) {
            completion(@[], @[], [NSError errorWithDomain:@"PFEffectResourceManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"invalid effect list url"}]);
        }
        return;
    }

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data.length == 0 || error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(@[], @[], error);
                }
            });
            return;
        }

        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (![json isKindOfClass:NSDictionary.class]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(@[], @[], jsonError);
                }
            });
            return;
        }

        NSArray *stickersJSON = [json[@"stickers"] isKindOfClass:NSArray.class] ? json[@"stickers"] : @[];
        NSArray *makeupJSON = [json[@"makeup"] isKindOfClass:NSArray.class] ? json[@"makeup"] : @[];
        NSArray<PFBeautyParam *> *stickers = [self effectParamsFromJSONArray:stickersJSON type:FUDataTypeStickers];
        NSArray<PFBeautyParam *> *makeup = [self effectParamsFromJSONArray:makeupJSON type:FUDataTypeMakeup];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(stickers, makeup, nil);
            }
        });
    }] resume];
}

- (NSString *)bundleDirectoryForType:(FUDataType)type {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = directories.firstObject;
    NSString *folder = type == FUDataTypeMakeup ? @"makeup" : @"stickers";
    NSString *path = [[documentDirectory stringByAppendingPathComponent:@"PixelFreeEffectBundles"] stringByAppendingPathComponent:folder];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (NSString *)bundleFileNameForParam:(PFBeautyParam *)param {
    NSString *name = param.bundleURL.length > 0 ? [[[NSURL URLWithString:param.bundleURL] lastPathComponent] stringByRemovingPercentEncoding] : nil;
    if (name.length == 0) {
        name = [NSString stringWithFormat:@"%@.bundle", param.mParam ?: @""];
    }
    return name;
}

- (NSString *)downloadedBundlePathForParam:(PFBeautyParam *)param {
    return [[self bundleDirectoryForType:param.type] stringByAppendingPathComponent:[self bundleFileNameForParam:param]];
}

- (NSString *)bundlePathForParam:(PFBeautyParam *)param {
    if (!param.isRemoteResource) {
        return nil;
    }

    NSString *downloadedPath = [self downloadedBundlePathForParam:param];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedPath]) {
        param.localBundlePath = downloadedPath;
        param.isDownloaded = YES;
        return downloadedPath;
    }
    param.localBundlePath = nil;
    param.isDownloaded = NO;
    return nil;
}

- (void)refreshDownloadStateForParam:(PFBeautyParam *)param {
    [self bundlePathForParam:param];
}

- (void)downloadBundleForParam:(PFBeautyParam *)param completion:(PFEffectDownloadCompletion)completion {
    NSString *bundleURL = param.bundleURL;
    if (bundleURL.length == 0) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"PFEffectResourceManager" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"empty bundle url"}]);
        }
        return;
    }

    NSString *existingPath = [self bundlePathForParam:param];
    if (existingPath.length > 0) {
        if (completion) {
            completion(existingPath, nil);
        }
        return;
    }

    NSMutableArray<PFEffectDownloadCompletion> *waiting = self.downloadCompletions[bundleURL];
    if (waiting) {
        if (completion) {
            [waiting addObject:[completion copy]];
        }
        return;
    }

    self.downloadCompletions[bundleURL] = completion ? [NSMutableArray arrayWithObject:[completion copy]] : [NSMutableArray array];
    param.isDownloading = YES;

    NSURL *url = [NSURL URLWithString:bundleURL];
    if (!url) {
        [self finishDownloadForParam:param path:nil error:[NSError errorWithDomain:@"PFEffectResourceManager" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"invalid bundle url"}]];
        return;
    }

    [[[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSString *targetPath = [self downloadedBundlePathForParam:param];
        BOOL success = NO;
        NSError *moveError = nil;
        if (location && !error) {
            [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
            NSURL *targetURL = [NSURL fileURLWithPath:targetPath];
            success = [[NSFileManager defaultManager] moveItemAtURL:location toURL:targetURL error:&moveError];
        }

        NSError *finalError = error ?: moveError;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishDownloadForParam:param path:success ? targetPath : nil error:finalError];
        });
    }] resume];
}

- (void)finishDownloadForParam:(PFBeautyParam *)param path:(NSString *)path error:(NSError *)error {
    NSString *bundleURL = param.bundleURL ?: @"";
    NSArray<PFEffectDownloadCompletion> *completions = [self.downloadCompletions[bundleURL] copy];
    [self.downloadCompletions removeObjectForKey:bundleURL];

    param.isDownloading = NO;
    param.isDownloaded = path.length > 0;
    param.localBundlePath = path;

    for (PFEffectDownloadCompletion completion in completions) {
        completion(path, error);
    }
}

- (NSArray<PFBeautyParam *> *)effectParamsFromJSONArray:(NSArray *)array type:(FUDataType)type {
    NSMutableArray<PFBeautyParam *> *params = [[self originParamsForType:type] mutableCopy];
    for (NSDictionary *dict in array) {
        if (![dict isKindOfClass:NSDictionary.class]) {
            continue;
        }
        PFBeautyParam *param = [self effectParamFromDictionary:dict type:type];
        if (param) {
            [params addObject:param];
        }
    }
    return [params copy];
}

- (PFBeautyParam *)effectParamFromDictionary:(NSDictionary *)dict type:(FUDataType)type {
    NSString *effectID = [dict[@"id"] isKindOfClass:NSString.class] ? dict[@"id"] : dict[@"mParam"];
    if (effectID.length == 0) {
        return nil;
    }

    PFBeautyParam *param = [[PFBeautyParam alloc] init];
    param.mParam = effectID;
    NSString *title = [dict[@"title"] isKindOfClass:NSString.class] ? dict[@"title"] : effectID;
    NSString *titleEN = [dict[@"title_en"] isKindOfClass:NSString.class] ? dict[@"title_en"] : nil;
    param.mTitle = ([self prefersEnglishEffectTitle] && titleEN.length > 0) ? titleEN : title;
    param.iconURL = [dict[@"icon_url"] isKindOfClass:NSString.class] ? dict[@"icon_url"] : nil;
    param.bundleURL = [dict[@"bundle_url"] isKindOfClass:NSString.class] ? dict[@"bundle_url"] : nil;
    param.type = type;
    param.mValue = type == FUDataTypeMakeup ? 1.0f : 0.0f;
    param.defaultValue = param.mValue;
    param.isRemoteResource = param.bundleURL.length > 0;
    [self refreshDownloadStateForParam:param];
    return param;
}

- (BOOL)prefersEnglishEffectTitle {
    NSString *language = NSLocale.preferredLanguages.firstObject.lowercaseString;
    return [language hasPrefix:@"en"];
}

@end
