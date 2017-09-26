//
//  ECDemoGroupManage+Admin.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/9.
//

#import "ECDemoGroupManage+Admin.h"
#import <objc/runtime.h>

@implementation ECDemoGroupManage (Admin)

const char ec_group_adminmerberKey;

- (void)setAdminMembers:(NSMutableArray *)adminMembers{
    objc_setAssociatedObject(self, &ec_group_adminmerberKey, adminMembers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)adminMembers {
    NSMutableArray *adminM = objc_getAssociatedObject(self, &ec_group_adminmerberKey);
    if (adminM.count == 0)
        adminM = [NSMutableArray arrayWithArray:[[ECDBManager sharedInstanced].groupMemberMgr querySpeakRoleMembers:[ECDemoGroupManage sharedInstanced].group.groupId role:ECMemberRole_Admin]];
    return adminM;
}

- (NSArray *)queryOrdinaryMembers {
    NSArray *members = [NSMutableArray arrayWithArray:[[ECDBManager sharedInstanced].groupMemberMgr querySpeakRoleMembers:[ECDemoGroupManage sharedInstanced].group.groupId role:ECMemberRole_Member]];
    [self configSearchManager:members];
    return members;
}

@end
