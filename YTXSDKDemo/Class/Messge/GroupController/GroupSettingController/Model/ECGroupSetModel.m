//
//  ECGroupSetModel.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/6.
//

#import "ECGroupSetModel.h"

@implementation ECGroupSetModel
+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECGroupSetModel *model = nil;
    dispatch_once(&onceToken, ^{
        model = [[[self class] alloc] init];
    });
    return model;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.members = [NSMutableArray array];
    }
    return self;
}

@end
