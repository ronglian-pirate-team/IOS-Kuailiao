//
//  ECMessageDB.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECMessageDB.h"
#import "ECDBManager.h"

#define Table_Name(sessionId) [@"Chat_" stringByAppendingString:[NSString MD5:sessionId]]

@implementation ECMessageDB

+ (instancetype)sharedInstanced {
    static ECMessageDB* dbManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dbManager = [[ECMessageDB alloc] init];
    });
    return dbManager;
}

- (void)createIMMessageTable:(NSString *)sessionId{
    NSString *tableName = Table_Name(sessionId);
    //    title 在ECPreviewMessageBody、ECLocationMessageBody用同一字段，type区分
    [[ECDBManager sharedInstanced] createTable:tableName sql:[NSString stringWithFormat:@"CREATE table %@(ID INTEGER PRIMARY KEY AUTOINCREMENT, sender varchar(32), receiver varchar(32), messageId varchar(64), timestamp varchar(32), userData varchar(256), sessionId varchar(32), isGroup INTEGER, messageState INTEGER, isRead INTEGER, groupSenderName varchar(32), senderName varchar(32), messageBodyType INTEGER,  callText TEXT, calltype INTEGER, displayName varchar(32), serverTime varchar(32), localPath TEXT, remotePath TEXT, fileLength varchar(32), isCompress  INTEGER, originFileLength varchar(32), mediaDownloadStatus INTEGER, thumbnailLocalPath TEXT, thumbnailRemotePath TEXT, url TEXT, title TEXT, desc TEXT, duration INTEGER, coordinate TEXT, text TEXT, isAted INTEGER, remark TEXT, cellHeight REAL, cellWidth REAL, readCount INTEGER, isHD INTEGER, HDLocalPath varchar(32), HDRemotePath varchar(32),HDDownloadStatus INTEGER)", tableName]];
}

- (void)selectMessage:(NSString *)session completion:(void (^)(NSArray *array))completion{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * from %@ where sessionId = %@", Table_Name(session), session];
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *msgArr = [NSMutableArray array];
        while ([rs next]) {
            ECMessage *msg = [[ECMessage alloc] init];
            msg.from = [rs stringForColumn:@"sender"];
            msg.to = [rs stringForColumn:@"receiver"];
            msg.messageId = [rs stringForColumn:@"messageId"];
            msg.timestamp = [rs stringForColumn:@"timestamp"];
            msg.userData = [rs stringForColumn:@"userData"];
            msg.sessionId = [rs stringForColumn:@"sessionId"];
            msg.isGroup = [rs intForColumn:@"isGroup"];
            msg.messageState = [rs intForColumn:@"messageState"];
            msg.isRead = [rs intForColumn:@"isRead"];
            msg.senderName = [rs stringForColumn:@"senderName"];
            msg.messageBody = [self confirmMessageBody:rs];
            msg.cellHeight = [rs doubleForColumn:@"cellHeight"];
            msg.cellWidth = [rs doubleForColumn:@"cellWidth"];
            msg.readCount = [rs intForColumn:@"readCount"];
            [msgArr addObject:msg];
        }
        [rs close];
        if (completion) {
            completion(msgArr);
        }
    }];
}

