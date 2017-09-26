//
//  AppDelegate+ECSDK.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/18.
//

#import "AppDelegate+ECSDK.h"
#import "ECDeviceDelegateHelper.h"
#import "ECDeviceDelegateConfigCenter.h"
#import <PushKit/PushKit.h>


@implementation AppDelegate (ECSDK)
- (void)ec_configECSDK {
    // 初始化配置
    [[ECDeviceDelegateConfigCenter sharedInstanced] ec_setAppKey:ECSDK_Key AppToken:ECSDK_Token];
    [ECDevice sharedInstance].delegate = [ECDeviceDelegateHelper sharedInstanced];
    
#if DEBUG
    // 是否打开sdk日志
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ecdevice.detail.sdk.log" object:nil];
#endif
    // 注册通知
    [self ec_addNotification];
}

- (void)connectStateChanged:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[ECError class]]) {
        ECError *error = (ECError *)noti.object;
        [ECDeviceDelegateConfigCenter sharedInstanced].isLogin = NO;
        if (error.errorCode == ECErrorType_NoError || error.errorCode == 10 || error.errorCode == ECErrorType_KickedOff) {
            
            if (error.errorCode == ECErrorType_KickedOff || error.errorCode == 10) {
                [AppDelegate sharedInstanced].mainView = nil;
                [ECDevicePersonInfo sharedInstanced].userPassword = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClearSessionDic object:error];
                error.errorCode != ECErrorType_KickedOff?:[[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"警告", nil) message:error.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil] show];
            }
            (error.errorCode == ECErrorType_NoError && [AppDelegate sharedInstanced].mainView)?:[self ec_configLaunchVC];
            
        } else if (error.errorCode != ECErrorType_Connecting
                   && error.errorCode != ECErrorType_TokenAuthFailed
                   && error.errorCode != ECErrorType_AuthServerException
                   && error.errorCode != ECErrorType_ConnectorServerException) {
            EC_Demo_AppLog(@"login faild errcode : %d",(int)error.errorCode);
        }
    }
}
#pragma mark - 通知
- (void)ec_addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChanged:) name:EC_DEMO_kNotification_LoginSucess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChanged:) name:EC_KNotification_ConnectedState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChanged:) name:EC_DEMO_kNotification_EixtSucess object:nil];

    [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_NetworkChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [[ECDeviceHelper sharedInstanced] ec_loginECSdk:^(ECError *error) {
        }];
    }];
    
    [self ec_addECSDKPush];
    [self ec_addECSDKBageNumber];
    [self ec_addECSDKPushKit];
}

#pragma mark - 是否使用ECSDKPush
- (void)ec_addECSDKPush {
    if ([ECDeviceDelegateConfigCenter sharedInstanced].isOpenECSDKPush) {
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_ReceiveDeviceToken object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[NSData class]]) {
                NSData *deviceToken = (NSData *)note.object;
                [[ECDevice sharedInstance] application:[UIApplication sharedApplication] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_ReceiveRemoteNotifyInfo object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *userInfo = (NSDictionary *)note.object;
                [ECDeviceDelegateConfigCenter sharedInstanced].offCallId = nil;
                NSString *userdata = [userInfo objectForKey:@"c"];
                EC_SDKCONFIG_AppLog(@"远程推送userdata:%@",userdata);
                if (userdata) {
                    NSDictionary*callidobj = [NSJSONSerialization JSONObjectWithData:[userdata dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                    EC_SDKCONFIG_AppLog(@"远程推送callidobj:%@",callidobj);
                    if ([callidobj isKindOfClass:[NSDictionary class]]) {
                        [ECDeviceDelegateConfigCenter sharedInstanced].offCallId = [callidobj objectForKey:@"callid"];
                    }
                }
            }
        }];
    }
}

#pragma mark - 是否使用ECSDKBageNumber
- (void)ec_addECSDKBageNumber {
    if ([ECDeviceDelegateConfigCenter sharedInstanced].isOpenECSDKBageNumber) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSInteger count = 0;
            if ([AppDelegate sharedInstanced].mainView) {
                count = [[ECSessionDB sharedInstanced] getTotalUnCountMessageOfSession];
            }
            [UIApplication sharedApplication].applicationIconBadgeNumber = count;
            [[ECDevice sharedInstance] setAppleBadgeNumber:count completion:^(ECError *error) {
                EC_SDKCONFIG_AppLog(@"UIApplicationWillResignActiveNotification bage: %d error:%d",(int)count,(int)error.errorCode);
            }];
            usleep(10);
        }];
    }
}

#pragma mark - 是否使用ECSDKPushKit
- (void)ec_addECSDKPushKit {
    if ([ECDeviceDelegateConfigCenter sharedInstanced].isOpenECSDKPushKit) {
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_ReceiveVoipDeviceToken object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[NSData class]]) {
                PKPushCredentials *pushCredentials = (PKPushCredentials *)note.object;
                [[ECDevice sharedInstance] pushRegistry:nil didUpdatePushCredentials:pushCredentials forType:pushCredentials.type];
            }
        }];
    }
}
@end
