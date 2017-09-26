//
//  ECDeviceHelper.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/31.
//
//

#import "ECDeviceHelper.h"
#import "ECMessage+ECUtil.h"

@interface ECDeviceHelper ()<ECProgressDelegate>
@property (nonatomic, copy) NSString *appKey;
@end
@implementation ECDeviceHelper
+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECDeviceHelper *cls = nil;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ec_fetchTopSessionId:) name:EC_KNOTIFICATION_HistoryMessageCompletion object:nil];
    }
    return self;
}
- (void)ec_setAppKey:(NSString *)appKey AppToken:(NSString *)AppToken {
    self.appKey = appKey;
    self.appToken = AppToken;
}

- (void)ec_loginECSdk:(void(^)(ECError *error))completion {
        [self loginECSDK:completion];
}

- (void)loginECSDK:(void(^)(ECError *error))completion {
    // 记录手机号
    ECLoginInfo * loginInfo = [[ECLoginInfo alloc] init];
    loginInfo.username = [ECDevicePersonInfo sharedInstanced].userName;
    loginInfo.userPassword = [ECDevicePersonInfo sharedInstanced].userPassword;
    loginInfo.appKey = self.appKey;
    loginInfo.appToken = self.appToken;
    loginInfo.authType = [ECDeviceDelegateConfigCenter sharedInstanced].loginAuthType;
    loginInfo.mode = LoginMode_InputPassword;
    
    [[ECDBManager sharedInstanced] openDB:loginInfo.username];
    [[ECDevice sharedInstance] login:loginInfo completion:^(ECError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_LoginSucess object:error];
        });
        [ECDeviceDelegateConfigCenter sharedInstanced].isLogin = error.errorCode == ECErrorType_NoError;
        if (completion)
            completion(error);
    }];
}

- (void)ec_fetchTopSessionId:(NSNotification *)noti {
    
    if ([noti.object isKindOfClass:[NSNumber class]]) {
        if ([noti.object boolValue]) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                
                [[ECDevice sharedInstance].messageManager getTopSessionLists:^(ECError *error, NSArray *topContactLists) {
                    if(error.errorCode == ECErrorType_NoError) {
                        EC_Demo_AppLog(@"top contact list = %@", topContactLists);
                        
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                            
                            for (NSString *sessionId in topContactLists) {
                                ECSession *session = [[ECSession alloc] init];
                                session.sessionId = sessionId;
                                session.isTop = YES;
                                ECSession *tempSession = [[ECDBManager sharedInstanced].sessionMgr selectSession:sessionId];
                                if (tempSession && tempSession.sessionId.length > 0 && tempSession.text.length>0) {
                                    tempSession.isTop = YES;
                                    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:tempSession isShow:YES];
                                } else {
                                    [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:NO];
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadSession object:nil];
                            });
                        });
                    }
                }];
            });
        }
    }
}

#pragma mark - 发送消息
- (ECMessage *)ec_sendMessage:(ECMessage *)message {
    [self ec_sendUserState:ECUserInputState_None to:message.to];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    message.messageId = [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
        EC_Demo_AppLog(@"send err code = %ld, err description = %@", error.errorCode, error.errorDescription);
        if (error.errorCode == ECErrorType_NoError) {
        } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        } else if (error.errorCode == ECErrorType_ContentTooLong) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        [[ECMessageDB sharedInstanced] updateState:amessage.messageState ofMessageId:message.messageId andSession:message.sessionId];
        /*发送通知*/
        if (amessage)
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_SendNewMesssageCompletion object:nil userInfo:@{EC_KErrorKey:error, EC_KMessageKey:amessage}];
    }];
    [[ECDBManagerUtil sharedInstanced] addNewMessage:message andSessionId:message.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_SendNewMesssage object:message];
    return message;
}

