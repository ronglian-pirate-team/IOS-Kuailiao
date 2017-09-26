//
//  ECAFNHttpTool+LiveChatRoom.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/23.
//

#import "ECAFNHttpTool+LiveChatRoom.h"

#define EC_CreateChatRoom @"IM/createChatRoom"// 创建聊天室
#define EC_ToggleState @"IM/ToggleState"//更改聊天室的状态
#define EC_GetChatRoomList @"IM/getChatRoomList"//获取聊天室的列表


@implementation ECAFNHttpTool (LiveChatRoom)

- (void)createLiveChatRoom:(ECCreateLiveChatRoomRequest *)request completion:(void (^)(NSInteger code, NSString * responseObject))completion {
    NSString *requestUrl = [self requestUrl:EC_CreateChatRoom withTime:[NSString sigTime:[NSDate date]]];
    [self PostUrl:requestUrl parameters:request completion:^(NSString *errCode, id responseObject) {
        NSString *roomId = @"";
        if ([responseObject isKindOfClass:[NSDictionary class]])
            roomId = [responseObject objectForKey:@"roomId"];
        completion(errCode.integerValue, roomId);
    }];
}

- (void)changeLiveChatRoomState:(ECChangeLiveChatRoomStateRequest *)request completion:(void (^)(NSInteger code, NSString *))completion {
    NSString *requestUrl = [self requestUrl:EC_ToggleState withTime:[NSString sigTime:[NSDate date]]];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setValue:request.roomId forKey:@"roomId"];
    [bodyDict setValue:request.userId forKey:@"operator"];
    [bodyDict setValue:request.state forKey:@"state"];
    [self PostUrl:requestUrl parameters:bodyDict completion:^(NSString *errCode, id responseObject) {
        completion(errCode.integerValue, responseObject);
    }];
}

- (void)queryLiveChatRoomLists:(ECQueryLiveChatRoomListsRequest *)request completion:(void (^)(NSInteger code, NSArray *))completion {
    NSString *requestUrl = [self requestUrl:EC_GetChatRoomList withTime:[NSString sigTime:[NSDate date]]];
    request.order = request.order.length==0?@"1":request.order;
    __block NSArray *array = [NSArray array];
    [self PostUrl:requestUrl parameters:request completion:^(NSString *errCode, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([[responseObject objectForKey:@"chatRoomList"] isKindOfClass:[NSArray class]]) {
                array = [responseObject objectForKey:@"chatRoomList"] ;
            }
        }
        completion(errCode.integerValue, array);
    }];
}
@end
