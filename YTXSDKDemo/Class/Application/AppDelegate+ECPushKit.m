//
//  AppDelegate+ECPushKit.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/29.
//

#import "AppDelegate+ECPushKit.h"

@implementation AppDelegate (ECPushKit)

- (void)ec_registerPushKit {
    PKPushRegistry *pkPush = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pkPush.delegate = self;
    pkPush.desiredPushTypes = [NSSet setWithObjects:PKPushTypeVoIP, nil];
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ReceiveVoipDeviceToken object:pushCredentials];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    
}
@end
