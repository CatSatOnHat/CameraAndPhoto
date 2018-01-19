//
//  ViewController.m
//  CameraAndPhoto
//
//  Created by 李朕 on 2018/1/17.
//  Copyright © 2018年 Dan. All rights reserved.
//

#import "ViewController.h"
#import "CameraVC.h"
#import "PhotoAlbumListVC.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(change:) name:kChangeImage object:nil];
}

- (IBAction)camera:(id)sender {
    //相机权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // 无权限 引导去开启
        [UIAlertView bk_showAlertViewWithTitle:@"相机未授权" message:@"打开设置->隐私->相机->我也不知道叫啥->打开" cancelButtonTitle:@"确定" otherButtonTitles:@[@"设置"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }                
            }
        }];
    } else {
        CameraVC *cameraVC = [[CameraVC alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:cameraVC];
        [self presentViewController:navi animated:YES completion:nil];
    }
}

- (IBAction)photo:(id)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                PhotoAlbumListVC *listVC = [[PhotoAlbumListVC alloc] init];
                listVC.selectedCount = 4;
                UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:listVC];
                [self presentViewController:navi animated:YES completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView bk_showAlertViewWithTitle:@"相册未授权" message:@"打开设置->隐私->相册->我也不知道叫啥->打开" cancelButtonTitle:@"确定" otherButtonTitles:@[@"设置"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }];
            });
        }
    }];
}
- (void)change:(NSNotification *)noti {
    UIImage *icon = [noti object];
    _imageV.image = icon;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
