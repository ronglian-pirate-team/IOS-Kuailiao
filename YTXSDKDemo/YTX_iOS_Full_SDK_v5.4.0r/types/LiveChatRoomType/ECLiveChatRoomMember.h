//
//  ECLiveChatRoomMember.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/5/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    
    /** 聊天室房间创建者*/
    LiveChatRoomMemberRole_Creator=1,
    
    /** 聊天室房间管理者*/
    LiveChatRoomMemberRole_Admin=2,
    
    /** 聊天室房间成员*/
    LiveChatRoomMemberRole_Member=3,
    
} LiveChatRoomMemberRole;

@interface ECLiveChatRoomMember : NSObject
/**
 @brief 房间id
 */
@property (nonatomic, copy) NSString *roomId;

/**
 @brief 用户id
 */
@property (nonatomic, copy) NSString *useId;

/**
 @brief 聊天室内个人昵称
 */
@property (nonatomic, copy) NSString *nickName;

/**
 @brief 聊天室个人信息透传
 */
@property (nonatomic, copy) NSString *infoExt;

/**
 @brief 进入聊天室的时间
 */
@property (nonatomic, copy) NSString *enterTime;

/**
 @brief 聊天室角色类型 1创建者 2管理员 3成员
 */
@property (nonatomic, assign) LiveChatRoomMemberRole type;

/**
 @brief 是否禁言.0 取消禁言 1禁言
 */
@property (nonatomic, assign) BOOL isMute;

/**
 @brief 禁言时长
 */
@property (nonatomic, assign) NSInteger muteDuration;

/**
 @brief 是否拉黑.0 取消拉黑 1拉黑
 */
@property (nonatomic, assign) BOOL isBlack;

@end
