//
//  ECAFNHttpTool+Friend.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/17.
//

#import "ECAFNHttpTool.h"
#import "ECRequestFriend.h"

@interface ECAFNHttpTool (Friend)

/**
 @brief 获取好友列表
 
 @param getFriend 获取好友参数
 @param completion 成功/失败回调
 */
- (void)getFriends:(ECRequestFriendList *)getFriend completion:(ECRequestCompletion)completion;


/**
 @brief 获取请求添加好友列表
 
 @param addRequest request 请求参数
 @param completion 回调
 */
- (void)requestAddFriendList:(ECRequestFriendAddList *)addRequest completion:(ECRequestCompletion)completion;


/**
 @brief 获取个人信息
 
 @param person 要获取的人信息
 @param completion 回调
 */
- (void)getPersionalInfo:(ECRequestPersonInfo *)person completion:(ECRequestCompletion)completion;


/**
 @brief 发起添加好友请求
 
 @param addFriend 添加信息
 @param completion 回调
 */
- (void)requestAddFriend:(ECRequestFriendAdd *)addFriend  completion:(ECRequestCompletion)completion;//内部错误


/**
 @brief 设置好友备注
 
 @param remarkInfo 设置备注信息
 @param completion 回调
 */
- (void)remarkFriend:(ECRequestFriendRemark *)remarkInfo completion:(ECRequestCompletion)completion;


/**
 @brief 用户权限设置，添加好友时是否验证
 
 @param setInfo 权限信息
 @param completion 回调
 */
- (void)userVerifySet:(ECRequestUserVerifySet *)setInfo completion:(ECRequestCompletion)completion;


/**
 @brief 同意用户好友添加请求
 
 @param agree 同意添加信息
 @param completion 回调
 */
- (void)agreeFriendAddRequest:(ECRequestFriendAddAgree *)agree completion:(ECRequestCompletion)completion;

/**
 @brief 拒绝用户好友添加请求
 
 @param refuse 拒绝信息
 @param completion 回调
 */
- (void)refuseFriendAddRequest:(ECRequestFriendAddRefuse *)refuse completion:(ECRequestCompletion)completion;


/**
 @brief 删除好友
 
 @param deleteInfo 删除信息
 @param completion 回调
 */
- (void)deleteFriend:(ECRequestFriendDelete *)deleteInfo completion:(ECRequestCompletion)completion;


/**
 @brief 获取好友信息
 
 @param friendInfo 需要获取信息的好友
 @param completion 回调
 */
- (void)getFriendInfo:(ECRequestFriendInfo *)friendInfo completion:(ECRequestCompletion)completion;

/**
 @brief 获取头像
 
 @param user 需要获取头像信息的用户
 @param completion 回调
 */
- (void)getUserAvatar:(ECRequestUserAcatar *)user completion:(ECRequestCompletion)completion;

/**
 @brief 上传用户头像
 
 @param imageData 用户头像数据
 @param completion 完成回调
 */
- (void)uploadUserAcatar:(NSData *)imageData completion:(ECRequestCompletion)completion;


/**
 @brief 获取用户隐私状态

 @param completion 完成回调
 */
- (void)fetchUserVerifyCompletion:(ECRequestCompletion)completion;

@end
