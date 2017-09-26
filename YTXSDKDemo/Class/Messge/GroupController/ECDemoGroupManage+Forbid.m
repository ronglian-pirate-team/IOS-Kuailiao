//
//  ECDemoGroupManage+Forbid.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/9.
//

#import "ECDemoGroupManage+Forbid.h"
#import <objc/runtime.h>

@implementation ECDemoGroupManage (Forbid)

const char ec_group_forbidmerberKey;

- (void)setForbidMembers:(NSArray *)forbidMembers {
    objc_setAssociatedObject(self, &ec_group_forbidmerberKey, forbidMembers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)forbidMembers {
    NSMutableArray *forbidM = objc_getAssociatedObject(self, &ec_group_forbidmerberKey);
    if (forbidM.count == 0)
        forbidM = [NSMutableArray arrayWithArray:[[ECDBManager sharedInstanced].groupMemberMgr querySpeakStatusMembers:[ECDemoGroupManage sharedInstanced].group.groupId speakStatus:ECSpeakStatus_Forbid]];
    return forbidM;
}

- (NSArray *)unForbidMembers {
    NSArray *unForbidM = [[ECDBManager sharedInstanced].groupMemberMgr querySpeakStatusMembers:[ECDemoGroupManage sharedInstanced].group.groupId speakStatus:ECSpeakStatus_Allow];
    [self configSearchManager:unForbidM];
    return unForbidM;
}

- (void)forbidMembers:(NSArray *)members completion:(void(^)())completion {
    [self baseForbidMembers:members status:ECSpeakStatus_Forbid completion:completion];
}

- (void)unForbidMembers:(NSArray *)members completion:(void(^)())completion {
    [self baseForbidMembers:members status:ECSpeakStatus_Allow completion:completion];
}

- (void)baseForbidMembers:(NSArray *)members status:(ECSpeakStatus)status completion:(void(^)())completion {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    for (ECGroupMember *member in members) {
        dispatch_group_enter(dispatchGroup);
        [[ECDevice sharedInstance].messageManager forbidMemberSpeakStatus:self.group.groupId member:member.memberId speakStatus:status completion:^(ECError *error, NSString *groupId, NSString *memberId) {
            dispatch_group_leave(dispatchGroup);
            if(error.errorCode == ECErrorType_NoError){
                member.speakStatus = status;
                if(status == ECSpeakStatus_Forbid)
                    [[ECDemoGroupManage sharedInstanced].forbidMembers addObject:member];
                else if (status == ECSpeakStatus_Allow)
                    [[ECDemoGroupManage sharedInstanced].forbidMembers removeObject:member];
                [[ECDBManager sharedInstanced].groupMemberMgr updateGroupMember:memberId speakerStatus:status inGroup:groupId];
            } else {
                EC_Demo_AppLog(@"禁言失败:%@",error.errorDescription)
                [ECCommonTool toast:NSLocalizedString(@"禁言失败", nil)];
            }
        }];
    }
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        if (completion)
            completion();
    });
}
#pragma mark - 全员禁言设置
- (void)forbidAllMember:(BOOL)isForbid {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    ECSpeakStatus status = isForbid ? ECSpeakStatus_Forbid : ECSpeakStatus_Allow;
    for (ECGroupMember *member in self.members) {
        if(member.role == ECMemberRole_Creator || [ECDemoGroupManage sharedInstanced].group.selfRole == member.role)
            continue;
        dispatch_group_enter(dispatchGroup);
        [[ECDevice sharedInstance].messageManager forbidMemberSpeakStatus:[ECDemoGroupManage sharedInstanced].group.groupId member:member.memberId speakStatus:status completion:^(ECError *error, NSString *groupId, NSString *memberId) {
            dispatch_group_leave(dispatchGroup);
            if(error.errorCode == ECErrorType_NoError){
                member.speakStatus = status;
                if(isForbid){
                    [self.forbidMembers addObject:member];
                } else {
                    if ([self.forbidMembers indexOfObject:member] != NSNotFound) {
                        [self.forbidMembers removeObject:member];
                    };
                }
                [[ECDBManager sharedInstanced].groupMemberMgr updateGroupMember:memberId speakerStatus:status inGroup:groupId];
            }else{
                EC_Demo_AppLog(@"forbidAllMember:%@",error.errorDescription)
            }
        }];
    }
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupForbidMember object:nil];
    });
}
@end
