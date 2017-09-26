//
//  ECSession+Util.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/19.
//

#import "ECSession+Util.h"

@implementation ECSession (Util)
+ (BOOL)queryNoDisturbOptionOfSessionid:(NSString *)sessionId {
    BOOL isNoDisurb = NO;
    isNoDisurb = [[ECDBManager sharedInstanced].sessionMgr selectSession:sessionId].isNoDisturb;
    return isNoDisurb;
}

+ (NSArray *)sortSessionWithDatetime:(NSArray *)sourceArray {
    NSArray *array = [sourceArray sortedArrayUsingComparator:^(ECSession *obj1, ECSession* obj2) {
        long long time1 = obj1.isTop?obj1.dateTime*1000:obj1.dateTime;
        long long time2 = obj2.isTop?obj2.dateTime*1000:obj2.dateTime;
        if(time1 > time2) {
            return(NSComparisonResult)NSOrderedAscending;
        } else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    return array;
}

+ (ECSession *)messageConvertToSession:(ECMessage *)message {
    return [[[[self class] alloc] init] messageConvertToSession:message];
}

+ (ECSession *)noticeConvertToSession:(ECBaseNoticeMsg *)notiMsg {
    return [[[[self class] alloc] init] noticeConvertToSession:notiMsg];
}
#pragma mark - Session 处理
- (ECSession *)messageConvertToSession:(ECMessage *)message {
    long long int time = [message.timestamp longLongValue];
    ECSession *session = [[ECDBManager sharedInstanced].dbMgrUtil.sessionDic objectForKey:message.sessionId];
    if (session) {
        if (session.dateTime>time) {
            time = session.dateTime+1;
            message.timestamp = [NSString stringWithFormat:@"%lld",time];
        }
    } else {
        session = [[ECDBManager sharedInstanced].sessionMgr selectSession:message.sessionId];
        session.unreadCount = 0;
        session.sumCount = 0;
        session.isAt = NO;
        if (message.sessionId.length >0 && session)
            [[ECDBManager sharedInstanced].dbMgrUtil.sessionDic setObject:session forKey:message.sessionId];
    }
    session.type = EC_Session_Type_One;
    session.sessionId = message.sessionId;
    session.dateTime = time;
    session.msgType = message.messageBody.messageBodyType;
    session.sessionName = [ECDeviceHelper ec_getNickNameWithSessionId:message.sessionId];
    NSString *fromName = @"";
    if ([message.to hasPrefix:@"g"]) {
        session.type = [[ECGroupInfoDB sharedInstanced] selectGroupOfGroupId:message.to].isDiscuss?EC_Session_Type_Discuss:EC_Session_Type_Group;
        fromName = message.senderName.length>0?message.senderName:message.from;
        fromName = [fromName stringByAppendingString:@":"];
    } 
    session = [self convertText:message session:session WithName:fromName];
    return session;
}

- (ECSession *)noticeConvertToSession:(ECBaseNoticeMsg *)msg {
    ECSession *session = [[ECDBManager sharedInstanced].dbMgrUtil.sessionDic objectForKey:NSLocalizedString(@"系统通知", nil)];
    if (!session) {
        session = [[ECSession alloc] init];
        session.sessionId = NSLocalizedString(@"系统通知", nil);
        [[ECDBManager sharedInstanced].dbMgrUtil.sessionDic setObject:session forKey:session.sessionId];
        session.unreadCount = 0;
    }
    
    if (msg.baseType == ECBaseNoticeMsg_Type_Group) {
        ECGroupNoticeMessage *groupNotiMsg = (ECGroupNoticeMessage *)msg;
        session.dateTime = [groupNotiMsg.dateCreated longLongValue];
        session.type = EC_Session_Type_System;
        session.sessionName = NSLocalizedString(@"系统通知", nil);
        
        NSString* groupName = groupNotiMsg.groupName;
        NSString *name = @"";
        if (groupNotiMsg.isDiscuss) {
            name = @"讨论组";
        } else {
            name = @"群组";
        }
        
        session = [self convertNotiMsg:groupNotiMsg session:session WithName:name groupName:groupName];
    } else if (msg.baseType == ECBaseNoticeMsg_Type_Friend) {
        ECFriendNoticeMsg *friendNotiMsg = (ECFriendNoticeMsg *)msg;
        session.dateTime = [friendNotiMsg.dateCreated longLongValue];
        session.type = EC_Session_Type_System;
        session.sessionName = NSLocalizedString(@"系统通知", nil);
        session.text = friendNotiMsg.noticeMsg;
    }
    return session;
}

- (ECSession *)convertText:(ECMessage *)message session:(ECSession *)session WithName:(NSString *)fromName {
    switch (message.messageBody.messageBodyType) {
        case MessageBodyType_None: {
            if ([[message.messageBody class] isSubclassOfClass:[ECRevokeMessageBody class]]) {
                ECRevokeMessageBody *revokeBody = (ECRevokeMessageBody*)message.messageBody;
                session.text = revokeBody.text;
            }
        }
            break;
        case MessageBodyType_Text: {
            ECTextMessageBody *msg = (ECTextMessageBody*)message.messageBody;
            session.text = [NSString stringWithFormat:@"%@%@",fromName,msg.text];
            if (msg.isAted) {
                session.isAt = msg.isAted;
            }
        }
            break;
        case MessageBodyType_Image:
            session.text = [NSString stringWithFormat:@"%@%@",fromName,@"[图片]"];
            break;
        case MessageBodyType_Video:
            session.text = [NSString stringWithFormat:@"%@%@",fromName,@"[视频]"];
            break;
        case MessageBodyType_Voice:
            session.text = [NSString stringWithFormat:@"%@%@",fromName,@"[语音]"];
            break;
        case MessageBodyType_Call: {
            ECCallMessageBody * msg = (ECCallMessageBody*)message.messageBody;
            session.text = [NSString stringWithFormat:@"%@%@",fromName,msg.callText];
        }
            break;
        case MessageBodyType_Location:{
            session.text = [NSString stringWithFormat:@"%@%@",fromName,@"[位置]"];
        }
            break;
        case MessageBodyType_Preview: {
            session.text = [NSString stringWithFormat:@"%@%@",fromName,@"[图文混排]"];
        }
            break;
        default:
            session.text = [NSString stringWithFormat:@"%@%@",fromName,@"[文件]"];
            break;
    }
    return session;
}

- (ECSession *)convertNotiMsg:(ECGroupNoticeMessage *)msg session:(ECSession *)session WithName:(NSString *)name groupName:(NSString *)groupName {
    
    if (msg.messageType == ECGroupMessageType_Dissmiss) {
        
        session.text = [NSString stringWithFormat:@"%@%@被解散",name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_Invite) {
        
        ECInviterMsg * message = (ECInviterMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"邀请您加入\"%@\"%@",EC_ISNullStr(message.nickName) ? message.admin : message.nickName,groupName,name];
        
    } else if (msg.messageType == ECGroupMessageType_Propose) {
        
        ECProposerMsg * message = (ECProposerMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"申请加入%@\"%@\"",EC_ISNullStr(message.nickName) ? message.proposer : message.nickName,name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_Join) {
        
        ECJoinGroupMsg *message = (ECJoinGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"加入%@\"%@\"",EC_ISNullStr(message.nickName) ? message.member : message.nickName,name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_Quit) {
        
        ECQuitGroupMsg *message = (ECQuitGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"退出%@\"%@\"",EC_ISNullStr(message.nickName) ? message.member : message.nickName,name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_RemoveMember) {
        
        ECRemoveMemberMsg *message = (ECRemoveMemberMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"被移除%@\"%@\"",EC_ISNullStr(message.nickName) ? message.member : message.nickName,name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_ReplyJoin) {
        
        ECReplyJoinGroupMsg *message = (ECReplyJoinGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"%@\"%@\"%@\"%@\"的加入申请",groupName,message.confirm==2?@"同意":@"拒绝",name,EC_ISNullStr(message.nickName) ? message.member : message.nickName];
        
    } else if (msg.messageType == ECGroupMessageType_ReplyInvite) {
        
        ECReplyInviteGroupMsg *message = (ECReplyInviteGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"%@\"%@\"的邀请加入%@\"%@\"",EC_ISNullStr(message.nickName) ? message.member : message.nickName,message.confirm==2?@"同意":@"拒绝",message.admin,name,groupName];
        
    } else if (msg.messageType == ECGroupMessageType_ModifyGroup) {
        
        ECModifyGroupMsg *message = (ECModifyGroupMsg *)msg;
        NSString * jsonString = @"";
        EC_Demo_AppLog(@"%@", message.modifyDic);
        if (message.modifyDic) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message.modifyDic options:NSJSONWritingPrettyPrinted error:nil];
            if (jsonData) {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
        session.text = [NSString stringWithFormat:@"\"%@\"修改了%@\"%@\"信息",message.member,name, groupName];
        
    } else if (msg.messageType == ECGroupMessageType_ChangeAdmin) {
        
        ECChangeAdminMsg *message = (ECChangeAdminMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"成为\"%@%@的管理员\"",EC_ISNullStr(message.nickName) ? message.member : message.nickName, groupName,name];
        
    } else if (msg.messageType == ECGroupMessageType_ChangeMemberRole) {
        ECChangeMemberRoleMsg *message = (ECChangeMemberRoleMsg *)msg;
        ECMemberRole role = (ECMemberRole)[[message.roleDic objectForKey:@"role"] integerValue];
        NSString *roleText = nil;
        if (role == ECMemberRole_Member) {
            roleText = @"取消管理员";
        } else if (role == ECMemberRole_Admin) {
            roleText = @"设置为管理员";
        } else if (role == ECMemberRole_Creator) {
            roleText = @"设置为群主";
        }
        session.text = [NSString stringWithFormat:@"\"%@\"被\"%@%@\"",EC_ISNullStr(message.nickName) ? message.member : message.nickName, message.sender,roleText];
    } else if (msg.messageType == ECGroupMessageType_ModifyGroupMember) {
        ECModifyGroupMemberMsg *message = (ECModifyGroupMemberMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"修改了\"%@\"名片",EC_ISNullStr(message.nickName) ? message.member : message.nickName,groupName];
    } else if (msg.messageType == ECGroupMessageType_InviteJoin) {
        ECInviteJoinGroupMsg *message = (ECInviteJoinGroupMsg *)msg;
        session.text = [NSString stringWithFormat:@"\"%@\"邀请加入%@\"%@\"",EC_ISNullStr(message.adminNickName) ? message.adminNickName : message.admin,message.members.firstObject,groupName];
        
    } else {
        session.text = @"暂不支持";
    }
    EC_Demo_AppLog(@"demo系统通知:%@",session.text);
    return session;
}
@end
