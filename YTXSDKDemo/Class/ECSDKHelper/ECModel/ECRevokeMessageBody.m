//
//  ECRevokeMessageBody.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/12.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ECRevokeMessageBody.h"

@implementation ECRevokeMessageBody
-(instancetype)initWithText:(NSString*)text {
    self = [super init];
    if (self) {
        _text = text;
    }
    return self;
}

+ (ECMessage *)sendDefaultRevokeMessage:(ECMessage *)message {
    return [self sendMessage:message WithText:@"您撤回了一条消息"];
}

+ (ECMessage *)sendMessage:(ECMessage *)message WithText:(NSString *)text {
    ECRevokeMessageBody *revokeBody = [[ECRevokeMessageBody alloc] initWithText:text];
    ECMessage *amessage = [[ECMessage alloc] initWithReceiver:message.sessionId body:revokeBody];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp = [date timeIntervalSince1970]*1000;
    amessage.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    amessage.isRead = YES;
    amessage.isGroup = [message.sessionId hasPrefix:@"g"]?YES:NO;
    amessage.messageState = ECMessageState_SendSuccess;
    amessage.messageId = message.messageId;
    if ([[ECDBManager sharedInstanced].messageMgr getMessageWithMessageId:message.messageId OfSession:message.sessionId]==nil) {
        [[ECDBManagerUtil sharedInstanced] addNewMessage:amessage andSessionId:message.sessionId];
    } else {
        [[ECDBManager sharedInstanced].dbMgrUtil updateSrcMessage:message.sessionId msgid:message.messageId withDstMessage:amessage];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveRevokeMessageNoti object:amessage];
    return amessage;
}
@end
