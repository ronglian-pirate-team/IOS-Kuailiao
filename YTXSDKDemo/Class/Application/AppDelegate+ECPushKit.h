//
//  AppDelegate+ECPushKit.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/29.
//

#import "AppDelegate.h"
#import <PushKit/PushKit.h>

@interface AppDelegate (ECPushKit)<PKPushRegistryDelegate>

- (void)ec_registerPushKit;

@end
