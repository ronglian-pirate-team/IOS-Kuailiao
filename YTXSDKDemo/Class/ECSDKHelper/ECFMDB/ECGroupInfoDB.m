//
//  ECGroupInfoDB.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECGroupInfoDB.h"
#import "ECDBManager.h"

@implementation ECGroupInfoDB

+ (instancetype)sharedInstanced {
    static ECGroupInfoDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECGroupInfoDB alloc] init];
    });
    return dbManager;
}

- (void)createGroupInfoTable{
    [[ECDBManager sharedInstanced] createTable:@"im_groupinfo" sql:@"CREATE table im_groupinfo (groupId TEXT NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE, owner varchar(32), createdTime varchar(32), name varchar(32), declared TEXT, remark TEXT, scope INTEGER, mode INEGER, type INTEGER, isDismiss INTEGER, isDiscuss INTEGER, isPushAPNS INTEGER, isNotice INTEGER, province varchar(32), city varchar(32), memberCount INTEGER, selfRole INTEGER);"];
}

- (void)selectGroupWithType:(ECGroupType)type completion:(void (^)(NSArray *array))completion{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isDiscuss = (type == ECGroupType_Discuss);
        NSString *sql = [NSString stringWithFormat:@"SELECT * from im_groupinfo where isDiscuss = '%d'", isDiscuss];
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *groupArr = [NSMutableArray array];
        while ([rs next]) {
            ECGroup *group = [[ECGroup alloc] init];
            group.groupId = [rs stringForColumn:@"groupId"];
            group.owner = [rs stringForColumn:@"owner"];
            group.createdTime = [rs stringForColumn:@"createdTime"];
            group.name = [rs stringForColumn:@"name"];
            group.declared = [rs stringForColumn:@"declared"];
            group.remark = [rs stringForColumn:@"remark"];
            group.scope = [rs intForColumn:@"scope"];
            group.mode = [rs intForColumn:@"mode"];
            group.remark = [rs stringForColumn:@"remark"];
            group.type = [rs intForColumn:@"type"];
            group.province = [rs stringForColumn:@"province"];
            group.city = [rs stringForColumn:@"city"];
            group.memberCount = [rs intForColumn:@"memberCount"];
            group.isDismiss = [rs boolForColumn:@"isDismiss"];
            group.isDiscuss = [rs boolForColumn:@"isDiscuss"];
            group.isPushAPNS = [rs boolForColumn:@"isPushAPNS"];
            group.isNotice = [rs boolForColumn:@"isNotice"];
            group.selfRole = [rs intForColumn:@"selfRole"];
            [groupArr addObject:group];
        }
        [rs close];
        if (completion) {
            completion(groupArr);
        }
    }];
}

- (void)insertGroups:(NSArray *)groups{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        for (ECGroup *group in groups) {
            if(![group isKindOfClass:[ECGroup class]])
                continue;
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO im_groupinfo VALUES ('%@','%@','%@','%@','%@','%@','%d','%d','%d','%d','%d','%d','%d','%@','%@','%d','%d')", group.groupId, group.owner, group.createdTime, group.name, group.declared, group.remark, (int)group.scope, (int)group.mode, (int)group.type, group.isDismiss, group.isDiscuss, group.isPushAPNS, group.isNotice, EC_ValidateNullStr(group.province), EC_ValidateNullStr(group.city),(int)group.memberCount,(int)group.selfRole];
            BOOL isSuccess = [db executeUpdate:sql];
            EC_DB_LOG(@"insertGroup isSuccess: %d",(int)isSuccess);
        }
        [db commit];
    }];
}

- (void)insertGroup:(ECGroup *)group{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO im_groupinfo VALUES ('%@','%@','%@','%@','%@','%@','%d','%d','%d','%d','%d','%d','%d','%@','%@','%d','%d')", group.groupId, group.owner, group.createdTime, group.name, group.declared, group.remark, (int)group.scope, (int)group.mode, (int)group.type, group.isDismiss, group.isDiscuss, group.isPushAPNS, group.isNotice, EC_ValidateNullStr(group.province), EC_ValidateNullStr(group.city),(int)group.memberCount,(int)group.selfRole];
       BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"insertGroup isSuccess: %d",(int)isSuccess);
    }];
}

- (ECGroup *)selectGroupOfGroupId:(NSString *)groupId {
    
    __block ECGroup *group = [[ECGroup alloc] init];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM im_groupinfo WHERE groupId=?",groupId];
        while ([rs next]) {
            group.groupId = [rs stringForColumn:@"groupId"];
            group.owner = [rs stringForColumn:@"owner"];
            group.createdTime = [rs stringForColumn:@"createdTime"];
            group.name = [rs stringForColumn:@"name"];
            group.declared = [rs stringForColumn:@"declared"];
            group.scope = [rs intForColumn:@"scope"];
            group.mode = [rs intForColumn:@"mode"];
            group.remark = [rs stringForColumn:@"remark"];
            group.type = [rs intForColumn:@"type"];
            group.province = EC_ValidateNullStr([rs stringForColumn:@"province"]);
            group.city = EC_ValidateNullStr([rs stringForColumn:@"city"]);
            group.isDismiss = [rs boolForColumn:@"isDismiss"];
            group.isDiscuss = [rs boolForColumn:@"isDiscuss"];
            group.isPushAPNS = [rs boolForColumn:@"isPushAPNS"];
            group.isNotice = [rs boolForColumn:@"isNotice"];
            group.memberCount = [rs intForColumn:@"memberCount"];
            group.selfRole = [rs intForColumn:@"selfRole"];
        }
        [rs close];
    }];
    return group;
}

- (void)updateGroupNotice:(BOOL)isNotice ofGroupId:(NSString *)groupId {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isSuccess = [db executeUpdate:@"UPDATE im_groupinfo SET isNotice=? WHERE groupId=?", @(isNotice), groupId];
        EC_DB_LOG(@"updateGroupNotice success = %d", isSuccess);
    }];
}

- (void)updateGroupPushAPNS:(BOOL)isPushAPNS ofGroupId:(NSString *)groupId {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isSuccess = [db executeUpdate:@"UPDATE im_groupinfo SET isPushAPNS=? WHERE groupId=?", @(isPushAPNS), groupId];
        EC_DB_LOG(@"updateGroupPushAPNS success = %d", isSuccess);
    }];
}

- (void)updateGroupSelfRole:(NSInteger)selfRole ofGroupId:(NSString *)groupId {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isSuccess = [db executeUpdate:@"UPDATE im_groupinfo SET selfRole=? WHERE groupId=?", @(selfRole), groupId];
        EC_DB_LOG(@"updateGroupSelfRole success = %d", isSuccess);
    }];
}

- (NSString *)getGroupNameOfId:(NSString *)groupId {
    
    __block NSString *groupName = nil;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT name FROM im_groupinfo WHERE groupId=?",groupId];
        if ([rs next]) {
            groupName = [rs stringForColumn:@"name"];
        }
        [rs close];
    }];
    return groupName;
}

- (void)deleteGroupWithId:(NSString *)groupId{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from im_groupinfo where groupId = '%@'", groupId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"delete group success = %d", isSuccess);
    }];
}

- (void)deleteAllGroupList {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from im_groupinfo"];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"deleteAllGroupList success = %d", isSuccess);
    }];
}
@end
