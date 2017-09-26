//
//  ECBaseManage.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/19.
//

#import <Foundation/Foundation.h>

@interface ECBaseManage : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) id basePushData;

@end
