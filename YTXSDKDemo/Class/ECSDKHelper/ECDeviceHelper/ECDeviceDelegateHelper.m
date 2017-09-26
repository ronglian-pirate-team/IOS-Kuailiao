
//
//  ECDeviceDelegate.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/21.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECDeviceDelegateHelper.h"
#import "ECMessageDB.h"
#import "ECSessionDB.h"
#import "ECDevicePersonInfo.h"
#import "ECMessage+RedpacketMessage.h"


NSString *const CellMessageReadCount = @"CellMessageReadCount";
NSString *const CellMessageUnReadCount = @"CellMessageUnReadCount";

@interface ECDeviceDelegateHelper ()
@property(atomic, assign) NSUInteger offlineCount;
@end

@implementation ECDeviceDelegateHelper

+ (instancetype)sharedInstanced {
    
    static ECDeviceDelegateHelper *devicedelegate;
    static dispatch_once_t devicedelegatehelperonce;
    dispatch_once(&devicedelegatehelperonce, ^{
        devicedelegate = [[[self class] alloc] init];
    });
    return devicedelegate;
}

- (instancetype)init {
    if (self = [super init]) {
        [ECDeviceDelegateConfigCenter sharedInstanced];
        self.interphoneArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - ECDelegateBase
- (void)onConnectState:(ECConnectState)state failed:(ECError*)error {
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    switch (state) {
        case State_ConnectSuccess:
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNotification_ConnectedState object:[ECError errorWithCode:ECErrorType_NoError]];
            break;
        case State_Connecting:
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNotification_ConnectedState object:[ECError errorWithCode:ECErrorType_Connecting]];
            break;
        case State_ConnectFailed:
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNotification_ConnectedState object:error];
            break;
        default:
            break;
    }
}

- (void)onServicePersonVersion:(unsigned long long)version {
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_PersionInfoVersion object:@(version)];
    if (![ECDeviceDelegateConfigCenter sharedInstanced].isContainIM)
        return;

    if ([ECDevicePersonInfo sharedInstanced].dataVersion==0 && version==0) {
        
    } else if (version>[ECDevicePersonInfo sharedInstanced].dataVersion) {
        [[ECDevice sharedInstance] getPersonInfo:^(ECError *error, ECPersonInfo *person) {
            if (error.errorCode == ECErrorType_NoError) {
                [ECDevicePersonInfo sharedInstanced].dataVersion = person.version;
                [ECDevicePersonInfo sharedInstanced].birth = person.birth;
                [ECDevicePersonInfo sharedInstanced].nickName = person.nickName;
                [ECDevicePersonInfo sharedInstanced].sex = person.sex;
                [ECDevicePersonInfo sharedInstanced].sign = person.sign;
            }
        }];
    }
}

/**
 @brief 网络改变后调用的代理方法
 @param status 网络状态值
 */
- (void)onReachbilityChanged:(ECNetworkType)status {
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_NetworkChanged object:@(status)];
}

#pragma mark - ECDeviceDelegate methord
- (void)onReceiveMessage:(ECMessage *)message {
    EC_SDKCONFIG_AppLog(@"%s",__func__);

    // 收到消息的的时间
    if(message.messageBody.messageBodyType == MessageBodyType_Text){
        NSLog(@"array = %@", ((ECTextMessageBody *)message.messageBody).atArray);
    }
    if (message.timestamp) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
    
    if (![ECDeviceDelegateConfigCenter sharedInstanced].isContainIM)
        return;

    if (message.messageBody.messageBodyType==MessageBodyType_UserState) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_Chat_UserState object:message];
        return;
    }
    if ([ECDeviceDelegateConfigCenter sharedInstanced].isContainRedPacket) {
        RedpacketMessageModel *model = [message getRpmodel:message.userData];
        if (message.messageBody.messageBodyType == MessageBodyType_Text && model && [message isRedpacketOpenMessage] && ![model.redpacketSender.userId isEqualToString:model.currentUser.userId]) {
            return;
        }
    }
    
    // 插入数据库
    if (EC_StoreAllMessage) {
        [[ECDBManagerUtil sharedInstanced] addNewMessage:message andSessionId:message.sessionId];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveNewMesssage object:message];

    MessageBodyType bodyType = message.messageBody.messageBodyType;
    if(bodyType == MessageBodyType_Voice || bodyType == MessageBodyType_Video || bodyType == MessageBodyType_File || bodyType == MessageBodyType_Image || bodyType== MessageBodyType_Preview) {
        ECFileMessageBody *body = (ECFileMessageBody*)message.messageBody;
        body.displayName = body.remotePath.lastPathComponent;
        [[ECDeviceHelper sharedInstanced] ec_downloadMediaMessage:message andCompletion:nil];
    }
}

