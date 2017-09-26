//
//  ECSessionFetchModel.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECSessionFetchModel.h"

@implementation ECSessionFetchModel

+ (instancetype)sharedInstanced {
    static ECSessionFetchModel *cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_KNotice_ReloadSessionGroup object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            ECSession *session = nil;
            if ([note.object isKindOfClass:[ECGroup class]]) {
                ECGroup *group = (ECGroup *)note.object;
                session = [ECDBManager sharedInstanced].dbMgrUtil.sessionDic[group.groupId];
                if (session) {
                    session.sessionName = group.name;
                    session.type = group.isDiscuss?EC_Session_Type_Discuss:EC_Session_Type_Group;
                    session.isNoDisturb = !group.isNotice;
                    [[ECSessionDB sharedInstanced] updateSession:session];
                    if (self.ec_reloadSessionBlock) {
                        self.ec_reloadSessionBlock(session);
                    }
                }
            }
        }];
    }
    return self;
}
@end
