//
//  AppDelegate+ECRemoteNotification.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/18.
//

#import "AppDelegate+ECRemoteNotification.h"

@implementation AppDelegate (ECRemoteNotification)

- (void)ec_registerRemoteNotification {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {

    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    EC_AlterShow(NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns), error.description, NSLocalizedString(@"确定", @"OK"));
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ReceiveDeviceToken object:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    EC_Demo_AppLog(@"%@--%@",@"推送的内容：",userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ReceiveRemoteNotifyInfo object:userInfo];
}
@end
