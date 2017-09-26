//
//  ECRequestFriend.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/29.
//

#import <Foundation/Foundation.h>


/**
 @brief 获取好友列表请求信息
 */
@interface ECRequestFriendList : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *isUpdate;
@property (nonatomic, copy) NSString *timestamp;

@end

/**
 @brief 获取好友添加请求列表，请求信息
 */
@interface ECRequestFriendAddList : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *timestamp;

@end

/**
 @brief 获取个人信息
 */
@interface ECRequestPersonInfo : NSObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *searchContent;

@end

/**
 @brief 好友添加请求所需信息
 */
@interface ECRequestFriendAdd : ECRequestObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *friendUseracc;

@end

/**
 @brief 设置好友备注，请求信息
 */
@interface ECRequestFriendRemark : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *remarkName;
@property (nonatomic, copy) NSString *friendUseracc;

@end


/**
 @brief 设置权限信息
 */
@interface ECRequestUserVerifySet : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *addVerify;

@end


/**
 @brief 同意用户好友请求
 */
@interface ECRequestFriendAddAgree : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *friendUseracc;

@end

/**
 @brief 拒绝用户好友请求
 */
@interface ECRequestFriendAddRefuse : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *friendUseracc;
@property (nonatomic, copy) NSString *message;

@end

/**
 @brief 删除用户好友
 */
@interface ECRequestFriendDelete : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *friendUseracc;
@property (nonatomic, copy) NSString *allDel;

@end

/**
 @brief 获取好友信息
 */
@interface ECRequestFriendInfo : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *friendUseracc;

@end

/**
 @brief 获取用户头像
 */
@interface ECRequestUserAcatar : ECRequestObject

@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *updateTime;

@end
