//
//  ECDBManagerUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/21.
//

#import "ECDBManagerUtil.h"
#import "ECSession+Util.h"
#import "ECCellHeightModel.h"

@implementation ECDBManagerUtil

+ (instancetype)sharedInstanced {
    static ECDBManagerUtil *cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupNotice:) name:EC_KNOTIFICATION_ReceivedGroupNoticeMessage object:nil];
    }
    return self;
}

- (ECSession *)addNewMessage:(ECMessage *)message andSessionId:(NSString*)sessionId {
    ECSession *session = [self.sessionDic objectForKey:sessionId];
    if (session == nil || session.msgType != -1) {
        session = [ECSession messageConvertToSession:message];
    }
    //如果该消息正在聊天中 或 消息的状态是已发送则代码消息已经在其他设备上是已读过
    if (message.messageState == ECMessageState_Receive) {
        session.unreadCount ++;
    } else {
        session.unreadCount = 0;
    }
    session.unreadCount = [ECDeviceDelegateConfigCenter sharedInstanced].isConversation==NO?session.unreadCount:0;
    __block ECMessage *msg = message;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        msg = [ECCellHeightModel ec_caculateCellSizeWithMessage:msg];
        [[ECDBManager sharedInstanced].messageMgr insertMessage:msg];
    });
    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
    return session;
}

- (void)updateMessageId:(ECMessage*)msgNewId andTime:(long long)time ofMessageId:(NSString*)msgOldId {
    ECSession *session = [self.sessionDic objectForKey:msgNewId.sessionId];
    if (session) {
        session.dateTime = time;
    }
    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
    [[ECDBManager sharedInstanced].messageMgr updateMessageId:msgNewId.messageId andTime:time ofMessageId:msgOldId andSession:msgNewId.sessionId];
}

- (void)deleteAllMessageSaveSessionOfSessionId:(NSString *)sessionId {
    //删除会话的数据,保留会话
    ECSession *session = [self.sessionDic objectForKey:sessionId];
    session.text = @"暂无";
    session.msgType = MessageBodyType_Text;
    if ([sessionId isEqualToString:@"系统通知"]) {
        [[ECDBManager sharedInstanced].groupNoticeMgr deleteAllGroupNoticeMessage];
        [[ECDBManager sharedInstanced].friendNoticeMgr deleteAllFriendNoticeMsg];
    } else {
        [[ECDBManager sharedInstanced].messageMgr deleteAllMessage:sessionId];
    }
    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_DB_DeleteMessage object:sessionId];
}

- (void)deleteSessionOfSessionId:(NSString *)sessionId {
    ECSession *session = [self.sessionDic objectForKey:sessionId];
    session.text = @"暂无";
    session.msgType = MessageBodyType_Text;
    [self.sessionDic removeObjectForKey:sessionId];
    if ([sessionId isEqualToString:@"系统通知"]) {
        [[ECGroupNoticeDB sharedInstanced] deleteAllGroupNoticeMessage];
        [[ECFriendNoticeDB sharedInstanced] deleteAllFriendNoticeMsg];
    } else {
        [[ECMessageDB sharedInstanced] deleteAllMessage:sessionId];
    }
    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_DB_DeleteMessage object:sessionId];
}

- (void)updateSessionWithMessage:(ECMessage *)message {
    ECSession *session = [ECSession messageConvertToSession:message];
    session.unreadCount += 1;
    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
}

- (void)updateSessionWithNotiMsg:(ECBaseNoticeMsg *)noticeMsg {
    ECSession *session = [ECSession noticeConvertToSession:noticeMsg];
    session.unreadCount += 1;
    if (noticeMsg.baseType == ECBaseNoticeMsg_Type_Group) {
        [[ECDBManager sharedInstanced].groupNoticeMgr insertGroupNoticeMessage:(ECGroupNoticeMessage *)noticeMsg];
    } else if (noticeMsg.baseType == ECBaseNoticeMsg_Type_Friend) {
        [[ECDBManager sharedInstanced].friendNoticeMgr insertFriendNoticeMessage:(ECFriendNoticeMsg *)noticeMsg];
    }
    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
}

