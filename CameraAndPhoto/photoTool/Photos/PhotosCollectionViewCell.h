//
//  PhotosCollectionViewCell.h
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosCollectionViewCell : UICollectionViewCell

/**
 照片
 */
@property (weak, nonatomic) IBOutlet UIImageView *photoImageV;

- (void)configCellWithData:(NSArray<PHAsset *> *)dataArray indexPath:(NSIndexPath *)indexPath;

@end