- (ECMessage *)ec_sendTransimitMessage:(ECMessage *)message to:(NSString *)to {
    message.to = to;
    message.sessionId = to;
    message.from = [ECDevicePersonInfo sharedInstanced].userName;
    NSInteger fileType = [ECMessage ExtendTypeOfTextMessage:message];
    switch (fileType) {
        case EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_SIGHTVIDEO:
        case EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_FIREMESSAGE:
        case MessageBodyType_Image:
        case MessageBodyType_Video:
        case MessageBodyType_Voice:
        case MessageBodyType_Preview:
        case MessageBodyType_File: {
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            if (body.localPath.length > 0) {
                body.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:body.localPath.lastPathComponent];
            }
        }
            break;
            
        default:
            break;
    }
    return [self ec_sendMessage:message];
}

- (ECMessage *)ec_sendMessage:(ECMessageBody*)mediaBody to:(NSString*)to{
    return [self ec_sendMessage:mediaBody to:to withUserData:@""];
}

- (ECMessage *)ec_sendMessage:(ECMessageBody*)mediaBody to:(NSString*)to withUserData:(NSString*)userData {
    return [self ec_sendMessage:mediaBody to:to withUserData:userData atArray:nil];
}

- (ECMessage *)ec_sendMessage:(ECMessageBody*)mediaBody to:(NSString*)to withUserData:(NSString*)userData atArray:(NSArray *)atArray{
    if([mediaBody isKindOfClass:[ECTextMessageBody class]]){
        ((ECTextMessageBody *)mediaBody).atArray = atArray;
    }
    ECMessage *message = [[ECMessage alloc] initWithReceiver:to body:mediaBody];
    message.userData = userData;
    message = [self ec_sendMessage:message];
    return message;
}

- (ECMessage *)ec_resendMessage:(ECMessage *)message {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    NSString *oldMsgId = message.messageId;
    message.messageId = [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
        EC_Demo_AppLog(@"send err code = %ld, err description = %@", error.errorCode, error.errorDescription);
        if (error.errorCode == ECErrorType_NoError) {
        } else if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已被禁言" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        } else if (error.errorCode == ECErrorType_ContentTooLong) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        [[ECMessageDB sharedInstanced] updateState:amessage.messageState ofMessageId:amessage.messageId andSession:amessage.sessionId];
        /*发送通知*/
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_SendNewMesssageCompletion object:nil userInfo:@{EC_KErrorKey:error, EC_KMessageKey:amessage}];
    }];
    [[ECDBManagerUtil sharedInstanced] updateMessageId:message andTime:(long long)tmp ofMessageId:oldMsgId];
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_SendNewMesssage object:message];
    
    return message;
}

//发生用户状态信息
- (void)ec_sendUserState:(ECUserInputState)state to:(NSString *)to{
    if ([to hasPrefix:@"g"])
        return;
    [[ECDevice sharedInstance].messageManager sendMessage:[[ECMessage alloc] initWithReceiver:to body:[[ECUserStateMessageBody alloc] initWithUserState:[NSString stringWithFormat:@"%ld", state]]] progress:nil completion:^(ECError *error, ECMessage *message) {
        EC_Demo_AppLog(@"%ld===%@", error.errorCode, error.errorDescription);
        if(error.errorCode == ECErrorType_NoError){
        }
    }];
}

//聊天室
- (ECMessage *)ec_sendLiveChatRoomMessage:(ECMessage*)message {
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    [[ECDevice sharedInstance].liveChatRoomManager sendLiveChatRoomMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
        
        if (error.errorCode == ECErrorType_LiveChatRoom_Forbid) {
        }
        EC_Demo_AppLog(@"error code = %ld, desc = %@, id = %@", error.errorCode, error.errorDescription, amessage.messageId);
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_SendLiveChatRoomMessageCompletion object:nil userInfo:@{EC_KErrorKey:error, EC_KMessageKey:amessage}];
    }];
    
    return message;
}

