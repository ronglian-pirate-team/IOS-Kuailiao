//
//  NSDictionary+ECExtension.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/24.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ECExtension)

@end

@interface NSMutableDictionary (ECExtension)

- (void)saveValue:(NSString *)value forKey:(NSString *)key;
- (id)fetchValueForKey:(NSString *)key;

@end
