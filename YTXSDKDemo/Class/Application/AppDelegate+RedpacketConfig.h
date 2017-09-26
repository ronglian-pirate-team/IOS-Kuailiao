//
//  AppDelegate+RedpacketConfig.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AppDelegate.h"

#pragma mark -红包- 红包头文件
#import "YZHRedpacketBridgeProtocol.h"
#import "RedpacketOpenConst.h"
#import "AlipaySDK.h"
#import "AFNetworking.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"
#import "RedpacketViewControl.h"

#import "ECAppInfo.h"

@interface AppDelegate (RedpacketConfig) <YZHRedpacketBridgeDataSource,RedpacketViewControlDelegate>

@property (nonatomic, strong) RedpacketViewControl *redpacketViewControl;

// 初始化红包sdk
- (void)ec_configRedpacket;

- (void)sendRedpacketMessage;
@end
