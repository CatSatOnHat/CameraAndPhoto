//
//  ClipPhotoVC.m
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import "ClipPhotoVC.h"
#import "OperationView.h"

static const CGFloat maskView_height = 140.0;
static const CGFloat clip_margin = 10.0;
static const CGFloat borderLayer_length = 25.0;

@interface ClipPhotoVC () <OperationViewDelegate, UIScrollViewDelegate> {
    CGFloat imageV_width;
    CGFloat imageV_height;
    CGRect clipRect;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageV;

@property (nonatomic, strong) UIImage *image;
//阴影层
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
//需要保留的阴影层
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;

@property (nonatomic, strong) OperationView *operationView;


@end

@implementation ClipPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    NSAssert(_originalAsset || _originalImage, @"好歹也传个东西进来吧");
    clipRect = CGRectMake(clip_margin, (SCREENH-SCREENW)/2, SCREENW-2*clip_margin, SCREENW-2*clip_margin);
    if (_originalAsset) {
        imageV_width = clipRect.size.width;
        imageV_height = imageV_width * _originalAsset.pixelHeight / _originalAsset.pixelWidth;
    } else {
        imageV_width = clipRect.size.width;
        imageV_height = imageV_width * SCREENH / SCREENW;
    }

    [self.view addSubview:self.scrollView];
    [self.view.layer addSublayer:self.shadowLayer];
    [self.view.layer addSublayer:self.borderLayer];
    [self.view addSubview:self.operationView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    _scrollView.zoomScale = 1.0;
    self.navigationController.navigationBar.hidden = NO;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#pragma mark - 切图
- (UIImage *)imageFromView {
    CGFloat scale = _imageV.frame.size.width / _image.size.width;
    
    CGFloat origX = (_scrollView.contentOffset.x - _imageV.frame.origin.x) / scale;
    CGFloat origY = (_scrollView.contentOffset.y - _imageV.frame.origin.y) / scale;
    CGFloat oriWidth = _scrollView.frame.size.width / scale;
    CGFloat oriHeight = _scrollView.frame.size.height / scale;
    
    CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect(_image.CGImage, myRect);
    UIGraphicsBeginImageContext(myRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myRect, imageRef);
    UIImage * clipImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    
    return clipImage;
}
#pragma mark - OperationViewDelegate
- (void)cancle {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)complete {
    UIImage *icon = [[UIImage alloc] init];
    icon = [self imageFromView];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeImage object:icon];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageV;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //当scrollView自身的宽度或者高度大于其contentSize的时候, 增量为:自身宽度或者高度减去contentSize宽度或者高度除以2,或者为0
    //当scrollView自身的宽度或者高度大于其contentSize的时候, 增量为:自身宽度或者高度减去contentSize宽度或者高度除以2,或者为0
    CGFloat delta_x= scrollView.bounds.size.width > scrollView.contentSize.width ? (scrollView.bounds.size.width-scrollView.contentSize.width)/2 : 0;
    CGFloat delta_y= scrollView.bounds.size.height > scrollView.contentSize.height ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0;
    //让imageView一直居中
    //实时修改imageView的center属性 保持其居中
    _imageV.center = CGPointMake(scrollView.contentSize.width/2 + delta_x, scrollView.contentSize.height/2 + delta_y);
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:clipRect];
        _scrollView.contentSize = CGSizeMake(imageV_width, imageV_height);
        _scrollView.contentOffset = CGPointMake((imageV_width-SCREENW)/2, fabs((imageV_height-(SCREENH-2*ControlsHeight6(maskView_height)))/2));
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.delegate = self;
        _scrollView.layer.masksToBounds = NO;
        [_scrollView addSubview:self.imageV];
    }
    return _scrollView;
}
- (UIImageView *)imageV {
    if (!_imageV) {
        _imageV = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, imageV_width, imageV_height)];
        _imageV.image = self.image;
        CGFloat delta_x= _scrollView.bounds.size.width > _scrollView.contentSize.width ? (_scrollView.bounds.size.width-_scrollView.contentSize.width)/2 : 0;
        CGFloat delta_y= _scrollView.bounds.size.height > _scrollView.contentSize.height ? (_scrollView.bounds.size.height - _scrollView.contentSize.height)/2 : 0;
        _imageV.center=CGPointMake(_scrollView.contentSize.width/2 + delta_x, _scrollView.contentSize.height/2 + delta_y);
        _imageV.userInteractionEnabled = YES;
        _imageV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageV;
}
- (UIImage *)image {
    if (!_image) {
        _image = [[UIImage alloc] init];
        if (_originalAsset) {
            [[PhotoTool shareTool] getImageByAsset:_originalAsset targetSize:CGSizeMake(imageV_width, imageV_height) resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *AssetImage) {
                _image = AssetImage;
            }];
        }
        if (_originalImage) {
            UIGraphicsBeginImageContext(CGSizeMake(_originalImage.size.width, _originalImage.size.height));
            [_originalImage drawInRect:CGRectMake(0, 0, _originalImage.size.width, _originalImage.size.height)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            _image = scaledImage;
        }
    }
    return _image;
}
- (OperationView *)operationView {
    if (!_operationView) {
        _operationView = [[OperationView alloc] initWithFrame:CGRectMake(0, SCREENH-44, SCREENW, 44)];
        _operationView.delegate = self;
    }
    return _operationView;
}
/**
 阴影层
 
 @return shadowLayer
 */
