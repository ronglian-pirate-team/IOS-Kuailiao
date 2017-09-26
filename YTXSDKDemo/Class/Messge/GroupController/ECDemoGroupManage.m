//
//  ECDemoGroupManage.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/6.
//

#import "ECDemoGroupManage.h"
#import "SearchCoreManager.h"

@interface ECDemoGroupManage ()
@property (nonatomic, copy) NSString *groupId;
@end

@implementation ECDemoGroupManage

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECDemoGroupManage *model = nil;
    dispatch_once(&onceToken, ^{
        model = [[[self class] alloc] init];
    });
    return model;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.members = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchGroupDetail:) name:EC_DEMO_kNotification_ClickNav_Item object:nil];
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_ClickSession object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECSession class]]) {
                ECSession *session = (ECSession *)note.object;
                self.groupId = session.sessionId;
                [[ECDBManager sharedInstanced].groupMemberMgr createGroupMemberTable:self.groupId];
                ECGroup *group = [[ECDBManager sharedInstanced].groupInfoMgr selectGroupOfGroupId:self.groupId];
                if (session.isGroup) {
                    NSArray *members = [[ECDBManager sharedInstanced].groupMemberMgr queryMembers:session.sessionId];
                    if (members.count == 0 || group.memberCount != members.count) {
                        [self queryGroupMembers:nil];
                    }
                }
            }
        }];
    }
    return self;
}

- (void)fetchGroupDetail:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[NSString class]]) {
        EC_WS(self);
        weakSelf.groupId = (NSString *)noti.object;
    }
}

- (void)queryGroup:(void (^)(ECGroup *demoGroup))completion {
    EC_WS(self);
    [[ECDevice sharedInstance].messageManager getGroupDetail:weakSelf.groupId completion:^(ECError *error, ECGroup *group) {
        if(error.errorCode == ECErrorType_NoError){
            weakSelf.group = group;
        } else {
            weakSelf.group = [[ECDBManager sharedInstanced].groupInfoMgr selectGroupOfGroupId:weakSelf.groupId];
        }
        if (group.memberCount != weakSelf.members.count)
            [weakSelf queryGroupMembers:nil];
        [[ECDBManager sharedInstanced].groupInfoMgr insertGroup:group];
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupSetTable object:nil];
        if (completion)
            completion(weakSelf.group);
    }];
}

- (void)queryGroupMembers:(void(^)(NSArray *demomember))completion {
    EC_WS(self);
    [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupId completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if(error.errorCode != ECErrorType_NoError){
            members = [[ECDBManager sharedInstanced].groupMemberMgr queryMembers:groupId];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[ECDBManager sharedInstanced].groupMemberMgr insertGroupMembers:members inGroup:weakSelf.groupId];
            });
        }
        for (ECGroupMember *member in members) {
            if([member.memberId isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]){
                weakSelf.group.selfRole = member.role;
                [[ECDBManager sharedInstanced].groupInfoMgr updateGroupSelfRole:member.role ofGroupId:weakSelf.groupId];
                break;
            }
        }
        weakSelf.members = [[members sortedArrayUsingComparator:^NSComparisonResult(ECGroupMember *obj1, ECGroupMember *obj2) {
            if(obj1.role < obj2.role) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }] mutableCopy];
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupMember object:members];
        if (completion)
            completion(members);
    }];
}

- (void)groupNoticeSet:(BOOL)isOpen {
    ECGroupOption *option = [[ECGroupOption alloc] init];
    option.isNotice = !isOpen;
    option.isPushAPNS = [ECDemoGroupManage sharedInstanced].group.isPushAPNS;
    option.groupId = [ECDemoGroupManage sharedInstanced].group.groupId;
    [ECDemoGroupManage sharedInstanced].group.isNotice = !isOpen;
    [[ECDevice sharedInstance].messageManager setGroupMessageOption:option completion:^(ECError *error, NSString *groupId) {
        if(error.errorCode == ECErrorType_NoError){
            [[ECDBManager sharedInstanced].groupInfoMgr updateGroupNotice:!isOpen ofGroupId:groupId];
            [[ECDBManager sharedInstanced].sessionMgr updateSessionNoDisturb:isOpen ofSessionId:groupId];
            [ECCommonTool toast:NSLocalizedString(@"设置成功",nil)];
        } else {
            [ECCommonTool toast:NSLocalizedString(@"设置失败",nil)];
            [ECDemoGroupManage sharedInstanced].group.isNotice = isOpen;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupSetTable object:nil];
    }];
}

