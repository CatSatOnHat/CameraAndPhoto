//
//  ClipPhotoVC.h
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClipPhotoVC : UIViewController
//必须传一个
@property (nonatomic, strong) PHAsset *originalAsset;
@property (nonatomic, strong) UIImage *originalImage;

@end
