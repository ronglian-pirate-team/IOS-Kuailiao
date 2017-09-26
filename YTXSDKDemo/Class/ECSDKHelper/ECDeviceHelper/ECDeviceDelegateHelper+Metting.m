//
//  ECDeviceDelegateHelper+Metting.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/1.
//
//

#import "ECDeviceDelegateHelper+Metting.h"

@implementation ECDeviceDelegateHelper (Metting)

/**
 @brief 有会议呼叫邀请
 @param callid      会话id
 @param calltype    呼叫类型
 @param meetingData 会议的数据
 */
- (NSString*)onMeetingCallReceived:(NSString*)callid withCallType:(CallType)calltype withMeetingData:(NSDictionary*)meetingData {
    EC_SDKCONFIG_AppLog(@"%s: callid:%@  meetingData=%@ calltype=%d",__func__,callid,meetingData,(int)calltype);
    
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    [ECDeviceDelegateConfigCenter sharedInstanced].offCallId = nil;
    if (self.isCallBusy) {
        [[ECDevice sharedInstance].VoIPManager rejectCall:callid andReason:ECErrorType_CallBusy];
        return @"";
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_Meeting_OnIncomingReceiveInfo object:nil userInfo:@{EC_KMetting_CallId:callid,EC_KMetting_CurNo:meetingData[@"ECMeetingDelegate_CallerConfId"], EC_KMetting_CallData:meetingData,EC_KMetting_CallType:@(calltype)}];

    self.isCallBusy = YES;
    return nil;
}

- (void)onReceiveInterphoneMeetingMsg:(ECInterphoneMeetingMsg *)message {
    EC_SDKCONFIG_AppLog(@"onReceiveInterphoneMeetingMsg: type=%d", (int)message.type);
    
    if (message.type == Interphone_INVITE) {
        if (message.interphoneId.length > 0) {
            BOOL isExist = NO;
            for (ECInterphoneMeetingMsg *interphone in self.interphoneArray) {
                if ([interphone.interphoneId isEqualToString:message.interphoneId]) {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist) {
                [self.interphoneArray addObject:message];
            }
        }
    } else if (message.type == Interphone_OVER) {
        if (message.interphoneId.length > 0) {
            for (ECInterphoneMeetingMsg *interphone in self.interphoneArray) {
                if ([interphone.interphoneId isEqualToString:message.interphoneId]) {
                    [self.interphoneArray removeObject:interphone];
                    break;
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveInterphoneMeetingMsg object:message];
}

- (void)onReceiveMultiVoiceMeetingMsg:(ECMultiVoiceMeetingMsg *)message {
    EC_SDKCONFIG_AppLog(@"%s---type=%d",__func__,(int)message.type);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveMultiVoiceMeetingMsg object:message];
}

- (void)onReceiveMultiVideoMeetingMsg:(ECMultiVideoMeetingMsg *)message {
    EC_SDKCONFIG_AppLog(@"%s---type=%d",__func__,(int)message.type);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveMultiVideoMeetingMsg object:message];
}

@end
