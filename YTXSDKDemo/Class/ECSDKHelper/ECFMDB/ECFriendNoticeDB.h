//
//  ECFriendNoticeDB.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import <Foundation/Foundation.h>

@interface ECFriendNoticeDB : NSObject

+ (instancetype)sharedInstanced;

- (void)createFriendNoticeTable;

- (void)insertFriendNoticeMessage:(ECFriendNoticeMsg *)msg;

- (void)updateFriendNoticeMsg:(ECFriendNoticeMsg *)msg;

- (void)deleteAllFriendNoticeMsg;
- (void)deleteFriendNoticeMsg:(ECFriendNoticeMsg *)msg;


- (void)queryAllFriendNoticeMsg:(void (^)(NSArray *array))completion;
- (ECFriendNoticeMsg *)queryFriendNoticeMsgWithSender:(NSString *)sender andFriendAccount:(NSString *)friendAccount;
@end
