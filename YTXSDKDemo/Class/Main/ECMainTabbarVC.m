//
//  MainTabbarController.m
//  ECSDKDemo_OC
//
//  Created by xt on 2017/7/20.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECMainTabbarVC.h"
#import "KxMenu.h"
#import "AppDelegate.h"
#import "ECFriendManager.h"

@interface ECMainTabbarVC ()

@end

@implementation ECMainTabbarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ECFriendManager sharedInstanced] fetchPersonalInfoFromServer:[ECDevicePersonInfo sharedInstanced].userName completion:^(ECFriend *friend) {
        [ECAppInfo sharedInstanced].contactMgr.selfInfo.useracc = friend.useracc;
        [ECDevicePersonInfo sharedInstanced].avatar = [friend.avatar hasPrefix:@"http"] ? friend.avatar : @"";
    }];
    [[ECFriendManager sharedInstanced] fetchFriendFromServer:^(NSMutableArray *friends) {}];//获取用户好友信息
    [self configChildsVC];
}

#pragma mark - 添加+配置
- (void)extensionOperation:(UIButton *)sender{
    NSArray *menuItems = @[
                           [KxMenuItem menuItem:NSLocalizedString(@"发起群聊",nil)
                                          image:EC_Image_Named(@"messageBtnStartchat")
                                         target:self
                                         action:@selector(startGroupChat)],
                           [KxMenuItem menuItem:NSLocalizedString(@"添加联系人",nil)
                                          image:EC_Image_Named(@"messageBtnAddfriend")
                                         target:self
                                         action:@selector(addContact:)],
                           [KxMenuItem menuItem:NSLocalizedString(@"扫一扫",nil)
                                          image:EC_Image_Named(@"messageBtnSaoyisao")
                                         target:self
                                         action:@selector(scanCode)],
                           ];
    
    CGRect rightF = sender.frame;
    rightF.origin.y = rightF.origin.y + 30;
    [menuItems enumerateObjectsUsingBlock:^(KxMenuItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.foreColor = [UIColor blackColor];
    }];
    [KxMenu setTintColor:EC_Color_White];
    [KxMenu setTitleFont:EC_Font_System(14.0f)];
    [KxMenu showMenuInView:[UIApplication sharedApplication].keyWindow fromRect:rightF menuItems:menuItems];
}

- (void)addContact:(UIButton *)sender{
    UIViewController *afVC = [[NSClassFromString(@"ECAddFriendVC") alloc] init];
    UINavigationController *nav = (UINavigationController *)self.selectedViewController;
    afVC.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:afVC animated:YES];
}

- (void)startGroupChat{
    UIViewController *vc = [[NSClassFromString(@"ECGroupCreateVC") alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.selectedViewController pushViewController:vc animated:YES];
}

- (void)scanCode{
    UIViewController *vc = [[NSClassFromString(@"ECQRCodeScanVC") alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.selectedViewController pushViewController:vc animated:YES];
}

#pragma mark - 配置tabaritem
- (void)configChildsVC {
    UIViewController *sessionVC = [[NSClassFromString(@"ECSessionController") alloc] init];
    sessionVC.title = NSLocalizedString(@"消息",nil);
    UINavigationController *sessionNC = [self configNC:sessionVC withImage:@"messageNavbtnGo"];
    
    UIViewController *connectVC = [[NSClassFromString(@"ECContactController") alloc] init];
    connectVC.title = NSLocalizedString(@"联系人",nil);
    UINavigationController *connectNC = [self configNC:connectVC withImage:@"addressbookNavbtnAddfriend"];
    
    UIViewController *workVC = [[NSClassFromString(@"ECWorkSpaceController") alloc] init];
    workVC.title = NSLocalizedString(@"发现",nil);
    UINavigationController *workNC = [[UINavigationController alloc] initWithRootViewController:workVC];
    
    UIViewController *mineVC = [[NSClassFromString(@"ECMineController") alloc] init];
    mineVC.title = NSLocalizedString(@"我的",nil);
    UINavigationController *mineNC = [[UINavigationController alloc] initWithRootViewController:mineVC];
    self.viewControllers = @[sessionNC, connectNC, workNC, mineNC];
    NSArray *imagesSelect = @[@"messageTabbarXiaoxiHigh", @"addressbookTabbarTongxunluHigh", @"workbenchTabbarGongzuotaiHigh", @"aboutmeTabbarAboutmeHigh"];
    NSArray *images = @[@"addressbookTabbarXiaoxiNormal", @"messageTabbarTongxunluNormal", @"messageTabbarGongzuotaiNormal", @"messageTabbarAboutmeNormal"];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        item.image = [[UIImage imageNamed:images[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:imagesSelect[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
}

- (UINavigationController *)configNC:(UIViewController *)vc withImage:(NSString *)image{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:EC_Image_Named(image) forState:UIControlStateNormal];
    [rightBtn sizeToFit];
    if([vc isKindOfClass:NSClassFromString(@"ECSessionController")])
        [rightBtn addTarget:self action:@selector(extensionOperation:) forControlEvents:UIControlEventTouchUpInside];
    else if([vc isKindOfClass:NSClassFromString(@"ECContactController")])
        [rightBtn addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    return navigationController;
}

@end
