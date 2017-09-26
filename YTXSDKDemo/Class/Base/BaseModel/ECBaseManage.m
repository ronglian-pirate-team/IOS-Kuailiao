//
//  ECBaseManage.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/19.
//

#import "ECBaseManage.h"

@implementation ECBaseManage

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECBaseManage *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_ClickNav_Item object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (note.object)
                self.basePushData = note.object;
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_Nav_PushData object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (note.object)
                self.basePushData = note.object;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_PopViewController object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [[AppDelegate sharedInstanced].rootNav popViewControllerAnimated:YES];
        }];

    }
    return self;
}
@end
