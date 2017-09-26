//
//  ECAFNHttpTool+Friend.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/17.
//

#import "ECAFNHttpTool+Friend.h"

#define EC_FriendList @"IM/getFriends"//获取好友列表
#define EC_FriendAddList @"IM/friendMessage"//获取添加好友请求列表
#define EC_PersonInfoGet @"IM/getPersonInfo"//获取个人信息
#define EC_FriendAdd @"IM/addFriend"//发起添加好友请求
#define EC_FriendRemark @"IM/setFriendRemark"//设置好友备注
#define EC_UserVerifySet @"IM/setUserVerify" //隐身设置，添加好友时是否需要验证
#define EC_FriendAddAgree @"IM/friendAgree"// 同意用户添加好友请求
#define EC_FriendAddRefuse @"IM/friendRefuse"// 拒绝用户添加好友请求
#define EC_FriendDelete @"IM/delFriend"// 删除好友
#define EC_FriendInfoGet @"IM/getFriendInfo"//获取好友个人信息
#define EC_UploadAvatar @"IM/uploadAvatar"//上传用户头像
#define EC_UserAvatarGet @"IM/getUserAvatar"//获取用户头像
#define EC_UserVerifyGet @"IM/getUserVerify"//获取用户头像

@implementation ECAFNHttpTool (Friend)
- (void)getFriends:(ECRequestFriendList *)getFriend completion:(ECRequestCompletion)completion{
    NSDate *date = [NSDate date];
    getFriend.timestamp = @"";//[NSString requestTime:date];
    NSString *requestUrl = [self requestUrl:EC_FriendList withTime:[NSString sigTime:date]];
    [self PostUrl:requestUrl parameters:getFriend completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        if(errCode.integerValue == 0){
            EC_Demo_AppLog(@"%@", responseObject);
        }
    }];
}

- (void)requestAddFriendList:(ECRequestFriendAddList *)addRequest completion:(ECRequestCompletion)completion{
    NSDate *date = [NSDate date];
    addRequest.timestamp = @"";//[NSString requestTime:date];
    NSString *requestUrl = [self requestUrl:EC_FriendAddList withTime:[NSString sigTime:date]];
    [self PostUrl:requestUrl parameters:addRequest completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
    }];
}

- (void)getPersionalInfo:(ECRequestPersonInfo *)person completion:(ECRequestCompletion)completion{
    NSDate *date = [NSDate date];
    NSString *requestUrl = [self requestUrl:EC_PersonInfoGet withTime:[NSString sigTime:date]];
    [self PostUrl:requestUrl parameters:person completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        
    }];
}

- (void)requestAddFriend:(ECRequestFriendAdd *)addFriend  completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_FriendAdd withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:addFriend completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        
    }];
}

- (void)remarkFriend:(ECRequestFriendRemark *)remarkInfo completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_FriendRemark withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:remarkInfo completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        
    }];
}

- (void)userVerifySet:(ECRequestUserVerifySet *)setInfo completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_UserVerifySet withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:setInfo completion:^(NSString *errCode, id responseObject) {
        if(completion)
            completion(errCode, responseObject);
    }];
}

- (void)agreeFriendAddRequest:(ECRequestFriendAddAgree *)agree completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_FriendAddAgree withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:agree completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        
    }];
}

- (void)refuseFriendAddRequest:(ECRequestFriendAddRefuse *)refuse completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_FriendAddRefuse withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:refuse completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        
    }];
}

- (void)deleteFriend:(ECRequestFriendDelete *)deleteInfo completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_FriendDelete withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:deleteInfo completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        
    }];
}

- (void)getFriendInfo:(ECRequestFriendInfo *)friendInfo completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_FriendInfoGet withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:friendInfo completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
        
    }];
}

- (void)getUserAvatar:(ECRequestUserAcatar *)user completion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_UserAvatarGet withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:user completion:^(NSString *errCode, id responseObject) {
        completion(errCode, responseObject);
    }];
}

- (void)fetchUserVerifyCompletion:(ECRequestCompletion)completion{
    NSString *requestUrl = [self requestUrl:EC_UserVerifyGet withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:@{@"useracc":[ECSDK_Key stringByAppendingFormat:@"#%@",[ECDevicePersonInfo sharedInstanced].userName]} completion:^(NSString *errCode, id responseObject) {
        if(completion)
            completion(errCode, responseObject);
    }];
}

- (void)uploadUserAcatar:(NSData *)imageData completion:(ECRequestCompletion)completion{
    NSString *timerStr = [NSString sigTime:[NSDate date]];
    NSString *authorBase64 = [NSString stringWithFormat:@"%@:%@", ECSDK_Key,timerStr];
    authorBase64 = [[authorBase64 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *requestUrl = [self requestUrl:EC_UploadAvatar withTime:[NSString sigTime:[NSDate date]]];
    requestUrl = [requestUrl stringByAppendingFormat:@"&useracc=%@&fileName=1.jpg", [ECSDK_Key stringByAppendingFormat:@"#%@", [ECDevicePersonInfo sharedInstanced].userName]];
    requestUrl = [requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    // 设置请求的为POST
    request.HTTPMethod = @"POST";
    request.HTTPBody = imageData;
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)imageData.length] forHTTPHeaderField:@"Content-Length"];
    // 设置请求 Content-Type
    [request setValue:[NSString stringWithFormat:@"application/octet-stream"] forHTTPHeaderField:@"Content-Type"];
    [request setValue:authorBase64 forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.URLCredentialStorage = nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:imageData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *responseObj = nil;
        if (!error) {
            responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            completion(responseObj[@"statusCode"], responseObj);
            EC_SDKCONFIG_AppLog(@"%@", responseObj);
        } else {
            EC_SDKCONFIG_AppLog(@"error --- %@", error.localizedDescription);
            completion([NSString stringWithFormat:@"%d",(int)error.code],responseObj);
        }
    }];
    [uploadTask resume];
    return;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    disposition = NSURLSessionAuthChallengeUseCredential;
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

@end
