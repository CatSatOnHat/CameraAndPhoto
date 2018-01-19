//
//  CameraVC.m
//  CameraAndPhoto
//
//  Created by 李朕 on 2018/1/17.
//  Copyright © 2018年 Dan. All rights reserved.
//

#import "CameraVC.h"
#import "ClipPhotoVC.h"

static NSString * const adjustingFocus = @"adjustingFocus";
static const CGFloat maxZoom = 4.0; /// 最大放大倍数

@interface CameraVC () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureConnection *connection;
///拍照
@property (nonatomic, strong) UIButton *shootBtn;
///切换摄像头
@property (nonatomic, strong) UIButton *changeCameraBtn;
///返回
@property (nonatomic, strong) UIButton *backBtn;
//单击手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
//捏合手势
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
//缩放尺寸
@property (nonatomic, assign) CGFloat currentZoom;

@end

@implementation CameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentZoom = 1.0;
    [self.view.layer addSublayer:self.previewLayer];
    [self.view addSubview:self.shootBtn];
    [self.view addSubview:self.changeCameraBtn];
    [self.view addSubview:self.backBtn];
    [self.view addGestureRecognizer:self.tapGesture];
    [self.view addGestureRecognizer:self.pinchGesture];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    //添加监听事件
    AVCaptureDevice *camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice addObserver:self forKeyPath:adjustingFocus options:NSKeyValueObservingOptionNew context:nil];
    if (self.session) {
        //启动会话
        [self.session startRunning];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //移除监听事件
    AVCaptureDevice*camDevice =[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice removeObserver:self forKeyPath:adjustingFocus];

    if (self.session) {
        //停止会话
        [self.session stopRunning];
    }
}

#pragma mark - private func
/**
 拍照
 */
- (void)clickToShoot {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    AVCaptureVideoOrientation captureOrientation = [self captureOrientationForDeviceOrientation:deviceOrientation];
    [self.connection setVideoOrientation:captureOrientation];
    [self.connection setVideoScaleAndCropFactor:1.0];
    [self.output captureStillImageAsynchronouslyFromConnection:self.connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer == nil) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        
        ClipPhotoVC *clipVC = [[ClipPhotoVC alloc] init];
        clipVC.originalImage = image;
        [self.navigationController pushViewController:clipVC animated:YES];
    }];
}

/**
 切换摄像头
 */
- (void)clickToChangeCamera {
    AVCaptureDevicePosition newPosition;
    if (self.input.device.position == AVCaptureDevicePositionFront || self.input.device.position == AVCaptureDevicePositionUnspecified) {
        newPosition = AVCaptureDevicePositionBack;
    } else {
        newPosition = AVCaptureDevicePositionFront;
    }
    for (AVCaptureDevice *camera in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (camera.position == newPosition) {
            self.device = camera;
            [self configFocus_Exposure_FlashAtPoint:CGPointZero];
        }
    }
    [self.session beginConfiguration];
    [self.session removeInput:self.input];
    self.input = nil;
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    [self.session commitConfiguration];
}

/**
 返回
 */
- (void)clickToBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 返回需要的图片方向

 @param deviceOrientation deviceOrientation
 @return AVCaptureVideoOrientation
 */
- (AVCaptureVideoOrientation)captureOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation orientation = (AVCaptureVideoOrientation)deviceOrientation;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
        orientation = AVCaptureVideoOrientationLandscapeRight;
    if (deviceOrientation == UIDeviceOrientationLandscapeRight)
        orientation = AVCaptureVideoOrientationLandscapeLeft;
    return orientation;
}
#pragma mark - gesture

/**
 单击对焦

 @param tapGesture tapGesture
 */
- (void)tapToFocus:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:self.view];
    [self configFocus_Exposure_FlashAtPoint:touchPoint];
}

/**
 捏合手势放大缩小

 @param pinchGesture pinchGesture
 */
- (void)pinchCameraZoom:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        pinchGesture.scale = _currentZoom;
    }
    if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        if (pinchGesture.scale >= 1.0 && pinchGesture.scale <= [self videoMaxZoomFactor]) {
            NSLog(@"%f ----- %f", _currentZoom, pinchGesture.scale);
            [self changeCameraZoomWithZoom:pinchGesture.scale];
        }
    }
    if (pinchGesture.state == UIGestureRecognizerStateEnded) {
        _currentZoom = self.device.videoZoomFactor;
    }
}

