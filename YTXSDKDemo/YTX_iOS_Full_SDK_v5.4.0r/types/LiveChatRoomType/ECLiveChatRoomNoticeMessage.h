//
//  ECLiveChatRoomNoticeMessage.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/5/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECLiveChatRoomMember.h"

typedef enum : NSUInteger {
    
    /** 默认 */
    ECLiveChatRoomNoticeType_None=0,
    
    /** 加入聊天室 */
    ECLiveChatRoomNoticeType_Join=1,
    
    /** 修改聊天室信息 */
    ECLiveChatRoomNoticeType_ModifyRoomInfo=2,
    
    /** 更改成员角色 */
    ECLiveChatRoomNoticeType_SetMemberRole=3,
    
    /** 踢出成员 */
    ECLiveChatRoomNoticeType_KickMember=4,
    
    /** 退出聊天室 */
    ECLiveChatRoomNoticeType_Eixt=5,
    
    /** 聊天室全员禁言 */
    ECLiveChatRoomNoticeType_AllMute=6,
    
    /** 聊天室全员取消禁言 */
    ECLiveChatRoomNoticeType_CancelAllMute=7,
    
    /** 成员禁言 */
    ECLiveChatRoomNoticeType_MemberMute=8,
    
    /** 成员取消禁言 */
    ECLiveChatRoomNoticeType_CancelMemberMute=9,
    
    /** 成员拉黑 */
    ECLiveChatRoomNoticeType_MemberBlack=10,
    
    /** 成员取消拉黑 */
    ECLiveChatRoomNoticeType_CancelMemberBlack=11,
    
    /** 聊天室关闭 */
    ECLiveChatRoomNoticeType_StopLiveChatRoom=12,
    
} ECLiveChatRoomNoticeType;


/**
 聊天室通知消息
 */
@interface ECLiveChatRoomNoticeMessage : NSObject

@property (nonatomic, assign) ECLiveChatRoomNoticeType type;
/**
 @brief 聊天室房间id
 */
@property (nonatomic, copy) NSString *roomId;

/**
 @brief 聊天室房间名称
 */
@property (nonatomic, copy) NSString *roomName;

/**
 @brief 通知发送者
 */
@property (nonatomic, copy) NSString *sender;

/**
 @brief 聊天室成员id
 */
@property (nonatomic, copy) NSString *userId;

/**
 @brief 聊天室成员昵称
 */
@property (nonatomic, copy) NSString *userName;

/**
 @brief 聊天室角色类型 1创建者 2管理员 3成员
 */
@property (nonatomic, assign) LiveChatRoomMemberRole role;

/**
 @brief 消息发送或接收的时间(发送消息是本地时间，接收消息是服务器时间)
 */
@property (nonatomic, copy) NSString* timestamp;

/**
 @brief 聊天室房间通知透传字段
 */
@property (nonatomic, copy) NSString *notifyExt;
@end
