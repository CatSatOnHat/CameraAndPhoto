//
//  PhotoListVC.h
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListVC : UIViewController

/**
 选取图片的数量
 */
@property (nonatomic, assign) NSInteger selectedCount;

/**
 照片数据
 */
@property (nonatomic, copy) NSArray<PHAsset *> *photosArray;

@end
