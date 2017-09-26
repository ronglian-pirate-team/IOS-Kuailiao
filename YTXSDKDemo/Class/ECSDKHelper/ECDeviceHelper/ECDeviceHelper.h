//
//  ECDeviceHelper.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/31.
//
//

#import <Foundation/Foundation.h>
#import "ECDeviceNotifyMacros.h"

typedef NS_ENUM(NSInteger, ECUserInputState) {
    ECUserInputState_None,
    ECUserInputState_White,
    ECUserInputState_Record
};

@interface ECDeviceHelper : NSObject

+ (instancetype)sharedInstanced;
@property (nonatomic, copy) NSString *appToken;

- (void)ec_setAppKey:(NSString *)appKey AppToken:(NSString *)AppToken;

- (void)ec_loginECSdk:(void(^)(ECError *error))completion;

- (ECMessage *)ec_sendMessage:(ECMessage *)message;

- (ECMessage *)ec_resendMessage:(ECMessage *)message;

- (ECMessage *)ec_sendTransimitMessage:(ECMessage *)message to:(NSString *)to;

/**
 @brief 发送消息
 
 @param mediaBody 消息body
 @param to 接收人
 @return 发送的消息
 */
- (ECMessage *)ec_sendMessage:(ECMessageBody *)mediaBody to:(NSString*)to;

/**
 @brief 发送消息

 @param mediaBody 消息body
 @param to 接收人
 @param userData userData
 @return 发送的消息
 */
- (ECMessage *)ec_sendMessage:(ECMessageBody *)mediaBody to:(NSString*)to withUserData:(NSString*)userData;


/**
 @brief 发送消息
 
 @param mediaBody 消息body
 @param to 接收人
 @param userData userData
 @param atArray @群组成员
 @return 发送的消息
 */
- (ECMessage *)ec_sendMessage:(ECMessageBody *)mediaBody to:(NSString*)to withUserData:(NSString*)userData atArray:(NSArray *)atArray;
- (ECMessage *)ec_sendLiveChatRoomMessage:(ECMessage*)message;


/**
 @brief 发生用户状态消息

 @param state 用户当前状态
 @param to 接收者
 */
- (void)ec_sendUserState:(ECUserInputState)state to:(NSString *)to;

- (void)ec_downloadMediaMessage:(ECMessage *)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion;

- (void)ec_deleteMessage:(ECMessage *)message;

- (void)ec_readMessage:(ECMessage *)message;

+ (NSString *)ec_getDeviceWithType:(ECDeviceType)type;
+ (NSString *)ec_getNetWorkWithType:(ECNetworkType)type;


/**
 @brief 获取云通讯平台会话对应的昵称

 @param sessionId 会话的id
 @return 返回会话的昵称
 */
+ (NSString *)ec_getNickNameWithSessionId:(NSString*)sessionId;

@end
