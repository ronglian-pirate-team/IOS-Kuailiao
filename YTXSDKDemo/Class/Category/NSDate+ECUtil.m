//
//  NSDate+ECUtil.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/24.
//
//

#import "NSDate+ECUtil.h"

@implementation NSDate (ECUtil)


+ (NSInteger)ageWithDateStr:(NSString *)dateStr{
    return [[self class] ageWithDateOfBirth:[self ec_dateFromString:@"yyyy-MM-dd" WithString:dateStr]];
}

+ (NSInteger)ageWithDateOfBirth:(NSDate *)date{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    return iAge;
}

+ (NSString *)ec_stringFromCurrentDateWithFormate:(NSString *)dateformateStr {
   return [self ec_stringFromDate:dateformateStr WithDate:[NSDate dateWithTimeIntervalSinceNow:0]];
}
#pragma mark - 将日期转换为格式字符串
+ (NSString *)ec_stringFromDate:(NSString *)dateformateStr WithDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = dateformateStr;
    return [dateFormat stringFromDate:date];
}

#pragma mark - 将日期转换为格式字符串
+ (NSDate *)ec_dateFromString:(NSString *)dateformateStr WithString:(NSString *)string {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = dateformateStr;
    return [dateFormat dateFromString:string];
}

@end
