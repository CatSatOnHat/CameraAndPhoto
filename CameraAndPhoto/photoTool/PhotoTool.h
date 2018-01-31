//
//  PhotoTool.h
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/23.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
//相册
@interface PhotoAlbum : NSObject

/**
 相册名
 */
@property (nonatomic, copy) NSString *title;

/**
 相册照片数量
 */
@property (nonatomic, assign) NSInteger count;

/**
 相册第一张图片
 */
@property (nonatomic, strong) PHAsset *firstImageAsset;

/**
 通过该属性可以取得相册的所有图片
 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end

@interface PhotoTool : NSObject

/**
 保存打开过的相册（读相册比较耗时）
 */
@property (nonatomic, strong) NSMutableDictionary *PHAssetsDic;

/**
 创建单例

 @return 返回实例
 */
+ (instancetype)shareTool;

/**
 获取手机上的所有相册

 @return 相册的数组
 */
- (NSArray<PhotoAlbum *> *)getAllPhotoAlbums;

/**
 获取某一相册的所有照片

 @param assetCollection 相册
 @param ascending 排序
 @return 照片数组
 */
- (NSArray<PHAsset *> *)getPhotosInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;
/**
 获取手机内的所有照片

 @param ascending 排序
 @return 照片数组
 */
- (NSArray<PHAsset *> *)getAllPhotosByAscending:(BOOL)ascending;
/**
 获取image

 @param asset 图片的详细信息
 @param size 需要图片的size
 @param resizeMode 设置显示模式
 @param completion 最后返回image
 */
- (void)getImageByAsset:(PHAsset *)asset targetSize:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage * AssetImage))completion;


@end
