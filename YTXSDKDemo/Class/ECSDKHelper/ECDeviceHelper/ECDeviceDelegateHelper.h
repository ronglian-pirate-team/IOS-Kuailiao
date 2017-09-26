//
//  ECDeviceDelegate.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/21.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDeviceNotifyMacros.h"

//设置连接状态
typedef enum {
    EC_CONNECTED_LinkState_Linking,
    EC_CONNECTED_LinkState_Failed,
    EC_CONNECTED_LinkState_Success,
} EC_CONNECTED_LinkState;

@interface ECDeviceDelegateHelper : NSObject<ECDeviceDelegate, UIAlertViewDelegate>

+ (instancetype)sharedInstanced;

@property (nonatomic, assign) BOOL isCallBusy;

@property (nonatomic, strong) NSMutableArray *interphoneArray;

@end
