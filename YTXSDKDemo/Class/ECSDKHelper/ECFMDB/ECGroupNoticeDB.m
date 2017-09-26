//
//  ECGroupNoticeDB.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECGroupNoticeDB.h"
#import "ECDBManager.h"

@implementation ECGroupNoticeDB

+ (instancetype)sharedInstanced {
    static ECGroupNoticeDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECGroupNoticeDB alloc] init];
    });
    return dbManager;
}

- (void)createGroupNoticeTable {
    [[ECDBManager sharedInstanced] createTable:@"im_groupnotice" sql:@"CREATE table im_groupnotice(ID INTEGER PRIMARY KEY AUTOINCREMENT, sender varchar(32),groupId varchar(32),groupName varchar(32),messageType INTEGER,declared varchar(32),isRead INTEGER,admin varchar(32),nickName varchar(32),dateCreated varchar(32), confirm INTEGER, proposer varchar(32), member varchar(32), modifyDic varchar(32), adminNickName varchar(32))"];
}

- (void)selectGroupNoticecompletion:(void (^)(NSArray *array))completion {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * from im_groupnotice order by ID desc"];
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *noticeArr = [NSMutableArray array];
        while ([rs next]) {
            ECGroupNoticeMessage *msg = [self confirmGroumNoticeMessage:rs];
            msg.sender = [rs stringForColumn:@"sender"];
            msg.groupId = [rs stringForColumn:@"groupId"];
            msg.groupName = [rs stringForColumn:@"groupName"];
            msg.isRead = [rs intForColumn:@"isRead"];
            msg.dateCreated = [rs stringForColumn:@"dateCreated"];
            [noticeArr addObject:msg];
        }
        if (completion) {
            completion(noticeArr);
        }
    }];
}

- (void)insertGroupNoticeMessage:(ECGroupNoticeMessage *)message{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"im_groupnotice"]) {
            [self createGroupNoticeTable];
        }
        NSString *declared = @"";//ECInviterMsg/ECProposerMsg/ECJoinGroupMsg
        NSString *admin = @"";//ECInviterMsg、ECReplyJoinGroupMsg、ECReplyInviteGroupMsg
        NSString *nickName = @"";//ECInviterMsg、ECProposerMsg、ECChangeAdminMsg、ECJoinGroupMsg、ECQuitGroupMsg、ECRemoveMemberMsg、ECReplyJoinGroupMsg、ECReplyInviteGroupMsg、ECModifyGroupMemberMsg、ECChangeMemberRoleMsg
        NSInteger confirm = 0;//ECInviterMsg、ECProposerMsg、ECReplyJoinGroupMsg、ECReplyInviteGroupMsg
        NSString *proposer = @"";//ECProposerMsg
        NSString *member = @"";//ECChangeAdminMsg、ECJoinGroupMsg、ECQuitGroupMsg、ECRemoveMemberMsg、ECReplyJoinGroupMsg、ECReplyInviteGroupMsg、ECModifyGroupMsg、ECModifyGroupMemberMsg、ECChangeMemberRoleMsg
        NSString *modifyDic = @"";
        NSString *adminNickName = @"";
        if([message respondsToSelector:@selector(declared)])
            declared = [message performSelector:@selector(declared)];
        if([message respondsToSelector:@selector(admin)])
            admin = [message performSelector:@selector(admin)];
        if([message respondsToSelector:@selector(nickName)])
            nickName = [message performSelector:@selector(nickName)];
        if([message respondsToSelector:@selector(proposer)])
            proposer = [message performSelector:@selector(proposer)];
        if([message respondsToSelector:@selector(member)])
            member = [message performSelector:@selector(member)];
        if ([message respondsToSelector:@selector(adminNickName)])
            adminNickName = [message performSelector:@selector(adminNickName)];
        if([message respondsToSelector:@selector(confirm)]){
            if(message.messageType == ECGroupMessageType_ReplyJoin)
                confirm = ((ECReplyJoinGroupMsg *)message).confirm;
            if(message.messageType == ECGroupMessageType_ReplyInvite)
                confirm = ((ECReplyInviteGroupMsg *)message).confirm;
            if (message.messageType == ECGroupMessageType_Invite)
                confirm = ((ECInviterMsg *)message).confirm;
            if (message.messageType == ECGroupMessageType_Propose)
                confirm = ((ECProposerMsg *)message).confirm;
        }
        if (message.messageType == ECGroupMessageType_ModifyGroupMember || message.messageType == ECGroupMessageType_InviteJoin || message.messageType == ECGroupMessageType_ChangeMemberRole) {
            id object = @"";
            if (message.messageType == ECGroupMessageType_ModifyGroupMember) {
                ECModifyGroupMemberMsg *msg = (ECModifyGroupMemberMsg *)message;
                object = msg.modifyDic;
            } else if (message.messageType == ECGroupMessageType_InviteJoin) {
                ECInviteJoinGroupMsg *msg = (ECInviteJoinGroupMsg *)message;
                object = msg.members;
            } else if (message.messageType == ECGroupMessageType_ChangeMemberRole) {
                ECChangeMemberRoleMsg *msg = (ECChangeMemberRoleMsg *)message;
                object = msg.roleDic;
            }
            NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
            if (!data) {
                EC_DB_LOG(@"im_groupnotice insert modifyDic error ");
            } else {
                modifyDic = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
        BOOL isSuccess = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO im_groupnotice(sender,groupId,groupName,messageType,declared,isRead,admin,nickName,dateCreated , confirm, proposer, member, modifyDic, adminNickName) VALUES ('%@','%@','%@','%d','%@','%d','%@','%@','%@','%d','%@','%@','%@','%@')",message.sender, message.groupId, message.groupName, (int)message.messageType, declared, message.isRead, admin, nickName, message.dateCreated, (int)confirm, proposer, member,modifyDic,adminNickName]];
        EC_DB_LOG(@"ECGroupNoticeMessage insert success %d", isSuccess);
    }];
}

