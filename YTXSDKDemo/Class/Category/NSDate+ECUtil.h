//
//  NSDate+ECUtil.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/24.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (ECUtil)

+ (NSInteger)ageWithDateStr:(NSString *)dateStr;
+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;


/**
 @brief 当前时间转换成指定格式
 
 @param dateformateStr 转换目标时间的格式
 @return 时间转换结果
 */
+ (NSString *)ec_stringFromCurrentDateWithFormate:(NSString *)dateformateStr;

/**
 @brief 时间转换成指定格式
 
 @param dateformateStr 转换目标时间的格式
 @param date 需要转换的时间
 @return 时间转换结果
 */
+ (NSString *)ec_stringFromDate:(NSString *)dateformateStr WithDate:(NSDate*)date;


/**
 按照格式将字符串时间转化为日期输出

 @param dateformateStr 格式器
 @param string 格式化的字符串时间
 @return 返回日期
 */
+ (NSDate *)ec_dateFromString:(NSString *)dateformateStr WithString:(NSString *)string;
@end
