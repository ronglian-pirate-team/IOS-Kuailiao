//
//  ECSession+Util.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/19.
//

#import "ECSession.h"

@interface ECSession (Util)

+ (BOOL)queryNoDisturbOptionOfSessionid:(NSString *)sessionId;

+ (NSArray *)sortSessionWithDatetime:(NSArray *)sourceArray;

+ (ECSession *)messageConvertToSession:(ECMessage *)message;

+ (ECSession *)noticeConvertToSession:(ECBaseNoticeMsg *)notiMsg;

@end
