//
//  ECAddRequestDB.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import <Foundation/Foundation.h>
#import "ECAddRequestUser.h"

@interface ECAddRequestDB : NSObject

+ (instancetype)sharedInstanced;

- (void)createAddRequestTable;

/**
 @brief 选择所有好友添加请求
 
 @return 所有好友添加请求
 */
- (NSMutableArray *)queryAllRequest;

/**
 @brief 添加好友添加请求
 
 @param user 待插入的好友添加请求
 */
- (void)insertAddRequest:(ECAddRequestUser *)user;

/**
 @brief 添加好友添加请求
 
 @param addRequests 待插入的好友添加请求数组
 */
- (void)insertAddRequests:(NSArray *)addRequests;


/**
 @brief 好友添加请求状态修改，，同意

 @param status 最新好友请求状态
 */
- (void)updateRequestStatus:(NSString *)status onRequest:(NSString *)useracc;
@end