/**
 @brief 离线消息数
 @param count 消息数
 */
- (void)onOfflineMessageCount:(NSUInteger)count{
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    EC_SDKCONFIG_AppLog(@"%@:onOfflineMessageCount=%lu",NSLocalizedString(@"离线消息数量", nil), (unsigned long)count);
    self.offlineCount = count;
}

/**
 @brief 需要获取的消息数
 @return 消息数 -1:全部获取 0:不获取
 */
- (NSInteger)onGetOfflineMessage {
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    if ([ECDeviceDelegateConfigCenter sharedInstanced].offLineMessageCount<-1)
        EC_SDKCONFIG_AppLog(@"onGetOfflineMessage:%@",NSLocalizedString(@"要获取的离线消息数量", @""));
    NSInteger retCount = -1;
    if (self.offlineCount!=0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_HistoryMessageCompletion object:nil];
        });
    }
    retCount = [ECDeviceDelegateConfigCenter sharedInstanced].offLineMessageCount;
    return retCount;
}

/**
 @brief 接收离线消息代理函数
 @param message 接收的消息
 */
- (void)onReceiveOfflineMessage:(ECMessage*)message {
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    if (!message.timestamp) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }

    if (![ECDeviceDelegateConfigCenter sharedInstanced].isContainIM)
        return;
    
    if ([ECDeviceDelegateConfigCenter sharedInstanced].isContainRedPacket) {
        RedpacketMessageModel *model = [message getRpmodel:message.userData];
        if (message.messageBody.messageBodyType == MessageBodyType_Text && model && [message isRedpacketOpenMessage] && ![model.redpacketSender.userId isEqualToString:model.currentUser.userId]) {
            return;
        }
    }
    
    // 插入数据库
    if (EC_StoreAllMessage) {
        [[ECDBManagerUtil sharedInstanced] addNewMessage:message andSessionId:message.sessionId];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveNewMesssage object:message];

    MessageBodyType bodyType = message.messageBody.messageBodyType;
    if( bodyType == MessageBodyType_Voice || bodyType == MessageBodyType_Video || bodyType == MessageBodyType_File || bodyType == MessageBodyType_Image || bodyType== MessageBodyType_Preview) {
        ECFileMessageBody *body = (ECFileMessageBody*)message.messageBody;
        body.displayName = body.remotePath.lastPathComponent;
        [[ECDeviceHelper sharedInstanced] ec_downloadMediaMessage:message andCompletion:nil];
    }
}

/**
 @brief 离线消息接收是否完成
 @param isCompletion YES:拉取完成 NO:拉取未完成(拉取消息失败)
 */
- (void)onReceiveOfflineCompletion:(BOOL)isCompletion {
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_HistoryMessageCompletion object:@(isCompletion)];
    });
}

/**
 @brief 客户端录音振幅代理函数
 @param amplitude 录音振幅
 */
- (void)onRecordingAmplitude:(double) amplitude{
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_RecordingAmplitudeChanged object:@(amplitude)];
}

/**
 接收消息通知

 @param message 通知消息体
 */
