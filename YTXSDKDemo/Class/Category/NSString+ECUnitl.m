//
//  NSString+ECUnitl.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "NSString+ECUnitl.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>

static NSDateFormatter *dateFormatter = nil;//dateFormatter耗性能，静态存储减少性能消耗

@implementation NSString (ECUnitl)

+ (NSString *)MD5:(NSString *)str{
    if(!str || ![str isKindOfClass:[NSString class]])
        return @"";
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString* MD5 =  [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
    return MD5;
}


/**
 @brief 聊天消息time转字符串

 @param dateTime messgae dateTime
 @return 格式化后时间
 */
+ (NSString *)dateTime:(long long)dateTime{
    NSTimeInterval tempMilli = dateTime;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    if (!myDate)
        return nil;
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    if (nowCmps.year != myCmps.year) {
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    } else {
        if (nowCmps.day==myCmps.day) {
            self.dateFormatter.dateFormat = @"HH:mm:ss";
        } else if((nowCmps.day-myCmps.day)==1) {
            self.dateFormatter.dateFormat = @"昨天 HH:mm:ss";
        } else {
            self.dateFormatter.dateFormat = @"MM-dd HH:mm:ss";
        }
    }
    return [dateFormatter stringFromDate:myDate];
}

+ (NSString *)sigTime:(NSDate *)date{
    self.dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)requestTime:(NSDate *)date{
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return [dateFormatter stringFromDate:date];
}

+ (NSDateFormatter *)dateFormatter{
    if(!dateFormatter){
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return dateFormatter;
}

- (BOOL)ec_MyContainsString:(NSString*)other {
    
    if ([[UIDevice currentDevice].systemVersion integerValue] >7)
        return [self containsString:other];
    NSRange range = [self rangeOfString:other];
    return (range.location == NSNotFound?NO:YES);
}

+ (double)ec_GetVideoPathDuration:(NSString *)videoPath {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:opts];
    CMTime time = [asset duration];
    double seconds = ceil(time.value/time.timescale);
    return seconds;
}

@end
