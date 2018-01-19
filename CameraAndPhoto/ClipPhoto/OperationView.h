//
//  OperationView.h
//  TestPhotosFrameWork
//
//  Created by 李朕 on 2017/6/26.
//  Copyright © 2017年 datuhongan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OperationViewDelegate <NSObject>

- (void)cancle;

- (void)complete;

@end

@interface OperationView : UIView

@property (nonatomic, weak) id<OperationViewDelegate> delegate;

@end
