//
//  NSDictionary+ECExtension.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/24.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "NSDictionary+ECExtension.h"

@implementation NSDictionary (ECExtension)

@end

@implementation NSMutableDictionary (ECExtension)

- (void)saveValue:(NSString *)value forKey:(NSString *)key{
    NSString *v = @"";
    if(value && [value isKindOfClass:[NSString class]])
        v = value;
    [self setValue:v forKey:key];
}

- (id)fetchValueForKey:(NSString *)key{
    id value = self[key];
    if(!value) value = @"";
    return value;
}

@end
