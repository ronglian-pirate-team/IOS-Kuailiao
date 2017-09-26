//
//  ECWorkSpaceManage.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/5.
//
//

#import "ECWorkSpaceManage.h"
#import "ECDemoMetttingManage.h"

@implementation ECWorkSpaceManage

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECWorkSpaceManage *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [ECDemoMetttingManage sharedInstanced];
    }
    return self;
}

@end
