//
//  ECFriend.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import "ECFriend.h"
#import "KCPinyinHelper.h"

@implementation ECFriend

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
    if([key isEqualToString:@"nickName"]){
        _firstLetter = [[KCPinyinHelper quickConvert:value] uppercaseString];
    }
}

- (NSString *)avatar{
    if(_avatar && _avatar.length > 0 && _avatar != nil)
        return _avatar;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if(self.remarkName && self.remarkName != nil && self.remarkName.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(60, 60) withName:self.remarkName];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", self.useracc, [NSString MD5:self.remarkName]];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    if(self.nickName && self.nickName != nil && self.nickName.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:self.nickName];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", self.useracc, [NSString MD5:self.nickName]];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    if(self.useracc && self.useracc != nil && self.useracc.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:self.useracc];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", self.useracc, self.useracc];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    return @"";
//    return @"";
}

- (NSString *)remarkName{
    if(_remarkName && _remarkName.length > 0)
        return _remarkName;
    return @"";
}

- (NSString *)nickName{
    if(_nickName && _nickName.length > 0)
        return _nickName;
    return @"";
}

- (NSString *)phoneNumber{
    if(_phoneNumber && _phoneNumber.length > 0)
        return _phoneNumber;
    return @"";
}

- (NSString *)region{
    if(_region && _region.length > 0)
        return _region;
    return @"";
}

- (NSString *)sign{
    if(_sign && _sign.length > 0)
        return _sign;
    return @"";
}

- (NSString *)firstLetter{
    if(_firstLetter && _sign.length > 0)
        return _firstLetter;
    if(_remarkName && _remarkName.length > 0)
        return [[KCPinyinHelper quickConvert:_remarkName] uppercaseString];
    if(_nickName && _nickName.length > 0)
        return [[KCPinyinHelper quickConvert:_nickName] uppercaseString];
    if(!_firstLetter || ![_firstLetter isKindOfClass:[NSString class]] || _firstLetter == nil)
        _firstLetter = @"#";
    return _firstLetter;
}

- (NSString *)useracc{
    if([_useracc hasPrefix:[ECSDK_Key stringByAppendingString:@"#"]]){
        return [_useracc substringFromIndex:ECSDK_Key.length + 1];
    }else if ([_useracc hasPrefix:ECSDK_Key]){
        return [_useracc substringFromIndex:ECSDK_Key.length];
    }else{
        return _useracc;
    }
}

- (NSString *)displayName{
    if(self.remarkName && self.remarkName.length > 0 && self.remarkName != nil)
        return self.remarkName;
    if(self.nickName && self.nickName.length > 0 && self.nickName != nil)
        return self.nickName;
    return self.useracc;
}

@end
