//
//  LiveChatRoomMemberController.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/24.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveChatRoomInfoController.h"


typedef void(^tapPersonView)(ECLiveChatRoomMember *member);

typedef void(^tapRoomInfoView)(LiveChatRoomInfoController *vc);


@interface LiveChatRoomMemberController : UIViewController

@property (nonatomic, strong) tapPersonView block;

@property (nonatomic, strong) tapRoomInfoView vcBlock;

@property (nonatomic, copy) NSString *roomId;

@end
