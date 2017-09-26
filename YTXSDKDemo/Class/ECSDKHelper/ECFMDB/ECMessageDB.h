//
//  ECMessageDB.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECMessageDB : NSObject
+ (instancetype)sharedInstanced;

- (void)createIMMessageTable:(NSString *)sessionId;
- (void)selectMessage:(NSString *)session completion:(void (^)(NSArray *array))completion;
- (void)insertMessage:(ECMessage *)message;
- (void)deleteMessage:(NSString *)msgId withSession:(NSString *)sessionId;
- (void)deleteAllMessage:(NSString *)sessionId;

- (BOOL)updateMessageLocalPath:(NSString*)msgId withPath:(NSString*)path withDownloadState:(ECMediaDownloadStatus)state andSession:(NSString*)sessionId;
-(BOOL)updateMessageHDLocalPath:(NSString *)msgId withPath:(NSString *)HDLocalPath withDownloadState:(ECMediaDownloadStatus)state andSession:(NSString*)sessionId;
- (ECMessage*)getMessageWithMessageId:(NSString*)messageId OfSession:(NSString *)sessionId;
- (NSArray *)getLatestSomeMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId;
- (NSArray *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId beforeTime:(long long)timesamp;

- (void)updateState:(ECMessageState)state ofMessageId:(NSString*)msgId andSession:(NSString*)sessionId;
- (BOOL)updateMessageReadCount:(NSString*)sessionId messageId:(NSString*)messageId readCount:(NSInteger)readCount;
- (void)updateMessageId:(NSString *)msdNewId andTime:(long long)time ofMessageId:(NSString *)msgOldId andSession:(NSString *)sessionId;
- (BOOL)updateMessage:(NSString*)sessionId msgid:(NSString*)msgId withMessage:(ECMessage *)message;
- (BOOL)updateMessageReadState:(NSString *)sessionId messageId:(NSString*)messageId isRead:(BOOL)isRead;

- (BOOL)updateMessageSize:(NSString *)sessionId messageId:(NSString *)messageId withCellSize:(CGSize)cellSize;

- (NSArray *)getAllLocalPathMessageOfSessionId:(NSString *)sessionId type:(MessageBodyType)messageBodyType;
- (NSArray *)getImageMessageLocalPath:(NSString *)sessionId isHD:(BOOL)isHD;
@end
