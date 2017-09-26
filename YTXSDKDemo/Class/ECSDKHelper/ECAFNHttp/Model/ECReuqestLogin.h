//
//  ECReuqestLogin.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/18.
//

#import "ECRequestObject.h"
typedef enum : NSInteger {
    EC_LOGIN_SmsVerifyCodeType_Register=0,
    EC_LOGIN_SmsVerifyCodeType_Forget=1
} EC_LOGIN_SmsVerifyCodeType;

@interface ECReuqestLogin : ECRequestObject
@property (nonatomic, copy) NSString *mobilenum;
@property (nonatomic, copy) NSString *userpasswd;
@property (nonatomic, copy) NSString *smsverifycode;
@property (nonatomic, assign) EC_LOGIN_SmsVerifyCodeType type;
@end

