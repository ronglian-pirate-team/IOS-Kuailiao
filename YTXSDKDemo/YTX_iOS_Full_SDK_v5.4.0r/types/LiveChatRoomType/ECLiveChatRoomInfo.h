//
//  ECLiveChatRoomInfo.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/8.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 直播聊天室信息
 */
@interface ECLiveChatRoomInfo : NSObject

/**
 @brief 创建者
 */
@property (nonatomic, copy) NSString *creator;

/**
 @brief 房间id
 */
@property (nonatomic, copy) NSString *roomId;

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
 @brief 聊天室在线人数
 */
@property (nonatomic, assign) NSInteger onlineCount;

/**
 @brief 是否全员禁言 0 不禁言 1全员禁言 默认0
 */
@property (nonatomic, assign) BOOL isAllMuteMode;

/**
 @brief 拉流地址
 */
@property (nonatomic, copy) NSString *pullUrl;
@end
