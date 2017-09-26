//
//  ECFriendDB.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import "ECFriendDB.h"
#import "ECFriend.h"

static NSString *friendTable = @"friend_table";

@implementation ECFriendDB

+ (instancetype)sharedInstanced {
    static ECFriendDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECFriendDB alloc] init];
    });
    return dbManager;
}

- (void)createFriendTable{
    NSString *sql = [NSString stringWithFormat:@"CREATE table %@ (useracc varchar(64) NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE, phoneNumber varchar(32), region TEXT, avatar TEXT, friendState varchar(2), nickName varchar(32), firstLetter varchar(2), remark varchar(32), sex INTEGER, sign TEXT, age varchar(32), extend varchar(32))", friendTable];
    [[ECDBManager sharedInstanced] createTable:friendTable sql:sql];
}

- (NSMutableArray *)queryAllFriend{
    NSMutableArray *allFriend = [NSMutableArray array];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * from friend_table where friendState = '1'"];
        while ([rs next]) {
            ECFriend *friend = [[ECFriend alloc] init];
            friend.useracc = [rs stringForColumn:@"useracc"];
            friend.avatar = [rs stringForColumn:@"avatar"];
            friend.friendState = [rs stringForColumn:@"friendState"];
            friend.nickName = [rs stringForColumn:@"nickName"];
            friend.remarkName = [rs stringForColumn:@"remark"];
            friend.phoneNumber = [rs stringForColumn:@"phoneNumber"];
            friend.region = [rs stringForColumn:@"region"];
            friend.sign = [rs stringForColumn:@"sign"];
            friend.age = [rs stringForColumn:@"age"];
            friend.sex = [rs intForColumn:@"sex"];
            [allFriend addObject:friend];
        }
    }];
    return allFriend;
}

- (ECFriend *)queryFriend:(NSString *)friendId{
    __block ECFriend *friend = nil;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [@"SELECT * from friend_table where useracc = " stringByAppendingFormat:@"'%@'", friendId];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            friend = [[ECFriend alloc] init];
            friend.useracc = [rs stringForColumn:@"useracc"];
            friend.avatar = [rs stringForColumn:@"avatar"];
            friend.friendState = [rs stringForColumn:@"friendState"];
            friend.nickName = [rs stringForColumn:@"nickName"];
            friend.remarkName = [rs stringForColumn:@"remark"];
            friend.phoneNumber = [rs stringForColumn:@"phoneNumber"];
            friend.region = [rs stringForColumn:@"region"];
            friend.sign = [rs stringForColumn:@"sign"];
            friend.age = [rs stringForColumn:@"age"];
            friend.sex = [rs intForColumn:@"sex"];
        }
    }];
    return friend;
}

- (void)insertFriend:(ECFriend *)ecFriend{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ VALUES ('%@', '%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", friendTable, ecFriend.useracc, ecFriend.phoneNumber, ecFriend.region, ecFriend.avatar, ecFriend.friendState, ecFriend.nickName, ecFriend.firstLetter, ecFriend.remarkName, @0, @"", @"", @""];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"%d", isSuccess);
    }];
}

- (void)insertFriends:(NSArray *)friends{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where 1=1", friendTable];
        [db executeUpdate:sql];
        [db beginTransaction];
        for (ECFriend *f in friends) {
            if(![f isKindOfClass:[ECFriend class]])
                continue;
            NSString *sql = [NSString stringWithFormat:@"insert into %@ VALUES ('%@', '%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", friendTable, f.useracc, f.phoneNumber, f.region, f.avatar, f.friendState, f.nickName, f.firstLetter, f.remarkName, @0, @"", @"", @""];
            [db executeUpdate:sql];
        }
        [db commit];
    }];
}

- (void)deleteFriend:(NSString *)friendId{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where useracc = '%@' ", friendTable, friendId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"deleteFriend isSuccess=%d",isSuccess)
    }];
}

- (void)updateRemark:(NSString *)remark inFriend:(NSString *)friendId{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set remark = '%@' where useracc = '%@'", friendTable, remark, friendId];
        EC_DB_LOG(@"sql = %@", sql);
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"is success = %d", isSuccess);
    }];
}
@end
