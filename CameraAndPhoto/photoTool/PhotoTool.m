//
//  PhotoTool.m
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/23.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import "PhotoTool.h"

@implementation PhotoAlbum

@end

@implementation PhotoTool

+ (instancetype)shareTool {
    static PhotoTool *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[PhotoTool alloc] init];
    });
    return tool;
}

- (NSArray<PhotoAlbum *> *)getAllPhotoAlbums {
    NSMutableArray<PhotoAlbum *> *photoAlbums = [NSMutableArray array];
    //系统相册
    PHFetchResult *systemPhotoAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //用户自定义相册
    PHFetchResult *userPhotoAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //集合所有相册
    //  系统
    [systemPhotoAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //只有中英文配置 麻烦
        if (!([obj.localizedTitle isEqualToString:@"Recently Deleted"] ||
              [obj.localizedTitle isEqualToString:@"Videos"] ||
              [obj.localizedTitle isEqualToString:@"最近删除"] ||
              [obj.localizedTitle isEqualToString:@"视频"])) {
            PHFetchResult *result = [self fetchAssetsInAssetCollection:obj ascending:NO];
            if (result.count > 0) {
                PhotoAlbum *album = [[PhotoAlbum alloc] init];
                album.title = obj.localizedTitle;
                album.count = result.count;
                album.firstImageAsset = result.firstObject;
                album.assetCollection = obj;
                [photoAlbums addObject:album];
            }
        }
    }];
    //  用户自定义的相簿
    [userPhotoAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:obj ascending:NO];
        if (result.count > 0) {
            PhotoAlbum *album = [[PhotoAlbum alloc] init];
            album.title = obj.localizedTitle;
            album.count = result.count;
            album.firstImageAsset = result.firstObject;
            album.assetCollection = obj;
            [photoAlbums addObject:album];
        }
    }];
    return photoAlbums;
}

- (NSArray<PHAsset *> *)getPhotosInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:obj];
    }];
    return assets;
}

- (NSArray<PHAsset *> *)getAllPhotosByAscending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //按创建时间排序
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:obj];
    }];
    return assets;
}

- (void)getImageByAsset:(PHAsset *)asset targetSize:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = resizeMode;
    options.networkAccessAllowed = YES;
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;//控制照片质量
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        completion(result);
    }];
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

@end