- (void)groupAPNSSet:(BOOL)isOpen {
    ECGroupOption *option = [[ECGroupOption alloc] init];
    option.isNotice = [ECDemoGroupManage sharedInstanced].group.isNotice;
    option.isPushAPNS = isOpen;
    option.groupId = [ECDemoGroupManage sharedInstanced].group.groupId;
    [ECDemoGroupManage sharedInstanced].group.isPushAPNS = isOpen;
    [[ECDevice sharedInstance].messageManager setGroupMessageOption:option completion:^(ECError *error, NSString *groupId) {
        if(error.errorCode == ECErrorType_NoError){
            [ECCommonTool toast:NSLocalizedString(@"设置成功",nil)];
            [[ECDBManager sharedInstanced].groupInfoMgr updateGroupPushAPNS:!isOpen ofGroupId:groupId];
        } else {
            [ECCommonTool toast:NSLocalizedString(@"设置失败",nil)];
            [ECDemoGroupManage sharedInstanced].group.isPushAPNS = !isOpen;
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupSetTable object:nil];
        }
    }];
}

- (void)modifyMemberCard:(ECGroupMember *)groupMember {
    [[ECDevice sharedInstance].messageManager modifyMemberCard:groupMember completion:^(ECError *error, ECGroupMember *member) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedInstanced].currentVC.view animated:YES];
        if (error.errorCode == ECErrorType_NoError) {
            [ECCommonTool toast:@"名片保存成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_PopViewController object:nil];
            });
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            EC_Demo_AppLog(@"名片保存失败:%@",detail);
            [ECCommonTool toast:@"名片保存失败"];
        }
    }];
}

- (void)deleteGroup:(NSString *)groupId {
    [[ECDevice sharedInstance].messageManager deleteGroup:groupId completion:^(ECError *error, NSString *groupId) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedInstanced].currentVC.view animated:YES];
        if (error.errorCode == ECErrorType_NoError){
            [ECCommonTool toast:NSLocalizedString(@"解散群组成功",nil)];
            [[ECDBManager sharedInstanced].sessionMgr deleteSession:groupId];
            [[ECDBManager sharedInstanced].groupInfoMgr deleteGroupWithId:groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadSession object:nil];
            [[AppDelegate sharedInstanced].rootNav popToRootViewControllerAnimated:YES];
        } else {
            EC_Demo_AppLog(@"解散群组%@",error.errorDescription)
            [ECCommonTool toast:NSLocalizedString(@"解散失败", nil)];
        };
    }];
}

- (void)exitGroup:(NSString *)groupId {
    [[ECDevice sharedInstance].messageManager quitGroup:groupId completion:^(ECError *error, NSString *groupId) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedInstanced].currentVC.view animated:YES];
        if (error.errorCode == ECErrorType_NoError){
            [ECCommonTool toast:NSLocalizedString(@"退出群组成功",nil)];
            [[ECDBManager sharedInstanced].groupInfoMgr deleteGroupWithId:[ECDemoGroupManage sharedInstanced].group.groupId];
            [[ECDBManager sharedInstanced].sessionMgr deleteSession:groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadSession object:nil];
            NSArray *vcs = [AppDelegate sharedInstanced].rootNav.viewControllers;
            UIViewController *vc = vcs[vcs.count - 3];
            [[AppDelegate sharedInstanced].rootNav popToViewController:vc animated:YES];
        } else {
            EC_Demo_AppLog(@"退出group%@",error.errorDescription)
            [ECCommonTool toast:NSLocalizedString(@"退出失败", nil)];
        }
    }];
}

#pragma mark - 懒加载
- (ECGroup *)group {
    if (!_group || (_group && ![self.groupId isEqualToString:_group.groupId])) {
        _group = [[ECDBManager sharedInstanced].groupInfoMgr selectGroupOfGroupId:self.groupId];
    }
    return _group;
}

- (NSMutableArray *)members {
    if (_members.count==0 || (_members.count>0 && ![[_members.firstObject groupId] isEqualToString:self.groupId])) {
        _members = [NSMutableArray arrayWithArray:[[ECDBManager sharedInstanced].groupMemberMgr queryMembers:self.groupId]];
    }
    [self configSearchManager:_members];
    return _members;
}


- (void)configSearchManager:(NSArray *)unForbidMembers{
    [[SearchCoreManager share] Reset];
    for (int i = 0; i < unForbidMembers.count; i++) {
        ECGroupMember *member = unForbidMembers[i];
        if(![member isKindOfClass:[ECGroupMember class]])
            continue;
        [[SearchCoreManager share] AddContact:@(i) name:member.display phone:@[member.memberId]];
    }
}

- (NSMutableArray *)searchMembers:(NSString *)text inMembers:(NSArray *)members{
    NSMutableArray *searchArr = [NSMutableArray array];
    NSMutableArray *nameArr = [NSMutableArray array];
    NSMutableArray *useraccArr = [NSMutableArray array];
    [[SearchCoreManager share] SearchWithFunc:@"22233344455566677778889999" searchText:text searchArray:nil nameMatch:nameArr phoneMatch:useraccArr];
    if (useraccArr.count>0) {
        for (NSNumber *index in useraccArr) {
            [searchArr addObject:members[index.integerValue]];
        }
    }else if (nameArr.count>0) {
        for (NSNumber *index in nameArr) {
            [searchArr addObject:members[index.integerValue]];
        }
    }
    return searchArr;
}

@end
