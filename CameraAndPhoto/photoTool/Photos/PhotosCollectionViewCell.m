//
//  PhotosCollectionViewCell.m
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import "PhotosCollectionViewCell.h"

@implementation PhotosCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _photoImageV.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)configCellWithData:(NSArray<PHAsset *> *)dataArray indexPath:(NSIndexPath *)indexPath {
    CGSize size = self.frame.size;
    size.width *= [UIScreen mainScreen].scale;
    size.height *= [UIScreen mainScreen].scale;
    [[PhotoTool shareTool] getImageByAsset:dataArray[indexPath.row] targetSize:size resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *AssetImage) {
        _photoImageV.image = AssetImage;
    }];
}


@end
