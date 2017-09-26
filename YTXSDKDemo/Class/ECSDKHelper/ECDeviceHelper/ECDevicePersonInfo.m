//
//  ECDevicePersonInfo.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/26.
//
//

#import "ECDevicePersonInfo.h"

#define EC_UserDefault_UserName            @"EC_UserDefault_UserName"
#define EC_UserDefault_UserPwd             @"EC_UserDefault_UserPwd"
#define EC_UserDefault_LoginAuthType       @"EC_UserDefault_LoginAuthType"

#define EC_UserDefault_NickName            [NSString stringWithFormat:@"%@_nickName",self.userName]
#define EC_UserDefault_UserSex             [NSString stringWithFormat:@"%@_UserSex",self.userName]
#define EC_UserDefault_UserBirth           [NSString stringWithFormat:@"%@_UserBirth",self.userName]
#define EC_UserDefault_UserDataVer         [NSString stringWithFormat:@"%@_UserDataVer",self.userName]
#define EC_UserDefault_UserSign            [NSString stringWithFormat:@"%@_UserSign",self.userName]
#define EC_UserDefault_FriendNeedConfirm   [NSString stringWithFormat:@"%@_FriendNeedConfirm",self.userName]

@implementation ECDevicePersonInfo

+ (instancetype)sharedInstanced{
    static dispatch_once_t once;
    static ECDevicePersonInfo *deviceInfo;
    dispatch_once(&once, ^{
        deviceInfo = [[[self class] alloc] init];
    });
    return deviceInfo;
}

- (void)setUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:EC_UserDefault_UserName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_UserName];
}

- (void)setUserPassword:(NSString *)userPassword{
    [[NSUserDefaults standardUserDefaults] setObject:userPassword forKey:EC_UserDefault_UserPwd];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userPassword {
    return [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_UserPwd];
}

- (void)setNickName:(NSString *)nickName {
    [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:EC_UserDefault_NickName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)nickName {
    NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_NickName];
    if (nickName.length == 0 )
        nickName = self.userName;
    return nickName;
}

- (void)setSex:(ECSexType)sex {
    [[NSUserDefaults standardUserDefaults] setObject:@(sex) forKey:EC_UserDefault_UserSex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (ECSexType)sex {
    NSNumber* nssex = [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_UserSex];
    return nssex.integerValue;
}

- (void)setSign:(NSString *)sign {
    [[NSUserDefaults standardUserDefaults] setObject:sign forKey:EC_UserDefault_UserBirth];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sign {
    return [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_UserBirth];
}

-(void)setDataVersion:(unsigned long long)dataVersion {
    [[NSUserDefaults standardUserDefaults] setObject:@(dataVersion) forKey:EC_UserDefault_UserDataVer];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (unsigned long long)dataVersion {
    NSNumber* nsdataver = [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_UserDataVer];
    return nsdataver.unsignedLongLongValue;
}

- (void)setBirth:(NSString *)birth {
    [[NSUserDefaults standardUserDefaults] setObject:birth forKey:EC_UserDefault_UserSign];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)birth {
    return [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_UserSign];
}

- (void)setIsNeedConfirm:(BOOL)isNeedConfirm {
    [[NSUserDefaults standardUserDefaults] setObject:@(isNeedConfirm) forKey:EC_UserDefault_FriendNeedConfirm];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isNeedConfirm {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_FriendNeedConfirm] boolValue];
}

- (NSString *)getOtherNameWithPhone:(NSString *)phone {
    
    if (phone.length <= 0)
        return @"";
    
    if ([phone isEqualToString:@"10089"])
        return @"系统通知";
    return phone;
}

- (NSString *)displayName{
    if(self.nickName && self.nickName.length > 0 && self.nickName != nil)
        return self.nickName;
    return self.userName;
}

@end
