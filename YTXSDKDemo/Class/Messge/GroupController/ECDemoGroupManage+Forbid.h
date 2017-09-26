//
//  ECDemoGroupManage+Forbid.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/9.
//

#import "ECDemoGroupManage.h"

#define EC_DEMO_KNotice_ReloadGroupForbidMember @"EC_DEMO_KNotice_ReloadGroupForbidMember"

@interface ECDemoGroupManage (Forbid)

@property (nonatomic, strong) NSMutableArray *forbidMembers;

- (NSArray *)unForbidMembers;

- (void)forbidAllMember:(BOOL)isForbid;

- (void)forbidMembers:(NSArray *)members completion:(void(^)())completion;
- (void)unForbidMembers:(NSArray *)members completion:(void(^)())completion;
@end
