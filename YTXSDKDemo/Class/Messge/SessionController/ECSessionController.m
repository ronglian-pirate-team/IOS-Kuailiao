//
//  ECSessionController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/19.
//  Copyright © 2017年 huangjue. All rights reserved.
//

#import "ECSessionController.h"
#import "ECNavigationLoadingView.h"
#import "ECDevice.h"
#import "ECSessionView.h"
#import "ECSessionManger.h"

@interface ECSessionController ()

@property (nonatomic, strong) ECNavigationLoadingView *loadingView;
@property (nonatomic, strong) ECSessionView *sessionView;

@end

@implementation ECSessionController

#pragma mark - 通知
- (void)ec_addNotify {
    EC_WS(self);
    [ECSessionManger sharedInstanced].ec_reloadSingleSessionBlock = ^(ECSession *session) {
        [weakSelf.sessionView ec_reloadSingleRowWithSession:session];
    };
    [ECSessionManger sharedInstanced].ec_reloadSessionBlock = ^(NSMutableArray *sessionArray, NSString *badgeValue) {
        weakSelf.sessionView.sessionArray = [sessionArray mutableCopy];
        [(UITabBarItem *)[weakSelf.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:badgeValue];
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_SessionWillAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStatusChange:) name:EC_KNotification_ConnectedState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStatusChange:) name:EC_DEMO_kNotification_LoginSucess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStatusChange:) name:EC_KNOTIFICATION_HistoryMessageCompletion object:nil];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        self.navigationItem.titleView = self.loadingView;
    }];
}

#pragma mark - 类私有方法
- (void)connectStatusChange:(NSNotification *)noti{
    self.navigationItem.titleView = self.loadingView;
    self.navigationItem.title = NSLocalizedString(@"消息",nil);
    if ([noti.object isKindOfClass:[ECError class]]) {
        ECError* error = (ECError *)noti.object;
        if (error.errorCode == ECErrorType_NoError) {
            self.navigationItem.titleView = nil;
            self.sessionView.linkState = EC_CONNECTED_LinkState_Success;
        } else if (error.errorCode == ECErrorType_Connecting) {
            self.loadingView.title = NSLocalizedString(@"连接中...",nil);
            self.sessionView.linkState = EC_CONNECTED_LinkState_Linking;
        } else if (error.errorCode == 171139 || error.errorCode ==
                   171251 || error.errorCode == 170003 || error.errorCode == 171137 || error.errorCode == 171140) {
            self.navigationItem.titleView = nil;
            self.navigationItem.title = NSLocalizedString(@"未连接",nil);
            self.sessionView.linkState = EC_CONNECTED_LinkState_Failed;
        } else {
            self.navigationItem.titleView = nil;
            self.sessionView.linkState = EC_CONNECTED_LinkState_Failed;
        }
        EC_Demo_AppLog(@"%s____%ld",__func__,(long)error.errorCode);
    } else if ([noti.object isKindOfClass:[NSNumber class]]) {
        NSNumber *isCompletion = noti.object;
        if (isCompletion.boolValue)
            self.navigationItem.titleView = nil;
    }
}

#pragma mark - UI创建
- (void)buildUI{
    [self.view addSubview:self.sessionView];
    EC_WS(self)
    [_sessionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    [self loginWithHaveUserLogined];
    [super buildUI];
}

- (void)loginWithHaveUserLogined {
    if (![ECDeviceDelegateConfigCenter sharedInstanced].isLogin)
        [[ECDeviceHelper sharedInstanced] ec_loginECSdk:^(ECError *error) {
        }];
}

#pragma mark - 懒加载
- (ECNavigationLoadingView *)loadingView{
    if(!_loadingView)
        _loadingView = [[ECNavigationLoadingView alloc] initWihTitle:NSLocalizedString(@"收取中...",nil)];
    return _loadingView;
}

- (ECSessionView *)sessionView {
    if (!_sessionView) {
        EC_WS(self);
        _sessionView = [[ECSessionView alloc] initWithBlock:^(ECSession *session) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickSession object:session];
            UIViewController *vc = nil;
            if (session.type == EC_Session_Type_One || session.type == EC_Session_Type_Group || session.type == EC_Session_Type_Discuss) {
                vc = [[NSClassFromString(@"ECChatController") alloc] init];
            } else if(session.type == EC_Session_Type_System){
                vc = [[NSClassFromString(@"ECNoticeController") alloc] init];
            }
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _sessionView;
}
@end
