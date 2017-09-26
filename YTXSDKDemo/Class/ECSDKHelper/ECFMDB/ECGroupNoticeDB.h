//
//  ECGroupNoticeDB.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECGroupNoticeDB : NSObject

+ (instancetype)sharedInstanced;

- (void)createGroupNoticeTable;
- (void)selectGroupNoticecompletion:(void (^)(NSArray *array))completion;
- (void)insertGroupNoticeMessage:(ECGroupNoticeMessage *)message;
- (void)updateGroupNoticeMessage:(NSString *)groupId withMember:(NSString *)member confirm:(NSInteger)confirm;
- (void)deleteAllGroupNoticeMessage;
- (void)deleteGroupNoticeMessage:(NSString *)groupId withMember:(NSString *)member;

@end
