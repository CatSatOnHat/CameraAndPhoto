//
//  PhotoListVC.m
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import "PhotoListVC.h"
#import "PhotosCollectionViewCell.h"
#import "ClipPhotoVC.h"

// 每排显示4张图片
static const NSInteger count = 4;
// 每张图片间距
static const CGFloat spacing = 5.0;

@interface PhotoListVC () <UICollectionViewDelegate, UICollectionViewDataSource> {
    CGFloat item_width;
    UIImage *selectedImage;
}

@property (nonatomic, strong) UICollectionView *photoCollectionView;

@property (nonatomic, assign) BOOL isFirstLoad;

@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation PhotoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    item_width = (SCREENW - spacing*(count+1)) / count;
    _isFirstLoad = YES;

    [self.view addSubview:self.photoCollectionView];
}
#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photosArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //滑到底部
    if (_isFirstLoad) {
        CGFloat offset = _photoCollectionView.contentSize.height - _photoCollectionView.bounds.size.height;
        if (offset > 0) {
            [_photoCollectionView setContentOffset:CGPointMake(0, offset) animated:NO];
        }
        _isFirstLoad = NO;
    }
    PhotosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotosCollectionViewCell class]) forIndexPath:indexPath];
    [cell configCellWithData:_photosArray indexPath:indexPath];

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ClipPhotoVC *VC = [[ClipPhotoVC alloc] init];
    VC.originalAsset = _photosArray[indexPath.row];
    [self.navigationController pushViewController:VC animated:YES];
}

- (UICollectionView *)photoCollectionView {
    if (!_photoCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = spacing;
        flowLayout.minimumInteritemSpacing = spacing;
        flowLayout.itemSize = CGSizeMake(item_width, item_width);
        flowLayout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) collectionViewLayout:flowLayout];
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        [_photoCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotosCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([PhotosCollectionViewCell class])];
    }
    return _photoCollectionView;
}
- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
        for (int i=0; i<_photosArray.count; i++) {
            [_selectedArray addObject:@"0"];
        }
    }
    return _selectedArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
