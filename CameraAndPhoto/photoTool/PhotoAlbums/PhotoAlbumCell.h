//
//  PhotoAlbumCell.h
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/23.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *firstImageV;

@property (weak, nonatomic) IBOutlet UILabel *photoAlbumTitle;

@property (weak, nonatomic) IBOutlet UILabel *photoAlbumCount;

- (void)configCellWithData:(NSArray<PhotoAlbum *> *)dataArray indexPath:(NSIndexPath *)indexPath;

@end
