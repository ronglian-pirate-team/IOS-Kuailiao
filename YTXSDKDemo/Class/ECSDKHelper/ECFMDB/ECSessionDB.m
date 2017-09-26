//
//  ECSessionDB.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECSessionDB.h"
#import "ECDBManager.h"

@interface ECSessionDB()

@property (nonatomic, strong) NSMutableDictionary *sessionDic;

@end

@implementation ECSessionDB

+(instancetype)sharedInstanced {
    static ECSessionDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECSessionDB alloc] init];
    });
    return dbManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)createSessionTable{
    [[ECDBManager sharedInstanced] createTable:@"session" sql:@"CREATE table session (sessionId TEXT NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE,sessionName varchar(32),type INTEGER, dateTime INTEGER,msgType INTEGER,text varchar(2048),unreadCount INTEGER,sumCount INTEGER,isAt INTEGER,isTop INTEGER, isNoDisturb INTEGER , isShow INTEGER)"];
}

- (NSMutableDictionary *)selectSessionCompletion:(void (^)(NSArray *array))completion{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * from session where isShow = '%d'",1];
        NSMutableDictionary *sessionDic = [NSMutableDictionary dictionary];
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *noticeArr = [NSMutableArray array];
        while ([rs next]) {
            ECSession *session = [[ECSession alloc] init];
            session.sessionId = [rs stringForColumn:@"sessionId"];
            session.sessionName = [rs stringForColumn:@"sessionName"];
            session.dateTime = [rs longLongIntForColumn:@"dateTime"];
            session.type = (EC_Session_Type)[rs intForColumn:@"type"];
            session.msgType = [rs intForColumn:@"msgType"];
            session.text = [rs stringForColumn:@"text"];
            session.unreadCount = [rs intForColumn:@"unreadCount"];
            session.sumCount = [rs intForColumn:@"sumCount"];
            session.isAt = [rs intForColumn:@"isAt"];
            session.isTop = [rs intForColumn:@"isTop"];
            session.isNoDisturb = [rs intForColumn:@"isNoDisturb"];
            session.isShow = [rs intForColumn:@"isShow"];
            [sessionDic setObject:session forKey:session.sessionId];
            [noticeArr addObject:session];
        }
        [rs close];
        if (completion) {
            completion(noticeArr);
        }
        self.sessionDic = sessionDic;
    }];
    return self.sessionDic;
}

- (void)updateShowSession:(ECSession *)session isShow:(BOOL)isShow {
    session.isShow = isShow;
    [self updateSession:session];
}

- (void)updateSession:(ECSession *)session {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isSuccess = [db executeUpdate:@"INSERT INTO session VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", session.sessionId,session.sessionName,@(session.type), @(session.dateTime), @(session.msgType), session.text, @(session.unreadCount), @(session.sumCount), @(session.isAt), @(session.isTop),@(session.isNoDisturb),@(session.isShow)];
        EC_DB_LOG(@"session insert success = %d", isSuccess);
    }];
}

- (ECSession *)selectSession:(NSString *)sessionId {
    __block ECSession *session = [[ECSession alloc] init];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * from session where sessionId = '%@'", sessionId];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            session.sessionId = [rs stringForColumn:@"sessionId"];
            session.sessionName = [rs stringForColumn:@"sessionName"];
            session.dateTime = [rs longLongIntForColumn:@"dateTime"];
            session.type = (EC_Session_Type)[rs intForColumn:@"type"];
            session.msgType = [rs intForColumn:@"msgType"];
            session.text = [rs stringForColumn:@"text"];
            session.unreadCount = [rs intForColumn:@"unreadCount"];
            session.sumCount = [rs intForColumn:@"sumCount"];
            session.isAt = [rs intForColumn:@"isAt"];
            session.isTop = [rs intForColumn:@"isTop"];
            session.isNoDisturb = [rs intForColumn:@"isNoDisturb"];
            session.isShow = [rs intForColumn:@"isShow"];
        }
        [rs close];
    }];
    return session;
}

- (void)deleteSession:(NSString *)sessionId{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from session where sessionId = '%@'", sessionId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"session delete success = %d", isSuccess);
    }];
}

- (void)deleteAllSession {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from session"];
        [db executeUpdate:sql];
    }];
}

- (void)updateSessionTop:(NSString *)sessionId isTop:(BOOL)isTop{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE session SET isTop=%d WHERE sessionid='%@' ",(int)isTop, sessionId];
        [db executeUpdate:sql];
    }];
}

- (NSInteger)getUndisturbUnCountMessageOfSession {
    __block NSInteger sessionTotalCount = 0;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select sum(unreadCount) FROM session where isNoDisturb=0 "]];
        while ([rs next]) {
            sessionTotalCount = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return sessionTotalCount;
}

- (NSInteger)getTotalUnCountMessageOfSession {
    __block NSInteger sessionTotalCount = 0;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select sum(unreadCount) FROM session"]];
        while ([rs next]) {
            sessionTotalCount = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return sessionTotalCount;
}

- (void)updateSessionNoDisturb:(BOOL)isNoDisturb ofSessionId:(NSString *)sessionId {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isSuccess = [db executeUpdate:@"UPDATE session SET isNoDisturb=? WHERE sessionId=?", @(isNoDisturb), sessionId];
        EC_DB_LOG(@"updateSessionNoDisturb success = %d", isSuccess);
    }];
}

@end