- (void)insertMessage:(ECMessage *)message{
    [self createIMMessageTable:message.sessionId];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        ECMessageBody *body = message.messageBody;
        NSString *tableName = Table_Name(message.sessionId);
        NSMutableDictionary *dic = [self operationMessage:message];
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(sender, receiver, messageId, timestamp, userData, sessionId, isGroup, messageState, isRead, groupSenderName, senderName, messageBodyType,  callText, calltype, displayName, serverTime, localPath, remotePath, fileLength, isCompress, originFileLength, mediaDownloadStatus, thumbnailLocalPath, thumbnailRemotePath, url, title, desc, duration, coordinate, text, isAted, remark, cellHeight,cellWidth,readCount, isHD, HDLocalPath, HDRemotePath,HDDownloadStatus) VALUES ('%@','%@','%@','%@','%@','%@','%d','%d','%d','%@','%@','%d','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@', '0.0','0.0','0','%d','%@','%@','%d')", tableName, message.from, message.to, message.messageId, message.timestamp, message.userData, message.sessionId, message.isGroup, (int)message.messageState, message.isRead, @"", message.senderName, (int)body.messageBodyType, [dic fetchValueForKey:@"callText"], [dic fetchValueForKey:@"calltype"], [dic fetchValueForKey:@"displayName"], [dic fetchValueForKey:@"serverTime"], [dic fetchValueForKey:@"localPath"], [dic fetchValueForKey:@"remotePath"], [dic fetchValueForKey:@"fileLength"], [dic fetchValueForKey:@"isCompress"], [dic fetchValueForKey:@"originFileLength"], @(ECMediaUnDownload), [dic fetchValueForKey:@"thumbnailLocalPath"], [dic fetchValueForKey:@"thumbnailRemotePath"], [dic fetchValueForKey:@"url"],  [dic fetchValueForKey:@"title"],  [dic fetchValueForKey:@"desc"],  [dic fetchValueForKey:@"duration"], [dic fetchValueForKey:@"coordinate"], [dic fetchValueForKey:@"text"], [dic fetchValueForKey:@"isAted"], @"",[[dic fetchValueForKey:@"isHD"] intValue],[dic fetchValueForKey:@"HDLocalPath"],[dic fetchValueForKey:@"HDRemotePath"],[[dic fetchValueForKey:@"HDDownloadStatus"] intValue]];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"message insert success %d", isSuccess);
    }];
}

- (void)deleteMessage:(NSString *)msgId withSession:(NSString *)sessionId{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where messageId = '%@' ", Table_Name(sessionId), msgId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"message delete success %d", isSuccess);
    }];
}

- (void)deleteAllMessage:(NSString *)sessionId{
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@", Table_Name(sessionId)];
        [db executeUpdate:sql];
    }];
}

//更新某消息的状态
- (void)updateState:(ECMessageState)state ofMessageId:(NSString*)msgId andSession:(NSString*)sessionId {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET messageState = %d WHERE messageId = '%@' ",Table_Name(sessionId),(int)state, msgId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"message UPDATE messageState success %d", isSuccess);
    }];
}

//重发，更新某消息的消息id
- (void)updateMessageId:(NSString *)msdNewId andTime:(long long)time ofMessageId:(NSString*)msgOldId andSession:(NSString*)sessionId {
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET messageId='%@', timestamp=%lld WHERE messageId='%@' ",Table_Name(sessionId),msdNewId,time, msgOldId];
        BOOL isSuccess = [db executeUpdate:sql];
        EC_DB_LOG(@"message delete success %d", isSuccess);
    }];
}

