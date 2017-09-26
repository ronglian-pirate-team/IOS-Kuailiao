//
//  LiveChatRoomBaseModel.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/26.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECLiveChatRoomListModel.h"

@interface LiveChatRoomBaseModel : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) ECLiveChatRoomInfo *roomInfo;

@property (nonatomic, assign) LiveChatRoomMemberRole type;

@property (nonatomic, strong) ECLiveChatRoomListModel *roomModel;

@property (nonatomic, assign) BOOL cancelBlack;

@property (nonatomic, copy) NSString *nickName;
@end
