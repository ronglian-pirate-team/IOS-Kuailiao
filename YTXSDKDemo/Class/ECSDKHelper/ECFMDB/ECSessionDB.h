//
//  ECSessionDB.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSession.h"

@interface ECSessionDB : NSObject

+ (instancetype)sharedInstanced;

- (void)createSessionTable;

/**
 @brief 取出聊天记录
 @param completion 选择完回调
 */
- (NSMutableDictionary *)selectSessionCompletion:(void (^)(NSArray *array))completion;

- (ECSession *)selectSession:(NSString *)sessionId;

/**
 @brief 通过session更新session信息
 */
- (void)updateSession:(ECSession *)session;
- (void)updateShowSession:(ECSession *)session isShow:(BOOL)isShow;

/**
 @brief 删除聊天session
 */
- (void)deleteSession:(NSString *)sessionId;

/**
 @brief 删除所有对话记录
 */
- (void)deleteAllSession;

/**
 @brief 置顶/取消置顶对话
 */
- (void)updateSessionTop:(NSString *)sessionId isTop:(BOOL)isTop;
- (void)updateSessionNoDisturb:(BOOL)isNoDisturb ofSessionId:(NSString *)sessionId;

- (NSInteger)getUndisturbUnCountMessageOfSession;
- (NSInteger)getTotalUnCountMessageOfSession;
@end