/**
 改变相机zoom

 @param zoom zoom
 */
- (void)changeCameraZoomWithZoom:(CGFloat)zoom {
    if (zoom >= 1.0 && zoom <= [self videoMaxZoomFactor]) {
        NSError *error;
        if ([self.device lockForConfiguration:&error]) {
            [self.device rampToVideoZoomFactor:zoom withRate:50];
        }else{
            NSLog(@"lockForConfiguration : %@", error);
        }
    }
}
//控制最大放大倍数
- (CGFloat)videoMaxZoomFactor {
    if (self.device.activeFormat.videoMaxZoomFactor >= maxZoom) {
        return maxZoom;
    }
    return self.device.activeFormat.videoMaxZoomFactor;
}
#pragma mark - 监听对焦事件
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if([keyPath isEqualToString:adjustingFocus]){
        BOOL adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        // 0代表焦距不发生改变 1代表焦距改变
//        NSLog(@"adjustingFocus : %d  change : %@", adjustingFocus, change);
        if (adjustingFocus == 0) {
            //焦距没有改变
        } else {
            //焦距改变
        }
    }
}
#pragma mark - lazyload
/**
 初始化设备,默认后置摄像头

 @return device
 */
- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [self configFocus_Exposure_FlashAtPoint:CGPointZero];
    }
    return _device;
}

/**
 初始化会话

 @return session
 */
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [self configSession];
    }
    return _session;
}

/**
 配置会话
 */
- (void)configSession {
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }
}

/**
 创建输入流

 @return input
 */
- (AVCaptureDeviceInput *)input {
    if (!_input) {
        NSError *error;
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
        if (error) {
            NSLog(@"AVCaptureDeviceInput error : %@", error);
        }
    }
    return _input;
}

/**
 自动聚焦、曝光、闪光灯
 */
- (void)configFocus_Exposure_FlashAtPoint:(CGPoint)point {
    if (CGPointEqualToPoint(point, CGPointZero)) {
        point = CGPointMake(self.previewLayer.frame.size.width/2, self.previewLayer.frame.size.height/2);
    }
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        if ([self.device isFocusPointOfInterestSupported] && [self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            //先设置位置在设置对焦模式
            self.device.focusPointOfInterest = CGPointMake(point.y/self.previewLayer.frame.size.height ,1-point.x/self.previewLayer.frame.size.width);
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.device.exposurePointOfInterest = CGPointMake(point.y/self.previewLayer.frame.size.height ,1-point.x/self.previewLayer.frame.size.width);
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        [self.device unlockForConfiguration];
    } else {
        NSLog(@"lockForConfiguration : %@", error);
    }
}

/**
 创建输出流

 @return output
 */
- (AVCaptureStillImageOutput *)output {
    if (!_output) {
        _output = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
        [_output setOutputSettings:outputSettings];
    }
    return _output;
}

/**
 创建预览图层

 @return previewlayer
 */
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        _previewLayer.frame = self.view.frame;
    }
    return _previewLayer;
}

/**
 创建connection

 @return connection
 */
- (AVCaptureConnection *)connection {
    if (!_connection) {
        _connection = [self.output connectionWithMediaType:AVMediaTypeVideo];
        //防抖动
        _connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    return _connection;
}

- (UIButton *)shootBtn {
    if (!_shootBtn) {
        _shootBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _shootBtn.frame = CGRectMake((SCREENW-60)/2, SCREENH-80, 60, 60);
        [_shootBtn setImage:[[UIImage imageNamed:@"shoot"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_shootBtn addTarget:self action:@selector(clickToShoot) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shootBtn;
}
- (UIButton *)changeCameraBtn {
    if (!_changeCameraBtn) {
        _changeCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _changeCameraBtn.frame = CGRectMake(SCREENW-80, 30, 40, 40);
        [_changeCameraBtn setImage:[[UIImage imageNamed:@"changeCamera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_changeCameraBtn addTarget:self action:@selector(clickToChangeCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeCameraBtn;
}
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _backBtn.frame = CGRectMake(30, SCREENH-80, 40, 40);
        [_backBtn setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(clickToBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
        _tapGesture.numberOfTouchesRequired = 1;
        _tapGesture.numberOfTapsRequired = 1;
    }
    return _tapGesture;
}
- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchCameraZoom:)];
    }
    return _pinchGesture;
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
