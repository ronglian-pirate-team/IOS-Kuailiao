//
//  UIColor+Util.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/20.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RgbaColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RgbColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(1.0)]

@interface UIColor (Util)

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(int)hexValue;

@end
