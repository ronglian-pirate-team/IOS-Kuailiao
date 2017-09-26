//
//  ECSession.h
//  CCPiPhoneSDK
//
//  Created by wang ming on 14-12-10.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    
    EC_Session_Type_None,
    
    EC_Session_Type_One,
    
    EC_Session_Type_Group,
    
    EC_Session_Type_Discuss,
    
    EC_Session_Type_System
    
} EC_Session_Type;


@interface ECSession : NSObject

/**
 @brief 区分不同的session
 */
@property (nonatomic, assign) EC_Session_Type type;

/**
 @brief 会话ID
 */
@property (nonatomic, copy) NSString *sessionId;

/**
 @brief session的名称
 */
@property (nonatomic, copy) NSString *sessionName;

/**
 @brief 创建时间 显示的时间 毫秒
 */
@property (nonatomic, assign) long long dateTime;

/**
 @brief 与消息表msgType一样
 */
@property (nonatomic, assign) NSInteger msgType;

/**
 @brief 显示的内容
 */
@property (nonatomic, copy) NSString *text;

/**
 @brief 未读消息数
 */
@property (nonatomic,assign) NSInteger unreadCount;

/**
 @brief 总消息数
 */
@property (nonatomic, assign) int sumCount;

/**
 @brief 是否被@了
 */
@property (nonatomic, assign) BOOL isAt;

/**
 @brief 会话是否置顶
 */
@property (nonatomic, assign) BOOL isTop;

@property (nonatomic, assign) BOOL isGroup;

@property (nonatomic, assign) NSInteger memberCount;

/**
 @property
 @brief isNoDisturb 是否免打扰  YES:免打扰 NO:提示
 */
@property (nonatomic, assign) BOOL isNoDisturb;
@property (nonatomic, assign) BOOL isShow;

/**
 @brief 头像
 */
@property (nonatomic, copy) NSString *avatar;

- (instancetype)initWithSessionId:(NSString *)sessionId;

@end
