//
//  AppDelegate.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/20.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+ShareSDK.h"
#import "AppDelegate+ECBQMM.h"
#import "AppDelegate+ECSDK.h"
#import "AppDelegate+RedpacketConfig.h"
#import "AppDelegate+ECRemoteNotification.h"
#import "AppDelegate+ECPushKit.h"

#import <Bugly/Bugly.h>

#import "CustomEmojiView.h"
#import "ECDemoLoginController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

+ (instancetype)sharedInstanced {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self ec_registerRemoteNotification];
    [self ec_registerPushKit];
    [self ec_configAppTheme];
    [self configThirdPart];
    [self ec_configAPPManage];
    [self ec_configLaunchVC];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - 配置第三方库

- (void)configThirdPart{
    [ECAFNHttpTool sharedInstanced];
    [self ec_configECSDK];
    [self ec_configShareSDK];
    NSString *emojiStr = [[NSBundle mainBundle] pathForResource:@"ECEmoji.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:emojiStr];
    [[CustomEmojiView shardInstance] setDefaultEmojiArray:array];
    [self ec_configBQMM:array];
}

#pragma mark - 打开App进入页面设置.有登录信息的进入tabbar页面,没有登录信息的进入登录页
- (void)ec_configLaunchVC {
    UIViewController *rootView = nil;
    UIViewController *loginView = nil;
    if ([ECAppInfo sharedInstanced].userName && [ECAppInfo sharedInstanced].pwd) {
        self.mainView = [[ECMainTabbarVC alloc] init];
        rootView = self.mainView;
    } else {
        loginView = [[ECDemoLoginController alloc] init];
        rootView = [[UINavigationController alloc] initWithRootViewController:loginView];
    }
    self.window.rootViewController = rootView;
}

#pragma mark - 配置App样式，NavigationBar、Tabbar等等

- (void)ec_configAppTheme{
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:EC_Color_White}];
    [[UINavigationBar appearance] setBarTintColor:EC_Color_App_Main];
    [[UINavigationBar appearance] setTintColor:EC_Color_White];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:EC_Color_App_Main,NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:EC_Color_App_Main} forState:UIControlStateSelected];
    [[UITabBar appearance] setBarTintColor:EC_Color_Tabbar];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - 配置数据库设置

- (void)ec_configAPPManage{
    [ECAppInfo sharedInstanced];
}

- (UINavigationController *)rootNav {
    UINavigationController *nav = nil;
    if([[AppDelegate sharedInstanced].window.rootViewController isKindOfClass:[UITabBarController class]]){
        ECMainTabbarVC *tabbarVC = (ECMainTabbarVC *)[AppDelegate sharedInstanced].window.rootViewController;
        if ([tabbarVC.selectedViewController isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *)tabbarVC.selectedViewController;
        }
    }
    return nav;
}

- (UIViewController *)currentVC {
    UIViewController *vc = nil;
    if (self.rootNav.visibleViewController)
        vc = self.rootNav.visibleViewController;
    else if (self.rootNav.topViewController)
        vc = self.rootNav.topViewController;
    return vc;
}
@end
