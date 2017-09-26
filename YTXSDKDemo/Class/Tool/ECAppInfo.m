//
//  ECAppInfo.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/21.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECAppInfo.h"
#import "ECDemoChatManager.h"
#import "ECBaseManage.h"

#define EC_DEMO_UserDefault_VideoviewContentMode     @"EC_DEMO_UserDefault_VideoviewContentMode"

@implementation ECAppInfo

+(instancetype)sharedInstanced {
    
    static dispatch_once_t once;
    static ECAppInfo *appInfo;
    dispatch_once(&once, ^{
        appInfo = [[[self class] alloc] init];
    });
    return appInfo;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.persionInfo = [ECDevicePersonInfo sharedInstanced];
        if (self.userName.length > 0)
            [[ECDBManager sharedInstanced] openDB:self.userName];
        [ECBaseManage sharedInstanced];
        self.sessionMgr = [ECSessionManger sharedInstanced];
        self.contactMgr = [ECContactManager sharedInstanced];
        self.workSpaceMgr = [ECWorkSpaceManage sharedInstanced];
        [ECDemoChatManager sharedInstanced];
    }
    return self;
}

- (NSString *)userName {
    return [ECDevicePersonInfo sharedInstanced].userName;
}

- (NSString *)pwd {
    return [ECDevicePersonInfo sharedInstanced].userPassword;
}

#pragma mark - 设置视频view的模式
- (void)setViewcontentMode:(UIViewContentMode)viewcontentMode {
    [[NSUserDefaults standardUserDefaults] setObject:@(viewcontentMode) forKey:EC_DEMO_UserDefault_VideoviewContentMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIViewContentMode)viewcontentMode {
    NSNumber *nsMode = [[NSUserDefaults standardUserDefaults] valueForKey:EC_DEMO_UserDefault_VideoviewContentMode];
    if (nsMode==nil) {
        return UIViewContentModeScaleToFill;
    }
    return nsMode.integerValue;
}

- (NSString*)viewContentModeToStr:(UIViewContentMode)contentMode {
    switch (self.viewcontentMode) {
        case UIViewContentModeScaleToFill:
            return @"ScaleToFill";
            
        case UIViewContentModeScaleAspectFit:
            return @"ScaleAspectFit";
            
        case UIViewContentModeScaleAspectFill:
            return @"ScaleAspectFill";
            
        default:
            break;
    }
    return @"ScaleAspectFit";
}

- (UIViewContentMode)viewContentModeFromStr:(NSString*)str {
    if ([str hasSuffix:@"ScaleToFill"]) {
        return UIViewContentModeScaleToFill;
    } else if ([str hasSuffix:@"ScaleAspectFill"]) {
        return UIViewContentModeScaleAspectFill;
    } else {
        return UIViewContentModeScaleAspectFit;
    }
}

@end