#pragma mark - 下载消息
- (void)ec_downloadMediaMessage:(ECMessage *)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion {
    
    ECFileMessageBody *mediaBody = (ECFileMessageBody*)message.messageBody;
    mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
    
    mediaBody.mediaDownloadStatus = ECMediaDownloading;
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:message progress:self completion:^(ECError *error, ECMessage *message) {
        if (error.errorCode == ECErrorType_NoError) {
            mediaBody.mediaDownloadStatus = ECMediaDownloadSuccessed;
            [[ECDBManager sharedInstanced].messageMgr updateMessageLocalPath:message.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody *)message.messageBody).mediaDownloadStatus andSession:message.sessionId];
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:mediaBody.localPath error:nil];
            mediaBody.mediaDownloadStatus = ECMediaDownloadFailure;
            mediaBody.localPath = nil;
            [[ECDBManager sharedInstanced].messageMgr updateMessageLocalPath:message.messageId withPath:@"" withDownloadState:ECMediaDownloadFailure andSession:message.sessionId];
        }
        
        if (completion != nil) {
            completion(error, message);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{EC_KErrorKey:error, EC_KMessageKey:message}];
    }];
    [self ec_downloadHDMediaMessage:message andCompletion:nil];
}

- (void)ec_downloadHDMediaMessage:(ECMessage *)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion {
    if ([message.messageBody isKindOfClass:[ECImageMessageBody class]]) {
        
        ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
        if (mediaBody.isHD) {
            
            mediaBody.HDLocalPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
            
            mediaBody.HDDownloadStatus = ECMediaDownloading;
            [[ECDevice sharedInstance].messageManager downloadHDImageMessage:message progress:self completion:^(ECError *error, ECMessage *message) {
                if (error.errorCode == ECErrorType_NoError) {
                    mediaBody.mediaDownloadStatus = ECMediaDownloadSuccessed;
                    [[ECDBManager sharedInstanced].messageMgr updateMessageHDLocalPath:message.messageId withPath:mediaBody.HDLocalPath withDownloadState:((ECImageMessageBody *)message.messageBody).HDDownloadStatus andSession:message.sessionId];
                } else {
                    [[NSFileManager defaultManager] removeItemAtPath:mediaBody.HDLocalPath error:nil];
                    mediaBody.HDDownloadStatus = ECMediaDownloadFailure;
                    mediaBody.HDLocalPath = nil;
                    [[ECDBManager sharedInstanced].messageMgr updateMessageHDLocalPath:message.messageId withPath:@"" withDownloadState:ECMediaDownloadFailure andSession:message.sessionId];
                }
                
                if (completion != nil) {
                    completion(error, message);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{EC_KErrorKey:error, EC_KMessageKey:message}];
            }];
        }
    }
}

- (void)setProgress:(float)progress forMessage:(ECMessage *)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_MessageProgressChanged object:nil userInfo:@{EC_KProgressKey:@(progress), EC_KMessageKey:message}];
}

#pragma mark - 删除消息
- (void)ec_deleteMessage:(ECMessage *)message {
    [[ECDevice sharedInstance].messageManager deleteMessage:message completion:^(ECError *error, ECMessage *smessage) {
        [[ECMessageDB sharedInstanced] deleteMessage:message.messageId withSession:message.sessionId];
        ECMessage *amessage = nil;
        if (error.errorCode == ECErrorType_NoError) {
            amessage = [ECRevokeMessageBody sendMessage:message WithText:@"您删除了一条阅后即焚消息"];
        } else if (message.messageState == ECMessageState_SendSuccess) {
            NSString *nickName = [[ECDevicePersonInfo sharedInstanced] getOtherNameWithPhone:message.from];
            amessage = [ECRevokeMessageBody sendMessage:message WithText:[NSString stringWithFormat:@"\"%@\"已阅此消息并删除",nickName.length>0?nickName:message.from]];
        }
        amessage.isReadFireMessage = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_DeleteMessageNoti object:amessage];
    }];
}

