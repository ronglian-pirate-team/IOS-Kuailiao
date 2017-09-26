//
//  ECDevicePersonInfo.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/26.
//
//

#import <Foundation/Foundation.h>
#import "ECDeviceHeaders.h"

@interface ECDevicePersonInfo : NSObject

+ (instancetype)sharedInstanced;

/**
 @brief userName 云通讯平台账号名称
 */
@property (nonatomic, copy) NSString *userName;

/**
 @brief userName 云通讯平台密码
 */
@property (nonatomic, copy) NSString *userPassword;

/**
 @brief userName 云通讯平台账号昵称
 */
@property (nonatomic, copy) NSString* nickName;

/**
 @brief userName 云通讯平台用户性别
 */
@property (nonatomic, assign) ECSexType sex;

/**
 @brief userName 云通讯平台用户生日
 */
@property (nonatomic, copy) NSString *birth;

/**
 @brief userName 云通讯平台用户签名
 */
@property (nonatomic, copy) NSString *sign;

/**
 @brief avatar 云通讯平台用户头像
 */
@property (nonatomic, copy) NSString *avatar;


/**
 @brief 添加我为好友时是否需要验证
 */
@property (nonatomic, assign) BOOL isNeedConfirm;

/**
 @brief userName 云通讯平台用户个人信息版本号
 */
@property (nonatomic, assign) unsigned long long dataVersion;

-(NSString*)getOtherNameWithPhone:(NSString*)phone;

- (NSString *)displayName;
@end
