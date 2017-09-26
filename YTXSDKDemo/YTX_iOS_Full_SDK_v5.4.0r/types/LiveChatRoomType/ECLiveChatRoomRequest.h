//
//  ECJoinLiveChatRoomRequest.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/5/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECLiveChatRoomMember.h"

@interface ECLiveChatRoomBaseRequest : NSObject
/**
 @brief 聊天室id
 */
@property (nonatomic, copy) NSString *roomId;

/**
 @brief 加入聊天室是否需要通知.NO 不通知 YES 通知(默认YES)
 */
@property (nonatomic, assign) BOOL needNotify;

/**
 @brief 加入聊天室通知透传字段
 */
@property (nonatomic, copy) NSString *notifyExt;
@end

/**
 @brief 加入直播聊天室请求
 */
@interface ECJoinLiveChatRoomRequest : ECLiveChatRoomBaseRequest

/**
 @brief 聊天室内个人昵称
 */
@property (nonatomic, copy) NSString *nickName;

/**
 @brief 聊天室个人信息透传
 */
@property (nonatomic, copy) NSString *infoExt;

@end


/**
 @brief 退出直播聊天室请求
 */
@interface ECExitLiveChatRoomRequest : ECLiveChatRoomBaseRequest


@end

/**
 @brief 踢出直播聊天室成员请求
 */
@interface ECKickLiveChatRoomMemberRequest : ECLiveChatRoomBaseRequest

/**
 @brief 用户id
 */
@property (nonatomic, copy) NSString *userId;

@end

/**
 @brief 更新直播聊天室信息请求
 */
@interface ECModifyLiveChatRoomInfoRequest : ECLiveChatRoomBaseRequest

/**
 @brief 房间名称
 */
@property (nonatomic, copy) NSString *roomName;

/**
 @brief 聊天室公告
 */
@property (nonatomic, copy) NSString *announcement;

/**
 @brief 自定义字段
 */
@property (nonatomic, copy) NSString *roomExt;

/**
 @brief 是否全员禁言 0 不禁言 1全员禁言 默认0
 */
@property (nonatomic, assign) BOOL isAllMuteMode;

@end

/**
 @brief 更新直播聊天室信息请求
 */
@interface ECModifyLiveChatRoomMemberRoleRequest : ECLiveChatRoomBaseRequest

/**
 @brief 用户id
 */
@property (nonatomic, copy) NSString *userId;

/**
 @brief 角色类型
 */
@property (nonatomic, assign) LiveChatRoomMemberRole type;

@end

/**
 @brief 修改个人信息请求
 */
@interface ECModifyLiveChatRoomMemberInfoRequest : NSObject
/**
 @brief 聊天室id
 */
@property (nonatomic, copy) NSString *roomId;

/**
 @brief 聊天室内个人昵称
 */
@property (nonatomic, copy) NSString *nickName;

/**
 @brief 聊天室个人信息透传
 */
@property (nonatomic, copy) NSString *infoExt;

@end

/**
 @brief 禁言用户请求
 */
@interface ECForbidLiveChatRoomMemberRequest : ECLiveChatRoomBaseRequest
/**
 @brief 用户id
 */
@property (nonatomic, copy) NSString *userId;

/**
 @brief 是否禁言.0 取消禁言 1禁言
 */
@property (nonatomic, assign) BOOL isMute;

/**
 @brief 禁言时长
 */
@property (nonatomic, assign) NSInteger muteDuration;

@end

/**
 @brief 拉黑成员请求
 */
@interface ECDefriendLiveChatRoomMemberRequest : ECLiveChatRoomBaseRequest
/**
 @brief 用户id
 */
@property (nonatomic, copy) NSString *userId;

/**
 @brief 是否拉黑.0 取消拉黑 1拉黑
 */
@property (nonatomic, assign) BOOL isBlack;

@end

