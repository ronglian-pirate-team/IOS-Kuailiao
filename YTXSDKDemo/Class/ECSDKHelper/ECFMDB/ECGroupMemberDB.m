//
//  ECGroupMemberDB.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/16.
//
//

#import "ECGroupMemberDB.h"
#import <objc/runtime.h>

#define Table_Name(groupId) [@"GroupMember_" stringByAppendingString:[NSString MD5:groupId]]

@implementation ECGroupMemberDB

+ (instancetype)sharedInstanced {
    static ECGroupMemberDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECGroupMemberDB alloc] init];
    });
    return dbManager;
}

- (void)createGroupMemberTable:(NSString *)groupId{
    NSString *tableName = Table_Name(groupId);
    NSString *sql = [NSString stringWithFormat:@"CREATE table %@ (memberId varchar(32) NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE, display varchar(32), tel varchar(32), mail varchar(32), remark varchar(32), groupId varchar(32), speakStatus INTEGER, role INTEGER, sex INTEGER)", tableName];
    [[ECDBManager sharedInstanced] createTable:tableName sql:sql];
}

- (void)insertGroupMembers:(NSArray *)members inGroup:(NSString *)groupId{
    [self createGroupMemberTable:groupId];
    NSString *tableName = Table_Name(groupId);
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        for (ECGroupMember *member in members) {
            if(![member isKindOfClass:[ECGroupMember class]])
                continue;
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES ('%@','%@','%@','%@','%@','%@',%ld,%ld,%ld)", tableName, member.memberId, [ECCommonTool validateNullStr:member.display], [ECCommonTool validateNullStr:member.tel], [ECCommonTool validateNullStr:member.mail], [ECCommonTool validateNullStr:member.remark], member.groupId, member.speakStatus, member.role, member.sex];
            BOOL isSuccess = [db executeUpdate:sql];
            EC_DB_LOG(@"group member insert success %d", isSuccess);
        }
        [db commit];
    }];
}

- (void)insertGroupMember:(ECGroupMember *)member inGroup:(NSString *)groupId{
    [self createGroupMemberTable:groupId];
    NSString *tableName = Table_Name(groupId);
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES ('%@','%@','%@','%@','%@','%@',%d,%d,%d)", tableName, member.memberId, [ECCommonTool validateNullStr:member.display], [ECCommonTool validateNullStr:member.tel], [ECCommonTool validateNullStr:member.mail], [ECCommonTool validateNullStr:member.remark], member.groupId, (int)member.speakStatus, (int)member.role, (int)member.sex];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"group member insert success %d", isSuccess);
    }];
}

- (void)updateGroupMember:(NSString *)memberId speakerStatus:(ECSpeakStatus)status inGroup:(NSString *)groupId{
    NSString *tableName = Table_Name(groupId);
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ set speakStatus = %d where memberId = %@", tableName, (int)status, memberId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"group member update success %d", isSuccess);
    }];
}

- (void)updateGroupMember:(NSString *)memberId memberRole:(ECMemberRole)role inGroup:(NSString *)groupId{
    NSString *tableName = Table_Name(groupId);
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ set role = %d where memberId = %@", tableName, (int)role, memberId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"group member update success %d", isSuccess);
    }];
}

- (void)deleteMember:(NSString *)memberId inGroup:(NSString *)groupId{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete FROM '%@' where memberId = '%@'", Table_Name(groupId), memberId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"group member delete success %d, sql = %@", isSuccess, sql);
    }];
}

- (void)deleteAllMemberOfGroupId:(NSString *)groupId {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete FROM '%@'", Table_Name(groupId)];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"deleteAllMemberOfGroupId success %d, sql = %@", isSuccess, sql);
    }];
}

- (NSArray *)queryMembers:(NSString *)groupId{
    NSMutableArray *members = [NSMutableArray array];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[@"select * from " stringByAppendingString:Table_Name(groupId)]];
        while ([rs next]) {
            ECGroupMember *m = [[ECGroupMember alloc] init];
            m.memberId = [rs stringForColumn:@"memberId"];
            m.display = [rs stringForColumn:@"display"];
            m.tel = [rs stringForColumn:@"tel"];
            m.mail = [rs stringForColumn:@"mail"];
            m.remark = [rs stringForColumn:@"remark"];
            m.groupId = [rs stringForColumn:@"groupId"];
            m.speakStatus = [rs intForColumn:@"speakStatus"];
            m.role = [rs intForColumn:@"role"];
            m.sex = [rs intForColumn:@"sex"];
            [members addObject:m];
        }
    }];
    return members;
}

- (NSArray *)querySpeakRoleMembers:(NSString *)groupId role:(ECMemberRole)role {
    NSMutableArray *members = [NSMutableArray array];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ Where role = %d " ,Table_Name(groupId),(int)role]];
        while ([rs next]) {
            ECGroupMember *m = [[ECGroupMember alloc] init];
            m.memberId = [rs stringForColumn:@"memberId"];
            m.display = [rs stringForColumn:@"display"];
            m.tel = [rs stringForColumn:@"tel"];
            m.mail = [rs stringForColumn:@"mail"];
            m.remark = [rs stringForColumn:@"remark"];
            m.groupId = [rs stringForColumn:@"groupId"];
            m.speakStatus = [rs intForColumn:@"speakStatus"];
            m.role = [rs intForColumn:@"role"];
            m.sex = [rs intForColumn:@"sex"];
            [members addObject:m];
        }
    }];
    return members;
}

- (NSArray *)querySpeakStatusMembers:(NSString *)groupId speakStatus:(ECSpeakStatus)speakStatus {
    NSMutableArray *members = [NSMutableArray array];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from %@ Where speakStatus = %d " ,Table_Name(groupId),(int)speakStatus]];
        while ([rs next]) {
            ECGroupMember *m = [[ECGroupMember alloc] init];
            m.memberId = [rs stringForColumn:@"memberId"];
            m.display = [rs stringForColumn:@"display"];
            m.tel = [rs stringForColumn:@"tel"];
            m.mail = [rs stringForColumn:@"mail"];
            m.remark = [rs stringForColumn:@"remark"];
            m.groupId = [rs stringForColumn:@"groupId"];
            m.speakStatus = [rs intForColumn:@"speakStatus"];
            m.role = [rs intForColumn:@"role"];
            m.sex = [rs intForColumn:@"sex"];
            [members addObject:m];
        }
    }];
    return members;
}
@end