- (void)updateSrcMessage:(NSString*)sessionId msgid:(NSString*)msgId withDstMessage:(ECMessage*)dstmessage {
    ECSession * session = [ECSession messageConvertToSession:dstmessage];
    //如果该消息正在聊天中 或 消息的状态是已发送则代码消息已经在其他设备上是已读过
    if ([sessionId isEqualToString:dstmessage.sessionId] || dstmessage.messageState==ECMessageState_SendSuccess) {
        session.unreadCount = 0;
    } else {
        session.unreadCount++;
    }
    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
    [[ECDBManager sharedInstanced].messageMgr updateMessage:sessionId msgid:msgId withMessage:dstmessage];
}
#pragma mark - 处理系统通知消息
- (void)selectNoticeCompletion:(void (^)(NSArray *))completion {
    NSMutableArray *tempTotalArray = [NSMutableArray array];
    __block NSArray *totalArray = nil;
    [[ECDBManager sharedInstanced].groupNoticeMgr selectGroupNoticecompletion:^(NSArray *array) {
        [tempTotalArray addObjectsFromArray:array];
    }];
    [[ECDBManager sharedInstanced].friendNoticeMgr queryAllFriendNoticeMsg:^(NSArray *array) {
        [tempTotalArray addObjectsFromArray:array];
        totalArray = [tempTotalArray sortedArrayUsingComparator:^(ECBaseNoticeMsg *obj1, ECBaseNoticeMsg* obj2) {
            long long time1 = [obj1.dateCreated longLongValue];
            long long time2 = [obj2.dateCreated longLongValue];
            if(time1 > time2) {
                return(NSComparisonResult)NSOrderedAscending;
            } else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
    }];
    if (completion)
        completion(totalArray);
}

#pragma mark - 处理群组
- (void)handleGroupNotice:(NSNotification *)note {
    if ([note.object isKindOfClass:[ECGroupNoticeMessage class]]) {
        ECGroupNoticeMessage *msg = (ECGroupNoticeMessage *)note.object;
        NSString *groupId = msg.groupId;
        ECGroup *group = [[ECDBManager sharedInstanced].groupInfoMgr selectGroupOfGroupId:groupId];
        switch (msg.messageType) {
            case ECGroupMessageType_Dissmiss: {
                [[ECDBManager sharedInstanced].sessionMgr deleteSession:groupId];
                [[ECDBManager sharedInstanced].groupMemberMgr deleteAllMemberOfGroupId:groupId];
                [[ECDBManager sharedInstanced].groupInfoMgr deleteGroupWithId:groupId];
            }
                break;
            case ECGroupMessageType_Quit: {
                ECQuitGroupMsg *message = (ECQuitGroupMsg *)msg;
                [[ECDBManager sharedInstanced].groupMemberMgr deleteMember:message.member inGroup:groupId];
            }
                break;
            case ECGroupMessageType_RemoveMember: {
                ECRemoveMemberMsg *message = (ECRemoveMemberMsg *)msg;
                [[ECDBManager sharedInstanced].groupMemberMgr deleteMember:message.member inGroup:groupId];
            }
                break;
            case ECGroupMessageType_ReplyJoin: {
                ECReplyJoinGroupMsg *message = (ECReplyJoinGroupMsg *)msg;
                group.memberCount -=1;
                message.confirm != 2?:[[ECDBManager sharedInstanced].groupInfoMgr insertGroup:group];
            }
                break;
            case ECGroupMessageType_ReplyInvite: {
                ECReplyInviteGroupMsg *message = (ECReplyInviteGroupMsg *)msg;
                group.memberCount -=1;
                message.confirm != 2?:[[ECDBManager sharedInstanced].groupInfoMgr insertGroup:group];
            }
                break;
            default:
                break;
        }
    }
}
#pragma mark - 懒加载
- (NSMutableDictionary *)sessionDic {
    if (!_sessionDic) {
        _sessionDic = [NSMutableDictionary dictionary];
        _sessionDic = [[ECDBManager sharedInstanced].sessionMgr selectSessionCompletion:nil];
    }
    return _sessionDic;
}

- (NSArray *)sessionArray {
    _sessionArray = [ECSession sortSessionWithDatetime:self.sessionDic.allValues];
    return _sessionArray;
}

@end
