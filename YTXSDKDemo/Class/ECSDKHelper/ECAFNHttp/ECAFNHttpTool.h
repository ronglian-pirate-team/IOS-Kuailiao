//
//  ECAFNHttpTool.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ECRequestUrl.h"
#import "ECRequestObject.h"

typedef void (^ECRequestCompletion)(NSString *errCode, id responseObject);

@interface ECAFNHttpTool : NSObject<NSURLSessionDelegate>

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) AFHTTPSessionManager* manager;

- (NSString *)requestUrl:(NSString *)url withTime:(NSString *)timeStamp;
- (void)PostUrl:(NSString *)url parameters:(id)info completion:(ECRequestCompletion)completion;


- (void)queryMessageReadStatus:(ECRequestReadMessageList *)request
                    completion:(void (^)(NSString *err,NSArray *array,NSInteger totalSize))completion;


- (void)joinQRCodeGroupId:(ECRequestQRJoinGroup *)request
               completion:(void (^)(NSInteger code,NSString *errStr))completion;

@end
