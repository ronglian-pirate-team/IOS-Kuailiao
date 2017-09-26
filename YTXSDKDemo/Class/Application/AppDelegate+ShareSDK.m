//
//  AppDelegate+ShareSDK.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "AppDelegate+ShareSDK.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"

@implementation AppDelegate (ShareSDK)
- (void)ec_configShareSDK {
    [ShareSDK registerApp:@"209748bbc0df8" activePlatforms:@[@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType) {
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            default:
                break;
        }
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:@"wx0f8338c39c481c34"
                                      appSecret:@"fd987624fde0f8b1c421d7f6bed7aaa6"];
                break;
            default:
                break;
        }
    }];
}

@end