#pragma mark - message处理
- (NSMutableDictionary *)operationMessage:(ECMessage *)message{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    ECMessageBody *body = message.messageBody;
    switch (body.messageBodyType) {
        case MessageBodyType_None: {
            ECRevokeMessageBody *revokeBody = (ECRevokeMessageBody *)body;
            dic[@"text"] = revokeBody.text;
        }
            break;
        case MessageBodyType_Text:{
            ECTextMessageBody *textBody = (ECTextMessageBody *)body;
            dic[@"text"] = textBody.text;
            dic[@"serverTime"] = textBody.serverTime;
            dic[@"isAted"] = @(textBody.isAted);
        }
            break;
        case MessageBodyType_Voice:{
            ECVoiceMessageBody *voiceBody = (ECVoiceMessageBody *)body;
            dic[@"duration"] = @(voiceBody.duration);
            [self configMessageDic:dic withBody:voiceBody];
        }
            break;
        case MessageBodyType_Video:{
            ECVideoMessageBody *videoBody = (ECVideoMessageBody *)body;
            dic[@"thumbnailLocalPath"] = videoBody.thumbnailLocalPath;
            dic[@"thumbnailRemotePath"] = videoBody.thumbnailRemotePath;
            dic[@"mediaDownloadStatus"] = @(videoBody.mediaDownloadStatus);
            [self configMessageDic:dic withBody:videoBody];
        }
            break;
        case MessageBodyType_Image:{
            ECImageMessageBody *imageBody = (ECImageMessageBody *)body;
            dic[@"thumbnailLocalPath"] = imageBody.thumbnailLocalPath;
            dic[@"thumbnailRemotePath"] = imageBody.thumbnailRemotePath;
            dic[@"mediaDownloadStatus"] = @(imageBody.mediaDownloadStatus);
            dic[@"isHD"] = @(imageBody.isHD);
            dic[@"HDLocalPath"] = imageBody.HDLocalPath;
            dic[@"HDRemotePath"] = imageBody.HDRemotePath;
            dic[@"HDDownloadStatus"] = @(imageBody.HDDownloadStatus);
            [self configMessageDic:dic withBody:imageBody];
        }
            break;
        case MessageBodyType_Location:{
            ECLocationMessageBody *locationBody = (ECLocationMessageBody *)body;
            dic[@"coordinate"] = NSStringFromCGPoint((CGPoint){locationBody.coordinate.latitude,locationBody.coordinate.longitude});
            dic[@"title"] = locationBody.title;
        }
            break;
        case MessageBodyType_File:{
            ECVideoMessageBody *fileBody = (ECVideoMessageBody *)body;
            [self configMessageDic:dic withBody:fileBody];
        }
            break;
        case MessageBodyType_Call:{
            ECCallMessageBody *callBody = (ECCallMessageBody *)body;
            dic[@"callText"] = callBody.callText;
            dic[@"calltype"] = @(callBody.calltype);
        }
            break;
        case MessageBodyType_Preview:{
            ECPreviewMessageBody *preBody = (ECPreviewMessageBody *)body;
            dic[@"url"] = preBody.url;
            dic[@"title"] = preBody.title;
            dic[@"desc"] = preBody.desc;
            dic[@"thumbnailRemotePath"] = preBody.thumbnailRemotePath;
            dic[@"thumbnailLocalPath"] = preBody.thumbnailLocalPath;
            [self configMessageDic:dic withBody:preBody];
        }
            break;
        default:
            break;
    }
    return dic;
}

- (void)configMessageDic:(NSMutableDictionary *)dic withBody:(ECFileMessageBody *)fileBody{
    dic[@"displayName"] = fileBody.displayName;
    dic[@"serverTime"] = fileBody.serverTime;
    dic[@"localPath"] = fileBody.localPath;
    dic[@"remotePath"] = fileBody.remotePath;
    dic[@"fileLength"] = @(fileBody.fileLength);
    dic[@"isCompress"] = @(fileBody.isCompress);
    dic[@"originFileLength"] = @(fileBody.originFileLength);
    dic[@"mediaDownloadStatus"] = @(fileBody.mediaDownloadStatus);
}

