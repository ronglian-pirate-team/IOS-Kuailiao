//
//  UIView+Frame.m
//  YoYo
//
//  Created by huangjue on 16/9/29.
//  Copyright © 2016年 com.ronglian.yoyo. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (void)setEc_origin:(CGPoint)ec_origin
{
    CGRect frame = self.frame;
    frame.origin = ec_origin;
    self.frame = frame;
}

- (CGPoint)ec_origin
{
    return self.frame.origin;
}

- (void)setEc_x:(CGFloat)ec_x
{
    CGRect frame = self.frame;
    frame.origin.x = ec_x;
    self.frame = frame;
}

- (CGFloat)ec_x
{
    return self.frame.origin.x;
}

- (void)setEc_y:(CGFloat)ec_y
{
    CGRect frame = self.frame;
    frame.origin.y = ec_y;
    self.frame = frame;
}

- (CGFloat)ec_y
{
    return self.frame.origin.y;
}

-(void)setEc_size:(CGSize)ec_size
{
    CGRect frame = self.frame;
    frame.size = ec_size;
    self.frame = frame;
}

-(CGSize)ec_size
{
    return self.frame.size;
}

- (void)setEc_width:(CGFloat)ec_width
{
    CGRect frame = self.frame;
    frame.size.width = ec_width;
    self.frame = frame;
}

- (CGFloat)ec_width
{
    return self.frame.size.width;
}

- (void)setEc_height:(CGFloat)ec_height
{
    CGRect frame = self.frame;
    frame.size.height = ec_height;
    self.frame = frame;
}

- (CGFloat)ec_height
{
    return self.frame.size.height;
}

- (void)setEc_radius:(CGFloat)ec_radius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = ec_radius;
}

- (CGFloat)ec_radius {
    return self.layer.cornerRadius;
}
@end
