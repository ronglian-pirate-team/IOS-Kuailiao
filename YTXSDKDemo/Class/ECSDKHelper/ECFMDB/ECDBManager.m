//
//  ECDBManager.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECDBManager.h"
#import "ECSession+Util.h"

#define EC_DB_NAME @"im_demo.db"

@interface ECDBManager()

@end

@implementation ECDBManager

+(instancetype)sharedInstanced {
    static ECDBManager* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECDBManager alloc] init];
    });
    return dbManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dbMgrUtil = [ECDBManagerUtil sharedInstanced];
        self.sessionMgr = [ECSessionDB sharedInstanced];
        self.messageMgr = [ECMessageDB sharedInstanced];
        self.groupInfoMgr = [ECGroupInfoDB sharedInstanced];
        self.groupNoticeMgr = [ECGroupNoticeDB sharedInstanced];
        self.groupMemberMgr = [ECGroupMemberDB sharedInstanced];
        self.friendMgr = [ECFriendDB sharedInstanced];
        self.addRequestMgr = [ECAddRequestDB sharedInstanced];
        self.friendNoticeMgr = [ECFriendNoticeDB sharedInstanced];
        self.
#ifdef DEBUG
        self.isOpenDebugLog = YES;
#else
        self.isOpenDebugLog = NO;
#endif
    }
    return self;
}

- (BOOL)isIsOpenDebugLog {
#ifdef DEBUG
    return _isOpenDebugLog;
#else
    return NO;
#endif
}

- (void)openDB:(NSString *)dbName{
    if (dbName.length==0) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *MD5 = [NSString MD5:dbName];
    NSString * documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:MD5];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:EC_DB_NAME];
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [[ECSessionDB sharedInstanced] createSessionTable];
    [[ECGroupInfoDB sharedInstanced] createGroupInfoTable];
    [[ECGroupNoticeDB sharedInstanced] createGroupNoticeTable];
    [[ECFriendDB sharedInstanced] createFriendTable];
    [[ECAddRequestDB sharedInstanced] createAddRequestTable];
    [[ECFriendNoticeDB sharedInstanced] createFriendNoticeTable];
}

- (void) createTable:(NSString *)tableName sql:(NSString *)createSql {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL isExist = [db tableExists:tableName];
        if (!isExist) {
            BOOL createSuccess = [db executeUpdate:createSql];
            EC_DB_LOG(@"createTable success = %d", createSuccess);
        }
    }];
}

@end