- (CAShapeLayer *)shadowLayer {
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.path = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
        _shadowLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        _shadowLayer.mask = self.maskLayer;
    }
    return _shadowLayer;
}

/**
 扣掉扫描
 
 @return maskLayer
 */
- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer = [self subtractMaskRect:clipRect fromRect:self.view.bounds];
    }
    return _maskLayer;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        //左上角
        [path moveToPoint:CGPointMake(CGRectGetMinX(clipRect), CGRectGetMinY(clipRect) + borderLayer_length)];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(clipRect), CGRectGetMinY(clipRect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(clipRect) + borderLayer_length, CGRectGetMinY(clipRect))];
        //右上角
        [path moveToPoint:CGPointMake(CGRectGetMaxX(clipRect) - borderLayer_length, CGRectGetMinY(clipRect))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(clipRect), CGRectGetMinY(clipRect))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(clipRect), CGRectGetMinY(clipRect) + borderLayer_length)];
        //左下角
        [path moveToPoint:CGPointMake(CGRectGetMinX(clipRect), CGRectGetMaxY(clipRect) - borderLayer_length)];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(clipRect), CGRectGetMaxY(clipRect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(clipRect) + borderLayer_length, CGRectGetMaxY(clipRect))];
        //右下角
        [path moveToPoint:CGPointMake(CGRectGetMaxX(clipRect) - borderLayer_length, CGRectGetMaxY(clipRect))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(clipRect), CGRectGetMaxY(clipRect))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(clipRect), CGRectGetMaxY(clipRect) - borderLayer_length)];
        
        _borderLayer.path = path.CGPath;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        _borderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _borderLayer.lineWidth = 1.0;
    }
    return _borderLayer;
}
/**
 生成扣掉扫描部分的layer
 
 @param maskRect 扣掉的rect
 @param originalRect 原rect
 @return 扣掉扫描部分的layer
 */
- (CAShapeLayer *)subtractMaskRect:(CGRect)maskRect fromRect:(CGRect)originalRect {
    CAShapeLayer *layer = [CAShapeLayer layer];
    if (CGRectEqualToRect(maskRect, CGRectZero)) {
        return layer;
    }
    if (CGRectEqualToRect(originalRect, CGRectZero)) {
        return nil;
    }
    CGFloat originalMinX = CGRectGetMinX(originalRect);
    CGFloat originalMinY = CGRectGetMinY(originalRect);
    CGFloat originalMaxX = CGRectGetMaxX(originalRect);
    CGFloat originalMaxY = CGRectGetMaxY(originalRect);
    
    CGFloat maskMinX = CGRectGetMinX(maskRect);
    CGFloat maskMinY = CGRectGetMinY(maskRect);
    CGFloat maskMaxX = CGRectGetMaxX(maskRect);
    CGFloat maskMaxY = CGRectGetMaxY(maskRect);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(originalMinX, originalMinY, maskMinX - originalMinX, originalMaxY - originalMinY)];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(maskMinX, originalMinY, maskMaxX - maskMinX, maskMinY - originalMinY)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(maskMaxX, originalMinY, originalMaxX - maskMaxX, originalMaxY- originalMinY)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(maskMinX, maskMaxY, maskMaxX - maskMinX, originalMaxY - maskMaxY)]];
    layer.path = path.CGPath;
    return layer;
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
