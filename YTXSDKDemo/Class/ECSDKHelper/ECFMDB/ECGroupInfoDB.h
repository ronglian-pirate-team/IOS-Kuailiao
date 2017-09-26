//
//  ECGroupInfoDB.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECGroupInfoDB : NSObject
+ (instancetype)sharedInstanced;

- (void)createGroupInfoTable;
- (void)selectGroupWithType:(ECGroupType)type completion:(void (^)(NSArray *array))completion;
- (void)insertGroups:(NSArray *)groups;
- (void)insertGroup:(ECGroup *)group;
- (void)updateGroupNotice:(BOOL)isNotice ofGroupId:(NSString *)groupId;
- (void)updateGroupPushAPNS:(BOOL)isPushAPNS ofGroupId:(NSString *)groupId;
- (void)updateGroupSelfRole:(NSInteger)selfRole ofGroupId:(NSString *)groupId;
- (ECGroup *)selectGroupOfGroupId:(NSString *)groupId;
- (NSString *)getGroupNameOfId:(NSString *)groupId;
- (void)deleteAllGroupList;
- (void)deleteGroupWithId:(NSString *)groupId;
@end
