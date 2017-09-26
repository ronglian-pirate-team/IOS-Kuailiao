//
//  LiveChatRoomController.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/8.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveChatRoomTool.h"

#define EC_kNotificationCenter_ClickMessageSender @"EC_kNotificationCenter_ClickMessageSender"

#define ECMsgH 160

@interface LiveChatRoomController : UIViewController<LiveChatRoomToolDelegate>
@property (nonatomic, copy) NSString *chatRoomId;
@end
