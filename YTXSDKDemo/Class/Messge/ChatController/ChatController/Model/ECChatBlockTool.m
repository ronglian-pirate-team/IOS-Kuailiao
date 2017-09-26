//
//  ECChatBlockTool.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECChatBlockTool.h"

@implementation ECChatBlockTool
+ (instancetype)sharedInstanced {
    static ECChatBlockTool *cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

@end
