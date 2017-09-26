//
//  ECAddRequestDB.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import "ECAddRequestDB.h"

static NSString *addRequestTable = @"add_request_table";

@implementation ECAddRequestDB

+ (instancetype)sharedInstanced {
    static ECAddRequestDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECAddRequestDB alloc] init];
    });
    return dbManager;
}

- (void)createAddRequestTable{
    NSString *sql = [NSString stringWithFormat:@"CREATE table %@ (friendUseracc varchar(64) NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE, dealState varchar(2), isInvited varchar(2), message TEXT, source varchar(2), extend varchar(32))", addRequestTable];
    [[ECDBManager sharedInstanced] createTable:addRequestTable sql:sql];
}

- (NSMutableArray *)queryAllRequest{
    NSMutableArray *addRequestArr = [NSMutableArray array];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@", addRequestTable];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            ECAddRequestUser *addRequestUser = [[ECAddRequestUser alloc] init];
            addRequestUser.friendUseracc = [rs stringForColumn:@"friendUseracc"];
            addRequestUser.dealState = [rs stringForColumn:@"dealState"];
            addRequestUser.isInvited = [rs stringForColumn:@"isInvited"];
            addRequestUser.message = [rs stringForColumn:@"message"];
            addRequestUser.source = [rs stringForColumn:@"source"];
            [addRequestArr addObject:addRequestUser];
        }
    }];
    return addRequestArr;
}

- (void)insertAddRequest:(ECAddRequestUser *)user{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ values ('%@','%@','%@','%@','%@','%@')", addRequestTable, user.friendUseracc, user.dealState, user.isInvited, user.message, user.source, @""];
        [db executeUpdate:sql];
    }];
}

- (void)insertAddRequests:(NSArray *)addRequests{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        for (ECAddRequestUser *user in addRequests) {
            if(![user isKindOfClass:[ECAddRequestUser class]])
                continue;
            NSString *sql = [NSString stringWithFormat:@"insert into %@ values ('%@','%@','%@','%@','%@','%@')", addRequestTable, user.friendUseracc, user.dealState, user.isInvited, user.message, user.source, @""];
            [db executeUpdate:sql];
        }
        [db commit];
    }];

}

- (void)updateRequestStatus:(NSString *)status onRequest:(NSString *)useracc{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set dealState = %@ where friendUseracc = '%@'", addRequestTable, status, useracc];
        [db executeUpdate:sql];
    }];
}

@end
