//
//  ECFriendDB.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import <Foundation/Foundation.h>
#import "ECFriend.h"

@interface ECFriendDB : NSObject

+ (instancetype)sharedInstanced;

- (void)createFriendTable;

/**
 @brief 选择所有好友

 @return 所有好友
 */
- (NSMutableArray *)queryAllFriend;


/**
 @brief 查询好友信息

 @param friendId 好友id
 @return 查询到得信息
 */
- (ECFriend *)queryFriend:(NSString *)friendId;

/**
 @brief 添加好友

 @param ecFriend 待插入的好友
 */
- (void)insertFriend:(ECFriend *)ecFriend;


/**
 @brief 插入好友

 @param friends 待插入的好友数组
 */
- (void)insertFriends:(NSArray *)friends;

/**
 @brief 删除好友

 @param friendId 但删除好友的useracc
 */
- (void)deleteFriend:(NSString *)friendId;


/**
 brief 修改好友备注

 @param remark 备注
 @param friendId 好友id
 */
- (void)updateRemark:(NSString *)remark inFriend:(NSString *)friendId;
@end
