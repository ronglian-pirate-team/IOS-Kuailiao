//
//  LiveChatRoomBaseModel.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/26.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "LiveChatRoomBaseModel.h"

@implementation LiveChatRoomBaseModel

+(instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static LiveChatRoomBaseModel *model = nil;
    dispatch_once(&onceToken, ^{
        model = [[[self class] alloc] init];
    });
    return model;
}

@end
