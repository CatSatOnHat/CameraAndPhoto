//
//  PhotoAlbumListVC.m
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/23.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import "PhotoAlbumListVC.h"
#import "PhotoAlbumCell.h"
#import "PhotoListVC.h"

static const CGFloat cell_height = 60;

@interface PhotoAlbumListVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<PhotoAlbum *> *photoAlbums;

@property (nonatomic, strong) UITableView *albumList;

@end

@implementation PhotoAlbumListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.albumList];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 64, 44)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photoAlbums.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cell_height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PhotoAlbumCell class])];
    if (cell == nil) {
        cell = [[PhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([PhotoAlbumCell class])];
    }
    [cell configCellWithData:self.photoAlbums indexPath:indexPath];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoListVC *photoListVC = [[PhotoListVC alloc] init];
    photoListVC.selectedCount = _selectedCount;
    photoListVC.title = self.photoAlbums[indexPath.row].title;
    photoListVC.photosArray = [[PhotoTool shareTool] getPhotosInAssetCollection:self.photoAlbums[indexPath.row].assetCollection ascending:YES];
    [self.navigationController pushViewController:photoListVC animated:YES];
}

- (UITableView *)albumList {
    if (!_albumList) {
        _albumList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH) style:UITableViewStyleGrouped];
        _albumList.delegate = self;
        _albumList.dataSource = self;
        [_albumList registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoAlbumCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([PhotoAlbumCell class])];
        _albumList.estimatedRowHeight = cell_height;
        _albumList.estimatedSectionHeaderHeight = 0;
        _albumList.estimatedSectionFooterHeight = 0;
    }
    return _albumList;
}
- (NSArray<PhotoAlbum *> *)photoAlbums {
    if (!_photoAlbums) {
        _photoAlbums = [[PhotoTool shareTool] getAllPhotoAlbums];
    }
    return _photoAlbums;
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
