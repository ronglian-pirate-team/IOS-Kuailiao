//
//  ECDeviceNotifyMacros.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/26.
//
//

#ifndef ECDeviceNotifyMacros_h
#define ECDeviceNotifyMacros_h

#import "ECDeviceHeaders.h"
#import "ECDeviceHelper.h"
#import "ECRevokeMessageBody.h"
#import "ECDeviceDelegateConfigCenter.h"
#import "ECDeviceDelegateHelper.h"
#import "ECDeviceVoipHelper.h"

#import "ECAFNHttpTool+Friend.h"
#import "ECAFNHttpTool+LiveChatRoom.h"

#import "ECMessage+ECChatCell.h"
#import "ECFriendNoticeMsg+ECUtil.h"
#import "ECSession+Util.h"
#import "ECGroup+ECUtil.h"
#import "ECDevicePersonInfo.h"

#import "ECDBMacro.h"


#define EC_DEMO_kNotification_ClearSessionDic @"EC_DEMO_kNotification_ClearSessionDic"//被踢或者主动退出通知
#define EC_DEMO_kNotification_LoginSucess @"EC_DEMO_kNotification_LoginSucess"//登录成功
#define EC_DEMO_kNotification_EixtSucess @"EC_DEMO_kNotification_EixtSucess"//退出成功

#define EC_KNOTIFICATION_NetworkChanged              @"EC_KNOTIFICATION_NetworkChanged"
#define EC_KNotification_ConnectedState              @"EC_KNotification_ConnectedState"
#define EC_KNOTIFICATION_ReceiveSystemEvent          @"EC_KNOTIFICATION_ReceiveSystemEvent"
#define EC_KNOTIFICATION_PersionInfoVersion          @"EC_KNOTIFICATION_PersionInfoVersion"

#define EC_KNOTIFICATION_SendNewMesssage             @"EC_KNOTIFICATION_SendNewMesssage"
#define EC_KNOTIFICATION_SendNewMesssageCompletion   @"EC_KNOTIFICATION_SendNewMesssageCompletion"

#define EC_KNOTIFICATION_ReceiveNewMesssage          @"EC_KNOTIFICATION_ReceiveNewMesssage"
#define EC_KNOTIFICATION_ReceivedGroupNoticeMessage  @"EC_KNOTIFICATION_ReceivedGroupNoticeMessage"

#define EC_KNOTIFICATION_HaveHistoryMessage          @"EC_KNOTIFICATION_HaveHistoryMessage"
#define EC_KNOTIFICATION_HistoryMessageCompletion    @"EC_KNOTIFICATION_HistoryMessageCompletion"

#define EC_KNOTIFICATION_DownloadMessageCompletion   @"EC_KNOTIFICATION_DownloadMessageCompletion"
#define EC_KNOTIFICATION_ReceiveMessageNoti          @"EC_KNOTIFICATION_ReceiveMessageNoti"
#define EC_KNOTIFICATION_ReceiveDeleteMessageNoti    @"EC_KNOTIFICATION_ReceiveDeleteMessageNoti"
#define EC_KNOTIFICATION_DeleteMessageNoti           @"EC_KNOTIFICATION_DeleteMessageNoti"
#define EC_KNOTIFICATION_ReadMessageNoti             @"EC_KNOTIFICATION_ReadMessageNoti"
#define EC_KNOTIFICATION_ReceiveRevokeMessageNoti    @"EC_KNOTIFICATION_ReceiveRevokeMessageNoti"
#define EC_KNOTIFICATION_ReceiveReadedMessageNoti    @"EC_KNOTIFICATION_ReceiveReadedMessageNoti"

#define EC_KNOTIFICATION_Chat_UserState              @"EC_KNOTIFICATION_Chat_UserState"
#define EC_KNOTIFICATION_RecordingAmplitudeChanged   @"EC_KNOTIFICATION_RecordingAmplitudeChanged"
#define EC_KNOTIFICATION_MessageProgressChanged      @"EC_KNOTIFICATION_MessageProgressChanged"

#define EC_KNOTIFICATION_Voip_OnIncomingReceiveInfo  @"EC_KNOTIFICATION_Voip_OnIncomingReceiveInfo"
#define EC_KNOTIFICATION_Voip_ReceiveCallEvents      @"EC_KNOTIFICATION_Voip_ReceiveCallEvents"
#define EC_KNOTIFICATION_Voip_ReceiveDTMFNoti        @"EC_KNOTIFICATION_Voip_ReceiveDTMFNoti"

#define EC_KNOTIFICATION_Meeting_OnIncomingReceiveInfo @"EC_KNOTIFICATION_Meeting_OnIncomingReceiveInfo"
#define EC_KNOTIFICATION_ReceiveInterphoneMeetingMsg @"EC_KNOTIFICATION_ReceiveInterphoneMeetingMsg"
#define EC_KNOTIFICATION_ReceiveMultiVoiceMeetingMsg @"EC_KNOTIFICATION_ReceiveMultiVoiceMeetingMsg"
#define EC_KNOTIFICATION_ReceiveMultiVideoMeetingMsg @"EC_KNOTIFICATION_ReceiveMultiVideoMeetingMsg"

#define EC_KNOTIFICATION_SendLiveChatRoomMessageCompletion @"EC_KNOTIFICATION_SendLiveChatRoomMessageCompletion"
#define EC_KNOTIFICATION_onLiveChatRoomMesssageChanged  @"EC_KNOTIFICATION_onLiveChatRoomMesssageChanged"
#define EC_KNOTIFICATION_onReceivedLiveChatRoomNotice  @"EC_KNOTIFICATION_onReceivedLiveChatRoomNotice"

#define EC_KNOTIFICATION_onReceiveFriendNotiMsg @"EC_KNOTIFICATION_onReceiveFriendNotiMsg"

#ifdef DEBUG
#define EC_SDKCONFIG_AppLog(fmt,...) {NSLog((fmt), ##__VA_ARGS__);}
#else
#define EC_SDKCONFIG_AppLog(fmt,...) {}
#endif


#define EC_KErrorKey   @"kerrorkey"
#define EC_KMessageKey @"kmessagekey"
#define EC_KMessageIdKey @"EC_KMessageIdKey"
#define EC_KSessionIdKey @"EC_KSessionIdKey"
#define EC_KProgressKey   @"EC_KProgressKey"
#define EC_KMessage_UnreadCountKey @"EC_KMessage_UnreadCountKey"


#define EC_KVoip_CallId @"EC_KVoip_CallId"
#define EC_KVoip_CallType @"EC_KVoip_CallType"
#define EC_KVoip_Caller @"EC_KVoip_Caller"
#define EC_KVoip_CallerPhone @"EC_KVoip_CallerPhone"
#define EC_KVoip_CallName @"EC_KVoip_CallName"
#define EC_KVoip_DTMF   @"EC_KVoip_DTMF"

#define EC_KMetting_CurNo @"EC_KMetting_CurNo"
#define EC_KMetting_CallId @"EC_KMetting_CallId"
#define EC_KMetting_CallId @"EC_KMetting_CallId"

#define EC_KMetting_CallType @"EC_KMetting_CallType"
#define EC_KMetting_CallData @"EC_KMetting_CallData"


#define EC_StoreAllMessage [ECDeviceDelegateConfigCenter sharedInstanced].isStoreAllMessage

#endif /* ECDeviceNotifyMacros_h */
