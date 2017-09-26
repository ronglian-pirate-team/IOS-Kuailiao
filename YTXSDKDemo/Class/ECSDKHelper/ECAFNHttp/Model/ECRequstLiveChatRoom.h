//
//  ECRequstLiveChatRoom.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECRequestObject.h"

@interface ECRequstLiveChatRoom : ECRequestObject

@end

@interface ECCreateLiveChatRoomRequest : ECRequestObject

/**
 @brief 创建者
 */
@property (nonatomic, copy) NSString *creator;

/**
 @brief 房间名称
 */
@property (nonatomic, copy) NSString *name;

/**
 @brief 聊天室公告
 */
@property (nonatomic, copy) NSString *declared;

/**
 @brief 自定义字段
 */
@property (nonatomic, copy) NSString *ext;

/**
 @brief 推流地址
 */
@property (nonatomic, copy) NSString *pushUrl;


/**
 @brief 拉流地址
 */
@property (nonatomic, copy) NSString *pullUrl;

@end

@interface ECChangeLiveChatRoomStateRequest : ECRequestObject
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *state;
@end

@interface ECQueryLiveChatRoomListsRequest : ECRequestObject
@property (nonatomic, copy) NSString *dateTime;
@property (nonatomic, copy) NSString *limit;
@property (nonatomic, copy) NSString *order;
@end
