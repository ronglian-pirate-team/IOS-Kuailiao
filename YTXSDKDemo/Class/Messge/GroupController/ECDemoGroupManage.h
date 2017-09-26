//
//  ECDemoGroupManage.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/6.
//

#import <Foundation/Foundation.h>
#import "ECGroup.h"

#define EC_DEMO_KNotice_ReloadGroupSetTable @"EC_DEMO_KNotice_ReloadGroupSetTable"
#define EC_DEMO_KNotice_ReloadGroupMember @"EC_DEMO_KNotice_ReloadGroupMember"
#define EC_DEMO_KNotice_ReloadGroupCreateChange @"EC_DEMO_KNotice_ReloadGroupCreateChange"

@interface ECDemoGroupManage : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) ECGroup *group;
@property (nonatomic, strong) NSMutableArray *members;

- (void)queryGroup:(void(^)(ECGroup *demoGroup))completion;

- (void)queryGroupMembers:(void(^)(NSArray *demoMember))completion;

- (void)groupNoticeSet:(BOOL)isOpen;
- (void)groupAPNSSet:(BOOL)isOpen;

- (void)modifyMemberCard:(ECGroupMember *)groupMember;
- (void)deleteGroup:(NSString *)groupId;
- (void)exitGroup:(NSString *)groupId;

- (void)configSearchManager:(NSArray *)unForbidMembers;
- (NSMutableArray *)searchMembers:(NSString *)text inMembers:(NSArray *)members;

@end
