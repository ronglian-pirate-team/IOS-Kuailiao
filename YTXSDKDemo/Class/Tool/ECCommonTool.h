//
//  ECCommonTool.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface ECCommonTool : NSObject

+ (BOOL)verifyMobilePhone:(NSString*)phone ;
/**
 @brief 提示

 @param message 显示的文字内容
 */
+ (void)toast:(NSString*)message;

/**
 @brief 提示 ，指定时间

 @param message 显示文字内容
 @param duration 持续显示时间
 */
+ (void)toast:(NSString*)message duration:(CGFloat)duration;


/**
 @brief 保存音视频文件

 @param movUrl 音视频url
 @return 文件路径
 */
+ (NSURL *)convertToMp4:(NSURL *)movUrl;
/**
 @brief 保存gif图到本地

 @param srcUrl 图片地址
 */
+ (NSString *)saveGifToDocument:(NSURL *)srcUrl;

/**
 @brief 发送图片时图片压缩，返回本地保存路径

 @param image 待发送图片
  @param isHD 是否是高清图片
 @return 压缩后图片保存路径
 */
+ (NSString *)saveToDocument:(UIImage*)image isHD:(BOOL)isHD;

+ (NSString *)validateNullStr:(NSString *)originalStr;

+ (NSString *)userAvatar:(NSString *)userId;
@end
