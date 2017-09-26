//
//  ECAppInfo.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/21.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSessionManger.h"
#import "ECContactManager.h"
#import "ECWorkSpaceManage.h"


@interface ECAppInfo : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *pwd;

@property (nonatomic, strong) ECDevicePersonInfo *persionInfo;

@property (nonatomic, strong) ECSessionManger *sessionMgr;
@property (nonatomic, strong) ECContactManager *contactMgr;
@property (nonatomic, strong) ECWorkSpaceManage *workSpaceMgr;


@property (nonatomic, assign) UIViewContentMode viewcontentMode;
- (NSString*)viewContentModeToStr:(UIViewContentMode)contentMode;
- (UIViewContentMode)viewContentModeFromStr:(NSString*)str;

@end