- (ECMessageBody *)confirmMessageBody:(FMResultSet*)rs {
    MessageBodyType type = [rs intForColumn:@"messageBodyType"];
    NSString *localPath = [rs stringForColumn:@"localPath"];
    if(localPath.length>0)
        localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localPath.lastPathComponent];
    switch (type) {
        case MessageBodyType_None:{
            ECRevokeMessageBody *revokeBody = [[ECRevokeMessageBody alloc] initWithText:[rs stringForColumn:@"text"]];
            return revokeBody;
        }
            break;
        case MessageBodyType_Text:{
            ECTextMessageBody* messageBody = [[ECTextMessageBody alloc] initWithText:[rs stringForColumn:@"text"]];
            messageBody.serverTime = [rs stringForColumn:@"serverTime"];
            messageBody.isAted = [rs intForColumn:@"isAted"];
            return messageBody;
        }
            break;
        case MessageBodyType_Voice:{
            ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:localPath displayName:@""];
            messageBody.remotePath = [rs stringForColumn:@"remotePath"];
            messageBody.mediaDownloadStatus = [rs intForColumn:@"mediaDownloadStatus"];
            messageBody.displayName = [rs stringForColumn:@"displayName"];
            messageBody.duration = [rs intForColumn:@"duration"];
            [self fileMessageBody:messageBody withResultSet:rs];
            return messageBody;
        }
            break;
        case MessageBodyType_Video:{
            ECVideoMessageBody * messageBody = [[ECVideoMessageBody alloc] initWithFile:localPath displayName:@""];
            messageBody.remotePath = [rs stringForColumn:@"remotePath"];
            messageBody.mediaDownloadStatus = [rs intForColumn:@"mediaDownloadStatus"];
            messageBody.thumbnailRemotePath = [rs stringForColumn:@"thumbnailRemotePath"];
            NSString *localImagePath = [rs stringForColumn:@"thumbnailLocalPath"];
            if(localImagePath && localImagePath.length > 0){
                localImagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localImagePath.lastPathComponent];
                messageBody.thumbnailLocalPath = localImagePath;
            }
            [self fileMessageBody:messageBody withResultSet:rs];
            return messageBody;
        }
            break;
        case MessageBodyType_Image:{
            ECImageMessageBody * messageBody = [[ECImageMessageBody alloc] initWithFile:localPath displayName:@""];
            messageBody.remotePath = [rs stringForColumn:@"remotePath"];
            messageBody.mediaDownloadStatus = [rs intForColumn:@"mediaDownloadStatus"];
            messageBody.thumbnailRemotePath = [rs stringForColumn:@"thumbnailRemotePath"];
            messageBody.isHD = [rs intForColumn:@"isHD"];
            messageBody.HDDownloadStatus = [rs intForColumn:@"HDDownloadStatus"];
            if([rs stringForColumn:@"HDLocalPath"])
                messageBody.HDLocalPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[rs stringForColumn:@"HDLocalPath"].lastPathComponent];
            messageBody.HDRemotePath = [rs stringForColumn:@"HDRemotePath"];
            [self fileMessageBody:messageBody withResultSet:rs];
            return messageBody;
        }
            break;
        case MessageBodyType_Location:{
            ECLocationMessageBody* messageBody = [[ECLocationMessageBody alloc] init];
            messageBody.title = [rs stringForColumn:@"title"];
            CGPoint point = CGPointFromString([rs stringForColumn:@"coordinate"]);
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = point.x -5;
            coordinate.longitude = point.y;
            messageBody.coordinate = coordinate;
            return messageBody;
        }
            break;
        case MessageBodyType_File:{
            ECFileMessageBody * messageBody = [[ECFileMessageBody alloc] initWithFile:localPath displayName:@""];
            [self fileMessageBody:messageBody withResultSet:rs];
            return messageBody;
        }
            break;
        case MessageBodyType_Call:{
            ECCallMessageBody* messageBody = [[ECCallMessageBody alloc] initWithCallText:[rs stringForColumn:@"callText"]];
            messageBody.calltype = [rs intForColumn:@"calltype"];
            return messageBody;
        }
            break;
        case MessageBodyType_Preview:{
            ECPreviewMessageBody *preBody = [[ECPreviewMessageBody alloc] init];
            preBody.url = [rs stringForColumn:@"url"];
            preBody.title = [rs stringForColumn:@"title"];
            preBody.desc = [rs stringForColumn:@"desc"];
            preBody.thumbnailRemotePath = [rs stringForColumn:@"thumbnailRemotePath"];
            preBody.thumbnailDownloadStatus = [rs intForColumn:@"thumbnailDownloadStatus"];
            if([rs stringForColumn:@"thumbnailLocalPath"])
                preBody.thumbnailLocalPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[rs stringForColumn:@"thumbnailLocalPath"].lastPathComponent];
            [self fileMessageBody:preBody withResultSet:rs];
            return preBody;
        }
            break;
        default:{
        }
            break;
    }
    return nil;
}

