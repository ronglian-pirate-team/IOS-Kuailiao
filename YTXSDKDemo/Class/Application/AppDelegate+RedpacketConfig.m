//
//  AppDelegate+RedpacketConfig.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AppDelegate+RedpacketConfig.h"
#import "ECMessage+RedpacketMessage.h"
#import <objc/runtime.h>

@implementation AppDelegate (RedpacketConfig)

- (void)ec_configRedpacket
{
    [[YZHRedpacketBridge sharedBridge] setDataSource:[AppDelegate sharedInstanced]];
    [YZHRedpacketBridge sharedBridge].redacketURLScheme = [[NSBundle mainBundle].infoDictionary objectForKey:(__bridge NSString*)kCFBundleIdentifierKey];
//    [YZHRedpacketBridge sharedBridge].isDebug = YES;
}

- (RedpacketUserInfo *)redpacketUserInfo
{
    RedpacketUserInfo *user = [[RedpacketUserInfo alloc] init];
    ECAppInfo * selfUser = [ECAppInfo sharedInstanced];
    user.userId = [selfUser.persionInfo userName];
    user.userNickname = [selfUser.persionInfo nickName];
    user.userAvatar = nil;
    return user;
}

- (NSString *)userId
{
    if ([[ECAppInfo sharedInstanced] userName]) {
        return [ECAppInfo sharedInstanced].userName;
    }
    return nil;
}

#pragma mark - 初始化控制器的红包逻辑
- (void)sendRedpacketMessage {
    RedpacketViewControl *redpacketViewControl = self.redpacketViewControl;
    // 设置发送红包和抢红包的回调
    [redpacketViewControl setRedpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
    } andRedpacketBlock:^(RedpacketMessageModel *model) {
        NSString *text = [NSString stringWithFormat:@"[容联云红包]%@",model.redpacket.redpacketGreeting];
        NSString *userData = [ECMessage voluationModele:model];
        ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];
        ECMessage *message = [[ECMessage alloc] initWithReceiver:[ECAppInfo sharedInstanced].sessionMgr.session.sessionId body:messageBody];
        message.userData = userData;
        message.rpModel = model;
        [[ECDeviceHelper sharedInstanced] ec_sendMessage:message];
    }];
    [redpacketViewControl presentRedPacketViewControllerWithType:RPSendRedPacketViewControllerSingle memberCount:0];
}

#pragma mark - RedpacketViewControlDelegate
- (void)getGroupMemberListCompletionHandle:(void (^)(NSArray<RedpacketUserInfo *> *))completionHandle {
    NSArray *groupMembers = [[ECGroupMemberDB sharedInstanced] queryMembers:[ECAppInfo sharedInstanced].sessionMgr.session.sessionId];
    NSMutableArray *groupMemberList = [[NSMutableArray alloc]init];
    for (ECGroupMember *member in groupMembers) {
        RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
        userInfo.userId = member.memberId;//可唯一标识用户的ID
        userInfo.userNickname = member.display;//用户昵称
        userInfo.userAvatar = nil; //用户头像地址
        if ([userInfo.userId isEqualToString:[ECAppInfo sharedInstanced].userName]) {
            // 专属红包不可以发送给自己
        }else{
            [groupMemberList addObject:userInfo];
        }
    }
    completionHandle(groupMemberList);
}
#pragma mark - redpacketViewControl
const char ec_redpacketControl;

- (void)setRedpacketViewControl:(RedpacketViewControl *)redpacketViewControl {
    objc_setAssociatedObject(self, &ec_redpacketControl, redpacketViewControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RedpacketViewControl *)redpacketViewControl {
    RedpacketViewControl *control = objc_getAssociatedObject(self, &ec_redpacketControl);
    if (control==nil) {
        control = [[RedpacketViewControl alloc] init];
        control.delegate = [AppDelegate sharedInstanced];
    }
    control.conversationController = [AppDelegate sharedInstanced].currentVC;
    //  需要当前聊天窗口的会话ID
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = [ECAppInfo sharedInstanced].sessionMgr.session.sessionId;
    control.converstationInfo = userInfo;
    self.redpacketViewControl = control;
    return control;
}
#pragma mark -红包- ------- Alipay

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    return YES;
}
@end
