//
//  ECFriendInfoDetailVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECBaseContoller.h"

@interface ECFriendInfoDetailVC : ECBaseContoller

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) ECFriend *friendInfo;
@property (nonatomic, assign) BOOL isFriendInfo;//YES 查看好友信息。NO 查看个人信息，非好友关系

@end
