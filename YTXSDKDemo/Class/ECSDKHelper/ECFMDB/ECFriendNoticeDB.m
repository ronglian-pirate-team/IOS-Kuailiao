//
//  ECFriendNoticeDB.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import "ECFriendNoticeDB.h"

#define EC_IM_friendnotice @"EC_IM_friendnotice"


@implementation ECFriendNoticeDB

+ (instancetype)sharedInstanced {
    static ECFriendNoticeDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[[self class] alloc] init];
    });
    return dbManager;
}

- (void)createFriendNoticeTable {
    [[ECDBManager sharedInstanced] createTable:EC_IM_friendnotice sql:[NSString stringWithFormat:@"CREATE table %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, sender varchar(32),friendAccount varchar(32),avatarUrl varchar(32),type INTEGER,noticeMsg varchar(32),source varchar(32),nickName varchar(32),dateCreated varchar(32), friendState INTEGER, isRead INTEGER, remark varchar(32))",EC_IM_friendnotice]];
}

- (void)insertFriendNoticeMessage:(ECFriendNoticeMsg *)msg {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:EC_IM_friendnotice])
            [self createFriendNoticeTable];
        
        BOOL isSuccess = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (sender, friendAccount, nickName,type, avatarUrl, noticeMsg, source, dateCreated, friendState, isRead, remark) VALUES ('%@','%@','%@','%d','%@','%@','%@','%@','%d', '%d','%@')",EC_IM_friendnotice,EC_ValidateNullStr(msg.sender), EC_ValidateNullStr(msg.friendAccount), EC_ValidateNullStr(msg.nickName), (int)msg.type, EC_ValidateNullStr(msg.avatarUrl), EC_ValidateNullStr(msg.noticeMsg), EC_ValidateNullStr(msg.source), EC_ValidateNullStr(msg.dateCreated), (int)msg.friendState,(int)msg.isRead, @""]];
        EC_DB_LOG(@"insertFriendNoticeMessage insert success %d", isSuccess);
    }];
}

- (void)deleteFriendNoticeMsg:(ECFriendNoticeMsg *)msg {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ WHERE sender = '%@' AND friendAccount='%@'",EC_IM_friendnotice,msg.sender,msg.friendAccount];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"deleteFriendNoticeMsg success %d", isSuccess);
    }];
}

- (void)deleteAllFriendNoticeMsg {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@",EC_IM_friendnotice];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"deleteAllFriendNoticeMsg success %d", isSuccess);
    }];
}

- (void)updateFriendNoticeMsg:(ECFriendNoticeMsg *)msg {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET nickName='%@',type='%d', avatarUrl='%@', noticeMsg='%@', source='%@', dateCreated='%@', friendState='%d',isRead='%d', remark='%@' WHERE sender = '%@' AND friendAccount='%@'",EC_IM_friendnotice, msg.nickName,(int)msg.type,msg.avatarUrl,msg.noticeMsg,msg.source,msg.dateCreated,(int)msg.friendState,(int)msg.isRead ,@"", msg.sender,msg.friendAccount];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"isSuccess = %d", isSuccess);
    }];
}

- (void)queryAllFriendNoticeMsg:(void (^)(NSArray *array))completion {
    __block NSMutableArray *array = [NSMutableArray array];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ ",EC_IM_friendnotice];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            ECFriendNoticeMsg *msg = [[ECFriendNoticeMsg alloc] init];
            msg.sender = [rs stringForColumn:@"sender"];
            msg.friendAccount = [rs stringForColumn:@"friendAccount"];
            msg.type = (ECFriendNoticeMsg_Type)[rs intForColumn:@"type"];
            msg.avatarUrl = [rs stringForColumn:@"avatarUrl"];
            msg.dateCreated = [rs stringForColumn:@"dateCreated"];
            msg.noticeMsg = [rs stringForColumn:@"noticeMsg"];
            msg.source = [rs stringForColumn:@"source"];
            msg.friendState = [rs intForColumn:@"friendState"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            msg.isRead = [rs intForColumn:@"isRead"];
            [array addObject:msg];
        }
        [rs close];
    }];
    if (completion)
        completion(array);
}

- (ECFriendNoticeMsg *)queryFriendNoticeMsgWithSender:(NSString *)sender andFriendAccount:(NSString *)friendAccount {
    __block ECFriendNoticeMsg *msg = [[ECFriendNoticeMsg alloc] init];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ WHERE sender = '%@' AND friendAccount='%@'",EC_IM_friendnotice,sender,friendAccount];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            msg.sender = [rs stringForColumn:@"sender"];
            msg.friendAccount = [rs stringForColumn:@"friendAccount"];
            msg.type = (ECFriendNoticeMsg_Type)[rs intForColumn:@"type"];
            msg.avatarUrl = [rs stringForColumn:@"avatarUrl"];
            msg.dateCreated = [rs stringForColumn:@"dateCreated"];
            msg.noticeMsg = [rs stringForColumn:@"noticeMsg"];
            msg.source = [rs stringForColumn:@"source"];
            msg.friendState = [rs intForColumn:@"friendState"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            msg.isRead = [rs intForColumn:@"isRead"];
        }
        [rs close];
    }];
    return msg;
}

@end