- (void)fileMessageBody:(ECFileMessageBody *)messageBody withResultSet:(FMResultSet *)rs{
    messageBody.remotePath = [rs stringForColumn:@"remotePath"];
    messageBody.mediaDownloadStatus = [rs intForColumn:@"mediaDownloadStatus"];
    messageBody.displayName = [rs stringForColumn:@"displayName"];
    messageBody.serverTime = [rs stringForColumn:@"serverTime"];
    if ([rs stringForColumn:@"localPath"])
        messageBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[rs stringForColumn:@"localPath"].lastPathComponent];
    messageBody.remotePath = [rs stringForColumn:@"remotePath"];
    messageBody.fileLength = [[rs stringForColumn:@"fileLength"] longLongValue];
    messageBody.isCompress = [rs intForColumn:@"isCompress"];
    messageBody.originFileLength = [[rs stringForColumn:@"originFileLength"] longLongValue];
}

//修改单条消息的下载路径
-(BOOL)updateMessageLocalPath:(NSString*)msgId withPath:(NSString*)path withDownloadState:(ECMediaDownloadStatus)state andSession:(NSString*)sessionId {
    __block BOOL isSuccess = NO;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:Table_Name(sessionId)]) {
            isSuccess = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET localPath='%@',mediaDownloadStatus = %d WHERE messageId = '%@' ",Table_Name(sessionId),path,(int)state, msgId]];
            EC_DB_LOG(@"%@---%d--%d",@"附件更新状态",(int)state,isSuccess);
        }
    }];
    return isSuccess;
}

//修改单条消息的下载路径
-(BOOL)updateMessageHDLocalPath:(NSString *)msgId withPath:(NSString *)HDLocalPath withDownloadState:(ECMediaDownloadStatus)state andSession:(NSString*)sessionId {
    __block BOOL isSuccess = NO;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:Table_Name(sessionId)]) {
            isSuccess = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET HDLocalPath='%@',HDDownloadStatus = %d WHERE messageId = '%@' ",Table_Name(sessionId),HDLocalPath,(int)state, msgId]];
            EC_DB_LOG(@"%@---%d--%d",@"附件更新状态",(int)state,isSuccess);
        }
    }];
    return isSuccess;
}

- (ECMessage *)getMessageWithMessageId:(NSString*)messageId OfSession:(NSString *)sessionId {
    NSArray *array = [self getSomeMessagesCount:1 andConditions:[NSString stringWithFormat:@"messageId = '%@' ",messageId] OfSession:sessionId];
    if (array.count>0) {
        return array[0];
    }
    return nil;
}

- (NSArray *)getLatestSomeMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId {
    return [self getSomeMessagesCount:count andConditions:nil OfSession:sessionId];
}

- (NSArray *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString*)sessionId beforeTime:(long long)timesamp {
    return [self getSomeMessagesCount:count andConditions:[NSString stringWithFormat:@"timestamp < %lld ",timesamp] OfSession:sessionId];
}

