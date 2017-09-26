//
//  ECAFNHttpTool.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECAFNHttpTool.h"
#import <objc/runtime.h>

#define EC_MessageReceipt @"IM/MessageReceipt"
#define EC_QRJoinGroup @"IM/JoinGroup"

@interface ECAFNHttpTool()

@property (nonatomic, copy) NSString *auth;

@end

@implementation ECAFNHttpTool

+(instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECAFNHttpTool *httptool;
    dispatch_once(&onceToken, ^{
        httptool = [[self alloc] init];
    });
    return httptool;
}

- (instancetype)init{
    if(self = [super init]){
        self.manager = [AFHTTPSessionManager manager];
    }
    return self;
}

#pragma mark - 查询已读未读列表
- (void)queryMessageReadStatus:(ECRequestReadMessageList *)request
                    completion:(void (^)(NSString *err,NSArray *array,NSInteger totalSize))completion {
    
    request.userName = [ECDevicePersonInfo sharedInstanced].userName;
    NSString *requestUrl = [self requestUrl:EC_MessageReceipt withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:[self createRequestParameter:request] completion:^(NSString *errCode, id responseObject) {
        NSMutableArray *readStatusArray = [NSMutableArray array];
        NSInteger totalSize = 0;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *result = [responseObject objectForKey:@"result"];
            totalSize = [[responseObject objectForKey:@"totalSize"] integerValue];
            for (NSDictionary *dict in result) {
                ECReadMessageMember *member = [[ECReadMessageMember alloc] init];
                member.userName = dict[@"useracc"];
                member.timetmp = dict[@"time"];
                [readStatusArray addObject:member];
            }
        }
        completion(errCode,readStatusArray,totalSize);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion([NSString stringWithFormat:@"%ld",(long)error.code],nil,0);
    }];
}


#pragma mark - 扫描二维码加群
- (void)joinQRCodeGroupId:(ECRequestQRJoinGroup *)request completion:(void (^)(NSInteger code, NSString *errStr))completion {
    request.joinUserAcc = [ECDevicePersonInfo sharedInstanced].userName;
    NSString *requestUrl = [self requestUrl:EC_QRJoinGroup withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:request completion:^(NSString *errCode, id responseObject) {
        completion(errCode.integerValue,responseObject);
    }];
}

#pragma mark - 公共方法

- (void)PostUrl:(NSString *)url parameters:(id)info completion:(ECRequestCompletion)completion failure:(void (^)(NSURLSessionDataTask *task, NSError *))failure{
    id parameter = info;
    if (![info isKindOfClass:[NSDictionary class]])
        parameter = [self createRequestParameter:info];
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];

    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    [mgr.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [mgr.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mgr.requestSerializer setValue:[NSString sigTime:[NSDate dateWithTimeIntervalSinceNow:0]] forHTTPHeaderField:@"reqtime"];
    [mgr.requestSerializer setValue:[self getUserAgent] forHTTPHeaderField:@"useragent"];

    [mgr.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        return parameters;
    }];
    
    NSString *timerStr = [NSString sigTime:[NSDate date]];
    NSString *authorBase64 = [NSString stringWithFormat:@"%@:%@", ECSDK_Key,timerStr];
    authorBase64 = [[authorBase64 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [mgr.requestSerializer setValue:authorBase64 forHTTPHeaderField:@"Authorization"];
    if ([url hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 是否允许,NO-- 不允许无效的证书
        [securityPolicy setAllowInvalidCertificates:YES];
        securityPolicy.validatesDomainName = NO;
        mgr.securityPolicy = securityPolicy;
    }

    [mgr POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString* statusCode = [responseObject objectForKey:@"statusCode"];
        if(statusCode.integerValue == 0){
            completion(statusCode, responseObject);
        }else{
            completion(statusCode, responseObject[@"statusMsg"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion([NSString stringWithFormat:@"%ld",(long)error.code], error.description);
    }];
}

- (void)PostUrl:(NSString *)url parameters:(id)info completion:(ECRequestCompletion)completion {
    [self PostUrl:url parameters:info completion:^(NSString *errCode, id responseObject) {
        completion(errCode,responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion([NSString stringWithFormat:@"%ld",(long)error.code], error.description);
    }];
}


/**
 @brief 生成请求url

 @param url 请求方法
 @param timeStamp 时间戳
 @return 完整的请求url
 */
- (NSString *)requestUrl:(NSString *)url withTime:(NSString *)timeStamp {
    NSString *requestUrl = [NSString stringWithFormat:@"%@/%@/%@", EC_UrlHeader, ECSDK_Key, url];
    return [requestUrl stringByAppendingFormat:@"?sig=%@", [self createSig:timeStamp]];
}

/**
 @brief 生成请求sig

 @param timeStamp 生成sig时所需的时间戳
 @return sig值
 */
- (NSString *)createSig:(NSString *)timeStamp{
    NSString *originalStr = [NSString stringWithFormat:@"%@%@%@", ECSDK_Key, [ECDeviceHelper sharedInstanced].appToken, timeStamp];
    return [NSString MD5:originalStr];
}

/**
 @brief 根据请求对象穿件请求参数

 @param obj 请求对象
 @return 请求所需参数
 */
- (NSDictionary *)createRequestParameter:(id)obj {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([obj class], &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++ ) {
        objc_property_t thisProperty = propertyList[i];
        const char* propertyName = property_getName(thisProperty);
        NSString *property = [[NSString alloc] initWithUTF8String:propertyName];
        id propertyValue = [obj valueForKey:property];
        [parameter setValue:propertyValue forKey:property];
    }
    return parameter;
}

- (NSString*)getUserAgent {
    UIScreen *screen = [UIScreen mainScreen];
    return [NSString stringWithFormat:@"%@;%@;%@;%d*%d;%@",
            [UIDevice currentDevice].name,
            [UIDevice currentDevice].model,
            [UIDevice currentDevice].systemVersion,
            (int)(screen.bounds.size.width*screen.scale),
            (int)(screen.bounds.size.height*screen.scale),
            [[NSBundle mainBundle].infoDictionary objectForKey:(__bridge NSString*)kCFBundleVersionKey]
            ];
}

@end
