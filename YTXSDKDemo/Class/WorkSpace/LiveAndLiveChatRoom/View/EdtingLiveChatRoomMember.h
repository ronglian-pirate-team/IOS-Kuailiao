//
//  EdtingLiveChatRoomMember.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EC_KECNOTIFICATION_LIVECHATROOM_BLACKMEMBER @"EC_KECNOTIFICATION_LIVECHATROOM_BLACKMEMBER"
#define EC_KECNOTIFICATION_LIVECHATROOM_KICKMEMBER @"EC_KECNOTIFICATION_LIVECHATROOM_KICKMEMBER"

@interface EdtingLiveChatRoomMember : UIView

+ (instancetype)animation:(UIView *)supView;
@property (nonatomic, strong) ECLiveChatRoomMember *member;
@end
