//
//  ECContactManager.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import "ECContactManager.h"

@implementation ECContactManager

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECContactManager *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selfInfo = [[ECFriend alloc] init];
    }
    return self;
}

@end
