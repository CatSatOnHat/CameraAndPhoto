//
//  PhotoAlbumListVC.h
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/23.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAlbumListVC : UIViewController

/**
 单例 （不知道有没有必要）

 @return instancetype
 */
+ (instancetype)shareAlbumListVC;
/**
 选取图片的数量 设置0或者不设置---选取头像  设置1以上---选取多张图片
 */
@property (nonatomic, assign) NSInteger selectedCount;

@end