#pragma mark - 已阅消息
- (void)ec_readMessage:(ECMessage *)message {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EC_Demo_AppLog(@"已阅了消息%@---%d",message.messageId,message.isRead);
        [[ECDevice sharedInstance].messageManager readedMessage:message completion:^(ECError *error, ECMessage *amessage) {
            if (error.errorCode == ECErrorType_NoError) {
                [[ECDBManager sharedInstanced].messageMgr updateMessageReadState:message.sessionId messageId:message.messageId isRead:amessage.isRead];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReadMessageNoti object:amessage];
                });
            }
        }];
    });
}

#pragma mark - 扩展
- (void)updateFileMessageDownloadState:(ECMessage *)message {
    MessageBodyType bodyType = message.messageBody.messageBodyType;
    if(bodyType == MessageBodyType_Voice || bodyType == MessageBodyType_Video || bodyType == MessageBodyType_File || bodyType == MessageBodyType_Image || bodyType== MessageBodyType_Preview) {
        ECFileMessageBody *mediaBody = (ECFileMessageBody*)message.messageBody;
        [[ECMessageDB sharedInstanced] updateMessageLocalPath:mediaBody.localPath withPath:mediaBody.localPath withDownloadState:mediaBody.mediaDownloadStatus andSession:message.sessionId];
    }
}

+ (NSString *)ec_getDeviceWithType:(ECDeviceType)type{
    switch (type) {
        case ECDeviceType_AndroidPhone:
            return NSLocalizedString(@"Android手机", nil);
            
        case ECDeviceType_iPhone:
            return NSLocalizedString(@"iPhone手机",nil);
            
        case ECDeviceType_iPad:
            return NSLocalizedString(@"iPad平板",nil);
            
        case ECDeviceType_AndroidPad:
            return NSLocalizedString(@"Android平板",nil);
            
        case ECDeviceType_PC:
            return NSLocalizedString(@"PC",nil);
            
        case ECDeviceType_Web:
            return NSLocalizedString(@"Web",nil);
            
        case ECDeviceType_Mac:
            return NSLocalizedString(@"Mac",nil);
            
        default:
            return NSLocalizedString(@"未知",nil);
    }
}

+ (NSString *)ec_getNetWorkWithType:(ECNetworkType)type {
    switch (type) {
        case ECNetworkType_WIFI:
            return @"wifi";
            
        case ECNetworkType_4G:
            return @"4G";
            
        case ECNetworkType_3G:
            return @"3G";
            
        case ECNetworkType_GPRS:
            return @"GRPS";
            
        case ECNetworkType_LAN:
            return @"Internet";
        default:
            return @"其他";
    }
}

#pragma mark - 根据sessionid获取昵称
+ (NSString *)ec_getNickNameWithSessionId:(NSString*)sessionId {
    
    if (sessionId.length <= 0)
        return @"";
    if ([sessionId isEqualToString:@"系统通知"])
        return @"系统通知";
    
    if ([sessionId hasPrefix:@"g"]) {
        NSString *name = [[ECDBManager sharedInstanced].groupInfoMgr getGroupNameOfId:sessionId];
        
        if (name.length ==0) {
            //请求群组信息
            [[ECDevice sharedInstance].messageManager getGroupDetail:sessionId completion:^(ECError *error, ECGroup *group) {
                if (error.errorCode == ECErrorType_NoError && group.name.length>0) {
                    [[ECGroupInfoDB sharedInstanced] insertGroup:group];
                    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadSession object:group];
                }
            }];
            return sessionId;
        }
        ECGroup *agroup = [[ECDBManager sharedInstanced].groupInfoMgr selectGroupOfGroupId:sessionId];
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadSession object:agroup];
        return name;
    }
    if([[ECDBManager sharedInstanced].friendMgr queryFriend:sessionId])
        return [[[ECDBManager sharedInstanced].friendMgr queryFriend:sessionId] displayName];
    return sessionId;
}

@end