- (NSArray*)getSomeMessagesCount:(NSInteger)count andConditions:(NSString*) conditions  OfSession:(NSString *)sessionId {
    
    NSMutableArray * msgArray = [NSMutableArray array];
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:Table_Name(sessionId)]) {
            NSString *sql = [NSString stringWithFormat:@"SELECT sender, receiver, messageId, timestamp, userData, sessionId, isGroup, messageState, isRead, groupSenderName, senderName, messageBodyType,  callText, calltype, displayName, serverTime, localPath, remotePath, fileLength, isCompress, originFileLength, mediaDownloadStatus, thumbnailLocalPath, thumbnailRemotePath, url, title, desc, duration, coordinate, text, isAted, remark, cellHeight, cellWidth, readCount, isHD, HDLocalPath, HDRemotePath,HDDownloadStatus FROM (SELECT * FROM %@ WHERE %@ ORDER BY timestamp DESC LIMIT %d) ORDER BY timestamp ASC", Table_Name(sessionId), conditions, (int)count];
            if (conditions.length==0)
                sql = [NSString stringWithFormat:@"SELECT sender, receiver, messageId, timestamp, userData, sessionId, isGroup, messageState, isRead, groupSenderName, senderName, messageBodyType,  callText, calltype, displayName, serverTime, localPath, remotePath, fileLength, isCompress, originFileLength, mediaDownloadStatus, thumbnailLocalPath, thumbnailRemotePath, url, title, desc, duration, coordinate, text, isAted, remark, cellHeight, cellWidth, readCount, isHD, HDLocalPath, HDRemotePath,HDDownloadStatus FROM (SELECT * FROM %@ ORDER BY timestamp DESC LIMIT %d) ORDER BY timestamp ASC", Table_Name(sessionId), (int)count];
            FMResultSet *rs = [db executeQuery:sql];
            while ([rs next]) {
                ECMessage* msg = [[ECMessage alloc] init];
                msg.messageId = [rs stringForColumn:@"messageId"];
                msg.from = [rs stringForColumn:@"sender"];
                msg.to = [rs stringForColumn:@"receiver"];
                msg.timestamp = [rs stringForColumn:@"timestamp"];
                msg.userData = [rs stringForColumn:@"userData"];
                msg.sessionId = [rs stringForColumn:@"sessionId"];
                msg.isGroup = [rs intForColumn:@"isGroup"];
                msg.messageState = [rs intForColumn:@"messageState"];
                msg.messageBody = (ECMessageBody *)[self confirmMessageBody:rs];
                msg.isRead = [rs intForColumn:@"isRead"];
                msg.cellHeight = [rs doubleForColumn:@"cellHeight"];
                msg.cellWidth = [rs doubleForColumn:@"cellWidth"];
                msg.readCount = [rs intForColumn:@"readCount"];
                [msgArray addObject:msg];
            }
            [rs close];
        }
    }];
    return msgArray;
}

- (BOOL)updateMessage:(NSString*)sessionId msgid:(NSString *)msgId withMessage:(ECMessage *)message {
    __block BOOL isSuccess = NO;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:Table_Name(sessionId)]) {
            ECMessageBody *body = message.messageBody;
            NSMutableDictionary *dic = [self operationMessage:message];
            isSuccess = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET sender='%@', receiver='%@', messageId='%@', timestamp='%@', userData='%@', sessionId='%@', isGroup='%d', messageState='%d', isRead='%d', groupSenderName='%@', senderName='%@', messageBodyType='%d', callText='%@', calltype='%@', displayName='%@', serverTime='%@', localPath='%@', remotePath='%@', fileLength='%@', isCompress='%@', originFileLength='%@', mediaDownloadStatus='%@', thumbnailLocalPath='%@', thumbnailRemotePath='%@', url='%@', title='%@', desc='%@', duration='%@', coordinate='%@', text='%@', isAted='%@', remark='%@', cellHeight='%f', cellWidth='%f', readCount = %d WHERE messageId='%@' ",Table_Name(sessionId),message.from, message.to, msgId, message.timestamp, message.userData, sessionId, message.isGroup, (int)message.messageState, message.isRead, @"", message.senderName, (int)body.messageBodyType, [dic fetchValueForKey:@"callText"], [dic fetchValueForKey:@"calltype"], [dic fetchValueForKey:@"displayName"], [dic fetchValueForKey:@"serverTime"], [dic fetchValueForKey:@"localPath"], [dic fetchValueForKey:@"remotePath"], [dic fetchValueForKey:@"fileLength"], [dic fetchValueForKey:@"isCompress"], [dic fetchValueForKey:@"originFileLength"], @(ECMediaUnDownload), [dic fetchValueForKey:@"thumbnailLocalPath"], [dic fetchValueForKey:@"thumbnailRemotePath"], [dic fetchValueForKey:@"url"],  [dic fetchValueForKey:@"title"],  [dic fetchValueForKey:@"desc"],  [dic fetchValueForKey:@"duration"], [dic fetchValueForKey:@"coordinate"], [dic fetchValueForKey:@"text"], [dic fetchValueForKey:@"isAted"], @"", message.cellWidth, message.cellHeight, (int)message.readCount, msgId]];
            EC_DB_LOG(@"updateMessage dstmessage %d ",isSuccess);
        }
    }];
    return isSuccess;
}

