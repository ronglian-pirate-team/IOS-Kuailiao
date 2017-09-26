//
//  NSString+ECUnitl.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import <Foundation/Foundation.h>

@interface NSString (ECUnitl)


/**
 @brief 字符串MD5

 @param str 需要转MD5的字符串
 @return MD5加密后的字符串
 */
+ (NSString *)MD5:(NSString *)str;


/**
 @brief 时间戳转字符串

 @param dateTime 需要转字符串的时间戳
 @return 转换结果
 */
+ (NSString *)dateTime:(long long)dateTime;


/**
 @brief 好友关系http请求生产sig时，时间戳

 @param date 需要转换的时间
 @return 格式化后的结果
 */
+ (NSString *)sigTime:(NSDate *)date;


/**
 @brief Http 请求参数时间戳

 @param date 请求时间
 @return 转换后时间
 */
+ (NSString *)requestTime:(NSDate *)date;


/**
 是否包含字符串

 @param other 包含的字符串
 @return YES或NO
 */
- (BOOL)ec_MyContainsString:(NSString*)other;

+ (double)ec_GetVideoPathDuration:(NSString *)videoPath;
@end