- (void)onReceiveMessageNotify:(ECMessageNotifyMsg *)message {
    EC_SDKCONFIG_AppLog(@"%s",__func__);

    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveMessageNoti object:message userInfo:nil];
    if (![ECDeviceDelegateConfigCenter sharedInstanced].isContainIM)
        return;

    if (message.messageType == ECMessageNotifyType_DeleteMessage) {
        
        ECMessageDeleteNotifyMsg *msg = (ECMessageDeleteNotifyMsg *)message;
        ECMessage *oldMessage = nil;
        if (EC_StoreAllMessage){
            oldMessage = [[ECDBManager sharedInstanced].messageMgr getMessageWithMessageId:msg.messageId OfSession:msg.sender];
            if (oldMessage) 
                oldMessage.isReadFireMessage = YES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveDeleteMessageNoti object:oldMessage];
        
    } else if (message.messageType == ECMessageNotifyType_RevokeMessage) {
        
        ECMessageRevokeNotifyMsg *msg = (ECMessageRevokeNotifyMsg*)message;
        if ([msg.sender isEqualToString:[ECDevicePersonInfo sharedInstanced].userName]) return;
        
        NSString *nickName = [[ECDevicePersonInfo sharedInstanced] getOtherNameWithPhone:msg.sender];
        ECMessage *oldMessage = [[ECMessage alloc] initWithReceiver:msg.sessionId body:nil];
        oldMessage.messageId = msg.messageId;
        oldMessage.sessionId = msg.sessionId;
        ECMessage *newMessage = [ECRevokeMessageBody sendMessage:oldMessage WithText:[NSString stringWithFormat:@"\"%@\"撤回了一条消息",nickName.length>0?nickName:msg.sender]];
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveRevokeMessageNoti object:newMessage];
        
    } else if (message.messageType == ECMessageNotifyType_MessageIsReaded) {
        
        ECMessageIsReadedNotifyMsg *isReadMsg = (ECMessageIsReadedNotifyMsg *)message;
        [[ECMessageDB sharedInstanced] updateMessageReadState:isReadMsg.sessionId messageId:isReadMsg.messageId isRead:YES];
        ECMessage *readMessage = [[ECDBManager sharedInstanced].messageMgr getMessageWithMessageId:isReadMsg.messageId OfSession:isReadMsg.sessionId];
        if ([readMessage.sessionId hasPrefix:@"g"] && readMessage.readCount>0) {
            readMessage.readCount -=1;
            readMessage.readCount = readMessage.readCount>0?readMessage.readCount:0;
            [[ECMessageDB sharedInstanced] updateMessageReadCount:readMessage.sessionId messageId:readMessage.messageId readCount:readMessage.readCount];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveReadedMessageNoti object:readMessage];
    }
}

/**
 @brief 接收群组相关消息
 @discussion 参数要根据消息的类型，转成相关的消息类；
 解散群组、收到邀请、申请加入、退出群组、有人加入、移除成员等消息
 @param groupMsg 群组消息
 */
- (void)onReceiveGroupNoticeMessage:(ECGroupNoticeMessage *)groupMsg{
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    groupMsg.dateCreated = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    if (EC_StoreAllMessage) {
        [[ECDBManager sharedInstanced].dbMgrUtil updateSessionWithNotiMsg:groupMsg];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceivedGroupNoticeMessage object:groupMsg];

}

#pragma mark - 好友通知
- (void)onReceiveFriendNotiMsg:(ECFriendNoticeMsg *)msg {
    EC_SDKCONFIG_AppLog(@"%s",__func__);
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    msg.dateCreated = [NSString stringWithFormat:@"%lld", (long long)tmp];
    EC_Demo_AppLog(@"%@==%@==%@==%@==%@==%ld", msg.sender, msg.friendAccount, msg.avatarUrl, msg.noticeMsg, msg.source, msg.friendState);
    if (EC_StoreAllMessage) {
        [[ECDBManager sharedInstanced].dbMgrUtil updateSessionWithNotiMsg:msg];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_onReceiveFriendNotiMsg object:msg];
}

@end
