//
//  OperationView.m
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import "OperationView.h"

static const CGFloat textSize = 17.0;
static const CGFloat btn_width = 90;

@interface OperationView ()

@property (nonatomic, strong) UIButton *cancleBtn;

@property (nonatomic, strong) UIButton *completeBtn;

@end

@implementation OperationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.cancleBtn];
        [self addSubview:self.completeBtn];
    }
    return self;
}
- (void)clickCancle {
    if ([self.delegate respondsToSelector:@selector(cancle)]) {
        [self.delegate cancle];
    }
}
- (void)clickComplete {
    if ([self.delegate respondsToSelector:@selector(complete)]) {
        [self.delegate complete];
    }
}

- (UIButton *)cancleBtn {
    if (!_cancleBtn) {
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancleBtn.frame = CGRectMake(0, 0, btn_width, self.frame.size.height);
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:textSize];
        [_cancleBtn addTarget:self action:@selector(clickCancle) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleBtn;
}
- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeBtn.frame = CGRectMake(SCREENW-btn_width, 0, btn_width, self.frame.size.height);
        [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _completeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:textSize];
        [_completeBtn addTarget:self action:@selector(clickComplete) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

@end
