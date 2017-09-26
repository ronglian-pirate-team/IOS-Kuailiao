//
//  ECDeviceDelegateConfigCenter.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/26.
//
//

#import "ECDeviceDelegateConfigCenter.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ECDeviceNotifyMacros.h"

#define EC_UserDefault_MessageSound            [NSString stringWithFormat:@"%@_MessageSound",[ECDevicePersonInfo sharedInstanced].userName]
#define EC_UserDefault_MessageShake             [NSString stringWithFormat:@"%@_MessageShake",[ECDevicePersonInfo sharedInstanced].userName]
#define EC_UserDefault_PlayEar           [NSString stringWithFormat:@"%@_PlayEar",[ECDevicePersonInfo sharedInstanced].userName]

@interface ECDeviceDelegateConfigCenter ()
@property (nonatomic, strong) NSDate* preDate;
@property (nonatomic, assign) BOOL isAppToBackground;
@end

@implementation ECDeviceDelegateConfigCenter
{
    SystemSoundID receiveSound;
}

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECDeviceDelegateConfigCenter *cls = nil;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isOpenECSDKPush = YES;
        self.isOpenECSDKBageNumber = YES;
        self.isOpenECSDKPushKit = YES;
        self.isContainIM = YES;
        self.isContainVoip = YES;
        self.isContainMeeting = YES;
        self.offLineMessageCount = -1;
        self.isMessageSound = YES;
        self.isStoreAllMessage = YES;
        self.isContainRedPacket = YES;
        self.loginAuthType = LoginAuthType_NormalAuth;
        self.chat_RevokeMessageTime = 120000;
        if ([self isSDKSupportVoIP]) {
            [ECDeviceVoipHelper sharedInstanced];
            [[ECDeviceVoipHelper sharedInstanced] SetLasterSaveCodec];
        }

        //添加通知
        [self registerNoti];
    }
    return self;
}

- (void)playRecMsgSound:(NSNotification *)noti {
    ECMessage *message = nil;
    if ([noti.object isKindOfClass:[ECMessage class]]) {
        message = (ECMessage *)noti.object;
    }
    //应用程序在后台接收到的消息，统一没有声音
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        return;
    
    if (!receiveSound) {
        NSString *fileName = self.receiveFileName.length>0?self.receiveFileName:@"receive_msg.caf";
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName.stringByDeletingPathExtension ofType:fileName.pathExtension];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,
                                                        &receiveSound);
        if (err != kAudioServicesNoError)
            EC_SDKCONFIG_AppLog(@"%@ Could not load %@, error code: %d", NSLocalizedString(@"消息铃声", nil),soundURL, (int)err);
    }
    
    //去除同步消息铃声
//    if (noti.object && [noti.object isKindOfClass:[ECMessage class]]) {
//        if ([(ECMessage *)noti.object messageState] == ECMessageState_Receive)
//            return;
//    }
    //后台切前台接收消息判断
    if (self.preDate==nil) {
        self.preDate = [NSDate date];
    }
    if (self.isAppToBackground && self.preDate != nil && [self.preDate timeIntervalSinceNow]>-1) {
        self.preDate = [NSDate date];
        return;
    }
    
    BOOL isNoDisturb = [ECSession queryNoDisturbOptionOfSessionid:message.sessionId];
    //播放声音
    if ([ECDeviceDelegateConfigCenter sharedInstanced].isMessageSound && !self.isConversation && !isNoDisturb)
        AudioServicesPlaySystemSound(receiveSound);
    
    //震动
    if ([ECDeviceDelegateConfigCenter sharedInstanced].isMessageShake)
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

-(void)ec_setAppKey:(NSString *)appKey AppToken:(NSString *)AppToken {
    [[ECDeviceHelper sharedInstanced] ec_setAppKey:appKey AppToken:AppToken];
}

#pragma mark - 通知
- (void)registerNoti {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        self.isAppToBackground = YES;
        self.preDate = nil;
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        self.isAppToBackground = NO;
        self.preDate = [NSDate date];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playRecMsgSound:) name:EC_KNOTIFICATION_ReceiveNewMesssage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playRecMsgSound:) name:EC_KNOTIFICATION_ReceivedGroupNoticeMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playRecMsgSound:) name:EC_KNOTIFICATION_SendNewMesssage object:nil];
}

- (BOOL)isSDKSupportVoIP {
    return ([ECDevice sharedInstance].VoIPManager != nil);
}

#pragma mark - 基本属性
- (void)setIsMessageSound:(BOOL)isMessageSound {
    [[NSUserDefaults standardUserDefaults] setValue:@(isMessageSound) forKey:EC_UserDefault_MessageSound];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (BOOL)isMessageSound {
    NSNumber *sound = [[NSUserDefaults standardUserDefaults] objectForKey:EC_UserDefault_MessageSound];
    return sound.boolValue;
}

- (void)setIsMessageShake:(BOOL)isMessageShake {
    [[NSUserDefaults standardUserDefaults] setValue:@(isMessageShake) forKey:EC_UserDefault_MessageShake];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (BOOL)isMessageShake {
    NSNumber *shake = [[NSUserDefaults standardUserDefaults] objectForKey:EC_UserDefault_MessageShake];
    return shake.boolValue;
}

- (void)setIsPlayEar:(BOOL)isPlayEar {
    [[NSUserDefaults standardUserDefaults] setValue:@(isPlayEar) forKey:EC_UserDefault_PlayEar];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isPlayEar {
    NSNumber *playEar = [[NSUserDefaults standardUserDefaults] objectForKey:EC_UserDefault_PlayEar];
    return playEar.boolValue;
}

#pragma mark - dealloc
- (void)dealloc {
    AudioServicesDisposeSystemSoundID(receiveSound);
}
@end
