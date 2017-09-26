//
//  ECDBManagerUtil.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/21.
//

#import <Foundation/Foundation.h>

@interface ECDBManagerUtil: NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) NSMutableDictionary *sessionDic;

@property (nonatomic, strong) NSArray *sessionArray;

- (ECSession *)addNewMessage:(ECMessage *)message andSessionId:(NSString*)sessionId;

- (void)updateSessionWithMessage:(ECMessage *)message;
- (void)updateMessageId:(ECMessage *)msgNewId andTime:(long long)time ofMessageId:(NSString*)msgOldId;
- (void)updateSrcMessage:(NSString*)sessionId msgid:(NSString*)msgId withDstMessage:(ECMessage*)dstmessage;

- (void)deleteAllMessageSaveSessionOfSessionId:(NSString *)sessionId;
- (void)deleteSessionOfSessionId:(NSString *)sessionId;

- (void)updateSessionWithNotiMsg:(ECBaseNoticeMsg *)noticeMsg;
- (void)selectNoticeCompletion:(void (^)(NSArray *array))completion;
@end
