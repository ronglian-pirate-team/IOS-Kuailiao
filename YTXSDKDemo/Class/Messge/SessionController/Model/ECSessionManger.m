//
//  ECSessionManger.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import "ECSessionManger.h"
#import "ECVoipCallManage.h"
#import "ECDemoGroupManage.h"

@implementation ECSessionManger

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECSessionManger *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [ECVoipCallManage sharedInstanced];
        [ECDemoGroupManage sharedInstanced];
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_ClickSession object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECSession class]]) {
                ECSession *session = (ECSession *)note.object;
                self.session = session;
                session.unreadCount = 0;
                session.isAt = NO;
                [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_ClearSessionDic object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [ECDBManagerUtil sharedInstanced].sessionDic = nil;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_EixtSucess object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [ECDBManagerUtil sharedInstanced].sessionDic = nil;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_KNotice_ReloadSession object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            ECSession *session = nil;
            if ([note.object isKindOfClass:[ECGroup class]]) {
                ECGroup *group = (ECGroup *)note.object;
                session = [ECDBManager sharedInstanced].dbMgrUtil.sessionDic[group.groupId];
                if (session) {
                    session.sessionName = group.name;
                    session.type = group.isDiscuss?EC_Session_Type_Discuss:EC_Session_Type_Group;
                    session.isNoDisturb = !group.isNotice;
                    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
                    if (self.ec_reloadSessionBlock) {
                        self.ec_reloadSingleSessionBlock(session);
                    }
                }
            } else if ([note.object isKindOfClass:[ECSession class]]) {
                ECSession *tempSession = note.object;
                session = [ECDBManager sharedInstanced].dbMgrUtil.sessionDic[tempSession.sessionId];
                if (self.ec_reloadSessionBlock && session) {
                    session.isTop = tempSession.isTop;
                    self.ec_reloadSingleSessionBlock(session);
                }
            } else {
                [ECDBManager sharedInstanced].dbMgrUtil.sessionDic = [[ECDBManager sharedInstanced].sessionMgr selectSessionCompletion:nil];
                [self fetchData];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:EC_DEMO_KNotice_SessionWillAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:EC_KNOTIFICATION_ReceiveNewMesssage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:EC_KNOTIFICATION_ReceivedGroupNoticeMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:EC_KNOTIFICATION_onReceiveFriendNotiMsg object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:EC_KNOTIFICATION_HistoryMessageCompletion object:nil];

        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_KNotice_HandleSession object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSInteger handleType = [note.userInfo[@"type"] integerValue];
            ECSession *session = note.object;
            if (handleType == 1) {
                session.unreadCount = 0;
                [[ECDBManager sharedInstanced].dbMgrUtil deleteSessionOfSessionId:session.sessionId];
                [self fetchData];
            } else if (handleType == 2) {
                [[ECDBManager sharedInstanced].sessionMgr updateSessionTop:session.sessionId isTop:session.isTop];
                if(!session.isTop)
                    [self fetchData];
            }
        }];
    }
    return self;
}

- (void)ec_setSessionTop:(BOOL)isTop completion:(void(^)(ECError *error, NSString *seesionId))completion {
    EC_WS(self);
    [[ECDevice sharedInstance].messageManager setSession:self.session.sessionId IsTop:isTop completion:^(ECError *error, NSString *seesionId) {
        if (error.errorCode != ECErrorType_NoError) {
            EC_Demo_AppLog(@"setSessiontop:%@",error.description);
        } else {
            weakSelf.session.isTop = isTop;
            [[ECDBManager sharedInstanced].sessionMgr updateSessionTop:seesionId isTop:isTop];
            [[ECDBManagerUtil sharedInstanced].sessionDic setValue:weakSelf.session forKey:seesionId];      
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadSession object:self.session];
            if (completion)
                completion(error,seesionId);
        });
    }];
}

- (void)fetchData {
    NSMutableArray *sessionArray = [[ECDBManagerUtil sharedInstanced].sessionArray mutableCopy];
    NSString *badgeValue = [NSString stringWithFormat:@"%d",(int)[[ECDBManager sharedInstanced].sessionMgr getUndisturbUnCountMessageOfSession]];
    if (badgeValue.intValue > 99)
        badgeValue = @"99+";
    else if (badgeValue.intValue <= 0)
        badgeValue = nil;
    if (self.ec_reloadSessionBlock)
        self.ec_reloadSessionBlock(sessionArray, badgeValue);
}

@end