- (BOOL)updateMessageReadState:(NSString*)sessionId messageId:(NSString*)messageId isRead:(BOOL)isRead {
    __block BOOL isSuccess = NO;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:Table_Name(sessionId)]) {
            isSuccess = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET isRead=%d WHERE messageId='%@' ",Table_Name(sessionId),isRead,messageId]];
            EC_DB_LOG(@"updateMessageReadState %d ",isSuccess);
        }
    }];
    return isSuccess;
}

- (BOOL)updateMessageReadCount:(NSString*)sessionId messageId:(NSString*)messageId readCount:(NSInteger)readCount {
    __block BOOL isSuccess = NO;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:Table_Name(sessionId)]) {
            isSuccess = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET readCount= %d WHERE messageId='%@' ",Table_Name(sessionId),(int)readCount,messageId]];
            EC_DB_LOG(@"updateMessageReadCount %d ",isSuccess);
        }
    }];
    return isSuccess;
}

- (BOOL)updateMessageSize:(NSString *)sessionId messageId:(NSString *)messageId withCellSize:(CGSize)cellSize{
    __block BOOL isSuccess = NO;
    [[ECDBManager sharedInstanced].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:Table_Name(sessionId)]) {
            isSuccess = [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET cellHeight=%f,cellWidth=%f WHERE messageId = '%@' ",Table_Name(sessionId),cellSize.height,cellSize.width, messageId]];
            EC_DB_LOG(@"%@---%@",NSLocalizedString(@"更新chatcell的尺寸", nil),@(isSuccess));
        }
    }];
    return isSuccess;
}

#pragma mark - 一些工具方法
- (NSArray *)getAllLocalPathMessageOfSessionId:(NSString *)sessionId type:(MessageBodyType)messageBodyType {
    NSMutableArray *imageArray = [NSMutableArray array];
    [self selectMessage:sessionId completion:^(NSArray *array) {
        ECFileMessageBody *mediaBody = [[ECFileMessageBody alloc] init];
        for (ECMessage *msg in array) {
            if (msg.messageBody.messageBodyType == messageBodyType) {
                mediaBody = (ECFileMessageBody *)msg.messageBody;
                if (mediaBody)
                    [imageArray addObject:mediaBody];
            }
        }
    }];
    return imageArray;
}

//获取会话消息里面为图片消息的路径数组
- (NSArray *)getImageMessageLocalPath:(NSString *)sessionId isHD:(BOOL)isHD {
    NSArray *imageMessage = [self getAllLocalPathMessageOfSessionId:sessionId type:MessageBodyType_Image];
    NSMutableArray *localPathArray = [NSMutableArray array];
    NSString *localPath = [NSString string];
    for (int index = 0; index < imageMessage.count; index++) {
        localPath = isHD?[[imageMessage objectAtIndex:index] HDLocalPath]:[[imageMessage objectAtIndex:index] localPath];
        if (localPath) {//图片路径
            localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:localPath.lastPathComponent];
            [localPathArray addObject:localPath];
        }
    }
    return localPathArray;
}
@end
