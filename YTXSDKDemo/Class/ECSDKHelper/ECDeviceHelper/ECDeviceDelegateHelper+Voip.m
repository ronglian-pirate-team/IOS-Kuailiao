//
//  ECDeviceDelegateHelper+Voip.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/1.
//
//

#import "ECDeviceDelegateHelper+Voip.h"

@implementation ECDeviceDelegateHelper (Voip)

- (NSString *)onIncomingCallReceived:(NSString *)callid withCallerAccount:(NSString *)caller withCallerPhone:(NSString *)callerphone withCallerName:(NSString *)callername withCallType:(CallType)calltype {
    
    EC_SDKCONFIG_AppLog(@"%s: Received:%@ Caller=%@ callerphone=%@ callername=%@ calltype=%d",__func__,callid,caller,callerphone,callername,(int)calltype);
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    [ECDeviceDelegateConfigCenter sharedInstanced].offCallId = nil;
    if (self.isCallBusy) {
        [[ECDevice sharedInstance].VoIPManager rejectCall:callid andReason:ECErrorType_CallBusy];
        return @"";
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_Voip_OnIncomingReceiveInfo object:nil userInfo:@{EC_KVoip_CallId:callid,EC_KVoip_Caller:caller,EC_KVoip_CallerPhone:callerphone,EC_KVoip_CallName:callername,EC_KVoip_CallType:@(calltype)}];
    self.isCallBusy = YES;
    return @"";
}

/**
 @brief 系统事件通知
 @param events 包含的系统事件
 */
- (void)onSystemEvents:(CCPEvents)events {
    EC_SDKCONFIG_AppLog(@"%s: %d",__func__,(int)events);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ReceiveSystemEvent object:@(events)];
}


/**
 呼叫状态的回调

 @param voipCall 呼叫实体类
 */
- (void)onCallEvents:(VoIPCall *)voipCall {
    EC_SDKCONFIG_AppLog(@"%s: %@ ----%d",__func__,voipCall.callID,(int)voipCall.callStatus);
    self.isCallBusy = (voipCall.callStatus == ECallStreaming);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_Voip_ReceiveCallEvents object:voipCall];
}

/**
 @brief 收到dtmf
 @param callid 会话id
 @param dtmf   键值
 */
- (void)onReceiveFrom:(NSString *)callid DTMF:(NSString *)dtmf {
    EC_SDKCONFIG_AppLog(@"onReceiveDTMF=%@",dtmf);
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_Voip_ReceiveDTMFNoti object:@{EC_KVoip_CallId:callid,EC_KVoip_DTMF:dtmf}];
}


/**
 @brief 收到对方切换音视频的请求
 @param callid  会话id
 @param requestType 视频:需要响应 音频:请求删除视频（不需要响应，双方自动去除视频）
 */
- (void)onSwitchCallMediaTypeRequest:(NSString *)callid withMediaType:(CallType)requestType {
    
    EC_SDKCONFIG_AppLog(@"%s=%d",__func__,(int)requestType);
    [[ECDevice sharedInstance].VoIPManager responseSwitchCallMediaType:callid withMediaType:requestType];
}

/**
 收到对方应答切换音视频请求

 @param callid 会话id
 @param responseType 呼叫类型
 */
- (void)onSwitchCallMediaTypeResponse:(NSString *)callid withMediaType:(CallType)responseType {
    EC_SDKCONFIG_AppLog(@"%s=%d",__func__,(int)responseType);
}

- (NSString*)onGetOfflineCallId {
    EC_SDKCONFIG_AppLog(@"%@:onGetOfflineCallId=%@",NSLocalizedString(@"离线呼叫", nil),[ECDeviceDelegateConfigCenter sharedInstanced].offCallId);
    return [ECDeviceDelegateConfigCenter sharedInstanced].offCallId;
}
@end
