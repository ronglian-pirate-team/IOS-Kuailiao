//
//  ECJoinLiveChatRoomRequest.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/5/11.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 加入直播聊天室请求
 */
@interface ECJoinLiveChatRoomRequest : NSObject

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

/**
 @brief 加入聊天室是否需要通知.0 不通知 1 通知(默认1)
 */
@property (nonatomic, assign) BOOL needNotify;

/**
 @brief 加入聊天室通知透传字段
 */
@property (nonatomic, copy) NSString *notifyExt;

@end
