//
//  ECGroupMemberDB.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/16.
//
//

#import <Foundation/Foundation.h>
#import "ECDBManager.h"

@interface ECGroupMemberDB : NSObject

+ (instancetype)sharedInstanced;


/**
 @brief 群组成员表创建

 @param groupId 群组id
 */
- (void)createGroupMemberTable:(NSString *)groupId;


/**
 @brief 添加群组成员

 @param members 群组成员数组
 */
- (void)insertGroupMembers:(NSArray *)members inGroup:(NSString *)groupId;


/**
 @brief 添加群组成员

 @param member 待添加的群组成员
 */
- (void)insertGroupMember:(ECGroupMember *)member inGroup:(NSString *)groupId;


/**
 @brief 更新群组发言状态

 @param memberId 带更新成员
 @param status 最新状态
 @param groupId 被更新成员所在群组
 */
- (void)updateGroupMember:(NSString *)memberId speakerStatus:(ECSpeakStatus)status inGroup:(NSString *)groupId;

/**
 @brief 更新群组发言状态
 
 @param memberId 带更新成员
 @param role 成员角色
 @param groupId 被更新成员所在群组
 */
- (void)updateGroupMember:(NSString *)memberId memberRole:(ECMemberRole)role inGroup:(NSString *)groupId;

/**
 @brief 删除群组成员

 @param memberId 待删除成员id
 */
- (void)deleteMember:(NSString *)memberId inGroup:(NSString *)groupId;
- (void)deleteAllMemberOfGroupId:(NSString *)groupId;

/**
 @brief 查询群组成员

 @param groupId 需要查询的群组id
 */
- (NSArray *)queryMembers:(NSString *)groupId;

- (NSArray *)querySpeakRoleMembers:(NSString *)groupId role:(ECMemberRole)role;

- (NSArray *)querySpeakStatusMembers:(NSString *)groupId speakStatus:(ECSpeakStatus)speakStatus;
@end
