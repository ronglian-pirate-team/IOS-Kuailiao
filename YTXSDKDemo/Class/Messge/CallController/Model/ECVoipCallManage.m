//
//  ECVoipCallManage.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/5.
//
//

#import "ECVoipCallManage.h"
#import "ECCallVoiceView.h"
#import "ECCallVideoView.h"

@implementation ECVoipCallManage

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECVoipCallManage *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_Voip_OnIncomingReceiveInfo object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [[AppDelegate sharedInstanced].currentVC.view endEditing:YES];
            if (note.userInfo) {
                NSDictionary *dict = note.userInfo;
                CallType calltype = (CallType)[[dict objectForKey:EC_KVoip_CallType] integerValue];
                if(calltype == VOICE){
                    ECCallVoiceView *callView = [[ECCallVoiceView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
                    callView.callNumber = dict[EC_KVoip_Caller];
                    callView.isIncomingCall = YES;
                    callView.callId = dict[EC_KVoip_CallId];
                    [callView show];
                }else if (calltype == VIDEO){
                    ECCallVideoView *callView = [[ECCallVideoView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
                    callView.callNumber = dict[EC_KVoip_Caller];
                    callView.isIncomingCall = YES;
                    callView.callId = dict[EC_KVoip_CallId];
                    [callView show];
                }
            }
        }];

    }
    return self;
}

@end
