//
//  PhotoAlbumCell.m
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/23.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import "PhotoAlbumCell.h"

@implementation PhotoAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _firstImageV.contentMode = UIViewContentModeScaleAspectFill;
    _firstImageV.clipsToBounds = YES;
}

- (void)configCellWithData:(NSArray<PhotoAlbum *> *)dataArray indexPath:(NSIndexPath *)indexPath{
    CGSize size = _firstImageV.frame.size;
    size.width *= [UIScreen mainScreen].scale;
    size.height *= [UIScreen mainScreen].scale;
    [[PhotoTool shareTool] getImageByAsset:dataArray[indexPath.row].firstImageAsset targetSize:size resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *AssetImage) {
        _firstImageV.image = AssetImage;
    }];
    _photoAlbumTitle.text = dataArray[indexPath.row].title;
    _photoAlbumCount.text = [NSString stringWithFormat:@"(%ld)", dataArray[indexPath.row].count];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
