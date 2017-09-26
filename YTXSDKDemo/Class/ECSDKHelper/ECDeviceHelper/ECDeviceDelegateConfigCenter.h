//
//  ECDeviceDelegateConfigCenter.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/26.
//
//

#import <Foundation/Foundation.h>

@interface ECDeviceDelegateConfigCenter : NSObject

+ (instancetype)sharedInstanced;

- (void)ec_setAppKey:(NSString *)appKey AppToken:(NSString *)AppToken;

/**
 @brief isOpenECSDKPush 是否开启云通讯平台的推送. 默认YES
 开启后会将devicetoken传给ECSDK然后传递给云通讯的服务器以便用于苹果推送给此设备
 */
@property (nonatomic, assign) BOOL isOpenECSDKPush;

/**
 @brief isOpenECSDKPushKit 是否开启云通讯平台的pushikit推送. 默认YES
 开启后会将voipdevicetoken传给ECSDK然后传递给云通讯的服务器以便用于苹果推送给此设备
 */
@property (nonatomic, assign) BOOL isOpenECSDKPushKit;

/**
 @brief isOpenECSDKBageNumber 是否开启云通讯平台的BageNumber. 默认YES
 开启后默认会从你设置的bage算起
 */
@property (nonatomic, assign) BOOL isOpenECSDKBageNumber;

/**
 @brief receiveFileName 接收消息铃声文件名
 */
@property (nonatomic, copy) NSString *receiveFileName;

/**
 @brief isContainIM 是否包含IM功能.默认YES.
 YES时将云通讯SDK的IM模块对应的代理方法默认实现,并发送通知(方便用户自定义操作);
 NO时则不作任何操作,只发送对应的通知(方便用户自定义操作)
 */
@property (nonatomic, assign) BOOL isContainIM;

/**
 @brief isContainVoip 是否包含Voip功能.默认YES.
 YES时将云通讯SDK的IM模块对应的代理方法默认实现,并发送通知(方便用户自定义操作);
 NO时则不作任何操作,只发送对应的通知(方便用户自定义操作)
 */
@property (nonatomic, assign) BOOL isContainVoip;

/**
 @brief isContainMeeting 是否包含会议功能.默认YES.
 YES时将云通讯SDK的IM模块对应的代理方法默认实现,并发送通知(方便用户自定义操作);
 NO时则不作任何操作,只发送对应的通知(方便用户自定义操作)
 */
@property (nonatomic, assign) BOOL isContainMeeting;

/**
 @brief offLineMessageCount 传入接收的离线消息数.默认-1.
 -1:接收全部离线消息
 0:不获取
 >0:可接收离线消息数量
 */
@property (nonatomic, assign) NSInteger offLineMessageCount;

/**
 @brief isMessageSound 是否播放接收消息声音.默认YES
 */
@property (nonatomic, assign) BOOL isMessageSound;

/**
 @brief isMessageShake 是否接收消息时震动.默认NO
 */
@property (nonatomic, assign) BOOL isMessageShake;

/**
 @brief isPlayEar 是否播放语音消息.默认NO
 */
@property (nonatomic, assign) BOOL isPlayEar;

/**
 @brief isStoreAllMessage 是否帮助用户存储所有消息.默认是YES
 */
@property (nonatomic, assign) BOOL isStoreAllMessage;

/**
 @brief isConversation 是否在会话里.默认NO
 功能:当在会话聊天页面,接收消息时,是否播放消息铃声.
 */
@property (nonatomic, assign) BOOL isConversation;

/**
 @brief isContainRedPacket 是否包含红包功能,默认YES
 */
@property (nonatomic, assign) BOOL isContainRedPacket;

/**
 @brief offCallId 离线呼叫的callid.
 功能:离线呼叫的推送内容解析出来callid,然后赋值给这个变量以供云通讯SDK使用.
 */
@property (nonatomic, copy) NSString *offCallId;

@property (nonatomic, assign) LoginAuthType loginAuthType;

@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, assign) CGFloat chat_RevokeMessageTime;

- (BOOL)isSDKSupportVoIP;

@end
