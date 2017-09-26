//
//  ECAddressBook.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECAddressBook.h"
#import "KCPinyinHelper.h"

@implementation ECAddressBook

@synthesize name = _name;

- (NSString *)name{
    if(!_name || ![_name isKindOfClass:[NSString class]])
        _name = _phone;
    return _name;
}

- (void)setName:(NSString *)name{
    _name = name;
    _firstLetter = [[KCPinyinHelper quickConvert:name] uppercaseString];
}

- (NSString *)phone{
    if(!_phone || ![_phone isKindOfClass:[NSString class]])
        _phone = @"";
    return _phone;
}

- (NSString *)firstLetter{
    if(!_firstLetter || ![_firstLetter isKindOfClass:[NSString class]])
        _firstLetter = @"#";
    return _firstLetter;
}

- (NSString *)avatar{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if(self.name && self.name != nil && self.name.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:self.name];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", [NSString MD5:self.name], self.phone];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    if(self.phone && self.phone != nil && self.phone.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:self.phone];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/image.data", self.phone];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    return @"";
}

@end
