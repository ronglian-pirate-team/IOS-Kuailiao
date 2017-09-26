//
//  ECContactManager.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import <Foundation/Foundation.h>

@class ECFriend;

@interface ECContactManager : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) ECFriend *selfInfo;

@end
