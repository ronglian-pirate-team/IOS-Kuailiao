//
//  ECAFNHttpTool+LiveChatRoom.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/23.
//

#import "ECAFNHttpTool.h"
#import "ECRequstLiveChatRoom.h"

@interface ECAFNHttpTool (LiveChatRoom)

- (void)createLiveChatRoom:(ECCreateLiveChatRoomRequest *)request completion:(void (^)(NSInteger code,NSString *roomId))completion;

- (void)changeLiveChatRoomState:(ECChangeLiveChatRoomStateRequest *)request completion:(void (^)(NSInteger code,NSString *errStr))completion;

- (void)queryLiveChatRoomLists:(ECQueryLiveChatRoomListsRequest *)request completion:(void (^)(NSInteger code,NSArray *lists))completion;

@end
