//
//  ECLiveChatRoomDelegate.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/5/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECLiveChatRoomNoticeMessage.h"

@protocol ECLiveChatRoomDelegate <NSObject>

/**
 收到聊天室的消息

 @param message 消息体
 */
- (void)onReceiveLiveChatRoomMessage:(ECMessage *)message;

/**
 收到聊天室的通知消息

 @param msg 通知消息体
 */
- (void)onReceiveLiveChatRoomNoticeMessage:(ECLiveChatRoomNoticeMessage *)msg;

@end