- (void)updateGroupNoticeMessage:(NSString *)groupId withMember:(NSString *)member confirm:(NSInteger)confirm{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE im_groupnotice SET confirm='%ld' WHERE groupId = '%@' AND admin='%@'", confirm, groupId,member];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"isSuccess = %d", isSuccess);
    }];
}

- (ECGroupNoticeMessage *)selectNoticeMessage:(NSString *)groupId withMember:(NSString *)member{
    __block ECGroupNoticeMessage *msg = nil;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from im_groupnotice where groupId = '%@' AND admin='%@'", groupId, member];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            msg = [self confirmGroumNoticeMessage:rs];
            msg.sender = [rs stringForColumn:@"sender"];
            msg.groupId = [rs stringForColumn:@"groupId"];
            msg.groupName = [rs stringForColumn:@"groupName"];
            msg.isRead = [rs intForColumn:@"isRead"];
            msg.dateCreated = [rs stringForColumn:@"dateCreated"];
        }
    }];
    return msg;
}

- (void)deleteAllGroupNoticeMessage{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from im_groupnotice"];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"ECGroupNoticeMessage deleteAllNoticeMessage success %d", isSuccess);
    }];
}

- (void)deleteGroupNoticeMessage:(NSString *)groupId withMember:(NSString *)member{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from im_groupnotice WHERE groupId = '%@' AND admin='%@'", groupId, member];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"ECGroupNoticeMessage deleteAllNoticeMessage success %d", isSuccess);
    }];
}

#pragma mark - message处理
- (ECGroupNoticeMessage *)confirmGroumNoticeMessage:(FMResultSet*)rs {
    ECGroupMessageType messageType = [rs intForColumn:@"messageType"];
    switch (messageType) {
        case ECGroupMessageType_Dissmiss:{
            ECDismissGroupMsg *msg = [[ECDismissGroupMsg alloc] init];
            return msg;
        }
            break;
        case ECGroupMessageType_Invite:{
            ECInviterMsg *msg = [[ECInviterMsg alloc] init];
            msg.declared = [rs stringForColumn:@"declared"];
            msg.admin = [rs stringForColumn:@"admin"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            msg.confirm = [rs intForColumn:@"confirm"];
            return msg;
        }
            break;
        case ECGroupMessageType_Propose:{
            ECProposerMsg *msg = [[ECProposerMsg alloc] init];
            msg.declared = [rs stringForColumn:@"declared"];
            msg.proposer = [rs stringForColumn:@"proposer"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            msg.confirm = [rs intForColumn:@"confirm"];
            return msg;
        }
            break;
        case ECGroupMessageType_Join:{
            ECJoinGroupMsg *msg = [[ECJoinGroupMsg alloc] init];
            msg.declared = [rs stringForColumn:@"declared"];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            return msg;
        }
            break;
        case ECGroupMessageType_Quit:{
            ECQuitGroupMsg *msg = [[ECQuitGroupMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            return msg;
        }
            break;
        case ECGroupMessageType_RemoveMember:{
            ECRemoveMemberMsg * msg = [[ECRemoveMemberMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            return msg;
        }
            break;
        case ECGroupMessageType_ReplyInvite: {
            ECReplyInviteGroupMsg * msg = [[ECReplyInviteGroupMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            msg.admin = [rs stringForColumn:@"admin"];
            msg.confirm = [rs intForColumn:@"confirm"];
            return msg;
        }
            break;
        case ECGroupMessageType_ReplyJoin: {
            ECReplyJoinGroupMsg * msg = [[ECReplyJoinGroupMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            msg.admin = [rs stringForColumn:@"admin"];
            msg.confirm = [rs intForColumn:@"confirm"];
            return msg;
        }
            break;
        case ECGroupMessageType_ModifyGroup: {
            ECModifyGroupMsg * msg = [[ECModifyGroupMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            return msg;
        }
            break;
        case ECGroupMessageType_ChangeAdmin: {
            ECChangeAdminMsg *msg = [[ECChangeAdminMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            return msg;
        }
            break;
        case ECGroupMessageType_ChangeMemberRole: {
            ECChangeMemberRoleMsg *msg = [[ECChangeMemberRoleMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            NSString *roleDic = [rs stringForColumn:@"modifyDic"];
            msg.roleDic = [NSJSONSerialization JSONObjectWithData:[roleDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            return msg;
        }
            break;
        case ECGroupMessageType_ModifyGroupMember: {
            ECModifyGroupMemberMsg *msg = [[ECModifyGroupMemberMsg alloc] init];
            msg.member = [rs stringForColumn:@"member"];
            msg.nickName = [rs stringForColumn:@"nickName"];
            NSString *modifyDic = [rs stringForColumn:@"modifyDic"];
            msg.modifyDic = [NSJSONSerialization JSONObjectWithData:[modifyDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            return msg;
        }
            break;
        case ECGroupMessageType_InviteJoin: {
            ECInviteJoinGroupMsg *msg = [[ECInviteJoinGroupMsg alloc] init];
            msg.admin = [rs stringForColumn:@"admin"];
            msg.adminNickName = [rs stringForColumn:@"adminNickName"];
            NSString *modifyDic = [rs stringForColumn:@"modifyDic"];
            msg.members = [NSJSONSerialization JSONObjectWithData:[modifyDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            return msg;
        }
            break;
        default:{
            ECGroupNoticeMessage *msg = [[ECGroupNoticeMessage alloc] init];
            return msg;
        }
            break;
    }
}
@end
