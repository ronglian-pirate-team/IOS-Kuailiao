//
//  AppDelegate.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/20.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECMainTabbarVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) ECMainTabbarVC *mainView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) UINavigationController *rootNav;

+ (instancetype)sharedInstanced ;

- (void)ec_configLaunchVC;

@end

