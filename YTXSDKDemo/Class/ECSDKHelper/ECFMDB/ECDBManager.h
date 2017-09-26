//
//  ECDBManager.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "ECDevice.h"
#import "ECSessionDB.h"
#import "ECMessageDB.h"
#import "ECGroupInfoDB.h"
#import "ECGroupNoticeDB.h"
#import "ECGroupMemberDB.h"
#import "ECFriendDB.h"
#import "ECAddRequestDB.h"
#import "ECFriendNoticeDB.h"
#import "ECDBManagerUtil.h"

@interface ECDBManager : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

+(instancetype)sharedInstanced;

/**
 是否开启debug日志,默认开启.
 release默认是关闭的.
 */
@property (nonatomic, assign) BOOL isOpenDebugLog;

- (void)openDB:(NSString *)dbName;
- (void)createTable:(NSString*)tableName sql:(NSString *)createSql;

#pragma mark - ECDBManagerUtil 扩展管理消息体
@property (nonatomic, strong) ECDBManagerUtil *dbMgrUtil;

#pragma mark - Session DB 会话管理消息体
@property (nonatomic, strong) ECSessionDB *sessionMgr;

#pragma mark - Message DB 消息管理消息体
@property (nonatomic, strong) ECMessageDB *messageMgr;

#pragma mark - ECGroupInfo DB 群组详情管理消息体
@property (nonatomic, strong) ECGroupInfoDB *groupInfoMgr;

#pragma mark - ECGroupNotice DB 群组通知管理消息体
@property (nonatomic, strong) ECGroupNoticeDB *groupNoticeMgr;

#pragma mark - ECGroupMember 群组成员管理消息体
@property (nonatomic, strong) ECGroupMemberDB *groupMemberMgr;

#pragma mark - 好友管理消息体
@property (nonatomic, strong) ECFriendDB *friendMgr;

#pragma mark - 好友添加请求管理消息体
@property (nonatomic, strong) ECAddRequestDB *addRequestMgr;

#pragma mark - 好友请求通知管理消息体
@property (nonatomic, strong) ECFriendNoticeDB *friendNoticeMgr;

@end
