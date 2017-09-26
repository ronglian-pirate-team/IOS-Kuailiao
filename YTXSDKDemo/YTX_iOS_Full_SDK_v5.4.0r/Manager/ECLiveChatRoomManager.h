//
//  ECLiveChatRoomManager.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/5/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECLiveChatRoomRequest.h"
#import "ECLiveChatRoomInfo.h"
#import "ECLiveChatRoomMember.h"
#import "ECError.h"
#import "ECMessage.h"
#import "ECProgressDelegate.h"

@protocol ECLiveChatRoomManager <NSObject>

/**
 @brief 发送聊天室消息
 @discussion 发送文本消息时，进度不生效；发送附件消息时，进度代理生效
 @param message 发送的消息
 @param progress 发送进度代理
 @param completion 执行结果回调block
 @return 函数调用成功返回消息id，失败返回nil
 */
- (NSString* )sendLiveChatRoomMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 加入聊天室
 @param request 加入聊天室请求类
 @param completion 回调
 */
- (void)joinLiveChatRoom:(ECJoinLiveChatRoomRequest *)request completion:(void(^)(ECError *error,ECLiveChatRoomInfo *roomInfo,ECLiveChatRoomMember *member))completion;

/**
 @brief 退出聊天室
 @param request 退出聊天室请求类
 @param completion 回调
 */
- (void)exitLiveChatRoom:(ECExitLiveChatRoomRequest *)request completion:(void(^)(ECError *error,NSString *roomId))completion;

/**
 @brief 查询聊天室信息
 @param roomId 聊天室id
 @param completion 回调
 */
- (void)queryLiveChatRoomInfo:(NSString *)roomId completion:(void(^)(ECError *error,ECLiveChatRoomInfo *roomInfo))completion;

/**
 @brief 查询聊天室成员列表
 @param roomId 聊天室id
 @param userId 成员id,默认nil(为第一页)
 @param pageSize 页数
 @param completion 回调
 */
- (void)queryLiveChatRoomMembers:(NSString *)roomId userId:(NSString *)userId pageSize:(NSInteger)pageSize completion:(void(^)(ECError *error,NSArray<ECLiveChatRoomMember *> *userArray))completion;

/**
 @brief 查询聊天室单个成员
 @param roomId 聊天室id
 @param userId 成员id
 @param completion 回调
 */
- (void)queryLiveChatRoomMember:(NSString *)roomId userId:(NSString *)userId completion:(void(^)(ECError *error,ECLiveChatRoomMember *member))completion;

/**
 @brief 踢出聊天室
 @param request 踢出聊天室请求类
 @param completion 回调
 */
- (void)kickLiveChatRoomMember:(ECKickLiveChatRoomMemberRequest *)request completion:(void(^)(ECError *error,NSString *userId))completion;

/**
 @brief 修改聊天室信息
 @param request 修改聊天室请求类
 @param completion 回调
 */
- (void)modifyLiveChatRoomInfo:(ECModifyLiveChatRoomInfoRequest *)request completion:(void(^)(ECError *error,ECLiveChatRoomInfo *roomInfo))completion;

/**
 @brief 修改聊天室成员角色
 @param request 修改聊天室成员角色请求类
 @param completion 回调
 */
- (void)modifyLiveChatRoomMemberRole:(ECModifyLiveChatRoomMemberRoleRequest *)request completion:(void(^)(ECError *error,ECLiveChatRoomMember *member))completion;

/**
 @brief 修改聊天室成员信息
 @param request 修改聊天室成员信息请求类
 @param completion 回调
 */
- (void)modifyLiveChatRoomSelfInfo:(ECModifyLiveChatRoomMemberInfoRequest *)request completion:(void(^)(ECError *error,ECLiveChatRoomMember *member))completion;

/**
 @brief 禁言聊天室成员
 @param request 禁言聊天室成员请求类
 @param completion 回调
 */
- (void)forbidLiveChatRoomMember:(ECForbidLiveChatRoomMemberRequest *)request completion:(void(^)(ECError *error,ECLiveChatRoomMember *member))completion;

/**
 @brief 拉黑聊天室成员
 @param request 拉黑聊天室成员请求类
 @param completion 回调
 */
- (void)dfriendLiveChatRoomMember:(ECDefriendLiveChatRoomMemberRequest *)request completion:(void(^)(ECError *error,ECLiveChatRoomMember *member))completion;
@end
