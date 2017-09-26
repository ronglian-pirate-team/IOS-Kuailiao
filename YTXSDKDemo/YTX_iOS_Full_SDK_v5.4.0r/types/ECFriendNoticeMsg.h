//
//  ECFriendNoticeMsg.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/8/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECBaseNoticeMsg.h"

typedef enum : NSUInteger {
    
    ECFriendNoticeMsg_Type_None,
    
    /** 添加好友通知 */
    ECFriendNoticeMsg_Type_AddFriend = 0,
    
    /** 直接成为好友通知 */
    ECFriendNoticeMsg_Type_BecomeFriend,
    
    /** 同意好友请求通知 */
    ECFriendNoticeMsg_Type_AgreeFriend,
    
    /** 拒绝好友通知 */
    ECFriendNoticeMsg_Type_RejectFriend,
    
    /** 删除好友通知 */
    ECFriendNoticeMsg_Type_DeleteFriend,
} ECFriendNoticeMsg_Type;


@interface ECFriendNoticeMsg : ECBaseNoticeMsg

/**
 @brief 通知消息类型
 */
@property (nonatomic, assign) ECFriendNoticeMsg_Type type;

/**
 @brief 消息的发送者
 */
@property (nonatomic, copy) NSString *sender;

/**
 @brief 好友的账号
 */
@property (nonatomic, copy) NSString *friendAccount;

/**
 @brief 还有头像地址
 */
@property (nonatomic, copy) NSString *avatarUrl;

/**
 @brief 通知消息内容
 */
@property (nonatomic, copy) NSString *noticeMsg;

/**
 @brief 好友来源
 */
@property (nonatomic, copy) NSString *source;


/**
 @brief 是否是好友关系 1 非好友关系 2 好友关系
 */
@property (nonatomic, assign) NSInteger friendState;

@end
