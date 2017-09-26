//
//  UIView+Frame.h
//  YoYo
//
//  Created by huangjue on 16/9/29.
//  Copyright © 2016年 com.ronglian.yoyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic, assign) CGPoint ec_origin;
@property (nonatomic, assign) CGFloat ec_x;
@property (nonatomic, assign) CGFloat ec_y;

@property (nonatomic, assign) CGSize  ec_size;
@property (nonatomic, assign) CGFloat ec_width;
@property (nonatomic, assign) CGFloat ec_height;

@property (nonatomic, assign) CGFloat ec_radius;

@end
